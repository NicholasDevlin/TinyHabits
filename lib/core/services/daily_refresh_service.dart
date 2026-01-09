import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/habit/presentation/providers/habit_providers.dart';

class DailyRefreshService {
  Timer? _midnightTimer;
  final Ref _ref;
  
  DailyRefreshService(this._ref);

  void initialize() {
    _scheduleMidnightRefresh();
  }

  void _scheduleMidnightRefresh() {
    // Cancel any existing timer
    _midnightTimer?.cancel();

    // Calculate time until next midnight
    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1, 0, 0, 0);
    final timeUntilMidnight = nextMidnight.difference(now);

    // Schedule the midnight refresh
    _midnightTimer = Timer(timeUntilMidnight, () {
      _performMidnightRefresh();
      // Schedule the next day's refresh
      _scheduleMidnightRefresh();
    });
  }

  void _performMidnightRefresh() {
    try {
      // Invalidate habit providers to trigger getAllHabits and getHabitsForToday
      _ref.invalidate(todayHabitsProvider);
      _ref.invalidate(allHabitsProvider);
    } catch (e) {
      print('Error during midnight refresh: $e');
    }
  }

  /// Dispose of the service
  void dispose() {
    _midnightTimer?.cancel();
    _midnightTimer = null;
  }
}

// Provider for the daily refresh service
final dailyRefreshServiceProvider = Provider<DailyRefreshService>((ref) {
  final service = DailyRefreshService(ref);
  service.initialize();
  
  ref.onDispose(() {
    service.dispose();
  });
  
  return service;
});
