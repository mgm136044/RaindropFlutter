import 'shop_item.dart';

class ShopCatalog {
  ShopCatalog._();

  static const List<ShopItem> allItems = [
    // 기본
    ShopItem(
      id: 'sticker_star',
      name: '별',
      description: '반짝이는 별 스티커',
      price: 1,
      emoji: '\u2B50',
      category: '기본',
    ),
    ShopItem(
      id: 'sticker_heart',
      name: '하트',
      description: '따뜻한 하트 스티커',
      price: 1,
      emoji: '\u2764\uFE0F',
      category: '기본',
    ),
    ShopItem(
      id: 'sticker_fire',
      name: '불꽃',
      description: '열정의 불꽃',
      price: 2,
      emoji: '\uD83D\uDD25',
      category: '기본',
    ),
    ShopItem(
      id: 'sticker_sparkle',
      name: '반짝',
      description: '빛나는 반짝이',
      price: 1,
      emoji: '\u2728',
      category: '기본',
    ),

    // 자연
    ShopItem(
      id: 'sticker_flower',
      name: '꽃',
      description: '아름다운 꽃',
      price: 2,
      emoji: '\uD83C\uDF38',
      category: '자연',
    ),
    ShopItem(
      id: 'sticker_rainbow',
      name: '무지개',
      description: '행운의 무지개',
      price: 3,
      emoji: '\uD83C\uDF08',
      category: '자연',
    ),
    ShopItem(
      id: 'sticker_leaf',
      name: '나뭇잎',
      description: '싱그러운 나뭇잎',
      price: 1,
      emoji: '\uD83C\uDF40',
      category: '자연',
    ),
    ShopItem(
      id: 'sticker_sun',
      name: '해',
      description: '밝은 태양',
      price: 2,
      emoji: '\u2600\uFE0F',
      category: '자연',
    ),

    // 동물
    ShopItem(
      id: 'sticker_cat',
      name: '고양이',
      description: '귀여운 고양이',
      price: 3,
      emoji: '\uD83D\uDC31',
      category: '동물',
    ),
    ShopItem(
      id: 'sticker_dog',
      name: '강아지',
      description: '충성스러운 강아지',
      price: 3,
      emoji: '\uD83D\uDC36',
      category: '동물',
    ),
    ShopItem(
      id: 'sticker_fish',
      name: '물고기',
      description: '양동이 속 물고기',
      price: 2,
      emoji: '\uD83D\uDC1F',
      category: '동물',
    ),
    ShopItem(
      id: 'sticker_butterfly',
      name: '나비',
      description: '예쁜 나비',
      price: 2,
      emoji: '\uD83E\uDD8B',
      category: '동물',
    ),
  ];

  static List<String> get categories {
    final cats = allItems.map((e) => e.category).toSet().toList();
    cats.sort();
    return cats;
  }

  static ShopItem? item(String id) {
    try {
      return allItems.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }
}
