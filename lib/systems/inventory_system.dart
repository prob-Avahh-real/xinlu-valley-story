import 'package:flutter/foundation.dart';
import '../data/game_data.dart';

/// 背包系统
///
/// 管理玩家背包（36 格 + 工具栏 12 格）。
/// 每个物品有 `id`、`count`、`quality` 属性。
class InventorySystem extends ChangeNotifier {
  static const int maxSlots = 36;
  static const int toolBarSlots = 12;

  final List<InventorySlot> _slots = List.generate(maxSlots, (_) => InventorySlot.empty());
  final List<InventorySlot> _toolBar = List.generate(toolBarSlots, (_) => InventorySlot.empty());
  int _gold = 500; // 初始金币
  int _selectedTool = 0;

  // ── Getters ──

  List<InventorySlot> get slots => List.unmodifiable(_slots);
  List<InventorySlot> get toolBar => List.unmodifiable(_toolBar);
  int get gold => _gold;
  int get selectedTool => _selectedTool;
  InventorySlot get selectedItem => _toolBar[_selectedTool];

  // ── Gold ──

  bool canAfford(int amount) => _gold >= amount;

  void addGold(int amount) {
    _gold += amount;
    notifyListeners();
  }

  bool spendGold(int amount) {
    if (!canAfford(amount)) return false;
    _gold -= amount;
    notifyListeners();
    return true;
  }

  // ── Toolbar ──

  void selectTool(int index) {
    if (index >= 0 && index < toolBarSlots) {
      _selectedTool = index;
      notifyListeners();
    }
  }

  /// 将工具栏物品设为当前选中
  void setToolBarItem(int index, String itemId, {int count = 1}) {
    if (index >= 0 && index < toolBarSlots) {
      _toolBar[index] = InventorySlot(itemId: itemId, count: count);
      notifyListeners();
    }
  }

  // ── Inventory Operations ──

  /// 添加物品到背包，返回实际添加数量
  int addItem(String itemId, {int count = 1, CropQuality quality = CropQuality.normal}) {
    final item = GameData.instance.items[itemId];
    if (item == null) return 0;

    int remaining = count;

    // 先尝试堆叠到已有物品
    if (item.stackSize > 1) {
      for (final slot in _slots) {
        if (slot.itemId == itemId && slot.count < item.stackSize) {
          final canAdd = (item.stackSize - slot.count).clamp(0, remaining);
          slot.count += canAdd;
          remaining -= canAdd;
          if (remaining <= 0) {
            notifyListeners();
            return count;
          }
        }
      }
    }

    // 放到空槽位
    for (int i = 0; i < maxSlots && remaining > 0; i++) {
      if (_slots[i].isEmpty) {
        final toAdd = remaining.clamp(0, item.stackSize);
        _slots[i] = InventorySlot(itemId: itemId, count: toAdd, quality: quality);
        remaining -= toAdd;
      }
    }

    notifyListeners();
    return count - remaining;
  }

  /// 移除物品，返回实际移除数量
  int removeItem(String itemId, {int count = 1}) {
    int remaining = count;
    for (final slot in _slots) {
      if (slot.itemId == itemId) {
        if (slot.count <= remaining) {
          remaining -= slot.count;
          slot.clear();
        } else {
          slot.count -= remaining;
          remaining = 0;
          break;
        }
      }
    }
    notifyListeners();
    return count - remaining; // actual removed
  }

  /// 是否有足够数量的物品
  bool hasItem(String itemId, {int count = 1}) {
    int total = 0;
    for (final slot in _slots) {
      if (slot.itemId == itemId) total += slot.count;
    }
    return total >= count;
  }

  /// 物品总数
  int countItem(String itemId) {
    int total = 0;
    for (final slot in _slots) {
      if (slot.itemId == itemId) total += slot.count;
    }
    return total;
  }

  /// 交换两个槽位
  void swapSlots(int from, int to) {
    final temp = _slots[from];
    _slots[from] = _slots[to];
    _slots[to] = temp;
    notifyListeners();
  }

  // ── Serialization ──

  Map<String, dynamic> toJson() => {
    'gold': _gold,
    'selectedTool': _selectedTool,
    'slots': _slots.map((s) => s.toJson()).toList(),
    'toolBar': _toolBar.map((s) => s.toJson()).toList(),
  };

  void fromJson(Map<String, dynamic> json) {
    _gold = json['gold'] ?? 500;
    _selectedTool = json['selectedTool'] ?? 0;

    final slotsJson = json['slots'] as List? ?? [];
    for (int i = 0; i < maxSlots && i < slotsJson.length; i++) {
      _slots[i] = InventorySlot.fromJson(slotsJson[i] as Map<String, dynamic>? ?? {});
    }

    final toolBarJson = json['toolBar'] as List? ?? [];
    for (int i = 0; i < toolBarSlots && i < toolBarJson.length; i++) {
      _toolBar[i] = InventorySlot.fromJson(toolBarJson[i] as Map<String, dynamic>? ?? {});
    }

    notifyListeners();
  }
}

/// 背包槽位
class InventorySlot {
  String? itemId;
  int count;
  CropQuality quality;

  InventorySlot({
    this.itemId,
    this.count = 0,
    this.quality = CropQuality.normal,
  });

  factory InventorySlot.empty() => InventorySlot();

  bool get isEmpty => itemId == null || count <= 0;

  ItemDef? get item => itemId != null ? GameData.instance.items[itemId] : null;

  String get displayName => item?.name ?? '(空)';

  void clear() {
    itemId = null;
    count = 0;
    quality = CropQuality.normal;
  }

  Map<String, dynamic> toJson() => {
    'itemId': itemId,
    'count': count,
    'quality': quality.index,
  };

  factory InventorySlot.fromJson(Map<String, dynamic> json) => InventorySlot(
    itemId: json['itemId'],
    count: json['count'] ?? 0,
    quality: CropQuality.values[json['quality'] ?? 0],
  );
}
