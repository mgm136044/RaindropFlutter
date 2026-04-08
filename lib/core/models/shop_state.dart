import 'package:uuid/uuid.dart';

class StickerPlacement {
  final String id;
  final String itemID;
  double relativeX;
  double relativeY;

  StickerPlacement({
    String? id,
    required this.itemID,
    required this.relativeX,
    required this.relativeY,
  }) : id = id ?? const Uuid().v4();

  factory StickerPlacement.fromJson(Map<String, dynamic> json) {
    return StickerPlacement(
      id: json['id'] as String,
      itemID: json['itemID'] as String,
      relativeX: (json['relativeX'] as num).toDouble(),
      relativeY: (json['relativeY'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'itemID': itemID,
      'relativeX': relativeX,
      'relativeY': relativeY,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StickerPlacement &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class ShopState {
  int totalBucketsEarned;
  int totalBucketsSpent;
  Set<String> purchasedItemIDs;
  List<StickerPlacement> placements;
  int totalFocusMinutes;
  int consecutiveFocusDays;
  String? lastFocusDateKey;

  int get balance => totalBucketsEarned - totalBucketsSpent;

  static const String storageFilename = 'shop_state.json';

  ShopState({
    this.totalBucketsEarned = 0,
    this.totalBucketsSpent = 0,
    Set<String>? purchasedItemIDs,
    List<StickerPlacement>? placements,
    this.totalFocusMinutes = 0,
    this.consecutiveFocusDays = 0,
    this.lastFocusDateKey,
  })  : purchasedItemIDs = purchasedItemIDs ?? {},
        placements = placements ?? [];

  factory ShopState.fromJson(Map<String, dynamic> json) {
    return ShopState(
      totalBucketsEarned: json['totalBucketsEarned'] as int,
      totalBucketsSpent: json['totalBucketsSpent'] as int,
      purchasedItemIDs:
          Set<String>.from(json['purchasedItemIDs'] as List<dynamic>),
      placements: (json['placements'] as List<dynamic>)
          .map((e) => StickerPlacement.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalFocusMinutes: json['totalFocusMinutes'] as int? ?? 0,
      consecutiveFocusDays: json['consecutiveFocusDays'] as int? ?? 0,
      lastFocusDateKey: json['lastFocusDateKey'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalBucketsEarned': totalBucketsEarned,
      'totalBucketsSpent': totalBucketsSpent,
      'purchasedItemIDs': purchasedItemIDs.toList(),
      'placements': placements.map((e) => e.toJson()).toList(),
      'totalFocusMinutes': totalFocusMinutes,
      'consecutiveFocusDays': consecutiveFocusDays,
      'lastFocusDateKey': lastFocusDateKey,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShopState &&
          runtimeType == other.runtimeType &&
          totalBucketsEarned == other.totalBucketsEarned &&
          totalBucketsSpent == other.totalBucketsSpent;

  @override
  int get hashCode => Object.hash(totalBucketsEarned, totalBucketsSpent);
}
