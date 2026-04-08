import 'package:flutter/foundation.dart';
import 'package:raindrop_flutter/core/models/shop_state.dart';
import 'package:raindrop_flutter/core/storage/json_file_store.dart';

class ShopRepository extends ChangeNotifier {
  final JsonFileStore _fileStore;

  ShopRepository({required JsonFileStore fileStore})
      : _fileStore = fileStore;

  Future<ShopState> load() async {
    return await _fileStore.load<ShopState>(
      ShopState.storageFilename,
      (json) => ShopState.fromJson(json as Map<String, dynamic>),
      orElse: () => ShopState(),
    );
  }

  Future<void> save(ShopState state) async {
    await _fileStore.save(ShopState.storageFilename, state.toJson());
    notifyListeners();
  }
}
