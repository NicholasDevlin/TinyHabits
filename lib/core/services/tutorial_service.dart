import 'package:shared_preferences/shared_preferences.dart';

class TutorialService {
  static const String _tutorialCompletedKey = 'tutorial_completed';

  /// Check if the user has completed the tutorial
  static Future<bool> hasCompletedTutorial() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getBool(_tutorialCompletedKey) ?? false;
  }

  /// Mark the tutorial as completed
  static Future<void> markTutorialCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_tutorialCompletedKey, true);
  }

  /// Reset the tutorial (for testing or user preference)
  static Future<void> resetTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tutorialCompletedKey);
  }
}
