import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'habit.dart';

part 'habit_widget.freezed.dart';
part 'habit_widget.g.dart';

@freezed
class WidgetHabit with _$WidgetHabit {
  const factory WidgetHabit({
    required int id,
    required String title,
    required bool isCompletedToday,
    required List<int> targetDays,
    String? reminderTime,
  }) = _WidgetHabit;

  factory WidgetHabit.fromHabit(Habit habit) {
    return WidgetHabit(
      id: habit.id,
      title: habit.title,
      isCompletedToday: habit.isCompletedToday,
      targetDays: habit.targetDays,
      reminderTime: habit.reminderTime,
    );
  }

  factory WidgetHabit.fromJson(Map<String, dynamic> json) => _$WidgetHabitFromJson(json);
}

@freezed
class WidgetData with _$WidgetData {
  const factory WidgetData({
    required List<WidgetHabit> habits,
    required DateTime lastUpdated,
    required int totalHabits,
    required int completedHabits,
  }) = _WidgetData;

  factory WidgetData.fromJson(Map<String, dynamic> json) => _$WidgetDataFromJson(json);
}

@freezed
class WidgetUpdateRequest with _$WidgetUpdateRequest {
  const factory WidgetUpdateRequest({
    required int habitId,
    required bool isCompleted,
    required DateTime timestamp,
  }) = _WidgetUpdateRequest;

  factory WidgetUpdateRequest.fromJson(Map<String, dynamic> json) => _$WidgetUpdateRequestFromJson(json);
}