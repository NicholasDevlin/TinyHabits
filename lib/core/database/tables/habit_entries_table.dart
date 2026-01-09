import 'package:drift/drift.dart';
import 'habits_table.dart';

@DataClassName('HabitEntryData')
class HabitEntriesTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get habitId => integer().references(HabitsTable, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get date => dateTime()(); // Date without time component
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
}
