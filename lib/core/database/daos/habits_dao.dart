import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/habits_table.dart';

part 'habits_dao.g.dart';

@DriftAccessor(tables: [HabitsTable])
class HabitsDao extends DatabaseAccessor<AppDatabase> with _$HabitsDaoMixin {
  HabitsDao(super.db);

  // Get all habits
  Future<List<HabitData>> getAllHabits() => select(habitsTable).get();

  // Get habit by id
  Future<HabitData?> getHabitById(int id) => (select(habitsTable)..where((h) => h.id.equals(id))).getSingleOrNull();

  // Get habits for today based on target days
  Future<List<HabitData>> getHabitsForToday() {
    final today = DateTime.now().weekday; // 1 = Monday, 7 = Sunday

    return (select(habitsTable)
          ..where((h) => h.targetDays.like('%$today%')))
        .get();
  }

  // Create new habit
  Future<int> createHabit(HabitsTableCompanion entry) => into(habitsTable).insert(entry);

  // Update habit
  Future<bool> updateHabit(HabitData habit) => update(habitsTable).replace(habit);

  // Delete habit
  Future<int> deleteHabit(int id) => (delete(habitsTable)..where((h) => h.id.equals(id))).go();
}