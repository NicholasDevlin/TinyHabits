import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/habit_repository_impl.dart';
import '../../domain/models/habit.dart';
import '../../../../core/services/notification_service.dart';

part 'habit_providers.g.dart';

// Provider for today's habits
@riverpod
Future<List<Habit>> todayHabits(TodayHabitsRef ref) async {
  final repository = ref.watch(habitRepositoryProvider);

  return await repository.getHabitsForToday();
}

// Provider for all habits
@riverpod
Future<List<Habit>> allHabits(AllHabitsRef ref) async {
  final repository = ref.watch(habitRepositoryProvider);

  return await repository.getAllHabits();
}

// Provider for a specific habit
@riverpod
Future<Habit?> habit(HabitRef ref, int habitId) async {
  final repository = ref.watch(habitRepositoryProvider);
  return await repository.getHabitById(habitId);
}

// Provider for habit completed dates (for calendar)
@riverpod
Future<List<DateTime>> habitCompletedDates(HabitCompletedDatesRef ref, int habitId) async {
  final repository = ref.watch(habitRepositoryProvider);
  return await repository.getCompletedDates(habitId);
}

// Habit controller for managing habit operations
@riverpod
class HabitController extends _$HabitController {
  @override
  FutureOr<void> build() {
    // No initial state needed
  }

  Future<void> createHabit(CreateHabitRequest request) async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(habitRepositoryProvider);
      final habitId = await repository.createHabit(request);

      // Schedule notifications for the new habit
      await NotificationService.scheduleHabitReminder(
        habitId: habitId,
        habitTitle: request.title,
        reminderTime: request.reminderTime,
        targetDays: request.targetDays,
      );

      // Invalidate providers to refresh the UI
      ref.invalidate(todayHabitsProvider);
      ref.invalidate(allHabitsProvider);
      
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> markHabitCompleted(int habitId, bool isCompleted) async {
    try {
      final repository = ref.read(habitRepositoryProvider);
      final today = DateTime.now();
      await repository.markHabitCompleted(habitId, today, isCompleted);

      // Invalidate providers to refresh the UI
      ref.invalidate(todayHabitsProvider);
      ref.invalidate(allHabitsProvider);
      ref.invalidate(habitProvider(habitId));
      ref.invalidate(habitCompletedDatesProvider(habitId));
    } catch (error) {
      rethrow;
    }
  }

  Future<void> updateHabit(int habitId, CreateHabitRequest request) async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(habitRepositoryProvider);

      final existingHabit = await repository.getHabitById(habitId);
      if (existingHabit == null) {
        throw Exception('Habit not found');
      }

      final updatedHabit = Habit(
        id: habitId,
        title: request.title,
        description: request.description,
        reminderTime: request.reminderTime,
        targetDays: request.targetDays,
        createdAt: existingHabit.createdAt,
        isCompletedToday: existingHabit.isCompletedToday,
        currentStreak: existingHabit.currentStreak,
        totalCompletions: existingHabit.totalCompletions,
      );

      await repository.updateHabit(updatedHabit);

      // Reschedule notifications for the updated habit
      await NotificationService.rescheduleHabitReminder(
        habitId: habitId,
        habitTitle: request.title,
        reminderTime: request.reminderTime,
        targetDays: request.targetDays,
      );

      // Invalidate providers to refresh the UI
      ref.invalidate(todayHabitsProvider);
      ref.invalidate(allHabitsProvider);
      ref.invalidate(habitProvider(habitId));

      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> deleteHabit(int habitId) async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(habitRepositoryProvider);

      // Cancel all notifications for this habit
      await NotificationService.cancelHabitReminders(habitId);

      await repository.deleteHabit(habitId);

      // Invalidate providers to refresh the UI
      ref.invalidate(todayHabitsProvider);
      ref.invalidate(allHabitsProvider);

      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }
}