// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Streakly';

  @override
  String get todayTab => 'Today';

  @override
  String get allTab => 'All';

  @override
  String get todayHeader => 'Today';

  @override
  String get allHeader => 'All';

  @override
  String get motivationalAllComplete =>
      '🎉 Amazing! You\'ve completed all your habits today!';

  @override
  String motivationalProgress(int completed, int total) {
    return '$completed of $total completed. Keep going!';
  }

  @override
  String get motivationalStart =>
      'Ready to make today count? Start with one habit.';

  @override
  String get noHabitsToday => 'No habits for today';

  @override
  String get noHabitsYet => 'No habits yet';

  @override
  String get noHabitsTodayMessage => 'Take a break and come back tomorrow!';

  @override
  String get noHabitsYetMessage => 'Your journey to better habits starts here.';

  @override
  String get createFirstHabit => 'Create Your First Habit';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get cancel => 'Cancel';

  @override
  String get undo => 'UNDO';

  @override
  String get deleteHabitTitle => 'Delete Habit?';

  @override
  String deleteHabitMessage(String habitTitle) {
    return 'Are you sure you want to delete \"$habitTitle\"?';
  }

  @override
  String deletingHabit(String habitTitle) {
    return 'Deleting $habitTitle...';
  }

  @override
  String deletedHabit(String habitTitle) {
    return 'Deleted $habitTitle';
  }

  @override
  String get habitCompleted => 'Habit marked as complete';

  @override
  String get habitIncomplete => 'Habit marked as incomplete';

  @override
  String errorUpdatingHabit(String error) {
    return 'Error updating habit: $error';
  }

  @override
  String failedToDelete(String error) {
    return 'Failed to delete: $error';
  }

  @override
  String get somethingWentWrong => 'Something went wrong. Please try again.';

  @override
  String get createHabit => 'Create Habit';

  @override
  String get editHabit => 'Edit Habit';

  @override
  String get updateHabit => 'Update Habit';

  @override
  String get habitName => 'Habit Name';

  @override
  String get habitNameHint => 'e.g., Morning Exercise, Read for 30 minutes';

  @override
  String get descriptionOptional => 'Description (Optional)';

  @override
  String get descriptionHint => 'Add details about your habit...';

  @override
  String get reminderTime => 'Reminder Time';

  @override
  String get repeatDays => 'Repeat Days';

  @override
  String get everyday => 'Everyday';

  @override
  String get pleaseEnterHabitName => 'Please enter a habit name';

  @override
  String get pleaseSelectAtLeastOneDay => 'Please select at least one day';

  @override
  String get habitCreatedSuccessfully => 'Habit created successfully!';

  @override
  String get habitUpdatedSuccessfully => 'Habit updated successfully!';

  @override
  String failedToCreateHabit(String error) {
    return 'Failed to create habit: $error';
  }

  @override
  String failedToUpdateHabit(String error) {
    return 'Failed to update habit: $error';
  }

  @override
  String get monday => 'Monday';

  @override
  String get tuesday => 'Tuesday';

  @override
  String get wednesday => 'Wednesday';

  @override
  String get thursday => 'Thursday';

  @override
  String get friday => 'Friday';

  @override
  String get saturday => 'Saturday';

  @override
  String get sunday => 'Sunday';

  @override
  String get mon => 'Mon';

  @override
  String get tue => 'Tue';

  @override
  String get wed => 'Wed';

  @override
  String get thu => 'Thu';

  @override
  String get fri => 'Fri';

  @override
  String get sat => 'Sat';

  @override
  String get sun => 'Sun';

  @override
  String get habitDetails => 'Habit Details';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get habitNotFound => 'Habit not found';

  @override
  String reminderAt(String time) {
    return 'Reminder at $time';
  }

  @override
  String get statistics => 'Statistics';

  @override
  String get currentStreak => 'Current Streak';

  @override
  String get days => 'days';

  @override
  String get totalCompleted => 'Total Completed';

  @override
  String get times => 'times';

  @override
  String get calendar => 'Calendar';

  @override
  String get failedToLoadCalendar => 'Failed to load calendar';

  @override
  String get oops => 'Oops!';

  @override
  String get everyDay => 'Every day';

  @override
  String get deleteHabit => 'Delete Habit';

  @override
  String get deleteHabitConfirmation =>
      'Are you sure you want to delete this habit? This action cannot be undone.';

  @override
  String get habitDeletedSuccessfully => 'Habit deleted successfully';

  @override
  String failedToDeleteHabit(String error) {
    return 'Failed to delete habit: $error';
  }

  @override
  String dayStreak(int days) {
    return '🔥 $days day streak';
  }

  @override
  String get habitNotAvailableToday => 'This habit isn\'t available';

  @override
  String get tutorialWelcomeTitle => 'Welcome to Streakly! 👋';

  @override
  String get tutorialWelcomeDescription =>
      'Build better habits, one day at a time. Let\'s take a quick tour to get you started!';

  @override
  String get tutorialCreateTitle => 'Create Your First Habit';

  @override
  String get tutorialCreateDescription =>
      'Tap the + button to create a new habit. Set a name, reminder time, and choose which days you want to track it.';

  @override
  String get tutorialSwipeLeftTitle => 'Swipe Left to Edit ✏️';

  @override
  String get tutorialSwipeLeftDescription =>
      'Swipe any habit card from left to right to quickly edit its details, reminder time, or schedule.';

  @override
  String get tutorialSwipeRightTitle => 'Swipe Right to Delete 🗑️';

  @override
  String get tutorialSwipeRightDescription =>
      'Swipe any habit card from right to left to delete it. Don\'t worry, we\'ll ask for confirmation first!';

  @override
  String get tutorialCompleteTitle => 'You\'re All Set! 🎉';

  @override
  String get tutorialCompleteDescription =>
      'Tap on a habit card to mark it complete and build your streak. Ready to start your journey?';

  @override
  String get tutorialNext => 'Next';

  @override
  String get tutorialBack => 'Back';

  @override
  String get tutorialSkip => 'Skip';

  @override
  String get tutorialGetStarted => 'Get Started';

  @override
  String get tutorialSwipeCard => 'Habit Card';
}
