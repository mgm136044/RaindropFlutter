import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:raindrop_flutter/core/models/environment_level.dart';
import 'package:raindrop_flutter/core/models/shop_catalog.dart';
import 'package:raindrop_flutter/core/models/shop_item.dart';
import 'package:raindrop_flutter/core/models/shop_state.dart';
import 'package:raindrop_flutter/core/models/weather_state.dart';
import 'package:raindrop_flutter/core/repositories/shop_repository.dart';

class ShopViewModel extends ChangeNotifier {
  final ShopRepository _repository;

  ShopState shopState;
  String? latestError;

  ShopViewModel({required ShopRepository repository})
      : _repository = repository,
        shopState = ShopState();

  Future<void> loadState() async {
    shopState = await _repository.load();
    notifyListeners();
  }

  int get balance => shopState.balance;

  List<ShopItem> get catalog => ShopCatalog.allItems;

  List<String> get categories => ShopCatalog.categories;

  List<ShopItem> items(String category) {
    return catalog.where((item) => item.category == category).toList();
  }

  bool isPurchased(ShopItem item) {
    return shopState.purchasedItemIDs.contains(item.id);
  }

  bool canAfford(ShopItem item) {
    return shopState.balance >= item.price;
  }

  void purchase(ShopItem item) {
    if (isPurchased(item) || !canAfford(item)) return;
    shopState.totalBucketsSpent += item.price;
    shopState.purchasedItemIDs.add(item.id);
    _saveState();
  }

  void addPlacement(StickerPlacement placement) {
    shopState.placements.add(placement);
    _saveState();
  }

  void removePlacement(String id) {
    shopState.placements.removeWhere((p) => p.id == id);
    _saveState();
  }

  void updatePlacementPosition(
      String id, double relativeX, double relativeY) {
    final index = shopState.placements.indexWhere((p) => p.id == id);
    if (index < 0) return;
    shopState.placements[index].relativeX =
        relativeX.clamp(0.05, 0.95);
    shopState.placements[index].relativeY =
        relativeY.clamp(0.05, 0.95);
    _saveState();
  }

  void removeAllPlacements() {
    shopState.placements.clear();
    _saveState();
  }

  void earnBucket() {
    shopState.totalBucketsEarned += 1;
    _saveState();
  }

  // -- Environment & Weather --

  EnvironmentStage get currentEnvironmentStage {
    return EnvironmentStage.stage(shopState.totalFocusMinutes);
  }

  WeatherCondition get currentWeather {
    return WeatherCondition.condition(shopState.consecutiveFocusDays);
  }

  int? get minutesToNextStage {
    final next = currentEnvironmentStage.nextStage;
    if (next == null) return null;
    return next.requiredTotalMinutes - shopState.totalFocusMinutes;
  }

  void recordFocusMinutes(int minutes, String dateKey) {
    shopState.totalFocusMinutes += minutes;

    final lastKey = shopState.lastFocusDateKey;
    if (lastKey != null) {
      if (lastKey == dateKey) {
        // Same day
      } else if (_isConsecutiveDay(lastKey, dateKey)) {
        shopState.consecutiveFocusDays += 1;
      } else {
        shopState.consecutiveFocusDays = 1;
      }
    } else {
      shopState.consecutiveFocusDays = 1;
    }
    shopState.lastFocusDateKey = dateKey;
    _saveState();
  }

  static final _dateKeyFormatter = DateFormat('yyyy-MM-dd');

  bool _isConsecutiveDay(String lastKey, String currentKey) {
    final lastDate = _dateKeyFormatter.tryParse(lastKey);
    final currentDate = _dateKeyFormatter.tryParse(currentKey);
    if (lastDate == null || currentDate == null) return false;
    return currentDate.difference(lastDate).inDays == 1;
  }

  Future<void> reload() async {
    shopState = await _repository.load();
    notifyListeners();
  }

  Future<void> _saveState() async {
    try {
      await _repository.save(shopState);
      latestError = null;
    } catch (_) {
      latestError = '상점 데이터 저장에 실패했습니다.';
    }
    notifyListeners();
  }
}
