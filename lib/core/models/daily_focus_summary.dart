import 'focus_session.dart';

class DailyFocusSummary {
  final String dateKey;
  final String displayDate;
  final int totalSeconds;
  final List<FocusSession> sessions;

  String get id => dateKey;

  const DailyFocusSummary({
    required this.dateKey,
    required this.displayDate,
    required this.totalSeconds,
    required this.sessions,
  });
}
