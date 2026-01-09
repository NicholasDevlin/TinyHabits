import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:home_widget/home_widget.dart';
import '../../features/habit/domain/repositories/habit_widget_repository.dart';
import '../../features/habit/data/repositories/habit_widget_repository_impl.dart';
import '../../features/habit/domain/models/habit_widget.dart';

class SimpleWidgetService {
  final HabitWidgetRepository _widgetRepository;
  bool _isInitialized = false;
  static const String _widgetDataKey = 'streakly_habits_widget_data';
  static const MethodChannel _widgetChannel = MethodChannel('com.example.streakly/widget');

  // Singleton instance
  static SimpleWidgetService? _instance;

  SimpleWidgetService._(this._widgetRepository) {
    _setupMethodChannel();
  }

  factory SimpleWidgetService(HabitWidgetRepository widgetRepository) {
    return _instance ??= SimpleWidgetService._(widgetRepository);
  }

  void _setupMethodChannel() {
    _widgetChannel.setMethodCallHandler((MethodCall call) async {
      switch (call.method) {
        case 'onHabitWidgetClicked':
          final int habitId = call.arguments['habitId'];
          await _handleHabitWidgetClick(habitId);
          break;
        default:
          throw PlatformException(code: 'Unimplemented', details: 'Method ${call.method} not implemented');
      }
    });
  }

  Future<void> _handleHabitWidgetClick(int habitId) async {
    try {
      // Get the habit to check current completion status
      final habits = await _widgetRepository.getTodayHabitsForWidget();
      final targetHabit = habits.cast<WidgetHabit?>().firstWhere((h) => h?.id == habitId, orElse: () => null);

      if (targetHabit == null) {
        return;
      }

      // Toggle completion status
      final newCompletionStatus = !targetHabit.isCompletedToday;

      // Mark habit as completed using widget repository
      await _widgetRepository.updateHabitCompletionFromWidget(habitId, newCompletionStatus);

      // Update widget to reflect changes
      await updateWidgetData();
    } catch (e) {
      print('Error handling widget click for habit $habitId: $e');
    }
  }

  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    _isInitialized = true;
    // Initial widget data update
    await updateWidgetData();
  }

  Future<void> updateWidgetData() async {
    try {
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

      // Update home_widget for actual home screen widget updates
      await HomeWidget.updateWidget(
        name: 'HabitHomeWidget',
        androidName: 'HabitWidgetProvider',
        iOSName: 'StreaklyWidget',
      );

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
    } catch (e) {
      print('Error cleaning up old widget data: $e');
    }
  }

  Future<void> onHabitChanged() async {
    await updateWidgetData();
  }

  // Consolidated habit change methods
  Future<void> onHabitCreated() async => onHabitChanged();
  Future<void> onHabitDeleted() async => onHabitChanged();
  Future<void> onHabitCompletionChanged() async => onHabitChanged();

  void dispose() {
    // Cleanup if needed
  }
}

// Provider for the simple widget service
final simpleWidgetServiceProvider = Provider<SimpleWidgetService>((ref) {
  final widgetRepository = ref.watch(habitWidgetRepositoryProvider);

  // Use singleton to prevent multiple instances
  final service = SimpleWidgetService(widgetRepository);

  return service;
});

// Provider to initialize the simple service
final simpleWidgetInitializationProvider = FutureProvider<void>((ref) async {
  final service = ref.watch(simpleWidgetServiceProvider);
  await service.initialize();
});
