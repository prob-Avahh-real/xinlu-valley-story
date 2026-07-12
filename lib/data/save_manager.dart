import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 存档管理器
///
/// 支持三个存档槽位，使用 SharedPreferences + JSON 持久化。
class SaveManager {
  SaveManager._();
  static final SaveManager instance = SaveManager._();

  static const _slotCount = 3;
  static const _keyPrefix = 'xinlu_save_';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// 获取所有存档槽的摘要
  List<SaveSlotInfo> listSlots() {
    final slots = <SaveSlotInfo>[];
    for (int i = 0; i < _slotCount; i++) {
      final data = _prefs.getString('$_keyPrefix${i}_data');
      if (data != null) {
        try {
          final json = jsonDecode(data) as Map<String, dynamic>;
          slots.add(SaveSlotInfo(
            slot: i,
            playerName: json['playerName'] ?? '农夫',
            year: json['year'] ?? 1,
            season: json['season'] ?? 0,
            day: json['day'] ?? 1,
            gold: json['gold'] ?? 0,
            playTime: json['playTime'] ?? '00:00',
            savedAt: json['savedAt'] ?? '',
          ));
        } catch (_) {
          // 损坏的存档：显示为损坏槽
          slots.add(SaveSlotInfo.corrupt(i));
        }
      }
    }
    return slots;
  }

  /// 保存游戏
  Future<bool> save(int slot, Map<String, dynamic> data) async {
    try {
      data['savedAt'] = DateTime.now().toIso8601String();
      await _prefs.setString('$_keyPrefix${slot}_data', jsonEncode(data));
      return true;
    } catch (e) {
      debugPrint('Save failed: $e');
      return false;
    }
  }

  /// 加载存档
  Future<Map<String, dynamic>?> load(int slot) async {
    final data = _prefs.getString('$_keyPrefix${slot}_data');
    if (data == null) return null;
    try {
      return jsonDecode(data) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// 删除存档
  Future<void> delete(int slot) async {
    await _prefs.remove('$_keyPrefix${slot}_data');
  }

  /// 自动保存到槽位 0
  Future<bool> autoSave(Map<String, dynamic> data) => save(0, data);
}

class SaveSlotInfo {
  final int slot;
  final String playerName;
  final int year;
  final int season;
  final int day;
  final int gold;
  final String playTime;
  final String savedAt;
  final bool isCorrupt;

  const SaveSlotInfo({
    required this.slot,
    required this.playerName,
    required this.year,
    required this.season,
    required this.day,
    required this.gold,
    required this.playTime,
    required this.savedAt,
    this.isCorrupt = false,
  });

  factory SaveSlotInfo.corrupt(int slot) => SaveSlotInfo(
    slot: slot,
    playerName: '损坏',
    year: 0,
    season: 0,
    day: 0,
    gold: 0,
    playTime: '--:--',
    savedAt: '',
    isCorrupt: true,
  );

  String get seasonName {
    switch (season) {
      case 0: return '春';
      case 1: return '夏';
      case 2: return '秋';
      case 3: return '冬';
      default: return '?';
    }
  }

  String get summary => '第${year}年 ${seasonName}季 第${day}天 — ${gold}G';
}
