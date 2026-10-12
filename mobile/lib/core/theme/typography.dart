import 'package:flutter/material.dart';

import 'colors.dart';

/// TaskVerse — Garden at Dawn
///
/// Persian-first typography system using Vazirmatn.
///
/// Design principles:
/// - Generous line height for Persian readability.
/// - Clear hierarchy from screen heroes to metadata.
/// - Consistent weights, numerals, and alignment.
/// - Semantic styles for reusable UI components.
/// - Theme-aware colors without duplicating the type scale.
abstract final class TvTypography {
  TvTypography._();

  // ─────────────────────────────────────────────────────────────────────────
  // FONT FAMILY & WEIGHTS
  // ─────────────────────────────────────────────────────────────────────────

  static const String fontFamily = 'Vazirmatn';

  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight bold = FontWeight.w700;

  // ─────────────────────────────────────────────────────────────────────────
  // DISPLAY
  // Screen heroes, welcome messages, and primary metrics.
  // ─────────────────────────────────────────────────────────────────────────

  static const TextStyle display = TextStyle(
    fontFamily: fontFamily,
    fontSize: 34,
    fontWeight: bold,
    height: 1.4,
    letterSpacing: -0.5,
  );

  /// A slightly smaller hero for compact screens.
  static const TextStyle displaySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 30,
    fontWeight: bold,
    height: 1.4,
    letterSpacing: -0.4,
  );

  // ─────────────────────────────────────────────────────────────────────────
  // HEADLINES
  // Screen titles and major section headings.
  // ─────────────────────────────────────────────────────────────────────────

  static const TextStyle headline = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: bold,
    height: 1.4,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: bold,
    height: 1.45,
  );

  // ─────────────────────────────────────────────────────────────────────────
  // TITLES
  // Card titles, dialogs, and prominent list items.
  // ─────────────────────────────────────────────────────────────────────────

  static const TextStyle title = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: medium,
    height: 1.5,
  );

  static const TextStyle titleEmphasized = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: bold,
    height: 1.5,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: medium,
    height: 1.55,
  );

  // ─────────────────────────────────────────────────────────────────────────
  // BODY
  // Descriptions, task details, and readable content.
  // ─────────────────────────────────────────────────────────────────────────

  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: regular,
    height: 1.7,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: medium,
    height: 1.7,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: regular,
    height: 1.6,
  );

  static const TextStyle bodySmallMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: medium,
    height: 1.6,
  );

  // ─────────────────────────────────────────────────────────────────────────
  // LABELS
  // Buttons, category chips, filters, and compact controls.
  // ─────────────────────────────────────────────────────────────────────────

  static const TextStyle label = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: medium,
    height: 1.5,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: medium,
    height: 1.5,
  );

  static const TextStyle labelEmphasized = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: bold,
    height: 1.5,
  );

  // ─────────────────────────────────────────────────────────────────────────
  // CAPTIONS
  // Timestamps, supporting details, and low-emphasis metadata.
  // ─────────────────────────────────────────────────────────────────────────

  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: regular,
    height: 1.5,
  );

  static const TextStyle captionMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: medium,
    height: 1.5,
  );

  // ─────────────────────────────────────────────────────────────────────────
  // NUMERALS
  // Progress rings, XP, streaks, counts, and statistics.
  // ─────────────────────────────────────────────────────────────────────────

  static const TextStyle numericDisplay = TextStyle(
    fontFamily: fontFamily,
    fontSize: 36,
    fontWeight: bold,
    height: 1.1,
    letterSpacing: -1,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle numericMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: bold,
    height: 1.15,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle numericSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: bold,
    height: 1.2,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle numericCaption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: medium,
    height: 1.4,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  // ─────────────────────────────────────────────────────────────────────────
  // SPECIALIZED SEMANTIC STYLES
  // ─────────────────────────────────────────────────────────────────────────

  /// Large text for onboarding and welcome screens.
  static const TextStyle greeting = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: bold,
    height: 1.45,
  );

  /// Supporting text under a screen heading.
  static const TextStyle subtitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: regular,
    height: 1.75,
  );

  /// Text inside compact task metadata.
  static const TextStyle metadata = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: regular,
    height: 1.5,
  );

  /// Persian-friendly text style for input fields.
  static const TextStyle input = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: regular,
    height: 1.6,
  );

  /// Text entered into search fields.
  static const TextStyle search = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: regular,
    height: 1.6,
  );

  /// Emphasized text for primary actions.
  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: bold,
    height: 1.5,
  );

  /// Small text for badges, streaks, and compact counters.
  static const TextStyle badge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: bold,
    height: 1.4,
  );

  // ─────────────────────────────────────────────────────────────────────────
  // COLOR HELPERS
  // ─────────────────────────────────────────────────────────────────────────

  /// Applies the correct foreground color for the current theme.
  ///
  /// Pass the resulting style to Text or merge it with another style.
  static TextStyle primaryText(
    Brightness brightness, {
    bool isAmoled = false,
    TextStyle? base,
  }) {
    return (base ?? body).copyWith(
      color: TvColors.primaryText(
        brightness,
        isAmoled: isAmoled,
      ),
    );
  }

  static TextStyle secondaryText(
    Brightness brightness, {
    bool isAmoled = false,
    TextStyle? base,
  }) {
    return (base ?? bodySmall).copyWith(
      color: TvColors.secondaryText(
        brightness,
        isAmoled: isAmoled,
      ),
    );
  }

  static TextStyle disabledText(
    Brightness brightness, {
    bool isAmoled = false,
    TextStyle? base,
  }) {
    return (base ?? bodySmall).copyWith(
      color: TvColors.disabledContent(
        brightness,
        isAmoled: isAmoled,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ACCESSIBILITY
  // ─────────────────────────────────────────────────────────────────────────

  /// Creates a style with a minimum readable font size.
  ///
  /// Intended for secondary UI text, not large display typography.
  static TextStyle accessibleSmall({
    Color? color,
    FontWeight weight = regular,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,
      fontWeight: weight,
      height: 1.6,
      color: color,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // THEME-AWARE TEXT THEME
  // Builds a complete Material TextTheme for a given brightness.
  // ─────────────────────────────────────────────────────────────────────────

  /// Builds a complete [TextTheme] for the given theme.
  static TextTheme bodyTextTheme({
    required Brightness brightness,
    required Color primary,
    required Color secondary,
    required Color subtle,
  }) {
    TextStyle p(TextStyle s) => s.copyWith(color: primary);
    TextStyle sec(TextStyle s) => s.copyWith(color: secondary);
    TextStyle sub(TextStyle s) => s.copyWith(color: subtle);

    return TextTheme(
      // Display
      displayLarge: p(display),
      displayMedium: p(displaySmall),
      displaySmall: p(headline),

      // Headlines
      headlineLarge: p(headline),
      headlineMedium: p(headlineSmall),
      headlineSmall: p(title),

      // Titles
      titleLarge: p(titleEmphasized),
      titleMedium: p(title),
      titleSmall: sec(titleSmall),

      // Body
      bodyLarge: p(body),
      bodyMedium: sec(bodySmall),
      bodySmall: sub(caption),

      // Labels
      labelLarge: p(label),
      labelMedium: sec(labelSmall),
      labelSmall: sub(captionMedium),
    );
  }
}
