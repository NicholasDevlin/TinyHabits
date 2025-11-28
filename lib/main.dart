import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'core/app_theme.dart';
import 'features/habit/presentation/pages/home_page.dart';
import 'core/database/app_database.dart';
import 'core/services/notification_service.dart';
import 'core/services/simple_widget_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize timezone
  tz.initializeTimeZones();
  // Use local timezone (automatically detects from system)
  tz.setLocalLocation(tz.local);

  // Initialize database
  final database = AppDatabase();

  // Initialize notifications
  await NotificationService.initialize();

  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(database),
      ],
      child: const TinyWinsApp(),
    ),
  );
}

class TinyWinsApp extends ConsumerWidget {
  const TinyWinsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize simple widget service
    final widgetInit = ref.watch(simpleWidgetInitializationProvider);

    return MaterialApp(
      title: 'TinyWins',
      theme: AppTheme.lightTheme,
      home: widgetInit.when(
        data: (_) => const HomePage(),
        loading: () => const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
        error: (error, stack) => const HomePage(), // Still show app if widget fails
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}