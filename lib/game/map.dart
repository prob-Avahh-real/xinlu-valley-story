import 'package:bonfire/bonfire.dart';

class GameMap {
  static const int tileSize = 16;
  static const int mapWidth = 40;
  static const int mapHeight = 30;
  static const int farmStartX = 5;
  static const int farmStartY = 5;
  static const int farmWidth = 20;
  static const int farmHeight = 15;

  static final Vector2 spawnPoint = Vector2(160, 120);

  static final Map<String, Vector2> npcPositions = {
    'lin': Vector2(350, 180),
    'mei': Vector2(400, 120),
    'lao_wang': Vector2(80, 300),
  };

  static bool isFarmTile(int tileX, int tileY) {
    return tileX >= farmStartX &&
        tileX < farmStartX + farmWidth &&
        tileY >= farmStartY &&
        tileY < farmStartY + farmHeight;
  }

  static bool isWalkable(int tileX, int tileY) {
    if (tileX < 0 || tileX >= mapWidth || tileY < 0 || tileY >= mapHeight) {
      return false;
    }
    return true;
  }
}
