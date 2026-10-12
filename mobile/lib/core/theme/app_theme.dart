import 'package:flutter/material.dart';

import 'colors.dart';
import 'typography.dart';

/// TaskVerse theme factory: light, dark, AMOLED.
/// Never use raw Colors.* in widgets — always read from Theme.of(context).
class AppTheme {
  AppTheme._();

  static ThemeData light() => _base(
        brightness: Brightness.light,
        background: TvColors.sand,
        surface: TvColors.paper,
        surfaceElevated: TvColors.cloud,
        onBackground: TvColors.ink,
        onSurface: TvColors.ink,
        onSurfaceMuted: TvColors.inkSoft,
        onSurfaceSubtle: TvColors.inkMuted,
      );

  static ThemeData dark() => _base(
        brightness: Brightness.dark,
        background: TvColors.night,
        surface: TvColors.nightSoft,
        surfaceElevated: TvColors.nightElevated,
        onBackground: const Color(0xFFEDEFEE),
        onSurface: const Color(0xFFEDEFEE),
        onSurfaceMuted: const Color(0xFF98A29E),
        onSurfaceSubtle: const Color(0xFF5A6663),
      );

  static ThemeData amoled() => _base(
        brightness: Brightness.dark,
        background: TvColors.amoled,
        surface: TvColors.amoled,
        surfaceElevated: const Color(0xFF0A0A0A),
        onBackground: const Color(0xFFFFFFFF),
        onSurface: const Color(0xFFFFFFFF),
        onSurfaceMuted: const Color(0xFF98A29E),
        onSurfaceSubtle: const Color(0xFF5A6663),
      );

  static ThemeData _base({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color surfaceElevated,
    required Color onBackground,
    required Color onSurface,
    required Color onSurfaceMuted,
    required Color onSurfaceSubtle,
  }) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: TvColors.brandPrimary,
      onPrimary: Colors.white,
      secondary: TvColors.mint,
      onSecondary: TvColors.ink,
      tertiary: TvColors.sunGold,
      onTertiary: TvColors.ink,
      error: TvColors.rose,
      onError: Colors.white,
      surface: surface,
      onSurface: onSurface,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      fontFamily: TvTypography.fontFamily,
      splashFactory: InkSparkle.splashFactory,

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: onBackground,
      ),

      cardTheme: CardThemeData(
        color: surfaceElevated,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),

      textTheme: TextTheme(
        displayLarge: TvTypography.display.copyWith(color: onBackground),
        displayMedium: TvTypography.headline.copyWith(color: onBackground),
        titleLarge: TvTypography.headline.copyWith(color: onBackground),
        titleMedium: TvTypography.title.copyWith(color: onSurface),
        bodyLarge: TvTypography.body.copyWith(color: onSurface),
        bodyMedium: TvTypography.body.copyWith(color: onSurfaceMuted),
        labelLarge: TvTypography.label.copyWith(color: onSurface),
        labelMedium: TvTypography.caption.copyWith(color: onSurfaceSubtle),
      ),

      iconTheme: IconThemeData(color: onSurface, size: 22),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: TvColors.mint, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: TvColors.brandPrimary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: TvTypography.title.copyWith(fontWeight: FontWeight.w700),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: surface,
        selectedColor: TvColors.mintSoft,
        labelStyle: TvTypography.label,
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}