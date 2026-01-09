import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'l10n/app_localizations.dart';

import 'core/app_theme.dart';
import 'core/providers/locale_provider.dart';
import 'features/habit/presentation/pages/home_page.dart';
import 'core/database/app_database.dart';
import 'core/services/notification_service.dart';
import 'core/services/simple_widget_service.dart';
import 'core/services/widget_action_handler.dart';
import 'core/services/daily_refresh_service.dart';

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
      child: const StreaklyApp(),
    ),
  );
}

class StreaklyApp extends ConsumerWidget {
  const StreaklyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the current locale
    final locale = ref.watch(localeProvider);

    // Initialize widget service in background (non-blocking)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Initialize widget action handler with provider container
      WidgetActionHandler.initialize(ProviderScope.containerOf(context));
      
      // Initialize widget service asynchronously without blocking UI
      ref.read(simpleWidgetInitializationProvider);
      
      // Initialize daily refresh service to refresh habits at midnight
      ref.read(dailyRefreshServiceProvider);
    });

    return MaterialApp(
      title: 'Streakly',
      theme: AppTheme.lightTheme,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
