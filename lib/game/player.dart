import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:bonfire/bonfire.dart';
import 'package:flutter/services.dart';

import '../systems/time_system.dart';
import '../systems/inventory_system.dart';
import '../systems/farming_system.dart';

class XinluPlayer extends SimplePlayer with KeyboardEventListener {
  final TimeSystem timeSystem;
  final InventorySystem inventorySystem;
  final FarmingSystem farmingSystem;
  final void Function(String action) onAction;

  String _currentTool = 'hoe';

  XinluPlayer({
    required this.timeSystem,
    required this.inventorySystem,
    required this.farmingSystem,
    required this.onAction,
    required super.position,
  }) : super(
          size: Vector2(16, 24),
          animation: _loadAnimations(),
          speed: 50,
        );

  static SimpleDirectionAnimation _loadAnimations() {
    return SimpleDirectionAnimation(
      idleDown: _loadAnim('player_idle_down.png', 4),
      idleUp: _loadAnim('player_idle_up.png', 4),
      idleLeft: _loadAnim('player_idle_left.png', 4),
      idleRight: _loadAnim('player_idle_right.png', 4),
      runDown: _loadAnim('player_run_down.png', 4),
      runUp: _loadAnim('player_run_up.png', 4),
      runLeft: _loadAnim('player_run_left.png', 4),
      runRight: _loadAnim('player_run_right.png', 4),
    );
  }

  static Future<SpriteAnimation> _loadAnim(String path, int frames) async {
    try {
      final image = await Flame.images.load(path);
      return SpriteAnimation.fromFrameData(
        image,
        SpriteAnimationData.sequenced(
          amount: frames,
          stepTime: 0.15,
          textureSize: Vector2(16, 24),
        ),
      );
    } catch (_) {
      return _emptyAnim();
    }
  }

  static SpriteAnimation _emptyAnim() {
    final sprite = Sprite(ui.decodeImageFromPixels(
      Uint8List.fromList([0, 0, 0, 0]), 1, 1, ui.PixelFormat.rgba8888,
      (ui.Image img) {},
    ) as dynamic);
    return SpriteAnimation.spriteList([sprite], stepTime: 1.0);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!timeSystem.isAwake) return;
  }

  void interact() {
    final facing = lastDirection;
    Vector2 offset;
    switch (facing) {
      case Direction.up:    offset = Vector2(0, -16);
      case Direction.down:  offset = Vector2(0, 16);
      case Direction.left:  offset = Vector2(-16, 0);
      case Direction.right: offset = Vector2(16, 0);
      default: return;
    }

    final tilePos = position + offset;
    final tileX = (tilePos.x / 16).floor();
    final tileY = (tilePos.y / 16).floor();

    switch (_currentTool) {
      case 'hoe':
        farmingSystem.till(tileX, tileY);
      case 'watering_can':
        farmingSystem.water(tileX, tileY);
      case 'scythe':
        final crop = farmingSystem.harvest(tileX, tileY);
        if (crop != null) {
          inventorySystem.addItem(
            crop.harvestId,
            count: crop.harvestMin +
                (DateTime.now().millisecond % (crop.harvestMax - crop.harvestMin + 1)),
          );
        }
      default:
        break;
    }
  }

  @override
  bool onKeyboard(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event is KeyDownEvent) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.keyE: onAction('inventory');
        case LogicalKeyboardKey.keyQ: onAction('save');
        case LogicalKeyboardKey.escape: onAction('menu');
        case LogicalKeyboardKey.digit1: _currentTool = 'hoe'; inventorySystem.selectTool(0);
        case LogicalKeyboardKey.digit2: _currentTool = 'watering_can'; inventorySystem.selectTool(1);
        case LogicalKeyboardKey.digit3: _currentTool = 'pickaxe'; inventorySystem.selectTool(2);
        case LogicalKeyboardKey.digit4: _currentTool = 'axe'; inventorySystem.selectTool(3);
        case LogicalKeyboardKey.digit5: _currentTool = 'scythe'; inventorySystem.selectTool(4);
        case LogicalKeyboardKey.space: interact();
        default: break;
      }
    }
    return true;
  }

  void joystickAction(JoystickActionEvent event) {
    if (event.event == ActionEvent.DOWN) interact();
  }
}
