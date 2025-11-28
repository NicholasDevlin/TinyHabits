import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/app_database.dart';
import '../../features/habit/domain/repositories/habit_widget_repository.dart';
import '../../features/habit/data/repositories/habit_widget_repository_impl.dart';

class SimpleWidgetService {
  final HabitWidgetRepository _widgetRepository;
  bool _isInitialized = false;
  static const String _widgetDataKey = 'tinywins_habits_widget_data';

  // Singleton instance
  static SimpleWidgetService? _instance;

  SimpleWidgetService._(this._widgetRepository);

  factory SimpleWidgetService(HabitWidgetRepository widgetRepository) {
    return _instance ??= SimpleWidgetService._(widgetRepository);
  }

  Future<void> initialize() async {
    if (_isInitialized) {
      print('SimpleWidgetService already initialized, skipping...');
      return;
    }

    print('SimpleWidgetService initialized');
    _isInitialized = true;
    // Initial widget data update
    await updateWidgetData();
  }

  Future<void> updateWidgetData() async {
    try {
      // Get today's habits
      final habits = await _widgetRepository.getTodayHabitsForWidget();
      final completedCount = habits.where((h) => h.isCompletedToday).length;

      // Prepare widget data in the format expected by Android widget
      final widgetData = {
        'habits': habits.map((habit) => {
          'id': habit.id,
          'title': habit.title,
          'isCompletedToday': habit.isCompletedToday,
        }).toList(),
        'totalHabits': habits.length,
        'completedHabits': completedCount,
        'lastUpdated': DateTime.now().toIso8601String(),
      };

      // Save to SharedPreferences in the format the Android widget expects
      final prefs = await SharedPreferences.getInstance();

      // Clean up old duplicate widget data first
      await _cleanupOldWidgetData(prefs);

      // Only save once to the main key that Android widget can find
      await prefs.setString('$_widgetDataKey', jsonEncode(widgetData));

      // Also save with the flutter. prefix for compatibility with Android widget
      await prefs.setString('flutter.$_widgetDataKey', jsonEncode(widgetData));

      print('Widget data updated: ${habits.length} habits, $completedCount completed');

      // Also update the repository's data
      await _widgetRepository.refreshWidget();

    } catch (e) {
      print('Error updating widget data: $e');
    }
  }

  Future<void> _cleanupOldWidgetData(SharedPreferences prefs) async {
    try {
      // Remove old widget data entries that were causing duplication
      for (int widgetId = 0; widgetId < 10; widgetId++) {
        await prefs.remove('flutter.HabitWidgetPrefs_$widgetId.widget_data');
      }
      print('Cleaned up old widget data entries');
    } catch (e) {
      print('Error cleaning up old widget data: $e');
    }
  }

  Future<void> onHabitChanged() async {
    await updateWidgetData();
  }

  Future<void> onHabitCreated() async {
    await updateWidgetData();
  }

  Future<void> onHabitDeleted() async {
    await updateWidgetData();
  }

  Future<void> onHabitCompletionChanged() async {
    await updateWidgetData();
  }

  void dispose() {
    // Cleanup if needed
  }
}

// Provider for the simple widget service
final simpleWidgetServiceProvider = Provider<SimpleWidgetService>((ref) {
  final widgetRepository = ref.watch(habitWidgetRepositoryProvider);

  // Use singleton to prevent multiple instances
  final service = SimpleWidgetService(widgetRepository);

  // Don't dispose in provider since it's a singleton managed elsewhere

  return service;
});

// Provider to initialize the simple service
final simpleWidgetInitializationProvider = FutureProvider<void>((ref) async {
  final service = ref.watch(simpleWidgetServiceProvider);
  await service.initialize();
});