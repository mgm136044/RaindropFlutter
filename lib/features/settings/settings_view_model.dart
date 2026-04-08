import 'package:flutter/foundation.dart';
import 'package:raindrop_flutter/core/models/app_settings.dart';
import 'package:raindrop_flutter/core/repositories/settings_repository.dart';

class SettingsViewModel extends ChangeNotifier {
  final SettingsRepository _repository;

  AppSettings settings;
  String? latestError;

  SettingsViewModel({required SettingsRepository repository})
      : _repository = repository,
        settings = AppSettings.defaults();

  Future<void> loadSettings() async {
    settings = await _repository.load();
    notifyListeners();
  }

  Future<void> save() async {
    try {
      await _repository.save(settings);
      latestError = null;
    } catch (_) {
      latestError = '설정 저장에 실패했습니다.';
    }
    notifyListeners();
  }

  Future<void> reload() async {
    settings = await _repository.load();
    notifyListeners();
  }
}
