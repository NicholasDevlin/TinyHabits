import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provider to manage the current locale
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  static const String _localeKey = 'selected_locale';
  
  LocaleNotifier() : super(const Locale('en', '')) {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_localeKey);
      if (languageCode != null) {
        state = Locale(languageCode, '');
      }
    } catch (e) {
      // If loading fails, keep default locale (English)
    }
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, locale.languageCode);
    } catch (e) {
      // Handle error silently
    }
  }

  void toggleLocale() {
    final newLocale = state.languageCode == 'en' 
        ? const Locale('id', '') 
        : const Locale('en', '');
    setLocale(newLocale);
  }
}
