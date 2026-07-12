import 'package:bonfire/bonfire.dart';
import 'package:bonfire/map/empty_map.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xinlu_grain_valley/main.dart';
import 'package:xinlu_grain_valley/systems/time_system.dart';
import 'package:xinlu_grain_valley/systems/inventory_system.dart';
import 'package:xinlu_grain_valley/systems/farming_system.dart';
import 'package:xinlu_grain_valley/systems/crafting_system.dart';
import 'package:xinlu_grain_valley/systems/relationship_system.dart';
import 'package:xinlu_grain_valley/game/player.dart';
import 'package:xinlu_grain_valley/game/map.dart' as game_map;

class XinluGameWidget extends StatefulWidget {
  const XinluGameWidget({super.key});
  @override
  State<XinluGameWidget> createState() => _XinluGameWidgetState();
}

class _XinluGameWidgetState extends State<XinluGameWidget> {
  late TimeSystem _timeSystem;
  late InventorySystem _inventorySystem;
  late FarmingSystem _farmingSystem;

  @override
  void initState() {
    super.initState();
    _timeSystem = TimeSystem();
    _inventorySystem = InventorySystem();
    _farmingSystem = FarmingSystem();
  }

  @override
  Widget build(BuildContext context) {
    return BonfireWidget(
      map: EmptyWorldMap(size: Vector2(640, 480)),
      player: XinluPlayer(
        timeSystem: _timeSystem,
        inventorySystem: _inventorySystem,
        farmingSystem: _farmingSystem,
        onAction: (action) {
          if (action == 'menu' && mounted) {
            context.read<GameState>().returnToMenu();
          }
        },
        position: game_map.GameMap.spawnPoint,
      ),
      cameraConfig: CameraConfig(zoom: 2.0),
      overlayBuilderMap: {
        'hud': (ctx, game) => Positioned(
          top: 8, left: 8,
          child: Container(
            padding: const EdgeInsets.all(8),
            color: Colors.black54,
            child: Text('${_inventorySystem.gold}G | ${_timeSystem.dateString}',
                style: const TextStyle(color: Colors.white, fontSize: 14)),
          ),
        ),
      },
    );
  }
}
