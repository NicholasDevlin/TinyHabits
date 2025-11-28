import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/habit/presentation/providers/habit_providers.dart';

class WidgetActionHandler {
  static const _channel = MethodChannel('com.example.tiny_wins/widget');
  static ProviderContainer? _container;

  static void initialize(ProviderContainer? container) {
    _container = container;
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  static Future<dynamic> _handleMethodCall(MethodCall call) async {
    try {
      if (call.method != 'getInitialHabitAction') {
        throw PlatformException(code: 'Unimplemented', details: 'Method ${call.method} not implemented');
      }

      final data = call.arguments as Map<String, dynamic>?;
      if (data == null || _container == null) return false;

      await _completeHabit(data['habitId'] as int, data['action'] as String);

      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<void> _completeHabit(int habitId, String action) async {
    if (!['toggle_habit', 'mark_complete'].contains(action)) return;

    try {
      final controller = _container!.read(habitControllerProvider.notifier);
      await controller.markHabitCompleted(habitId, true);
    } catch (e) {
      print('Habit completion error: $e');
    }
  }
}