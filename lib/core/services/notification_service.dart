import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  static bool _isInitialized = false;

  // Constants for better maintainability
  static const String _habitChannelId = 'habit_reminders';
  static const String _habitChannelName = 'Habit Reminders';
  static const String _habitChannelDescription = 'Scheduled reminders for your habits';
  static const Color _primaryColor = Color(0xFFBC6F0F);
  static final Int64List _vibrationPattern = Int64List.fromList([0, 1000, 500, 1000]);

  static Future<void> initialize({Function(int habitId, String action)? onHabitActionCallback}) async {
    if (_isInitialized) return;

    try {
      // Set the callback for handling habit actions
      _onHabitActionCallback = onHabitActionCallback;

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
    // Parse the payload to extract habit ID and action
    if (response.payload != null && response.payload!.startsWith('habit_')) {
      final parts = response.payload!.split(':action:');
      if (parts.length == 2) {
        final habitId = int.tryParse(parts[0].replaceFirst('habit_', ''));
        final action = parts[1];

        if (habitId != null) {
          await _handleNotificationAction(habitId!, action);
        }
      }
    }

    // Could navigate to specific habit or open the app
    // TODO: Implement navigation logic if needed
  }

  static Future<void> _handleNotificationAction(int habitId, String action) async {
    try {
      if (action == 'mark_complete') {
        // This will be handled by the habit controller through a global callback
        _onHabitActionCallback?.call(habitId, 'complete');
      } else if (action == 'skip') {
        // Just dismiss the notification - don't do anything else
        _onHabitActionCallback?.call(habitId, 'skip');
      }
    } catch (e) {
      print('Error handling notification action: $e');
    }
  }

  // Global callback to handle habit actions from notifications
  static Function(int habitId, String action)? _onHabitActionCallback;

  // External method to complete a habit from notification
  static Future<void> completeHabitFromNotification(int habitId) async {
    _onHabitActionCallback?.call(habitId, 'complete');
  }

  // Method to be called from HabitController to handle notification actions
  static void setHabitActionCallback(Function(int habitId, String action) callback) {
    _onHabitActionCallback = callback;
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
        payload: 'habit_$habitId:action_complete,habit_$habitId:action_skip',
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
        actions: [
          const AndroidNotificationAction(
            'mark_complete',
            'Mark Complete',
            showsUserInterface: true,
          ),
          const AndroidNotificationAction(
            'skip',
            'Skip',
            showsUserInterface: true,
          ),
        ],
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
    try {
    } catch (e) {
      rethrow; // Let the caller handle this since rescheduling is critical
    }
  }

  /// Cancel today's notification for a specific habit and reschedule for next target day
  static Future<void> cancelTodayAndRescheduleNext({
    required int habitId,
    required String habitTitle,
    required String reminderTime,
    required List<int> targetDays,
  }) async {
    try {
      if (!_isInitialized) await initialize();

      // Cancel today's notification only
      await _cancelTodayNotification(habitId);

      // Reschedule for next target day
      await _scheduleNextTargetDay(
        habitId: habitId,
        habitTitle: habitTitle,
        reminderTime: reminderTime,
        targetDays: targetDays,
      );
    } catch (e) {
      print('Error in cancelTodayAndRescheduleNext: $e');
      rethrow;
    }
  }

  /// Cancel today's notification for a specific habit
  static Future<void> _cancelTodayNotification(int habitId) async {
    final now = DateTime.now();
    final todayWeekday = now.weekday; // 1=Monday, 7=Sunday
    final todayNotificationId = _generateNotificationId(habitId, todayWeekday);

    await _notifications.cancel(todayNotificationId);
  }

  /// Schedule the next target day notification (excluding today)
  static Future<void> _scheduleNextTargetDay({
    required int habitId,
    required String habitTitle,
    required String reminderTime,
    required List<int> targetDays,
  }) async {
    final timeParts = _parseReminderTime(reminderTime);

    // Find the next target day (excluding today)
    final nextTargetDay = _findNextTargetDay(targetDays);

    if (nextTargetDay != null) {
      final notificationId = _generateNotificationId(habitId, nextTargetDay);

      await _notifications.zonedSchedule(
        notificationId,
        habitTitle,
        'Time for your habit! 🎯',
        _getNextOccurrence(nextTargetDay, timeParts.hour, timeParts.minute),
        _buildNotificationDetails(),
        payload: 'habit_$habitId:action_complete,habit_$habitId:action_skip',
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } else {
      print('No more target days found for habit $habitId in this week');
    }
  }

  /// Find the next target day from today's date (excluding today)
  static int? _findNextTargetDay(List<int> targetDays) {
    final now = DateTime.now();
    int currentWeekday = now.weekday; // 1=Monday, 7=Sunday

    // Sort target days to ensure proper order
    final sortedTargetDays = List<int>.from(targetDays)..sort();

    // Search for the next target day in the current week
    for (int i = 0; i < 7; i++) {
      currentWeekday = currentWeekday % 7 + 1; // Move to next day (1-7)

      if (sortedTargetDays.contains(currentWeekday)) {
        return currentWeekday;
      }
    }

    return null; // No target days found
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