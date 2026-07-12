import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:xinlu_grain_valley/main.dart';
import 'package:xinlu_grain_valley/data/save_manager.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  List<SaveSlotInfo> _slots = [];
  bool _loading = true;

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

  void _startNewGame() {
    context.read<GameState>().startGame();
  }

  void _loadGame(int slot) async {
    final data = await SaveManager.instance.load(slot);
    if (data != null && mounted) {
      context.read<GameState>().startGame();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2E7D32), Color(0xFF1B5E20), Color(0xFF4E342E)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  const Text('🌾', style: TextStyle(fontSize: 60)),
                  const SizedBox(height: 8),
                  Text('芯麓谷物语', style: TextStyle(
                    fontSize: 36, fontWeight: FontWeight.bold,
                    color: Colors.amber.shade300,
                    shadows: const [Shadow(color: Colors.black87, blurRadius: 4, offset: Offset(2, 2))],
                  )),
                  const SizedBox(height: 4),
                  Text('XINLU GRAIN VALLEY',
                    style: TextStyle(fontSize: 14, color: Colors.amber.shade200.withValues(alpha: 0.7), letterSpacing: 4)),
                  const SizedBox(height: 48),
                  _menuButton('新游戏', Icons.play_arrow, _startNewGame),
                  const SizedBox(height: 12),
                  _menuButton('继续游戏', Icons.replay, () => _showLoadDialog()),
                  const SizedBox(height: 12),
                  _menuButton('读取存档', Icons.folder_open, () => _showLoadDialog()),
                  const SizedBox(height: 12),
                  _menuButton('设置', Icons.settings, () {}),
                  const SizedBox(height: 40),
                  Text('v0.1.0', style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _menuButton(String label, IconData icon, VoidCallback onTap) {
    return SizedBox(
      width: 220, height: 50,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 20),
        label: Text(label, style: const TextStyle(fontSize: 18)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.brown.shade600,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.amber.shade300, width: 1.5),
          ),
        ),
      ),
    );
  }

  void _showLoadDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF2D1B0E),
        title: const Text('读取存档', style: TextStyle(color: Colors.amber)),
        content: SizedBox(
          width: double.maxFinite,
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: Colors.amber))
              : _slots.isEmpty
                  ? const Text('没有存档', style: TextStyle(color: Colors.white70))
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: _slots.length,
                      itemBuilder: (_, i) {
                        final slot = _slots[i];
                        return ListTile(
                          title: Text('存档 ${slot.slot + 1}', style: const TextStyle(color: Colors.white)),
                          subtitle: Text(slot.isCorrupt ? '存档已损坏' : slot.summary,
                            style: TextStyle(color: slot.isCorrupt ? Colors.red : Colors.white54, fontSize: 12)),
                          trailing: const Icon(Icons.arrow_forward, color: Colors.amber),
                          onTap: slot.isCorrupt ? null : () { Navigator.pop(context); _loadGame(slot.slot); },
                        );
                      },
                    ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
            child: const Text('取消', style: TextStyle(color: Colors.white54))),
        ],
      ),
    );
  }
}
