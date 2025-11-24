import 'package:freezed_annotation/freezed_annotation.dart';

part 'habit.freezed.dart';
part 'habit.g.dart';

@freezed
class Habit with _$Habit {
  const factory Habit({
    required int id,
    required String title,
    String? description,
    required String reminderTime, // "HH:mm" format
    required List<int> targetDays, // 1-7 (Monday to Sunday)
    required DateTime createdAt,
    @Default(false) bool isCompletedToday,
    @Default(0) int currentStreak,
    @Default(0) int totalCompletions,
  }) = _Habit;

  factory Habit.fromJson(Map<String, dynamic> json) => _$HabitFromJson(json);
}

@freezed
class HabitEntry with _$HabitEntry {
  const factory HabitEntry({
    required int id,
    required int habitId,
    required DateTime date,
    required bool isCompleted,
  }) = _HabitEntry;

  factory HabitEntry.fromJson(Map<String, dynamic> json) => _$HabitEntryFromJson(json);
}

@freezed
class CreateHabitRequest with _$CreateHabitRequest {
  const factory CreateHabitRequest({
    required String title,
    String? description,
    required String reminderTime,
    required List<int> targetDays,
  }) = _CreateHabitRequest;

  factory CreateHabitRequest.fromJson(Map<String, dynamic> json) => _$CreateHabitRequestFromJson(json);
}