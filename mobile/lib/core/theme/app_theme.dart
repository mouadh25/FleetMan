import 'package:flutter/material.dart';

class AppTheme {
  // Brand Colors
  static const Color primaryBlue = Color(0xFF1A3A5C);
  static const Color accentOrange = Color(0xFFF28C28);

  // Semantic Colors
  static const Color errorRed = Color(0xFFD32F2F);
  static const Color successGreen = Color(0xFF2E7D32);

  // Backgrounds
  static const Color backgroundLight = Color(0xFFF5F7FA);
  static const Color backgroundDark = Color(0xFF121212);

  // Standard Touch Target Size (48x48 API Min)
  static const double minimumTouchTarget = 48.0;
  static const double defaultBorderRadius = 12.0;

  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundLight,
      colorScheme: const ColorScheme.light(
        primary: primaryBlue,
        secondary: accentOrange,
        error: errorRed,
        surface: Colors.white,
      ),
      fontFamily: 'Inter',
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, minimumTouchTarget), 
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(defaultBorderRadius),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(defaultBorderRadius),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundDark,
      colorScheme: const ColorScheme.dark(
        primary: primaryBlue,
        secondary: accentOrange,
        error: errorRed,
        surface: Color(0xFF1E1E1E),
      ),
      fontFamily: 'Inter',
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, minimumTouchTarget),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(defaultBorderRadius),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(defaultBorderRadius),
        ),
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
      ),
    );
  }
}
