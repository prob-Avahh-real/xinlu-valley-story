import 'package:flutter/material.dart';

import '../data/save_manager.dart';

/// 存档管理界面
class SavePanel extends StatefulWidget {
  final VoidCallback onClose;
  final Future<bool> Function(int slot, Map<String, dynamic> data) onSave;

  const SavePanel({
    super.key,
    required this.onClose,
    required this.onSave,
  });

  @override
  State<SavePanel> createState() => _SavePanelState();
}

class _SavePanelState extends State<SavePanel> {
  List<SaveSlotInfo> _slots = [];
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadSlots();
  }

  void _loadSlots() {
    setState(() => _loading = true);
    _slots = SaveManager.instance.listSlots();
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const Divider(color: Colors.amber),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: Colors.amber))
                  : _buildSlotList(),
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
          const Icon(Icons.save, color: Colors.amber, size: 24),
          const SizedBox(width: 8),
          const Text('保存游戏', style: TextStyle(color: Colors.amber, fontSize: 20)),
          const Spacer(),
          if (_saving)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(color: Colors.amber, strokeWidth: 2),
            ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _saving ? null : widget.onClose,
            child: const Icon(Icons.close, color: Colors.white70, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildSlotList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (_, index) {
        final existingSlot = index < _slots.length ? _slots[index] : null;
        return _buildSlotCard(index, existingSlot);
      },
    );
  }

  Widget _buildSlotCard(int index, SaveSlotInfo? slot) {
    return Card(
      color: const Color(0xFF3E2723),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(
          slot != null ? Icons.save : Icons.save_outlined,
          color: slot != null ? Colors.amber : Colors.white38,
          size: 32,
        ),
        title: Text(
          '存档 ${index + 1}',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        subtitle: slot != null
            ? Text(
                slot.isCorrupt ? '存档已损坏' : slot.summary,
                style: TextStyle(
                  color: slot.isCorrupt ? Colors.red : Colors.white54,
                  fontSize: 12,
                ),
              )
            : const Text('空', style: TextStyle(color: Colors.white24, fontSize: 12)),
        trailing: TextButton(
          onPressed: _saving ? null : () => _saveToSlot(index),
          child: const Text('保存', style: TextStyle(color: Colors.amber)),
        ),
      ),
    );
  }

  Future<void> _saveToSlot(int slot) async {
    setState(() => _saving = true);

    // 收集当前数据（由父组件负责）
    final data = <String, dynamic>{
      'playerName': '农夫',
      'slot': slot,
    };

    final success = await widget.onSave(slot, data);
    if (mounted) {
      setState(() => _saving = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('保存成功！'), backgroundColor: Colors.green),
        );
        _loadSlots();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('保存失败'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
