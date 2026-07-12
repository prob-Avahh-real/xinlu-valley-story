import 'package:flutter/foundation.dart';

import '../data/game_data.dart';

/// 好感度系统
///
/// 管理玩家与 NPC 的关系：好感度值 (0-10 心)、对话状态、送礼记录。
class RelationshipSystem extends ChangeNotifier {
  static const int maxHearts = 10;
  static const int pointsPerHeart = 250;
  static const int maxPoints = maxHearts * pointsPerHeart;

  /// npcId → friendship points
  final Map<String, int> _friendship = {};

  /// npcId → 本日是否已送礼
  final Map<String, bool> _giftedToday = {};

  /// npcId → 已对话的等级标记
  final Map<String, int> _dialogueLevel = {};

  // ── Access ──

  int getFriendship(String npcId) => _friendship[npcId] ?? 0;

  int getHearts(String npcId) => getFriendship(npcId) ~/ pointsPerHeart;

  bool hasGiftedToday(String npcId) => _giftedToday[npcId] ?? false;

  int getDialogueLevel(String npcId) => _dialogueLevel[npcId] ?? 0;

  /// 获取当前对话文本
  String getDialogue(String npcId) {
    final npc = GameData.instance.npcs[npcId];
    if (npc == null) return '...';

    final level = getHearts(npcId).clamp(0, 5);

    // 先检查是否有任务对话
    if (npc.questDialogues.containsKey(level)) {
      return npc.questDialogues[level]!;
    }

    return npc.dialogues[level] ?? npc.dialogues[0] ?? '你好！';
  }

  // ── Actions ──

  /// 与 NPC 对话
  void talk(String npcId) {
    _dialogueLevel[npcId] = (getDialogueLevel(npcId) + 1) % 6;
    // 每日首次对话 +10 好感
    if (!_giftedToday.containsKey(npcId)) {
      _addFriendship(npcId, 10);
    }
    notifyListeners();
  }

  /// 赠送礼物
  /// 返回反应：'love', 'like', 'neutral', 'hate'
  String giveGift(String npcId, String itemId) {
    if (hasGiftedToday(npcId)) return 'already_gifted';

    final npc = GameData.instance.npcs[npcId];
    if (npc == null) return 'neutral';

    _giftedToday[npcId] = true;

    if (npc.lovedGifts.contains(itemId)) {
      _addFriendship(npcId, 80);
      notifyListeners();
      return 'love';
    } else if (npc.likedGifts.contains(itemId)) {
      _addFriendship(npcId, 45);
      notifyListeners();
      return 'like';
    } else if (npc.hatedGifts.contains(itemId)) {
      _addFriendship(npcId, -40);
      notifyListeners();
      return 'hate';
    } else {
      _addFriendship(npcId, 20);
      notifyListeners();
      return 'neutral';
    }
  }

  void _addFriendship(String npcId, int points) {
    final current = _friendship[npcId] ?? 0;
    _friendship[npcId] = (current + points).clamp(0, maxPoints);
  }

  /// 每日重置送礼状态
  void resetDaily() {
    _giftedToday.clear();
    notifyListeners();
  }

  // ── Serialization ──

  Map<String, dynamic> toJson() => {
    'friendship': _friendship,
    'giftedToday': _giftedToday,
    'dialogueLevel': _dialogueLevel,
  };

  void fromJson(Map<String, dynamic> json) {
    _friendship.clear();
    (json['friendship'] as Map<String, dynamic>? ?? {}).forEach((k, v) {
      _friendship[k] = v as int;
    });

    _giftedToday.clear();
    (json['giftedToday'] as Map<String, dynamic>? ?? {}).forEach((k, v) {
      _giftedToday[k] = v as bool;
    });

    _dialogueLevel.clear();
    (json['dialogueLevel'] as Map<String, dynamic>? ?? {}).forEach((k, v) {
      _dialogueLevel[k] = v as int;
    });

    notifyListeners();
  }
}
