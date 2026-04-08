import 'package:intl/intl.dart';

class DateService {
  final DateFormat _keyFormatter;
  final DateFormat _sectionFormatter;
  final DateFormat _timeFormatter;

  DateService()
      : _keyFormatter = DateFormat('yyyy-MM-dd', 'ko_KR'),
        _sectionFormatter = DateFormat('M월 d일 EEEE', 'ko_KR'),
        _timeFormatter = DateFormat('HH:mm', 'ko_KR');

  String dateKey(DateTime date) {
    return _keyFormatter.format(date);
  }

  String historyTitle(String dateKey) {
    final date = _keyFormatter.parse(dateKey);
    return _sectionFormatter.format(date);
  }

  String sessionTimeRange(DateTime start, DateTime end) {
    return '${_timeFormatter.format(start)} - ${_timeFormatter.format(end)}';
  }

  String weekKey(DateTime date) {
    // ISO week number calculation
    final thursday = date.add(Duration(days: DateTime.thursday - date.weekday));
    final jan1 = DateTime(thursday.year, 1, 1);
    final weekOfYear =
        ((thursday.difference(jan1).inDays) / 7).ceil() + 1;
    return '${thursday.year}-W$weekOfYear';
  }
}
