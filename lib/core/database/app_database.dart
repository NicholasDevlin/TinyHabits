import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables/habits_table.dart';
import 'tables/habit_entries_table.dart';
import 'daos/habits_dao.dart';
import 'daos/habit_entries_dao.dart';

part 'app_database.g.dart'; // Database file

@DriftDatabase(
  tables: [HabitsTable, HabitEntriesTable],
  daos: [HabitsDao, HabitEntriesDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection()); // Initializer List

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'streakly.db'));

    return NativeDatabase.createInBackground(file);
  });
}

// Provider for database
final databaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError();
});
