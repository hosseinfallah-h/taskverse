import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';

import 'colors.dart';
import 'motion.dart';
import 'seasons/tv_season.dart';
import 'spacing.dart';
import 'typography.dart';

/// TaskVerse theme factory.
///
/// Each season has its own palette. Each brightness mode (light/dark/amoled)
/// multiplies with that season. So there are 4 × 3 = 12 theme combinations.
class AppTheme {
  AppTheme._();

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  static ThemeData forSeason(
    TvSeason season, {
    Brightness brightness = Brightness.light,
    bool amoled = false,
  }) {
    final palette = TvSeasonPalette.of(season);
    return _base(palette: palette, brightness: brightness, amoled: amoled);
  }

  // Convenience constructors (default season = spring for backwards compat).
  static ThemeData light([TvSeason? season]) =>
      forSeason(season ?? TvSeason.spring, brightness: Brightness.light);

  static ThemeData dark([TvSeason? season]) =>
      forSeason(season ?? TvSeason.spring, brightness: Brightness.dark);

  static ThemeData amoled([TvSeason? season]) => forSeason(
    season ?? TvSeason.spring,
    brightness: Brightness.dark,
    amoled: true,
  );

  // ---------------------------------------------------------------------------
  // Core builder
  // ---------------------------------------------------------------------------

  static ThemeData _base({
    required TvSeasonPalette palette,
    required Brightness brightness,
    required bool amoled,
  }) {
    final isLight = brightness == Brightness.light;

    // Base background/surface depend on brightness mode.
    final background = !isLight
        ? (amoled ? Colors.black : TvColors.night)
        : palette.background;

    final surface = !isLight
        ? (amoled ? const Color(0xFF0A0A0A) : TvColors.nightSoft)
        : palette.surface;

    final surfaceElevated = !isLight
        ? (amoled ? const Color(0xFF151515) : TvColors.nightElevated)
        : palette.surfaceElevated;

    final onBackground = !isLight ? const Color(0xFFEDEFEE) : palette.ink;
    final onSurface = !isLight ? const Color(0xFFEDEFEE) : palette.ink;
    final onSurfaceMuted = !isLight ? const Color(0xFF98A29E) : palette.inkSoft;
    final onSurfaceSubtle = !isLight
        ? const Color(0xFF7A8580)
        : palette.inkMuted;

    final outline = isLight
        ? palette.ink.withValues(alpha: 0.10)
        : Colors.white.withValues(alpha: 0.08);

    final subtleSurface = isLight
        ? palette.background
        : (amoled ? const Color(0xFF080808) : const Color(0xFF19211D));

    final scheme = ColorScheme(
      brightness: brightness,
      primary: palette.brandPrimary,
      onPrimary: Colors.white,
      primaryContainer: palette.brandPrimarySoft,
      onPrimaryContainer: palette.brandPrimaryDeep,
      secondary: palette.accent,
      onSecondary: Colors.white,
      secondaryContainer: palette.accentSoft,
      onSecondaryContainer: palette.brandPrimaryDeep,
      tertiary: TvColors.sunGold,
      onTertiary: const Color(0xFF352407),
      tertiaryContainer: TvColors.sunGoldSoft,
      onTertiaryContainer: const Color(0xFF60420C),
      error: TvColors.rose,
      onError: Colors.white,
      errorContainer: TvColors.roseSoft,
      onErrorContainer: const Color(0xFF8D263C),
      surface: surface,
      onSurface: onSurface,
      surfaceContainerLowest: background,
      surfaceContainerLow: subtleSurface,
      surfaceContainer: surface,
      surfaceContainerHigh: surfaceElevated,
      surfaceContainerHighest: isLight
          ? palette.ink.withValues(alpha: 0.06)
          : Colors.white.withValues(alpha: 0.08),
      onSurfaceVariant: onSurfaceMuted,
      outline: outline,
      outlineVariant: outline.withValues(alpha: 0.6),
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: isLight ? palette.ink : Colors.white,
      onInverseSurface: isLight ? palette.background : palette.ink,
      inversePrimary: palette.brandPrimarySoft,
    );

    final defaultTextTheme = TvTypography.bodyTextTheme(
      brightness: brightness,
      primary: onSurface,
      secondary: onSurfaceMuted,
      subtle: onSurfaceSubtle,
    );

    final outlineBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(TvRadius.lg),
      borderSide: BorderSide(color: outline, width: 1),
    );

    final focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(TvRadius.lg),
      borderSide: BorderSide(color: palette.accent, width: 1.5),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      canvasColor: background,
      fontFamily: TvTypography.fontFamily,
      splashFactory: InkSparkle.splashFactory,
      dividerColor: outline,
      disabledColor: onSurfaceSubtle.withValues(alpha: 0.55),

      textTheme: defaultTextTheme.copyWith(
        displayLarge: TvTypography.display.copyWith(color: onBackground),
        displayMedium: TvTypography.display.copyWith(
          color: onBackground,
          fontSize: 30,
        ),
        displaySmall: TvTypography.headline.copyWith(color: onBackground),
        headlineLarge: TvTypography.headline.copyWith(color: onBackground),
        headlineMedium: TvTypography.headline.copyWith(
          color: onBackground,
          fontSize: 22,
        ),
        headlineSmall: TvTypography.title.copyWith(color: onBackground),
        titleLarge: TvTypography.headline.copyWith(
          color: onSurface,
          fontSize: 20,
        ),
        titleMedium: TvTypography.title.copyWith(color: onSurface),
        titleSmall: TvTypography.label.copyWith(color: onSurfaceMuted),
        bodyLarge: TvTypography.body.copyWith(color: onSurface),
        bodyMedium: TvTypography.bodySmall.copyWith(color: onSurface),
        bodySmall: TvTypography.caption.copyWith(color: onSurfaceMuted),
        labelLarge: TvTypography.label.copyWith(color: onSurface),
        labelMedium: TvTypography.caption.copyWith(color: onSurfaceMuted),
        labelSmall: TvTypography.caption.copyWith(color: onSurfaceSubtle),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: onBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TvTypography.title.copyWith(
          color: onBackground,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: IconThemeData(color: onBackground, size: 22),
      ),

      cardTheme: CardThemeData(
        color: surfaceElevated,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TvRadius.xl),
          side: BorderSide(color: outline.withValues(alpha: 0.75), width: 0.7),
        ),
      ),

      iconTheme: IconThemeData(color: onSurfaceMuted, size: 22),

      dividerTheme: DividerThemeData(color: outline, thickness: 0.8, space: 1),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: subtleSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: TvSpacing.md,
          vertical: TvSpacing.md,
        ),
        hintStyle: TvTypography.bodySmall.copyWith(color: onSurfaceSubtle),
        labelStyle: TvTypography.bodySmall.copyWith(color: onSurfaceMuted),
        floatingLabelStyle: TvTypography.label.copyWith(color: palette.accent),
        border: outlineBorder,
        enabledBorder: outlineBorder,
        focusedBorder: focusedBorder,
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: palette.brandPrimary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TvRadius.lg),
          ),
          textStyle: TvTypography.title.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
          animationDuration: TvMotion.quick,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.brandPrimary,
          minimumSize: const Size.fromHeight(50),
          side: BorderSide(color: palette.brandPrimary.withValues(alpha: 0.35)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TvRadius.lg),
          ),
          textStyle: TvTypography.label.copyWith(fontWeight: FontWeight.w700),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: palette.brandPrimary,
          textStyle: TvTypography.label.copyWith(fontWeight: FontWeight.w700),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: subtleSurface,
        selectedColor: palette.accentSoft,
        labelStyle: TvTypography.label.copyWith(color: onSurface),
        padding: const EdgeInsets.symmetric(
          horizontal: TvSpacing.sm,
          vertical: TvSpacing.xs,
        ),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TvRadius.full),
        ),
        showCheckmark: false,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: isLight ? palette.ink : const Color(0xFF29332D),
        contentTextStyle: TvTypography.bodySmall.copyWith(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TvRadius.lg),
        ),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surfaceElevated,
        modalBackgroundColor: surfaceElevated,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        showDragHandle: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(TvRadius.xl),
          ),
        ),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: palette.accent,
        linearTrackColor: isLight
            ? palette.brandPrimarySoft
            : const Color(0xFF26352D),
        circularTrackColor: isLight
            ? palette.brandPrimarySoft
            : const Color(0xFF26352D),
        linearMinHeight: 5,
      ),

      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: ZoomPageTransitionsBuilder(),
          TargetPlatform.linux: ZoomPageTransitionsBuilder(),
        },
      ),
    );
  }
}
