import '../models/habit_widget.dart';

abstract class HabitWidgetRepository {
  // Widget data operations
  Future<WidgetData> getWidgetData();
  Future<void> updateWidgetData(WidgetData data);
  Stream<WidgetData> watchWidgetData();

  // Widget-specific habit operations
  Future<void> updateHabitCompletionFromWidget(int habitId, bool isCompleted);
  Future<List<WidgetHabit>> getTodayHabitsForWidget();

  // Widget maintenance
  Future<void> refreshWidget();
}