import 'package:flutter/material.dart';

/// TaskVerse design system.
/// Three modes: light, dark, AMOLED (pure black).
class AppTheme {
  AppTheme._();

  // Brand colors
  static const Color brandPrimary = Color(0xFF013A34);   // deep green
  static const Color brandSecondary = Color(0xFFD4AF37); // gold
  static const Color brandAccent = Color(0xFF00D9A3);    // mint

  static ThemeData light() => _base(
        brightness: Brightness.light,
        background: const Color(0xFFF7F7F5),
        surface: Colors.white,
      );

  static ThemeData dark() => _base(
        brightness: Brightness.dark,
        background: const Color(0xFF0E1110),
        surface: const Color(0xFF1A1F1D),
      );

  static ThemeData amoled() => _base(
        brightness: Brightness.dark,
        background: Colors.black,
        surface: Colors.black,
      );

  static ThemeData _base({
    required Brightness brightness,
    required Color background,
    required Color surface,
  }) {
    final scheme = ColorScheme.fromSeed(
      seedColor: brandPrimary,
      brightness: brightness,
      surface: surface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: scheme.onSurface,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      fontFamily: 'IranSans',
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontWeight: FontWeight.w800),
        displayMedium: TextStyle(fontWeight: FontWeight.w700),
        titleLarge: TextStyle(fontWeight: FontWeight.w700),
        titleMedium: TextStyle(fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(fontSize: 16, height: 1.6),
        bodyMedium: TextStyle(fontSize: 14, height: 1.6),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
    );
  }
}