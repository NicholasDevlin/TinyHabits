class AppDateUtils {
  /// Returns today's date with time set to midnight
  static DateTime getToday() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  /// Checks if a date is today
  static bool isToday(DateTime date) {
    final today = getToday();
    final checkDate = DateTime(date.year, date.month, date.day);
    return checkDate == today;
  }

  /// Gets the day name for a day number (1-7)
  static String getDayName(int dayNumber) {
    const dayNames = [
      'Monday',
      'Tuesday', 
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];

    if (dayNumber < 1 || dayNumber > 7) {
      throw ArgumentError('Day number must be between 1 and 7');
    }

    return dayNames[dayNumber - 1];
  }

  /// Gets short day name for a day number (1-7)
  static String getShortDayName(int dayNumber) {
    const shortDayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    if (dayNumber < 1 || dayNumber > 7) {
      throw ArgumentError('Day number must be between 1 and 7');
    }

    return shortDayNames[dayNumber - 1];
  }

  /// Formats target days list into readable string
  static String formatTargetDays(List<int> targetDays) {
    if (targetDays.length == 7) {
      return 'Every day';
    }

    if (targetDays.isEmpty) {
      return 'No days selected';
    }

    final dayNames = targetDays.map((day) => getShortDayName(day)).join(', ');

    return dayNames;
  }
}
