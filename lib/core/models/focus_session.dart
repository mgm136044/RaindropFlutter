import 'package:uuid/uuid.dart';

class FocusSession {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final int durationSeconds;
  final String dateKey;
  final int? goalSeconds;

  FocusSession({
    String? id,
    required this.startTime,
    required this.endTime,
    required this.durationSeconds,
    required this.dateKey,
    this.goalSeconds,
  }) : id = id ?? const Uuid().v4();

  factory FocusSession.fromJson(Map<String, dynamic> json) {
    return FocusSession(
      id: json['id'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      durationSeconds: json['durationSeconds'] as int,
      dateKey: json['dateKey'] as String,
      goalSeconds: json['goalSeconds'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'durationSeconds': durationSeconds,
      'dateKey': dateKey,
      'goalSeconds': goalSeconds,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FocusSession &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
