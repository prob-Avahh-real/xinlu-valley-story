import 'package:flutter/foundation.dart';

import '../data/game_data.dart';

/// 农场土地状态
class FarmTile {
  bool isTilled;       // 是否已翻土
  bool isWatered;      // 是否已浇水
  String? cropId;      // 当前作物 ID
  int growthDay;       // 已生长天数
  bool isHarvestable;  // 是否可收获

  FarmTile({
    this.isTilled = false,
    this.isWatered = false,
    this.cropId,
    this.growthDay = 0,
    this.isHarvestable = false,
  });

  CropDef? get crop => cropId != null ? GameData.instance.crops[cropId] : null;

  /// 今日生长推进（在每日结束时调用）
  void grow() {
    if (cropId == null || !isWatered) return;
    final def = crop;
    if (def == null) return;

    growthDay++;

    if (!isHarvestable && growthDay >= def.growthDays) {
      isHarvestable = true;
      if (def.regrowDays > 0) {
        // 可重新生长的作物：重置到再生天数
        growthDay = def.growthDays - def.regrowDays;
      }
    }
  }

  /// 每日重置浇水状态
  void resetWater() {
    isWatered = false;
  }

  Map<String, dynamic> toJson() => {
    'isTilled': isTilled,
    'isWatered': isWatered,
    'cropId': cropId,
    'growthDay': growthDay,
    'isHarvestable': isHarvestable,
  };

  factory FarmTile.fromJson(Map<String, dynamic> json) => FarmTile(
    isTilled: json['isTilled'] ?? false,
    isWatered: json['isWatered'] ?? false,
    cropId: json['cropId'],
    growthDay: json['growthDay'] ?? 0,
    isHarvestable: json['isHarvestable'] ?? false,
  );
}

/// 农场系统
///
/// 管理农场网格（20×15），负责翻土、种植、浇水、收获。
class FarmingSystem extends ChangeNotifier {
  static const int width = 20;
  static const int height = 15;

  late final List<List<FarmTile>> _grid;

  FarmingSystem() {
    _grid = List.generate(
      width,
      (_) => List.generate(height, (_) => FarmTile()),
    );
  }

  // ── Access ──

  FarmTile getTile(int x, int y) {
    if (x < 0 || x >= width || y < 0 || y >= height) return FarmTile();
    return _grid[x][y];
  }

  List<List<FarmTile>> get grid => _grid;

  // ── Actions ──

  /// 翻土
  bool till(int x, int y) {
    if (x < 0 || x >= width || y < 0 || y >= height) return false;
    if (_grid[x][y].isTilled) return false;
    _grid[x][y].isTilled = true;
    notifyListeners();
    return true;
  }

  /// 浇水
  bool water(int x, int y) {
    if (x < 0 || x >= width || y < 0 || y >= height) return false;
    if (!_grid[x][y].isTilled || _grid[x][y].isWatered) return false;
    _grid[x][y].isWatered = true;
    notifyListeners();
    return true;
  }

  /// 播种
  bool plant(int x, int y, String cropId) {
    if (x < 0 || x >= width || y < 0 || y >= height) return false;
    final tile = _grid[x][y];
    if (!tile.isTilled || tile.cropId != null) return false;

    final crop = GameData.instance.crops[cropId];
    if (crop == null) return false;

    tile.cropId = cropId;
    tile.growthDay = 0;
    tile.isHarvestable = false;
    notifyListeners();
    return true;
  }

  /// 收获
  CropDef? harvest(int x, int y) {
    if (x < 0 || x >= width || y < 0 || y >= height) return null;
    final tile = _grid[x][y];
    if (!tile.isHarvestable || tile.cropId == null) return null;

    final crop = tile.crop;
    tile.cropId = null;
    tile.growthDay = 0;
    tile.isHarvestable = false;

    notifyListeners();
    return crop;
  }

  /// 每日推进（在每日结束时调用）
  void advanceDay() {
    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
        _grid[x][y].grow();
        _grid[x][y].resetWater();
      }
    }
    notifyListeners();
  }

  // ── Serialization ──

  Map<String, dynamic> toJson() => {
    'grid': _grid.map((col) => col.map((t) => t.toJson()).toList()).toList(),
  };

  void fromJson(Map<String, dynamic> json) {
    final gridJson = json['grid'] as List? ?? [];
    for (int x = 0; x < width && x < gridJson.length; x++) {
      final colJson = gridJson[x] as List? ?? [];
      for (int y = 0; y < height && y < colJson.length; y++) {
        _grid[x][y] = FarmTile.fromJson(colJson[y] as Map<String, dynamic>? ?? {});
      }
    }
    notifyListeners();
  }
}
