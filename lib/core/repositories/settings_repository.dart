import 'package:flutter/foundation.dart';
import 'package:raindrop_flutter/core/models/app_settings.dart';
import 'package:raindrop_flutter/core/storage/json_file_store.dart';

class SettingsRepository extends ChangeNotifier {
  final JsonFileStore _fileStore;

  SettingsRepository({required JsonFileStore fileStore})
      : _fileStore = fileStore;

  Future<AppSettings> load() async {
    return await _fileStore.load<AppSettings>(
      AppSettings.storageFilename,
      (json) => AppSettings.fromJson(json as Map<String, dynamic>),
      orElse: () => AppSettings.defaults(),
    );
  }

  Future<void> save(AppSettings settings) async {
    await _fileStore.save(AppSettings.storageFilename, settings.toJson());
    notifyListeners();
  }
}
