import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id')
  ];

  /// The application title
  ///
  /// In en, this message translates to:
  /// **'Streakly'**
  String get appTitle;

  /// Today tab label
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayTab;

  /// All habits tab label
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allTab;

  /// Today header text
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayHeader;

  /// All habits header text
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allHeader;

  /// Message shown when all habits are completed
  ///
  /// In en, this message translates to:
  /// **'🎉 Amazing! You\'ve completed all your habits today!'**
  String get motivationalAllComplete;

  /// Message showing progress
  ///
  /// In en, this message translates to:
  /// **'{completed} of {total} completed. Keep going!'**
  String motivationalProgress(int completed, int total);

  /// Message to start habits
  ///
  /// In en, this message translates to:
  /// **'Ready to make today count? Start with one habit.'**
  String get motivationalStart;

  /// Message when no habits scheduled for today
  ///
  /// In en, this message translates to:
  /// **'No habits for today'**
  String get noHabitsToday;

  /// Message when no habits exist
  ///
  /// In en, this message translates to:
  /// **'No habits yet'**
  String get noHabitsYet;

  /// Message for no habits today
  ///
  /// In en, this message translates to:
  /// **'Take a break and come back tomorrow!'**
  String get noHabitsTodayMessage;

  /// Message when starting fresh
  ///
  /// In en, this message translates to:
  /// **'Your journey to better habits starts here.'**
  String get noHabitsYetMessage;

  /// Button to create first habit
  ///
  /// In en, this message translates to:
  /// **'Create Your First Habit'**
  String get createFirstHabit;

  /// Edit button label
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Delete button label
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Cancel button label
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Undo button label
  ///
  /// In en, this message translates to:
  /// **'UNDO'**
  String get undo;

  /// Delete confirmation dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete Habit?'**
  String get deleteHabitTitle;

  /// Delete confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{habitTitle}\"?'**
  String deleteHabitMessage(String habitTitle);

  /// Deleting in progress message
  ///
  /// In en, this message translates to:
  /// **'Deleting {habitTitle}...'**
  String deletingHabit(String habitTitle);

  /// Deleted success message
  ///
  /// In en, this message translates to:
  /// **'Deleted {habitTitle}'**
  String deletedHabit(String habitTitle);

  /// Habit completion message
  ///
  /// In en, this message translates to:
  /// **'Habit marked as complete'**
  String get habitCompleted;

  /// Habit incomplete message
  ///
  /// In en, this message translates to:
  /// **'Habit marked as incomplete'**
  String get habitIncomplete;

  /// Error message when updating fails
  ///
  /// In en, this message translates to:
  /// **'Error updating habit: {error}'**
  String errorUpdatingHabit(String error);

  /// Error message when deletion fails
  ///
  /// In en, this message translates to:
  /// **'Failed to delete: {error}'**
  String failedToDelete(String error);

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get somethingWentWrong;

  /// Create habit page title
  ///
  /// In en, this message translates to:
  /// **'Create Habit'**
  String get createHabit;

  /// Edit habit page title
  ///
  /// In en, this message translates to:
  /// **'Edit Habit'**
  String get editHabit;

  /// Update habit button label
  ///
  /// In en, this message translates to:
  /// **'Update Habit'**
  String get updateHabit;

  /// Habit name field label
  ///
  /// In en, this message translates to:
  /// **'Habit Name'**
  String get habitName;

  /// Habit name field hint
  ///
  /// In en, this message translates to:
  /// **'e.g., Morning Exercise, Read for 30 minutes'**
  String get habitNameHint;

  /// Description field label
  ///
  /// In en, this message translates to:
  /// **'Description (Optional)'**
  String get descriptionOptional;

  /// Description field hint
  ///
  /// In en, this message translates to:
  /// **'Add details about your habit...'**
  String get descriptionHint;

  /// Reminder time field label
  ///
  /// In en, this message translates to:
  /// **'Reminder Time'**
  String get reminderTime;

  /// Repeat days section label
  ///
  /// In en, this message translates to:
  /// **'Repeat Days'**
  String get repeatDays;

  /// Everyday option label
  ///
  /// In en, this message translates to:
  /// **'Everyday'**
  String get everyday;

  /// Validation message for empty habit name
  ///
  /// In en, this message translates to:
  /// **'Please enter a habit name'**
  String get pleaseEnterHabitName;

  /// Validation message for no days selected
  ///
  /// In en, this message translates to:
  /// **'Please select at least one day'**
  String get pleaseSelectAtLeastOneDay;

  /// Success message for habit creation
  ///
  /// In en, this message translates to:
  /// **'Habit created successfully!'**
  String get habitCreatedSuccessfully;

  /// Success message for habit update
  ///
  /// In en, this message translates to:
  /// **'Habit updated successfully!'**
  String get habitUpdatedSuccessfully;

  /// Error message when creation fails
  ///
  /// In en, this message translates to:
  /// **'Failed to create habit: {error}'**
  String failedToCreateHabit(String error);

  /// Error message when update fails
  ///
  /// In en, this message translates to:
  /// **'Failed to update habit: {error}'**
  String failedToUpdateHabit(String error);

  /// Monday full name
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get monday;

  /// Tuesday full name
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get tuesday;

  /// Wednesday full name
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get wednesday;

  /// Thursday full name
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get thursday;

  /// Friday full name
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get friday;

  /// Saturday full name
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get saturday;

  /// Sunday full name
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get sunday;

  /// Monday short name
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get mon;

  /// Tuesday short name
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get tue;

  /// Wednesday short name
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get wed;

  /// Thursday short name
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get thu;

  /// Friday short name
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get fri;

  /// Saturday short name
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get sat;

  /// Sunday short name
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get sun;

  /// Habit detail page title
  ///
  /// In en, this message translates to:
  /// **'Habit Details'**
  String get habitDetails;

  /// Loading indicator text
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Error label
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Error when habit not found
  ///
  /// In en, this message translates to:
  /// **'Habit not found'**
  String get habitNotFound;

  /// Reminder time display
  ///
  /// In en, this message translates to:
  /// **'Reminder at {time}'**
  String reminderAt(String time);

  /// Statistics section label
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// Current streak label
  ///
  /// In en, this message translates to:
  /// **'Current Streak'**
  String get currentStreak;

  /// Days unit
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// Total completed label
  ///
  /// In en, this message translates to:
  /// **'Total Completed'**
  String get totalCompleted;

  /// Times unit
  ///
  /// In en, this message translates to:
  /// **'times'**
  String get times;

  /// Calendar section label
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// Error loading calendar
  ///
  /// In en, this message translates to:
  /// **'Failed to load calendar'**
  String get failedToLoadCalendar;

  /// Error exclamation
  ///
  /// In en, this message translates to:
  /// **'Oops!'**
  String get oops;

  /// Every day schedule text
  ///
  /// In en, this message translates to:
  /// **'Every day'**
  String get everyDay;

  /// Delete habit button label
  ///
  /// In en, this message translates to:
  /// **'Delete Habit'**
  String get deleteHabit;

  /// Delete habit confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this habit? This action cannot be undone.'**
  String get deleteHabitConfirmation;

  /// Habit deleted success message
  ///
  /// In en, this message translates to:
  /// **'Habit deleted successfully'**
  String get habitDeletedSuccessfully;

  /// Error deleting habit
  ///
  /// In en, this message translates to:
  /// **'Failed to delete habit: {error}'**
  String failedToDeleteHabit(String error);

  /// Day streak display
  ///
  /// In en, this message translates to:
  /// **'🔥 {days} day streak'**
  String dayStreak(int days);

  /// Message when habit not scheduled for today
  ///
  /// In en, this message translates to:
  /// **'This habit isn\'t available'**
  String get habitNotAvailableToday;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
