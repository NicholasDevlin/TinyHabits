import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:streakly/main.dart';
import 'package:streakly/core/database/app_database.dart';

void main() {
  testWidgets('Streakly app smoke test', (WidgetTester tester) async {
    // Create a test database
    final database = AppDatabase();

    // Build our app with test database
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
        ],
        child: const StreaklyApp(),
      ),
    );

    // Verify the app title appears
    expect(find.text('Streakly'), findsOneWidget);

    // Verify the empty state appears when no habits exist
    expect(find.text('Start Your Journey'), findsOneWidget);
    expect(find.text('Create First Habit'), findsOneWidget);

    // Verify the FAB is present
    expect(find.byType(FloatingActionButton), findsOneWidget);

    // Cleanup
    await database.close();
  });

  testWidgets('Create habit navigation test', (WidgetTester tester) async {
    final database = AppDatabase();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
        ],
        child: const StreaklyApp(),
      ),
    );

    // Wait for the widget to fully render
    await tester.pumpAndSettle();

    // Tap the FAB to navigate to create habit page
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Verify we're on the create habit page
    expect(find.text('Create Habit'), findsOneWidget);
    expect(find.text('Habit Name'), findsOneWidget);
    expect(find.text('Reminder Time'), findsOneWidget);
    expect(find.text('Repeat Days'), findsOneWidget);

    // Cleanup
    await database.close();
  });
}