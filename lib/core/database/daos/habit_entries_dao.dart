import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/habit_entries_table.dart';
import '../tables/habits_table.dart';

part 'habit_entries_dao.g.dart';

@DriftAccessor(tables: [HabitEntriesTable, HabitsTable])
class HabitEntriesDao extends DatabaseAccessor<AppDatabase> with _$HabitEntriesDaoMixin {
  HabitEntriesDao(super.db);

  // Get all entries for a habit
  Future<List<HabitEntryData>> getEntriesForHabit(int habitId) =>
      (select(habitEntriesTable)
            ..where((e) => e.habitId.equals(habitId))
            ..orderBy([(e) => OrderingTerm.desc(e.date)]))
          .get();

  // Get entry for a specific habit and date
  Future<HabitEntryData?> getEntryForDate(int habitId, DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);

    return (select(habitEntriesTable)
          ..where((e) => e.habitId.equals(habitId) & e.date.equals(dateOnly)))
        .getSingleOrNull();
  }

  // Get today's entries for all habits
  Future<List<HabitEntryData>> getTodayEntries() {
    final today = DateTime.now();
    final dateOnly = DateTime(today.year, today.month, today.day);

    return (select(habitEntriesTable)
          ..where((e) => e.date.equals(dateOnly)))
        .get();
  }

  // Mark habit as completed for a date
  Future<void> markHabitCompleted(int habitId, DateTime date, bool isCompleted) async {
    final dateOnly = DateTime(date.year, date.month, date.day);
    final existingEntry = await getEntryForDate(habitId, dateOnly);

    if (existingEntry != null) {
      // Update existing entry
      await (update(habitEntriesTable)
            ..where((e) => e.id.equals(existingEntry.id)))
          .write(HabitEntriesTableCompanion(
            isCompleted: Value(isCompleted),
          ));
    } else {
      // Create new entry
      await into(habitEntriesTable).insert(HabitEntriesTableCompanion(
        habitId: Value(habitId),
        date: Value(dateOnly),
        isCompleted: Value(isCompleted),
      ));
    }
  }

  // Calculate current streak for a habit
  Future<int> calculateStreak(int habitId) async {
    final habit = await (select(habitsTable)..where((h) => h.id.equals(habitId)))
        .getSingleOrNull();

    if (habit == null) return 0;

    final targetDays = habit.targetDays
        .split(',')
        .map((day) => int.tryParse(day.trim()))
        .whereType<int>()
        .toSet();

    final now = DateTime.now();
    final yearAgo = now.subtract(const Duration(days: 365));

    final habitEntries = await (select(habitEntriesTable)
      ..where((e) =>
      e.habitId.equals(habitId) &
      e.isCompleted.equals(true) &
      e.date.isBiggerThan(Variable(yearAgo)))
      ..orderBy([(e) => OrderingTerm.desc(e.date)]))
        .get();

    if (habitEntries.isEmpty) return 0;

    int streak = 0;
    DateTime checkDate = DateTime(now.year, now.month, now.day);
    int entryIndex = 0;

    while (now.difference(checkDate).inDays <= 365) {
      // If we have run out of habitEntries to check, and we hit a target day, the streak is over.
      // (Unless we haven't hit a target day yet, then we keep going back)

      if (targetDays.contains(checkDate.weekday)) {
        bool foundMatch = false;

        while (entryIndex < habitEntries.length) {
          final entryDate = habitEntries[entryIndex].date;
          final habitEntryDate = DateTime(entryDate.year, entryDate.month, entryDate.day);

          if (habitEntryDate.isAtSameMomentAs(checkDate)) {
            foundMatch = true;
            entryIndex++;

            break;
          } else if (habitEntryDate.isBefore(checkDate)) {
            break;
          } else {
            // The entry is NEWER than check date (shouldn't happen often due to logic, but strictly skips ahead)
            entryIndex++;
          }
        }

        if (foundMatch) {
          streak++;
        } else {
          // Scheduled day, but no entry found -> Streak broken
          break;
        }
      }

      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    return streak;
  }

  // Get total completions for a habit
  Future<int> getTotalCompletions(int habitId) async {
    final result = await (selectOnly(habitEntriesTable)
          ..addColumns([habitEntriesTable.id.count()])
          ..where(habitEntriesTable.habitId.equals(habitId) &
              habitEntriesTable.isCompleted.equals(true)))
        .getSingle();

    return result.read(habitEntriesTable.id.count()) ?? 0;
  }

  // Get completed dates for calendar view
  Future<List<DateTime>> getCompletedDates(int habitId) async {
    final entries = await (select(habitEntriesTable)
          ..where((e) => e.habitId.equals(habitId) & e.isCompleted.equals(true)))
        .get();

    return entries.map((e) => e.date).toList();
  }
}