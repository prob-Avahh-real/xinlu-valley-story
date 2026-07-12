import 'package:flutter/foundation.dart';

import '../data/game_data.dart';
import 'inventory_system.dart';

/// 制作系统
///
/// 管理配方解锁与物品制作。
class CraftingSystem extends ChangeNotifier {
  final Set<String> _unlockedRecipes = {};

  // ── Access ──

  Set<String> get unlockedRecipes => Set.unmodifiable(_unlockedRecipes);

  bool isUnlocked(String recipeId) => _unlockedRecipes.contains(recipeId);

  List<RecipeDef> get availableRecipes {
    return GameData.instance.recipes.values
        .where((r) => _unlockedRecipes.contains(r.id))
        .toList();
  }

  // ── Recipe Management ──

  void unlockRecipe(String recipeId) {
    if (GameData.instance.recipes.containsKey(recipeId)) {
      _unlockedRecipes.add(recipeId);
      notifyListeners();
    }
  }

  void unlockRecipes(Iterable<String> recipeIds) {
    bool changed = false;
    for (final id in recipeIds) {
      if (GameData.instance.recipes.containsKey(id) && _unlockedRecipes.add(id)) {
        changed = true;
      }
    }
    if (changed) notifyListeners();
  }

  // ── Craft ──

  /// 尝试制作。返回 null 表示成功，否则返回错误消息。
  String? craft(String recipeId, InventorySystem inventory) {
    final recipe = GameData.instance.recipes[recipeId];
    if (recipe == null) return '未知配方';
    if (!_unlockedRecipes.contains(recipeId)) return '该配方尚未解锁';

    // 检查材料
    for (final ing in recipe.ingredients.entries) {
      if (!inventory.hasItem(ing.key, count: ing.value)) {
        final itemName = GameData.instance.items[ing.key]?.name ?? ing.key;
        return '缺少材料: $itemName ×${ing.value}';
      }
    }

    // 扣除材料
    for (final ing in recipe.ingredients.entries) {
      inventory.removeItem(ing.key, count: ing.value);
    }

    // 产出
    inventory.addItem(recipe.resultId, count: recipe.resultCount);

    notifyListeners();
    return null; // success
  }

  // ── Serialization ──

  Map<String, dynamic> toJson() => {
    'unlockedRecipes': _unlockedRecipes.toList(),
  };

  void fromJson(Map<String, dynamic> json) {
    _unlockedRecipes.clear();
    final list = json['unlockedRecipes'] as List? ?? [];
    for (final id in list) {
      if (id is String) _unlockedRecipes.add(id);
    }
    notifyListeners();
  }
}
