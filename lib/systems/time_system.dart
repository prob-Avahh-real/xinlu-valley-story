import 'package:flutter/foundation.dart';

import '../data/game_data.dart';

/// 游戏时间系统
///
/// 管理昼夜循环、季节轮替、天气变化。
/// 每天 6:00–26:00（次日凌晨 2:00）为可活动时间。
/// 每 7 现实秒 = 10 游戏分钟（可调节）。
class TimeSystem extends ChangeNotifier {
  static const int dayStart = 600;   // 6:00
  static const int dayEnd = 2600;    // 26:00 (次日 2:00)
  static const int minutesPerDay = 20 * 60; // 20小时 * 60分
  static const int daysPerSeason = 28;

  int _year = 1;
  Season _season = Season.spring;
  int _day = 1;
  int _time = 600;       // 以 HHMM 格式存储：600 = 6:00
  Weather _weather = Weather.sunny;
  double _elapsed = 0;   // 累计秒数

  // Getters
  int get year => _year;
  Season get season => _season;
  int get day => _day;
  int get time => _time;
  Weather get weather => _weather;

  String get seasonName {
    switch (_season) {
      case Season.spring: return '春';
      case Season.summer: return '夏';
      case Season.autumn: return '秋';
      case Season.winter: return '冬';
    }
  }

  String get timeString {
    final h = _time ~/ 100;
    final m = _time % 100;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  String get dateString => '第${_year}年 ${seasonName}季 第${_day}天';

  /// 是否在可活动时间内
  bool get isAwake => _time >= dayStart && _time < dayEnd;

  /// 推进时间（每秒调用一次，传入 delta 秒数）
  void update(double dt) {
    _elapsed += dt;

    // 7 秒 = 10 分钟游戏时间
    const realSecondsPer10GameMinutes = 7.0;
    while (_elapsed >= realSecondsPer10GameMinutes) {
      _elapsed -= realSecondsPer10GameMinutes;
      _advanceTime(10);
    }
  }

  void _advanceTime(int minutes) {
    int h = _time ~/ 100;
    int m = _time % 100;

    m += minutes;
    while (m >= 60) {
      m -= 60;
      h++;
    }

    _time = h * 100 + m;

    // 跨越 26:00 → 进入下一天
    if (_time >= dayEnd) {
      _time = dayStart + (_time - dayEnd);
      _advanceDay();
    }

    notifyListeners();
  }

  void _advanceDay() {
    _day++;

    if (_day > daysPerSeason) {
      _day = 1;
      _advanceSeason();
    }
  }

  void _advanceSeason() {
    switch (_season) {
      case Season.spring: _season = Season.summer;
      case Season.summer: _season = Season.autumn;
      case Season.autumn: _season = Season.winter;
      case Season.winter:
        _season = Season.spring;
        _year++;
    }
  }

  /// 随机天气
  void rollWeather() {
    final r = DateTime.now().millisecondsSinceEpoch % 100;
    if (_season == Season.winter) {
      _weather = r < 30 ? Weather.snowy : Weather.sunny;
    } else if (_season == Season.summer) {
      _weather = r < 15 ? Weather.stormy : (r < 35 ? Weather.rainy : Weather.sunny);
    } else {
      _weather = r < 25 ? Weather.rainy : Weather.sunny;
    }
    notifyListeners();
  }

  /// 浇水已被雨水/暴风雨覆盖
  bool get isWateringDay => _weather == Weather.rainy || _weather == Weather.stormy;

  Map<String, dynamic> toJson() => {
    'year': _year,
    'season': _season.index,
    'day': _day,
    'time': _time,
    'weather': _weather.index,
  };

  void fromJson(Map<String, dynamic> json) {
    _year = json['year'] ?? 1;
    _season = Season.values[json['season'] ?? 0];
    _day = json['day'] ?? 1;
    _time = json['time'] ?? 600;
    _weather = Weather.values[json['weather'] ?? 0];
    notifyListeners();
  }
}
