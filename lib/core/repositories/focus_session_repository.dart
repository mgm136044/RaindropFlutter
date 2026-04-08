import 'package:flutter/foundation.dart';
import 'package:raindrop_flutter/core/models/focus_session.dart';
import 'package:raindrop_flutter/core/storage/json_file_store.dart';
import 'package:raindrop_flutter/core/utils/app_constants.dart';

class FocusSessionRepository extends ChangeNotifier {
  final JsonFileStore _fileStore;

  FocusSessionRepository({required JsonFileStore fileStore})
      : _fileStore = fileStore;

  Future<List<FocusSession>> fetchAll() async {
    final sessions = await _fileStore.load<List<FocusSession>>(
      AppConstants.storageFilename,
      (json) => (json as List<dynamic>)
          .map((e) => FocusSession.fromJson(e as Map<String, dynamic>))
          .toList(),
      orElse: () => [],
    );
    sessions.sort((a, b) => b.startTime.compareTo(a.startTime));
    return sessions;
  }

  Future<List<FocusSession>> fetchByDateKey(String dateKey) async {
    final all = await fetchAll();
    return all.where((s) => s.dateKey == dateKey).toList();
  }

  Future<void> save(FocusSession session) async {
    final sessions = await fetchAll();
    sessions.add(session);
    sessions.sort((a, b) => b.startTime.compareTo(a.startTime));
    await _fileStore.save(
      AppConstants.storageFilename,
      sessions.map((s) => s.toJson()).toList(),
    );
    notifyListeners();
  }
}
