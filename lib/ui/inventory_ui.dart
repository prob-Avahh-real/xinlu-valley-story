import 'package:flutter/material.dart';

import '../systems/inventory_system.dart';

class InventoryPanel extends StatelessWidget {
  final InventorySystem inventorySystem;
  final VoidCallback onClose;

  const InventoryPanel({
    super.key,
    required this.inventorySystem,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: inventorySystem,
      builder: (context, _) {
        return Container(
          color: Colors.black87,
          child: SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                const Divider(color: Colors.amber, height: 1),
                _buildSectionTitle('工具栏'),
                _buildToolBarGrid(),
                const Divider(color: Colors.amber, height: 1),
                _buildSectionTitle('背包 (${inventorySystem.slots.where((s) => !s.isEmpty).length}/36)'),
                Expanded(child: _buildInventoryGrid()),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.backpack, color: Colors.amber, size: 24),
          const SizedBox(width: 8),
          const Text('背包', style: TextStyle(color: Colors.amber, fontSize: 20, fontWeight: FontWeight.bold)),
          const Spacer(),
          Text('💰 ${inventorySystem.gold}G',
              style: const TextStyle(color: Colors.amber, fontSize: 18)),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: onClose,
            child: const Icon(Icons.close, color: Colors.white70, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Text(title, style: const TextStyle(color: Colors.white54, fontSize: 12)),
    );
  }

  Widget _buildToolBarGrid() {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: InventorySystem.toolBarSlots,
        itemBuilder: (_, index) {
          final slot = inventorySystem.toolBar[index];
          final isSelected = inventorySystem.selectedTool == index;
          return _slotWidget(slot, isSelected, () => inventorySystem.selectTool(index));
        },
      ),
    );
  }

  Widget _buildInventoryGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
        childAspectRatio: 1,
      ),
      itemCount: InventorySystem.maxSlots,
      itemBuilder: (_, index) {
        final slot = inventorySystem.slots[index];
        return _slotWidget(slot, false, () {});
      },
    );
  }

  Widget _slotWidget(InventorySlot slot, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.amber.withValues(alpha: 0.3)
              : Colors.grey.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected ? Colors.amber : Colors.white24,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: slot.isEmpty
            ? null
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_itemIcon(slot.itemId), style: const TextStyle(fontSize: 18)),
                  if (slot.count > 1)
                    Text('${slot.count}', style: const TextStyle(color: Colors.white, fontSize: 10)),
                ],
              ),
      ),
    );
  }

  String _itemIcon(String? itemId) {
    return switch (itemId) {
      'hoe' => '⛏️', 'watering_can' => '💧', 'pickaxe' => '⛰️',
      'axe' => '🪓', 'scythe' => '🌾', 'fishing_rod' => '🎣',
      'seed_turnip' => '🌱', 'seed_potato' => '🥔', 'seed_cabbage' => '🥬',
      'seed_rice' => '🌾', 'seed_tomato' => '🍅', 'seed_corn' => '🌽',
      'seed_pepper' => '🌶️', 'seed_melon' => '🍈', 'seed_pumpkin' => '🎃',
      'seed_carrot' => '🥕', 'seed_grape' => '🍇', 'seed_wheat' => '🌾',
      'turnip' => '🫒', 'potato' => '🥔', 'cabbage' => '🥬', 'rice' => '🍚',
      'tomato' => '🍅', 'corn' => '🌽', 'pepper' => '🌶️', 'melon' => '🍈',
      'pumpkin' => '🎃', 'carrot' => '🥕', 'grape' => '🍇', 'wheat' => '🌾',
      'wood' => '🪵', 'stone' => '🪨', 'coal' => '🪨',
      'copper_ore' => '🔶', 'iron_ore' => '🔩', 'gold_ore' => '✨',
      'copper_bar' => '🟠', 'iron_bar' => '⚙️', 'gold_bar' => '🟡',
      'carp' => '🐟', 'bass' => '🐟', 'trout' => '🐟', 'salmon' => '🐟', 'eel' => '🐍',
      'wine' => '🍷', 'juice' => '🧃', 'cheese' => '🧀', 'bread' => '🍞',
      'bouquet' => '💐', 'chocolate' => '🍫',
      'furnace' => '🔥', 'keg' => '🛢️', 'chest' => '📦', 'scarecrow' => '🗿',
      'wild_herb' => '🌿', 'mushroom' => '🍄', 'berry' => '🫐', 'flower' => '🌸',
      _ => '📦',
    };
  }
}
