/// 芯麓谷物语 — 全局游戏数据定义
///
/// 包含所有物品、作物、工具、食谱、NPC 等的静态数据。
/// 使用单例模式便于全局访问。
library;

import 'dart:collection';

// ═══════════════════════════════════════════════════════════
// Enums
// ═══════════════════════════════════════════════════════════

enum Season { spring, summer, autumn, winter }

enum Weather { sunny, rainy, stormy, snowy }

enum CropQuality { normal, silver, gold, iridium }

enum ToolTier { basic, copper, iron, gold, iridium }

enum ItemCategory {
  tool,
  seed,
  crop,
  fish,
  mineral,
  artisan,
  cooked,
  forage,
  resource,
  furniture,
  gift,
}

// ═══════════════════════════════════════════════════════════
// Data Classes
// ═══════════════════════════════════════════════════════════

class ItemDef {
  final String id;
  final String name;
  final ItemCategory category;
  final int sellPrice;
  final int buyPrice;
  final int stackSize;
  final String description;
  final Map<String, dynamic>? props;

  const ItemDef({
    required this.id,
    required this.name,
    required this.category,
    required this.sellPrice,
    this.buyPrice = -1,
    this.stackSize = 99,
    this.description = '',
    this.props,
  });
}

class CropDef {
  final String id;
  final String name;
  final String seedId;
  final Season season;
  final int growthDays;
  final int regrowDays; // 0 = 单次收获
  final String harvestId;
  final int harvestMin;
  final int harvestMax;
  final int seedPrice;
  final int sellPrice;

  const CropDef({
    required this.id,
    required this.name,
    required this.seedId,
    required this.season,
    required this.growthDays,
    this.regrowDays = 0,
    required this.harvestId,
    this.harvestMin = 1,
    this.harvestMax = 1,
    required this.seedPrice,
    required this.sellPrice,
  });
}

class RecipeDef {
  final String id;
  final String name;
  final String resultId;
  final int resultCount;
  final Map<String, int> ingredients;
  final String? source; // e.g. "farming_lv3", "shop_pierre"

  const RecipeDef({
    required this.id,
    required this.name,
    required this.resultId,
    this.resultCount = 1,
    required this.ingredients,
    this.source,
  });
}

class NPCDef {
  final String id;
  final String name;
  final Set<String> lovedGifts;
  final Set<String> likedGifts;
  final Set<String> hatedGifts;
  final Map<int, String> dialogues;
  final Map<int, String> questDialogues;

  const NPCDef({
    required this.id,
    required this.name,
    this.lovedGifts = const {},
    this.likedGifts = const {},
    this.hatedGifts = const {},
    this.dialogues = const {},
    this.questDialogues = const {},
  });
}

class ShopItem {
  final String itemId;
  final int price;
  final int stock; // -1 = 无限

  const ShopItem({required this.itemId, required this.price, this.stock = -1});
}

// ═══════════════════════════════════════════════════════════
// GameData Singleton
// ═══════════════════════════════════════════════════════════

class GameData {
  GameData._();
  static final GameData instance = GameData._();

  // ── Items ──
  late final Map<String, ItemDef> items;

  // ── Crops ──
  late final Map<String, CropDef> crops;

  // ── Recipes ──
  late final Map<String, RecipeDef> recipes;

  // ── NPCs ──
  late final Map<String, NPCDef> npcs;

  // ── Shops ──
  late final Map<String, List<ShopItem>> shops;

  void init() {
    _initItems();
    _initCrops();
    _initRecipes();
    _initNPCs();
    _initShops();
  }

  // ─────────────────────────────────────────────
  // Items
  // ─────────────────────────────────────────────

  void _initItems() {
    final map = <String, ItemDef>{};

    void add(ItemDef i) => map[i.id] = i;

    // Tools
    add(ItemDef(id: 'hoe',        name: '锄头',   category: ItemCategory.tool,  sellPrice: 0,  stackSize: 1, description: '翻土种地的基础工具'));
    add(ItemDef(id: 'watering_can', name: '水壶', category: ItemCategory.tool,  sellPrice: 0,  stackSize: 1, description: '给作物浇水'));
    add(ItemDef(id: 'pickaxe',    name: '镐子',   category: ItemCategory.tool,  sellPrice: 0,  stackSize: 1, description: '采矿与碎石'));
    add(ItemDef(id: 'axe',        name: '斧头',   category: ItemCategory.tool,  sellPrice: 0,  stackSize: 1, description: '砍伐树木'));
    add(ItemDef(id: 'scythe',     name: '镰刀',   category: ItemCategory.tool,  sellPrice: 0,  stackSize: 1, description: '收割作物和割草'));
    add(ItemDef(id: 'fishing_rod', name: '鱼竿',  category: ItemCategory.tool,  sellPrice: 0,  stackSize: 1, description: '在水边钓鱼'));

    // Seeds — Spring
    add(ItemDef(id: 'seed_turnip',   name: '白萝卜种子', category: ItemCategory.seed, sellPrice: 10,  buyPrice: 20, description: '春天播种，4天成熟'));
    add(ItemDef(id: 'seed_potato',    name: '土豆种子',   category: ItemCategory.seed, sellPrice: 25,  buyPrice: 50, description: '春天播种，6天成熟，可能多产'));
    add(ItemDef(id: 'seed_cabbage',   name: '卷心菜种子', category: ItemCategory.seed, sellPrice: 40,  buyPrice: 80, description: '春天播种，12天成熟'));
    add(ItemDef(id: 'seed_rice',      name: '水稻种子',   category: ItemCategory.seed, sellPrice: 15,  buyPrice: 40, description: '春天播种，8天成熟'));

    // Seeds — Summer
    add(ItemDef(id: 'seed_tomato',    name: '番茄种子',   category: ItemCategory.seed, sellPrice: 30,  buyPrice: 50, description: '夏天播种，11天成熟，之后每4天再收获'));
    add(ItemDef(id: 'seed_corn',      name: '玉米种子',   category: ItemCategory.seed, sellPrice: 35,  buyPrice: 60, description: '夏秋两季，14天成熟，之后每4天再收获'));
    add(ItemDef(id: 'seed_pepper',    name: '辣椒种子',   category: ItemCategory.seed, sellPrice: 25,  buyPrice: 40, description: '夏天播种，5天成熟，之后每3天再收获'));
    add(ItemDef(id: 'seed_melon',     name: '西瓜种子',   category: ItemCategory.seed, sellPrice: 50,  buyPrice: 100, description: '夏天播种，12天成熟'));

    // Seeds — Autumn
    add(ItemDef(id: 'seed_pumpkin',   name: '南瓜种子',   category: ItemCategory.seed, sellPrice: 50,  buyPrice: 100, description: '秋天播种，13天成熟'));
    add(ItemDef(id: 'seed_carrot',    name: '胡萝卜种子', category: ItemCategory.seed, sellPrice: 20,  buyPrice: 30, description: '秋天播种，5天成熟'));
    add(ItemDef(id: 'seed_grape',     name: '葡萄种子',   category: ItemCategory.seed, sellPrice: 45,  buyPrice: 90, description: '秋天播种，10天成熟，之后每3天再收获'));
    add(ItemDef(id: 'seed_wheat',     name: '小麦种子',   category: ItemCategory.seed, sellPrice: 15,  buyPrice: 25, description: '夏秋两季，4天成熟'));

    // Crops — Harvest
    add(ItemDef(id: 'turnip',    name: '白萝卜', category: ItemCategory.crop,   sellPrice: 35,  description: '清脆爽口'));
    add(ItemDef(id: 'potato',    name: '土豆',   category: ItemCategory.crop,   sellPrice: 80,  description: '淀粉丰富'));
    add(ItemDef(id: 'cabbage',   name: '卷心菜', category: ItemCategory.crop,   sellPrice: 150, description: '营养丰富'));
    add(ItemDef(id: 'rice',      name: '稻米',   category: ItemCategory.crop,   sellPrice: 70,  description: '主食谷物'));
    add(ItemDef(id: 'tomato',    name: '番茄',   category: ItemCategory.crop,   sellPrice: 60,  description: '多汁鲜美'));
    add(ItemDef(id: 'corn',      name: '玉米',   category: ItemCategory.crop,   sellPrice: 65,  description: '黄金谷物'));
    add(ItemDef(id: 'pepper',    name: '辣椒',   category: ItemCategory.crop,   sellPrice: 50,  description: '辛辣火热'));
    add(ItemDef(id: 'melon',     name: '西瓜',   category: ItemCategory.crop,   sellPrice: 180, description: '夏日清凉'));
    add(ItemDef(id: 'pumpkin',   name: '南瓜',   category: ItemCategory.crop,   sellPrice: 200, description: '秋天丰收'));
    add(ItemDef(id: 'carrot',    name: '胡萝卜', category: ItemCategory.crop,   sellPrice: 55,  description: '地下宝藏'));
    add(ItemDef(id: 'grape',     name: '葡萄',   category: ItemCategory.crop,   sellPrice: 80,  description: '甜蜜多汁'));
    add(ItemDef(id: 'wheat',     name: '小麦',   category: ItemCategory.crop,   sellPrice: 40,  description: '面包之源'));

    // Forage
    add(ItemDef(id: 'wild_herb',    name: '野草',   category: ItemCategory.forage, sellPrice: 15,  description: '路边常见的草药'));
    add(ItemDef(id: 'mushroom',     name: '蘑菇',   category: ItemCategory.forage, sellPrice: 30,  description: '林间野生菌'));
    add(ItemDef(id: 'berry',        name: '浆果',   category: ItemCategory.forage, sellPrice: 25,  description: '酸甜野果'));
    add(ItemDef(id: 'flower',       name: '野花',   category: ItemCategory.forage, sellPrice: 20,  description: '美丽芬芳'));

    // Resources
    add(ItemDef(id: 'wood',         name: '木材',   category: ItemCategory.resource, sellPrice: 5,   description: '基础建材'));
    add(ItemDef(id: 'stone',        name: '石头',   category: ItemCategory.resource, sellPrice: 5,   description: '基础建材'));
    add(ItemDef(id: 'coal',         name: '煤炭',   category: ItemCategory.resource, sellPrice: 15,  description: '燃料'));
    add(ItemDef(id: 'copper_ore',   name: '铜矿石', category: ItemCategory.resource, sellPrice: 20,  description: '可冶炼成铜锭'));
    add(ItemDef(id: 'iron_ore',     name: '铁矿石', category: ItemCategory.resource, sellPrice: 40,  description: '可冶炼成铁锭'));
    add(ItemDef(id: 'gold_ore',     name: '金矿石', category: ItemCategory.resource, sellPrice: 80,  description: '可冶炼成金锭'));
    add(ItemDef(id: 'copper_bar',   name: '铜锭',   category: ItemCategory.resource, sellPrice: 60,  description: '精炼铜'));
    add(ItemDef(id: 'iron_bar',     name: '铁锭',   category: ItemCategory.resource, sellPrice: 120, description: '精炼铁'));
    add(ItemDef(id: 'gold_bar',     name: '金锭',   category: ItemCategory.resource, sellPrice: 250, description: '精炼金'));

    // Fish
    add(ItemDef(id: 'carp',         name: '鲤鱼',   category: ItemCategory.fish, sellPrice: 30,  description: '常见淡水鱼'));
    add(ItemDef(id: 'bass',         name: '鲈鱼',   category: ItemCategory.fish, sellPrice: 45,  description: '肉质鲜美'));
    add(ItemDef(id: 'trout',        name: '鳟鱼',   category: ItemCategory.fish, sellPrice: 65,  description: '游动敏捷'));
    add(ItemDef(id: 'salmon',       name: '三文鱼', category: ItemCategory.fish, sellPrice: 100, description: '高价值鱼类'));
    add(ItemDef(id: 'eel',          name: '鳗鱼',   category: ItemCategory.fish, sellPrice: 85,  description: '夜间出没'));

    // Artisan
    add(ItemDef(id: 'wine',         name: '果酒',   category: ItemCategory.artisan, sellPrice: 300, description: '醇香浓郁'));
    add(ItemDef(id: 'juice',        name: '果汁',   category: ItemCategory.artisan, sellPrice: 120, description: '新鲜压榨'));
    add(ItemDef(id: 'cheese',       name: '奶酪',   category: ItemCategory.artisan, sellPrice: 200, description: '手工制作'));
    add(ItemDef(id: 'bread',        name: '面包',   category: ItemCategory.cooked, sellPrice: 60,  description: '新鲜出炉'));

    // Gifts (special)
    add(ItemDef(id: 'bouquet',      name: '花束',   category: ItemCategory.gift, sellPrice: 100, buyPrice: 200, description: '表达心意'));
    add(ItemDef(id: 'chocolate',    name: '巧克力', category: ItemCategory.gift, sellPrice: 80,  buyPrice: 150, description: '甜蜜礼物'));

    // Furniture
    add(ItemDef(id: 'furnace',      name: '熔炉',   category: ItemCategory.furniture, sellPrice: 0,  stackSize: 1, description: '冶炼矿石'));
    add(ItemDef(id: 'keg',          name: '酿酒桶', category: ItemCategory.furniture, sellPrice: 0,  stackSize: 1, description: '酿造果酒'));
    add(ItemDef(id: 'preserves_jar', name: '腌制罐', category: ItemCategory.furniture, sellPrice: 0,  stackSize: 1, description: '制作果酱'));
    add(ItemDef(id: 'chest',        name: '储物箱', category: ItemCategory.furniture, sellPrice: 0,  stackSize: 1, description: '存放物品'));
    add(ItemDef(id: 'scarecrow',    name: '稻草人', category: ItemCategory.furniture, sellPrice: 0,  stackSize: 1, description: '驱赶乌鸦'));

    items = Map.unmodifiable(map);
  }

  // ─────────────────────────────────────────────
  // Crops
  // ─────────────────────────────────────────────

  void _initCrops() {
    crops = Map.unmodifiable({
      'turnip': CropDef(id: 'turnip',  name: '白萝卜', seedId: 'seed_turnip',  season: Season.spring, growthDays: 4,  harvestId: 'turnip',  seedPrice: 20,  sellPrice: 35),
      'potato':  CropDef(id: 'potato',  name: '土豆',   seedId: 'seed_potato',   season: Season.spring, growthDays: 6,  harvestId: 'potato',  harvestMax: 3, seedPrice: 50,  sellPrice: 80),
      'cabbage': CropDef(id: 'cabbage', name: '卷心菜', seedId: 'seed_cabbage',  season: Season.spring, growthDays: 12, harvestId: 'cabbage', seedPrice: 80,  sellPrice: 150),
      'rice':    CropDef(id: 'rice',    name: '稻米',   seedId: 'seed_rice',     season: Season.spring, growthDays: 8,  harvestId: 'rice',    seedPrice: 40,  sellPrice: 70),
      'tomato':  CropDef(id: 'tomato',  name: '番茄',   seedId: 'seed_tomato',   season: Season.summer, growthDays: 11, regrowDays: 4, harvestId: 'tomato',  seedPrice: 50,  sellPrice: 60),
      'corn':    CropDef(id: 'corn',    name: '玉米',   seedId: 'seed_corn',     season: Season.summer, growthDays: 14, regrowDays: 4, harvestId: 'corn',    seedPrice: 60,  sellPrice: 65),
      'pepper':  CropDef(id: 'pepper',  name: '辣椒',   seedId: 'seed_pepper',   season: Season.summer, growthDays: 5,  regrowDays: 3, harvestId: 'pepper',  seedPrice: 40,  sellPrice: 50),
      'melon':   CropDef(id: 'melon',   name: '西瓜',   seedId: 'seed_melon',    season: Season.summer, growthDays: 12, harvestId: 'melon',   seedPrice: 100, sellPrice: 180),
      'pumpkin': CropDef(id: 'pumpkin', name: '南瓜',   seedId: 'seed_pumpkin',  season: Season.autumn, growthDays: 13, harvestId: 'pumpkin', seedPrice: 100, sellPrice: 200),
      'carrot':  CropDef(id: 'carrot',  name: '胡萝卜', seedId: 'seed_carrot',   season: Season.autumn, growthDays: 5,  harvestId: 'carrot',  seedPrice: 30,  sellPrice: 55),
      'grape':   CropDef(id: 'grape',   name: '葡萄',   seedId: 'seed_grape',    season: Season.autumn, growthDays: 10, regrowDays: 3, harvestId: 'grape',   seedPrice: 90,  sellPrice: 80),
      'wheat':   CropDef(id: 'wheat',   name: '小麦',   seedId: 'seed_wheat',    season: Season.summer, growthDays: 4,  harvestId: 'wheat',   seedPrice: 25,  sellPrice: 40),
    });
  }

  // ─────────────────────────────────────────────
  // Recipes
  // ─────────────────────────────────────────────

  void _initRecipes() {
    recipes = Map.unmodifiable({
      'furnace':     RecipeDef(id: 'furnace',     name: '熔炉',   resultId: 'furnace',     ingredients: {'stone': 25, 'copper_ore': 20}),
      'keg':         RecipeDef(id: 'keg',         name: '酿酒桶', resultId: 'keg',         ingredients: {'wood': 30, 'copper_bar': 1, 'iron_bar': 1}),
      'chest':       RecipeDef(id: 'chest',       name: '储物箱', resultId: 'chest',       ingredients: {'wood': 50}),
      'scarecrow':   RecipeDef(id: 'scarecrow',   name: '稻草人', resultId: 'scarecrow',   ingredients: {'wood': 10, 'coal': 1}),
      'wine_grape':  RecipeDef(id: 'wine_grape',  name: '葡萄酒', resultId: 'wine',        ingredients: {'grape': 1}),
      'juice_tomato': RecipeDef(id: 'juice_tomato', name: '番茄汁', resultId: 'juice',     ingredients: {'tomato': 1}),
      'cheese':      RecipeDef(id: 'cheese',      name: '奶酪',   resultId: 'cheese',      ingredients: {'tomato': 0}), // placeholder
    });
  }

  // ─────────────────────────────────────────────
  // NPCs
  // ─────────────────────────────────────────────

  void _initNPCs() {
    npcs = Map.unmodifiable({
      'lin': NPCDef(
        id: 'lin',
        name: '小林',
        lovedGifts: {'grape', 'wine'},
        likedGifts: {'melon', 'flower'},
        hatedGifts: {'stone'},
        dialogues: {
          0: '你好！欢迎来到芯麓村，我叫小林。',
          1: '最近农活还顺利吗？',
          2: '谢谢你一直帮忙照看这个村子。',
          3: '你知道吗？这里的土地非常适合种葡萄。',
          4: '村里的老人们说，芯麓山上有古老的秘密...',
          5: '你和大家都成了好朋友呢！',
        },
      ),
      'mei': NPCDef(
        id: 'mei',
        name: '小美',
        lovedGifts: {'flower', 'chocolate'},
        likedGifts: {'berry', 'juice'},
        hatedGifts: {'coal'},
        dialogues: {
          0: '嗨！我是小美，在村里开杂货店。',
          1: '需要买种子或者卖东西吗？',
          2: '春天最适合种花了～',
          3: '最近进了些新货，来看看？',
          4: '你知道吗？给朋友送礼物可以增进感情哦。',
          5: '谢谢你的光顾！',
        },
      ),
      'lao_wang': NPCDef(
        id: 'lao_wang',
        name: '老王',
        lovedGifts: {'wine', 'fish'},
        likedGifts: {'pumpkin', 'potato'},
        hatedGifts: {'wild_herb'},
        dialogues: {
          0: '咳咳...我是老王，在这村子里住了大半辈子。',
          1: '钓鱼啊，最重要的是耐心。',
          2: '芯麓湖的鱼可是远近闻名的。',
          3: '年轻人，要不要跟我学两招钓鱼技巧？',
          4: '这片土地承载着太多回忆了...',
          5: '你让我想起了年轻时的自己。',
        },
      ),
    });
  }

  // ─────────────────────────────────────────────
  // Shops
  // ─────────────────────────────────────────────

  void _initShops() {
    shops = Map.unmodifiable({
      'general': [
        ShopItem(itemId: 'seed_turnip', price: 20),
        ShopItem(itemId: 'seed_potato', price: 50),
        ShopItem(itemId: 'seed_cabbage', price: 80),
        ShopItem(itemId: 'seed_rice', price: 40),
        ShopItem(itemId: 'seed_tomato', price: 50),
        ShopItem(itemId: 'seed_corn', price: 60),
        ShopItem(itemId: 'seed_pepper', price: 40),
        ShopItem(itemId: 'seed_melon', price: 100),
        ShopItem(itemId: 'seed_pumpkin', price: 100),
        ShopItem(itemId: 'seed_carrot', price: 30),
        ShopItem(itemId: 'seed_grape', price: 90),
        ShopItem(itemId: 'seed_wheat', price: 25),
        ShopItem(itemId: 'fertilizer', price: 50),
      ],
      'carpenter': [
        ShopItem(itemId: 'wood', price: 10),
        ShopItem(itemId: 'stone', price: 10),
        ShopItem(itemId: 'coal', price: 25),
        ShopItem(itemId: 'copper_ore', price: 30),
        ShopItem(itemId: 'iron_ore', price: 60),
      ],
    });
  }
}
