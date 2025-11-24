import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    // Request notification permission
    await _requestPermissions();

    // Initialize plugin
    const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');

    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channels explicitly
    await _createNotificationChannels();

    _isInitialized = true;
  }

  static Future<void> _createNotificationChannels() async {
    final vibrationPattern = Int64List.fromList([0, 1000, 500, 1000]);
    final habitRemindersChannel = AndroidNotificationChannel(
      'habit_reminders',
      'Habit Reminders',
      description: 'Scheduled reminders for your habits - works like an alarm',
      importance: Importance.max, // Changed to max for alarm-like behavior
      enableVibration: true,
      playSound: true,
      enableLights: true,
      ledColor: const Color(0xFF85D8EA),
      vibrationPattern: vibrationPattern,
    );

    // Actually create the channel
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
    // Could navigate to specific habit or open the app
    // TODO: Implement navigation logic if needed
  }

  static Future<void> scheduleHabitReminder({
    required int habitId,
    required String habitTitle,
    required String reminderTime, // "HH:mm" format
    required List<int> targetDays, // 1-7 (Monday to Sunday)
  }) async {
    if (!_isInitialized) await initialize();

    final reminderTimeParts = reminderTime.split(':');
    final hour = int.parse(reminderTimeParts[0]);
    final minute = int.parse(reminderTimeParts[1]);

    // Schedule notification for each target day
    for (int dayOfWeek in targetDays) {
      final notificationId = _generateNotificationId(habitId, dayOfWeek);

      final scheduledTime = _nextInstanceOfWeekdayAndTime(dayOfWeek, hour, minute);
      final dayName = _getDayName(dayOfWeek);
      
      await _notifications.zonedSchedule(
        notificationId,
        'Time for your habit! 🎯',
        '$habitTitle - Every $dayName at $reminderTime',
        scheduledTime,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'habit_reminders',
            'Habit Reminders',
            channelDescription: 'Scheduled reminders for your habits - works like an alarm',
            importance: Importance.max, // Maximum importance for alarm-like behavior
            priority: Priority.max, // Maximum priority
            icon: '@mipmap/ic_launcher',
            color: const Color(0xFF85D8EA),
            playSound: true,
            enableVibration: true,
            vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]), // Custom vibration pattern
            enableLights: true,
            ledColor: Color(0xFF85D8EA),
            ledOnMs: 1000,
            ledOffMs: 500,
            autoCancel: false, // Don't auto-cancel so user has to interact
            ongoing: false, // Not ongoing, but persistent until dismissed
            showWhen: true,
            when: scheduledTime.millisecondsSinceEpoch,
          ),
        ),
        payload: 'habit_$habitId',
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    }
  }

  static Future<void> cancelHabitReminders(int habitId) async {
    // Cancel all notifications for this habit (for all days)
    for (int dayOfWeek = 1; dayOfWeek <= 7; dayOfWeek++) {
      final notificationId = _generateNotificationId(habitId, dayOfWeek);
      await _notifications.cancel(notificationId);
    }
  }

  /// Cancel all pending notifications
  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Get list of pending notifications (for debugging)
  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  /// Reschedule all notifications for a habit (useful when updating)
  static Future<void> rescheduleHabitReminder({
    required int habitId,
    required String habitTitle,
    required String reminderTime,
    required List<int> targetDays,
  }) async {
    // Cancel existing notifications first
    await cancelHabitReminders(habitId);
    
    // Schedule new notifications
    await scheduleHabitReminder(
      habitId: habitId,
      habitTitle: habitTitle,
      reminderTime: reminderTime,
      targetDays: targetDays,
    );
  }

  /// Debug method to get scheduled times for a habit
  static Map<String, DateTime> getScheduledTimesForHabit({
    required String reminderTime,
    required List<int> targetDays,
  }) {
    final reminderTimeParts = reminderTime.split(':');
    final hour = int.parse(reminderTimeParts[0]);
    final minute = int.parse(reminderTimeParts[1]);

    final Map<String, DateTime> scheduledTimes = {};
    
    for (int dayOfWeek in targetDays) {
      final dayName = _getDayName(dayOfWeek);
      final scheduledTime = _nextInstanceOfWeekdayAndTime(dayOfWeek, hour, minute);
      scheduledTimes[dayName] = scheduledTime.toLocal();
    }

    return scheduledTimes;
  }

  static int _generateNotificationId(int habitId, int dayOfWeek) {
    return habitId * 10 + dayOfWeek;
  }

  static String _getDayName(int dayOfWeek) {
    switch (dayOfWeek) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return 'Unknown';
    }
  }

  static tz.TZDateTime _nextInstanceOfWeekdayAndTime(int weekday, int hour, int minute) {
    tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    // Calculate next occurrence of the specified weekday
    final currentWeekday = now.weekday;
    int daysUntilTarget = weekday - currentWeekday;

    // If it's the same day but the time has already passed, schedule for next week
    if (daysUntilTarget == 0 && scheduledDate.isBefore(now)) {
      daysUntilTarget = 7;
    }
    
    // If the target day is in the past this week, schedule for next week
    if (daysUntilTarget < 0) {
      daysUntilTarget += 7;
    }

    scheduledDate = scheduledDate.add(Duration(days: daysUntilTarget));

    return scheduledDate;
  }
}