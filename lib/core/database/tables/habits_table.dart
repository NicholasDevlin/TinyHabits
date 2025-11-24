import 'package:drift/drift.dart';

@DataClassName('HabitData')
class HabitsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get reminderTime => text()(); // Store as "HH:mm" format
  TextColumn get targetDays => text()(); // Store as comma-separated string "1,2,3,4,5,6,7"
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}