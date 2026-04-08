import 'package:flutter/foundation.dart';
import 'package:raindrop_flutter/core/models/daily_focus_summary.dart';
import 'package:raindrop_flutter/core/models/focus_session.dart';
import 'package:raindrop_flutter/core/repositories/focus_session_repository.dart';
import 'package:raindrop_flutter/core/services/date_service.dart';

class HistoryViewModel extends ChangeNotifier {
  final FocusSessionRepository _repository;
  final DateService dateService;

  List<DailyFocusSummary> summaries = [];
  String? latestError;

  HistoryViewModel({
    required FocusSessionRepository repository,
    required this.dateService,
  }) : _repository = repository {
    _repository.addListener(_onDataChanged);
    load();
  }

  bool get isEmpty => summaries.isEmpty;

  Map<String, int> get dailyTotals {
    return {for (final s in summaries) s.dateKey: s.totalSeconds};
  }

  /// Per-session goalSeconds based daily bucket counts.
  /// Sessions with null goalSeconds (infinity mode) are excluded.
  Map<String, int> get dailyBucketCounts {
    final counts = <String, int>{};
    for (final summary in summaries) {
      var dayBuckets = 0;
      for (final session in summary.sessions) {
        final goal = session.goalSeconds;
        if (goal == null) continue;
        if (goal > 0 && session.durationSeconds >= goal) {
          dayBuckets += 1;
        }
      }
      counts[summary.dateKey] = dayBuckets;
    }
    return counts;
  }

  Future<void> load() async {
    try {
      final sessions = await _repository.fetchAll();
      final grouped = <String, List<FocusSession>>{};
      for (final session in sessions) {
        grouped.putIfAbsent(session.dateKey, () => []).add(session);
      }

      final sortedKeys = grouped.keys.toList()
        ..sort((a, b) => b.compareTo(a));
      summaries = sortedKeys.map((key) {
        final items = grouped[key]!..sort((a, b) => b.startTime.compareTo(a.startTime));
        final total = items.fold<int>(0, (acc, s) => acc + s.durationSeconds);
        return DailyFocusSummary(
          dateKey: key,
          displayDate: dateService.historyTitle(key),
          totalSeconds: total,
          sessions: items,
        );
      }).toList();
      latestError = null;
    } catch (_) {
      summaries = [];
      latestError = '기록을 불러오지 못했습니다.';
    }
    notifyListeners();
  }

  String timeRangeText(FocusSession session) {
    return dateService.sessionTimeRange(session.startTime, session.endTime);
  }

  void _onDataChanged() {
    load();
  }

  @override
  void dispose() {
    _repository.removeListener(_onDataChanged);
    super.dispose();
  }
}
