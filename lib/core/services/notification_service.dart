import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  static bool _isInitialized = false;
  
  // Store the habit ID that needs navigation when app comes to foreground
  static int? _pendingNavigationHabitId;

  // Constants for better maintainability
  static const String _habitChannelId = 'habit_reminders';
  static const String _habitChannelName = 'Habit Reminders';
  static const String _habitChannelDescription = 'Scheduled reminders for your habits';
  static const Color _primaryColor = Color(0xFFBC6F0F);
  static final Int64List _vibrationPattern = Int64List.fromList([0, 1000, 500, 1000]);

  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      tz.initializeTimeZones();

      await _requestPermissions();

      // Initialize plugin with iOS and Android settings
      const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');

      const initializationSettingsIOS = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      final initialized = await _notifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      if (initialized == null || !initialized) {
        throw Exception('Failed to initialize notification plugin');
      }

      await _createNotificationChannels();

      _isInitialized = true;
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> _createNotificationChannels() async {
    final habitRemindersChannel = AndroidNotificationChannel(
      _habitChannelId,
      _habitChannelName,
      description: _habitChannelDescription,
      importance: Importance.max,
      enableVibration: true,
      playSound: true,
      enableLights: true,
      ledColor: _primaryColor,
      vibrationPattern: _vibrationPattern,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(habitRemindersChannel);
  }

  static Future<void> _requestPermissions() async {
    final status = await Permission.notification.request();

    if (status.isDenied) {
      // Handle denied permission - could show a dialog or snackbar in production
    }
  }

  static Future<void> _onNotificationTapped(NotificationResponse response) async {
    if (response.payload != null && response.payload!.startsWith('habit_')) {
      final habitId = int.tryParse(response.payload!.replaceFirst('habit_', ''));

      if (habitId != null) {
        _pendingNavigationHabitId = habitId;
      }
    }
  }

  // Get and clear pending navigation habit ID
  static int? getPendingNavigationHabitId() {
    final habitId = _pendingNavigationHabitId;
    _pendingNavigationHabitId = null;
    return habitId;
  }

  static Future<void> scheduleHabitReminder({
    required int habitId,
    required String habitTitle,
    required String reminderTime,
    required List<int> targetDays,
    bool? isCompletedToday,
  }) async {
    try {
      if (!_isInitialized) await initialize();

      final timeParts = _parseReminderTime(reminderTime);
      await _scheduleNotificationsForDays(
        habitId: habitId,
        habitTitle: habitTitle,
        reminderTime: reminderTime,
        targetDays: targetDays,
        hour: timeParts.hour,
        minute: timeParts.minute,
        isCompletedToday: isCompletedToday,
      );
    } catch (e) {
      rethrow;
    }
  }

  static ({int hour, int minute}) _parseReminderTime(String reminderTime) {
    final parts = reminderTime.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    return (hour: hour, minute: minute);
  }

  static Future _scheduleNotificationsForDays({
    required int habitId,
    required String habitTitle,
    required String reminderTime,
    required List<int> targetDays,
    required int hour,
    required int minute,
    bool? isCompletedToday,
  }) async {
    final now = DateTime.now();

    for (final dayOfWeek in targetDays) {
      final notificationId = _generateNotificationId(habitId, dayOfWeek);

      // Skip today if habit is already completed or time has passed
      if (dayOfWeek == now.weekday) {
        final scheduledTime = DateTime(now.year, now.month, now.day, hour, minute);
        final isTimePassed = scheduledTime.isBefore(now);

        // If habit is completed today or time has passed, schedule for next week instead
        if (isCompletedToday == true || isTimePassed) {
          continue; // Skip scheduling for today
        }
      }

      await _notifications.zonedSchedule(
        notificationId,
        habitTitle,
        'Time for your habit! 🎯',
        _getNextOccurrence(dayOfWeek, hour, minute),
        _buildNotificationDetails(),
        payload: 'habit_$habitId',
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    }
  }

  static NotificationDetails _buildNotificationDetails() {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        _habitChannelId,
        _habitChannelName,
        channelDescription: _habitChannelDescription,
        importance: Importance.max,
        priority: Priority.max,
        icon: '@mipmap/ic_launcher',
        color: _primaryColor,
        vibrationPattern: _vibrationPattern,
        autoCancel: false,
        category: AndroidNotificationCategory.reminder,
        fullScreenIntent: true,
        visibility: NotificationVisibility.public,
      ),
    );
  }

  static Future<void> cancelHabitReminders(int habitId) async {
    for (int dayOfWeek = 1; dayOfWeek <= 7; dayOfWeek++) {
      final notificationId = _generateNotificationId(habitId, dayOfWeek);
      await _notifications.cancel(notificationId);
    }
  }

  static Future<void> rescheduleHabitReminder({
    required int habitId,
    required String habitTitle,
    required String reminderTime,
    required List<int> targetDays,
    bool? isCompletedToday,
  }) async {
    await cancelHabitReminders(habitId);
    await scheduleHabitReminder(
      habitId: habitId,
      habitTitle: habitTitle,
      reminderTime: reminderTime,
      targetDays: targetDays,
      isCompletedToday: isCompletedToday,
    );
  }


  static int _generateNotificationId(int habitId, int dayOfWeek) {
    return habitId * 10 + dayOfWeek;
  }

  static tz.TZDateTime _getNextOccurrence(int weekday, int hour, int minute) {
    final now = DateTime.now();
    DateTime scheduledDate = DateTime(now.year, now.month, now.day, hour, minute);

    // Calculate next occurrence of the specified weekday
    final currentWeekday = now.weekday;
    int daysUntilTarget = weekday - currentWeekday;

    // If it's the same day but the time has already passed, schedule for next week
    if (daysUntilTarget == 0 && scheduledDate.isBefore(now)) {
      daysUntilTarget = 7;
    } else if (daysUntilTarget < 0) { // If the target day is in the past this week, schedule for next week
      daysUntilTarget += 7;
    }

    scheduledDate = scheduledDate.add(Duration(days: daysUntilTarget));

    // Convert to TZDateTime using local timezone (system timezone)
    return tz.TZDateTime.from(scheduledDate, tz.local);
  }
}
