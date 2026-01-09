import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/services/notification_service.dart';
import '../../domain/models/habit.dart';
import '../../domain/repositories/habit_repository.dart';

class HabitRepositoryImpl implements HabitRepository {
  final AppDatabase _database;

  HabitRepositoryImpl(this._database);

  @override
  Future<List<Habit>> getAllHabits() async {
    final habitData = await _database.habitsDao.getAllHabits();
    final List<Habit> habits = [];

    for (final data in habitData) {
      final habit = await _mapHabitDataToHabit(data);
      habits.add(habit);
    }

    return habits;
  }

  @override
  Future<Habit?> getHabitById(int id) async {
    final habitData = await _database.habitsDao.getHabitById(id);
    if (habitData == null) return null;

    return _mapHabitDataToHabit(habitData);
  }

  @override
  Future<List<Habit>> getHabitsForToday() async {
    final habitData = await _database.habitsDao.getHabitsForToday();
    final List<Habit> habits = [];

    for (final data in habitData) {
      final habit = await _mapHabitDataToHabit(data);
      habits.add(habit);
    }

    return habits;
  }

  @override
  Future<int> createHabit(CreateHabitRequest request) async {
    final companion = HabitsTableCompanion(
      title: Value(request.title),
      description: Value(request.description),
      reminderTime: Value(request.reminderTime),
      targetDays: Value(request.targetDays.join(',')),
    );

    final habitId = await _database.habitsDao.createHabit(companion);

    // Schedule notifications for the new habit
    try {
      await _scheduleNotificationsForHabit(habitId, request);
    } catch (e) {
      print('Failed to schedule notifications: $e');
    }

    return habitId;
  }

  Future<void> _scheduleNotificationsForHabit(int habitId, CreateHabitRequest request) async {
    await NotificationService.scheduleHabitReminder(
      habitId: habitId,
      habitTitle: request.title,
      reminderTime: request.reminderTime,
      targetDays: request.targetDays,
    );
  }

  @override
  Future<void> updateHabit(Habit habit) async {
    final habitData = HabitData(
      id: habit.id,
      title: habit.title,
      description: habit.description,
      reminderTime: habit.reminderTime,
      targetDays: habit.targetDays.join(','),
      createdAt: habit.createdAt,
    );

    await _database.habitsDao.updateHabit(habitData);
  }

  @override
  Future<void> deleteHabit(int id) async {
    await _database.habitsDao.deleteHabit(id);
  }

  @override
  Future<void> markHabitCompleted(int habitId, DateTime date, bool isCompleted) async {
    await _database.habitEntriesDao.markHabitCompleted(habitId, date, isCompleted);
  }

  @override
  Future<bool> isHabitCompletedForDate(int habitId, DateTime date) async {
    final entry = await _database.habitEntriesDao.getEntryForDate(habitId, date);

    return entry?.isCompleted ?? false;
  }

  @override
  Future<int> calculateStreak(int habitId) async {
    return await _database.habitEntriesDao.calculateStreak(habitId);
  }

  @override
  Future<int> getTotalCompletions(int habitId) async {
    return await _database.habitEntriesDao.getTotalCompletions(habitId);
  }

  @override
  Future<List<DateTime>> getCompletedDates(int habitId) async {
    return await _database.habitEntriesDao.getCompletedDates(habitId);
  }

  // Helper method to map database model to domain model
  Future<Habit> _mapHabitDataToHabit(HabitData data) async {
    final today = DateTime.now();
    final isCompletedToday = await isHabitCompletedForDate(data.id, today);
    final currentStreak = await calculateStreak(data.id);
    final totalCompletions = await getTotalCompletions(data.id);

    return Habit(
      id: data.id,
      title: data.title,
      description: data.description,
      reminderTime: data.reminderTime,
      targetDays: data.targetDays.split(',').map((e) => int.parse(e)).toList(),
      createdAt: data.createdAt,
      isCompletedToday: isCompletedToday,
      currentStreak: currentStreak,
      totalCompletions: totalCompletions,
    );
  }
}

// Provider for habit repository
final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  final database = ref.watch(databaseProvider);

  return HabitRepositoryImpl(database);
});
