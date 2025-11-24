import '../models/habit.dart';

abstract class HabitRepository {
  // Habit CRUD operations
  Future<List<Habit>> getAllHabits();
  Future<Habit?> getHabitById(int id);
  Future<List<Habit>> getHabitsForToday();
  Future<int> createHabit(CreateHabitRequest request);
  Future<void> updateHabit(Habit habit);
  Future<void> deleteHabit(int id);

  // Habit entry operations
  Future<void> markHabitCompleted(int habitId, DateTime date, bool isCompleted);
  Future<bool> isHabitCompletedForDate(int habitId, DateTime date);
  Future<int> calculateStreak(int habitId);
  Future<int> getTotalCompletions(int habitId);
  Future<List<DateTime>> getCompletedDates(int habitId);
}