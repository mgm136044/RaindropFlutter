class CalendarDay {
  final String dateKey;
  final int totalSeconds;
  final int bucketCount;
  final int level; // 0-4
  final double fillRatio; // 0.0 - 1.0

  const CalendarDay({
    required this.dateKey,
    required this.totalSeconds,
    required this.bucketCount,
    required this.level,
    required this.fillRatio,
  });
}
