import 'package:flutter/material.dart';

class AppTheme {
  static TextStyle appTextStyle({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
  }) {
    return TextStyle(
      fontFamily: 'Roboto',
      fontSize: fontSize ?? 14,
      fontWeight: fontWeight,
      color: color,
    );
  }
  // Color Palette as specified in the instructions
  static const Color primaryColor = Color(0xFF85D8EA); // Light Cyan/Blue
  static const Color secondaryColor = Color(0xFF546A7B); // Blue Grey
  static const Color backgroundColor = Colors.white;
  static const Color lightBackgroundColor = Color(0xFFFAFAFA);
  static const Color successColor = Colors.green;
  static const Color warningColor = Colors.orangeAccent;
  static const Color errorColor = Colors.red;
  static const Color surfaceColor = Colors.white;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        error: errorColor,
      ),
      scaffoldBackgroundColor: lightBackgroundColor,
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontFamily: 'Roboto', fontSize: 57),
        displayMedium: TextStyle(fontFamily: 'Roboto', fontSize: 45),
        displaySmall: TextStyle(fontFamily: 'Roboto', fontSize: 36),
        headlineLarge: TextStyle(fontFamily: 'Roboto', fontSize: 32),
        headlineMedium: TextStyle(fontFamily: 'Roboto', fontSize: 28),
        headlineSmall: TextStyle(fontFamily: 'Roboto', fontSize: 24),
        titleLarge: TextStyle(fontFamily: 'Roboto', fontSize: 22),
        titleMedium: TextStyle(fontFamily: 'Roboto', fontSize: 16),
        titleSmall: TextStyle(fontFamily: 'Roboto', fontSize: 14),
        bodyLarge: TextStyle(fontFamily: 'Roboto', fontSize: 16),
        bodyMedium: TextStyle(fontFamily: 'Roboto', fontSize: 14),
        bodySmall: TextStyle(fontFamily: 'Roboto', fontSize: 12),
        labelLarge: TextStyle(fontFamily: 'Roboto', fontSize: 14),
        labelMedium: TextStyle(fontFamily: 'Roboto', fontSize: 12),
        labelSmall: TextStyle(fontFamily: 'Roboto', fontSize: 11),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundColor,
        elevation: 0,
        titleTextStyle: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: secondaryColor,
        ),
        iconTheme: const IconThemeData(color: secondaryColor),
      ),
      cardTheme: const CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)), // Rounded corners as specified
        ),
        color: surfaceColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: secondaryColor.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: secondaryColor.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}