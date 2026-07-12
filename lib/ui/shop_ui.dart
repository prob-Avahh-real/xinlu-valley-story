import 'package:flutter/material.dart';

import '../data/game_data.dart';
import '../systems/inventory_system.dart';
import '../systems/time_system.dart';

/// 商店界面
///
/// 支持买卖物品，按季节筛选种子。
class ShopPanel extends StatelessWidget {
  final InventorySystem inventorySystem;
  final TimeSystem timeSystem;
  final String shopId;
  final VoidCallback onClose;

  const ShopPanel({
    super.key,
    required this.inventorySystem,
    required this.timeSystem,
    required this.shopId,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final shopItems = GameData.instance.shops[shopId] ?? [];

    return Container(
      color: Colors.black87,
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const Divider(color: Colors.amber),
            Expanded(
              child: ListenableBuilder(
                listenable: inventorySystem,
                builder: (context, _) {
                  final availableItems = _filterBySeason(shopItems);
                  return ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: availableItems.length,
                    itemBuilder: (_, index) {
                      final shopItem = availableItems[index];
                      return _buildShopItemRow(context, shopItem);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.store, color: Colors.amber, size: 24),
          const SizedBox(width: 8),
          const Text('商店', style: TextStyle(color: Colors.amber, fontSize: 20)),
          const Spacer(),
          GestureDetector(
            onTap: onClose,
            child: const Icon(Icons.close, color: Colors.white70, size: 24),
          ),
        ],
      ),
    );
  }

  List<ShopItem> _filterBySeason(List<ShopItem> items) {
    // 如果物品是种子，检查季节是否匹配
    return items.where((si) {
      final item = GameData.instance.items[si.itemId];
      if (item == null) return false;
      if (item.category != ItemCategory.seed) return true;

      // 查找对应的作物季节
      final crop = GameData.instance.crops.values.firstWhere(
        (c) => c.seedId == si.itemId,
        orElse: () => GameData.instance.crops.values.first,
      );
      return crop.season == timeSystem.season;
    }).toList();
  }

  Widget _buildShopItemRow(BuildContext context, ShopItem shopItem) {
    final item = GameData.instance.items[shopItem.itemId];
    if (item == null) return const SizedBox.shrink();

    final canBuy = inventorySystem.canAfford(shopItem.price);

    return Card(
      color: const Color(0xFF3E2723),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Text(
          _shopItemIcon(item.id),
          style: const TextStyle(fontSize: 28),
        ),
        title: Text(item.name, style: const TextStyle(color: Colors.white)),
        subtitle: Text(
          item.description,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${shopItem.price}G',
              style: TextStyle(
                color: canBuy ? Colors.amber : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              height: 28,
              child: ElevatedButton(
                onPressed: canBuy
                    ? () {
                        if (inventorySystem.spendGold(shopItem.price)) {
                          inventorySystem.addItem(shopItem.itemId);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('购买了 ${item.name}')),
                          );
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber.shade700,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: const Text('购买', style: TextStyle(color: Colors.white, fontSize: 12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _shopItemIcon(String itemId) {
    return switch (itemId) {
      'seed_turnip' => '🌱', 'seed_potato' => '🥔', 'seed_cabbage' => '🥬',
      'seed_rice' => '🌾', 'seed_tomato' => '🍅', 'seed_corn' => '🌽',
      'seed_pepper' => '🌶️', 'seed_melon' => '🍈', 'seed_pumpkin' => '🎃',
      'seed_carrot' => '🥕', 'seed_grape' => '🍇', 'seed_wheat' => '🌾',
      'wood' => '🪵', 'stone' => '🪨', 'coal' => '🪨',
      'copper_ore' => '🔶', 'iron_ore' => '🔩',
      'fertilizer' => '🧪',
      _ => '📦',
    };
  }
}
