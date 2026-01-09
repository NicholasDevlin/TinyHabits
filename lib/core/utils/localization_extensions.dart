import '../../l10n/app_localizations.dart';

extension AppLocalizationsExtension on AppLocalizations {
  /// Helper method to get day names list
  List<String> get dayNames => [
    monday, tuesday, wednesday, thursday, friday, saturday, sunday
  ];
  
  /// Helper method to get short day names list
  List<String> get dayNamesShort => [
    mon, tue, wed, thu, fri, sat, sun
  ];
}
