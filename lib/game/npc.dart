import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:bonfire/bonfire.dart';

class XinluNpc extends SimpleNpc with TapGesture {
  final String npcId;
  final String npcName;
  final void Function() onTalk;

  XinluNpc({
    required this.npcId,
    required this.npcName,
    required this.onTalk,
    required super.position,
  }) : super(
          size: Vector2(16, 24),
          animation: _loadAnimations(npcId),
        );

  static SimpleDirectionAnimation _loadAnimations(String id) {
    return SimpleDirectionAnimation(
      idleDown: _loadAnim('${id}_idle_down.png', 4),
      idleUp: _loadAnim('${id}_idle_up.png', 4),
      idleLeft: _loadAnim('${id}_idle_left.png', 4),
      idleRight: _loadAnim('${id}_idle_right.png', 4),
      runDown: _loadAnim('${id}_run_down.png', 4),
      runUp: _loadAnim('${id}_run_up.png', 4),
      runLeft: _loadAnim('${id}_run_left.png', 4),
      runRight: _loadAnim('${id}_run_right.png', 4),
    );
  }

  static Future<SpriteAnimation> _loadAnim(String path, int frames) async {
    try {
      final image = await Flame.images.load(path);
      return SpriteAnimation.fromFrameData(
        image,
        SpriteAnimationData.sequenced(
          amount: frames,
          stepTime: 0.2,
          textureSize: Vector2(16, 24),
        ),
      );
    } catch (_) {
      return SpriteAnimation.spriteList(
        [Sprite(ui.decodeImageFromPixels(
          Uint8List.fromList([0, 0, 0, 0]), 1, 1, ui.PixelFormat.rgba8888,
          (ui.Image img) {},
        ) as dynamic)],
        stepTime: 1.0,
      );
    }
  }

  @override
  void onTap() {
    onTalk();
  }

  @override
  void update(double dt) {
    if (checkInterval('wander', 2000, dt)) {
      _randomWalk();
    }
    super.update(dt);
  }

  void _randomWalk() {
    final dir = Direction.values[(DateTime.now().millisecond % 8)];
    switch (dir) {
      case Direction.up:    moveFromAngle(0, speed: 20);
      case Direction.down:  moveFromAngle(180, speed: 20);
      case Direction.left:  moveFromAngle(270, speed: 20);
      case Direction.right: moveFromAngle(90, speed: 20);
      default: break;
    }
  }
}
