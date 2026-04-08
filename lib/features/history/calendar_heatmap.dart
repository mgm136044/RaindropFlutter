import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:raindrop_flutter/core/models/bucket_skin.dart';
import 'package:raindrop_flutter/core/models/calendar_day.dart';
import 'package:raindrop_flutter/core/services/date_service.dart';
import 'package:raindrop_flutter/core/utils/time_formatter.dart';
import 'package:raindrop_flutter/shared/theme/app_colors.dart';

class CalendarHeatmapView extends StatefulWidget {
  final Map<String, int> dailyData;
  final DateService dateService;
  final Map<String, int> dailyBucketCounts;
  final BucketSkin skin;

  const CalendarHeatmapView({
    super.key,
    required this.dailyData,
    required this.dateService,
    required this.dailyBucketCounts,
    this.skin = BucketSkin.wood,
  });

  @override
  State<CalendarHeatmapView> createState() => _CalendarHeatmapViewState();
}

class _CalendarHeatmapViewState extends State<CalendarHeatmapView> {
  late DateTime _displayedMonth;
  CalendarDay? _selectedDay;

  static const _cellSpacing = 4.0;
  static const _cellHeight = 40.0;
  static const _dayHeaders = ['월', '화', '수', '목', '금', '토', '일'];

  static final _monthYearFormatter = DateFormat('yyyy년 M월', 'ko_KR');
  static final _dayKeyFormatter = DateFormat('yyyy-MM-dd', 'ko_KR');

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _displayedMonth = DateTime(now.year, now.month);
  }

  bool get _isCurrentMonth {
    final now = DateTime.now();
    return _displayedMonth.year == now.year &&
        _displayedMonth.month == now.month;
  }

  List<DateTime> get _availableMonths {
    final now = DateTime.now();
    final current = DateTime(now.year, now.month);
    return List.generate(12, (i) {
      return DateTime(current.year, current.month - i);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.panelBackground(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '집중 달력',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildMonthNavigator(context),
          const SizedBox(height: 12),
          _buildDayOfWeekHeaders(context),
          const SizedBox(height: 4),
          _buildCalendarGrid(context),
          const SizedBox(height: 12),
          _buildLegendRow(context),
          if (_selectedDay != null) ...[
            const SizedBox(height: 12),
            _buildSelectedDayDetail(context, _selectedDay!),
          ],
        ],
      ),
    );
  }

  Widget _buildMonthNavigator(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, size: 14),
            onPressed: _previousMonth,
            iconSize: 14,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const Spacer(),
          PopupMenuButton<DateTime>(
            onSelected: (month) {
              setState(() {
                _displayedMonth = month;
                _selectedDay = null;
              });
            },
            itemBuilder: (_) => _availableMonths.map((month) {
              return PopupMenuItem(
                value: month,
                child: Text(_monthYearFormatter.format(month)),
              );
            }).toList(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _monthYearFormatter.format(_displayedMonth),
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.unfold_more,
                  size: 10,
                  color: AppColors.secondaryText(context),
                ),
              ],
            ),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(
              Icons.chevron_right,
              size: 14,
              color: _isCurrentMonth
                  ? AppColors.tertiaryText(context)
                  : null,
            ),
            onPressed: _isCurrentMonth ? null : _nextMonth,
            iconSize: 14,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildDayOfWeekHeaders(BuildContext context) {
    return Row(
      children: _dayHeaders.map((day) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: _cellSpacing / 2),
            child: SizedBox(
              height: 20,
              child: Center(
                child: Text(
                  day,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondaryText(context),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCalendarGrid(BuildContext context) {
    final weeks = _buildMonthWeeks();
    return Column(
      children: List.generate(weeks.length, (weekIndex) {
        return Padding(
          padding: EdgeInsets.only(top: weekIndex > 0 ? _cellSpacing : 0),
          child: Row(
            children: List.generate(7, (dayIndex) {
              final day = weeks[weekIndex][dayIndex];
              if (day == null) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: _cellSpacing / 2),
                    child: const SizedBox(height: _cellHeight),
                  ),
                );
              }
              return Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: _cellSpacing / 2),
                  child: _buildDayCell(context, day),
                ),
              );
            }),
          ),
        );
      }),
    );
  }

  Widget _buildDayCell(BuildContext context, CalendarDay day) {
    final isSelected = _selectedDay?.dateKey == day.dateKey;
    final now = DateTime.now();
    final todayKey = _dayKeyFormatter.format(now);
    final isToday = day.dateKey == todayKey;
    final dayNumber = int.tryParse(day.dateKey.split('-').last) ?? 0;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDay = _selectedDay?.dateKey == day.dateKey ? null : day;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: _cellHeight,
        decoration: BoxDecoration(
          color: _colorForLevel(context, day.level),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? AppColors.accent(context)
                : isToday
                    ? AppColors.accent(context).withValues(alpha: 0.5)
                    : day.level == 0
                        ? AppColors.calendarEmptyCellBorder(context)
                        : Colors.transparent,
            width: (isSelected || isToday) ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            '$dayNumber',
            style: TextStyle(
              fontSize: 14,
              fontWeight:
                  day.level > 0 ? FontWeight.bold : FontWeight.normal,
              color: day.level >= 3 ? Colors.white : null,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegendRow(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '적음',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: AppColors.secondaryText(context),
          ),
        ),
        const SizedBox(width: 6),
        for (int level = 0; level <= 4; level++) ...[
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: _colorForLevel(context, level),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          if (level < 4) const SizedBox(width: 3),
        ],
        const SizedBox(width: 6),
        Text(
          '많음',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: AppColors.secondaryText(context),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedDayDetail(BuildContext context, CalendarDay day) {
    final completedBuckets = widget.dailyBucketCounts[day.dateKey] ?? 0;
    final bucketEmoji =
        List.filled(completedBuckets.clamp(0, 10), '\u{1FAA3}').join();

    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          Text(
            widget.dateService.historyTitle(day.dateKey),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (day.totalSeconds == 0)
            Text(
              '이 날은 집중 기록이 없습니다.',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.secondaryText(context),
              ),
            )
          else
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '총 집중 시간',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.secondaryText(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      TimeFormatter.compactDuration(day.totalSeconds),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.accent(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '채운 양동이',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.secondaryText(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    completedBuckets > 0
                        ? Text(
                            '$bucketEmoji $completedBuckets개',
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          )
                        : Text(
                            '아직 없음',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.secondaryText(context),
                            ),
                          ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  // -- Navigation --

  void _previousMonth() {
    setState(() {
      _displayedMonth =
          DateTime(_displayedMonth.year, _displayedMonth.month - 1);
      _selectedDay = null;
    });
  }

  void _nextMonth() {
    if (_isCurrentMonth) return;
    setState(() {
      _displayedMonth =
          DateTime(_displayedMonth.year, _displayedMonth.month + 1);
      _selectedDay = null;
    });
  }

  // -- Data Building --

  List<List<CalendarDay?>> _buildMonthWeeks() {
    final firstOfMonth =
        DateTime(_displayedMonth.year, _displayedMonth.month, 1);
    final daysInMonth =
        DateTime(_displayedMonth.year, _displayedMonth.month + 1, 0).day;
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);

    // Monday-based offset: Mon=0 ... Sun=6
    final firstWeekday = firstOfMonth.weekday; // 1=Mon, 7=Sun
    final startOffset = firstWeekday - 1;

    final totalCells = startOffset + daysInMonth;
    final weekCount = (totalCells + 6) ~/ 7;

    final weeks = <List<CalendarDay?>>[];

    for (var week = 0; week < weekCount; week++) {
      final weekDays = <CalendarDay?>[];
      for (var dayOfWeek = 0; dayOfWeek < 7; dayOfWeek++) {
        final dayNumber = week * 7 + dayOfWeek - startOffset + 1;

        if (dayNumber < 1 || dayNumber > daysInMonth) {
          weekDays.add(null);
        } else {
          final date = DateTime(
              _displayedMonth.year, _displayedMonth.month, dayNumber);
          if (date.isAfter(todayStart)) {
            weekDays.add(null);
          } else {
            final key = _dayKeyFormatter.format(date);
            final seconds = widget.dailyData[key] ?? 0;
            final minutes = seconds ~/ 60;
            final level = minutes == 0
                ? 0
                : minutes < 15
                    ? 1
                    : minutes < 30
                        ? 2
                        : minutes < 60
                            ? 3
                            : 4;
            final fillRatio = (seconds / 60.0 / 240.0).clamp(0.0, 1.0);
            weekDays.add(CalendarDay(
              dateKey: key,
              totalSeconds: seconds,
              bucketCount: widget.dailyBucketCounts[key] ?? 0,
              level: level,
              fillRatio: fillRatio,
            ));
          }
        }
      }
      weeks.add(weekDays);
    }
    return weeks;
  }

  Color _colorForLevel(BuildContext context, int level) {
    switch (level) {
      case 0:
        return AppColors.calendarEmptyCell(context);
      case 1:
        return AppColors.accent(context).withValues(alpha: 0.25);
      case 2:
        return AppColors.accent(context).withValues(alpha: 0.50);
      case 3:
        return AppColors.accent(context).withValues(alpha: 0.75);
      default:
        return AppColors.accent(context);
    }
  }
}
