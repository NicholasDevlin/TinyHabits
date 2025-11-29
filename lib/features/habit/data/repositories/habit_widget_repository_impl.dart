import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/models/habit_widget.dart';
import '../../domain/repositories/habit_widget_repository.dart';

class HabitWidgetRepositoryImpl implements HabitWidgetRepository {
  final AppDatabase _database;

  static const String _widgetDataKey = 'tinywins_habits_widget_data';

  HabitWidgetRepositoryImpl(this._database);

  @override
  Future<WidgetData> getWidgetData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedData = prefs.getString(_widgetDataKey);

      if (storedData != null) {
        final widgetData = WidgetData.fromJson(jsonDecode(storedData));
        // Return cached data if it's recent (within 5 minutes)
        if (DateTime.now().difference(widgetData.lastUpdated).inMinutes < 5) {
          return widgetData;
        }
      }

      // Always fetch fresh data if cache is expired or doesn't exist
      return await _getFreshWidgetData();
    } catch (e) {
      print('Error getting widget data: $e');
      return await _getFreshWidgetData();
    }
  }

  @override
  Future<void> updateWidgetData(WidgetData data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(data.toJson());
      await prefs.setString(_widgetDataKey, jsonString);
    } catch (e) {
      print('Error updating widget data: $e');
      rethrow;
    }
  }

  @override
  Stream<WidgetData> watchWidgetData() async* {
    while (true) {
      final data = await getWidgetData();
      yield data;
      await Future.delayed(const Duration(minutes: 10)); // Poll every 10 minutes for more responsive updates
    }
  }

  @override
  Future<void> updateHabitCompletionFromWidget(int habitId, bool isCompleted) async {
    // TODO: Implement widget habit completion functionality
    print('Widget habit completion not fully implemented yet');

    // Update widget after habit completion change
    await refreshWidget();
  }

  @override
  Future<List<WidgetHabit>> getTodayHabitsForWidget() async {
    // For now, get habits directly from database
    final today = DateTime.now();
    final todayWeekday = today.weekday; // 1=Monday, 7=Sunday

    final habitDataList = await _database.habitsDao.getAllHabits();
    final List<WidgetHabit> todayHabits = [];

    for (final habitData in habitDataList) {
      final targetDays = habitData.targetDays.split(',').map((e) => int.parse(e.trim())).toList();

      if (targetDays.contains(todayWeekday)) {
        // Calculate completion status for today
        final todayEntry = await _database.habitEntriesDao.getEntryForDate(habitData.id, today);
        final isCompleted = todayEntry?.isCompleted ?? false;

        todayHabits.add(WidgetHabit(
          id: habitData.id,
          title: habitData.title,
          isCompletedToday: isCompleted,
          targetDays: targetDays,
          reminderTime: habitData.reminderTime,
        ));
      }
    }

    // Sort habits: reminder time ascending, completed habits at bottom
    return _sortWidgetHabits(todayHabits);
  }

  @override
  Future<void> refreshWidget() async {
    try {
      await updateWidgetData(await _getFreshWidgetData());
    } catch (e) {
      print('Error refreshing widget: $e');
    }
  }

  @override
  Future<void> clearWidgetData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_widgetDataKey);
    } catch (e) {
      print('Error clearing widget data: $e');
    }
  }

  Future<WidgetData> _getFreshWidgetData() async {
    final habits = await getTodayHabitsForWidget();
    final completedCount = habits.where((h) => h.isCompletedToday).length;

    return WidgetData(
      habits: habits,
      lastUpdated: DateTime.now(),
      totalHabits: habits.length,
      completedHabits: completedCount,
    );
  }

  List<WidgetHabit> _sortWidgetHabits(List<WidgetHabit> habits) {
    return habits.toList()..sort((a, b) {
      // First, compare completion status - completed habits go to bottom
      if (a.isCompletedToday != b.isCompletedToday) {
        return a.isCompletedToday ? 1 : -1;
      }

      // If both have the same completion status, sort by reminder time
      final timeA = _parseWidgetTime(a.reminderTime);
      final timeB = _parseWidgetTime(b.reminderTime);
      return timeA.compareTo(timeB);
    });
  }

  DateTime _parseWidgetTime(String? timeString) {
    if (timeString == null || timeString.isEmpty) {
      // If no reminder time is set, treat it as very late in the day
      return DateTime(2023, 1, 1, 23, 59);
    }

    final parts = timeString.split(':');
    final hour = int.parse(parts[0]);
    final minute = parts.length > 1 ? int.parse(parts[1]) : 0;
    return DateTime(2023, 1, 1, hour, minute); // Use dummy date for time comparison
  }
}

// Provider for widget repository - simplified for now
final habitWidgetRepositoryProvider = Provider<HabitWidgetRepository>((ref) {
  // Create a simple repository instance without dependencies for now
  final database = ref.watch(databaseProvider);

  return HabitWidgetRepositoryImpl(database); // Remove habitRepository dependency for now
});