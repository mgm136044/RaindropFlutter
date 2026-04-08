import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:raindrop_flutter/core/models/bucket_skin.dart';
import 'package:raindrop_flutter/core/models/calendar_day.dart';
import 'package:raindrop_flutter/core/services/date_service.dart';
import 'package:raindrop_flutter/core/utils/time_formatter.dart';
import 'package:raindrop_flutter/features/history/mini_bucket_view.dart';
import 'package:raindrop_flutter/shared/theme/app_colors.dart';

class WeeklyDensityView extends StatefulWidget {
  final Map<String, int> dailyData;
  final Map<String, int> dailyBucketCounts;
  final DateService dateService;
  final BucketSkin skin;

  const WeeklyDensityView({
    super.key,
    required this.dailyData,
    required this.dailyBucketCounts,
    required this.dateService,
    required this.skin,
  });

  @override
  State<WeeklyDensityView> createState() => _WeeklyDensityViewState();
}

class _WeeklyDensityViewState extends State<WeeklyDensityView> {
  int _weekOffset = 0;
  bool _animatedFill = false;

  static const _dayLabels = ['월', '화', '수', '목', '금', '토', '일'];
  static final _weekRangeFormatter = DateFormat('M/d', 'ko_KR');
  static final _dayKeyFormatter = DateFormat('yyyy-MM-dd', 'ko_KR');

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) setState(() => _animatedFill = true);
    });
  }

  List<CalendarDay> get _weekDays {
    final today = DateTime.now();
    final startOfWeek = today.add(Duration(days: _weekOffset * 7));
    // Find Monday of the week
    final monday = startOfWeek.subtract(
        Duration(days: startOfWeek.weekday - 1));

    return List.generate(7, (offset) {
      final date = DateTime(monday.year, monday.month, monday.day + offset);
      final key = _dayKeyFormatter.format(date);
      final seconds = widget.dailyData[key] ?? 0;
      final buckets = widget.dailyBucketCounts[key] ?? 0;
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
      return CalendarDay(
        dateKey: key,
        totalSeconds: seconds,
        bucketCount: buckets,
        level: level,
        fillRatio: fillRatio,
      );
    });
  }

  int get _weekBucketTotal =>
      _weekDays.fold(0, (acc, d) => acc + d.bucketCount);

  int get _weekTotalSeconds =>
      _weekDays.fold(0, (acc, d) => acc + d.totalSeconds);

  String get _weekRangeText {
    if (_weekDays.isEmpty) return '';
    final today = DateTime.now();
    final startOfWeek = today.add(Duration(days: _weekOffset * 7));
    final monday = startOfWeek.subtract(
        Duration(days: startOfWeek.weekday - 1));
    final sunday = monday.add(const Duration(days: 6));
    return '${_weekRangeFormatter.format(monday)} ~ ${_weekRangeFormatter.format(sunday)}';
  }

  @override
  Widget build(BuildContext context) {
    final days = _weekDays;
    return Column(
      children: [
        const SizedBox(height: 16),
        // Week navigator
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              IconButton(
                onPressed: _weekOffset > -12
                    ? () {
                        setState(() {
                          _weekOffset -= 1;
                          _animatedFill = false;
                        });
                        Future.delayed(const Duration(milliseconds: 100), () {
                          if (mounted) setState(() => _animatedFill = true);
                        });
                      }
                    : null,
                icon: const Icon(Icons.chevron_left),
                iconSize: 18,
              ),
              const Spacer(),
              Text(
                _weekRangeText,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryText(context),
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: _weekOffset < 0
                    ? () {
                        setState(() {
                          _weekOffset += 1;
                          _animatedFill = false;
                        });
                        Future.delayed(const Duration(milliseconds: 100), () {
                          if (mounted) setState(() => _animatedFill = true);
                        });
                      }
                    : null,
                icon: const Icon(Icons.chevron_right),
                iconSize: 18,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // 7 buckets side by side
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(days.length, (index) {
              final day = days[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Column(
                  children: [
                    SizedBox(
                      width: 52,
                      height: 52,
                      child: MiniBucketView(
                        fillRatio:
                            _animatedFill ? day.fillRatio : 0,
                        skin: widget.skin,
                        tappable: true,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _dayLabels[index],
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.secondaryText(context),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      TimeFormatter.compactDuration(day.totalSeconds),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: AppColors.secondaryText(context),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 16),
        // Summary
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.water_drop, size: 14, color: AppColors.accent(context)),
            const SizedBox(width: 4),
            Text(
              '양동이 $_weekBucketTotal개',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.accent(context),
              ),
            ),
            const SizedBox(width: 16),
            Icon(Icons.access_time,
                size: 14, color: AppColors.secondaryText(context)),
            const SizedBox(width: 4),
            Text(
              TimeFormatter.compactDuration(_weekTotalSeconds),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.secondaryText(context),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
