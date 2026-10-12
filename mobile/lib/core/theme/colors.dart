
import 'package:flutter/material.dart';

/// TaskVerse — Garden at Dawn
///
/// Central source of truth for the application's visual color language.
///
/// Principles:
/// - Never introduce ad hoc colors in UI widgets.
/// - Prefer semantic tokens over raw color values.
/// - Keep the light theme warm and the dark themes atmospheric.
/// - AMOLED surfaces remain genuinely black.
/// - Use restrained gradients and colored ambient shadows.
///
/// Existing brand colors and gradient definitions are preserved.
abstract final class TvColors {
  TvColors._();

  // ─────────────────────────────────────────────────────────────────────────
  // BRAND
  // ─────────────────────────────────────────────────────────────────────────

  static const Color brandPrimary = Color(0xFF0F5132);
  static const Color brandPrimaryDeep = Color(0xFF083D24);
  static const Color brandPrimarySoft = Color(0xFFD5E5DE);

  static const Color mint = Color(0xFF00C896);
  static const Color mintSoft = Color(0xFFC8F3E4);

  static const Color sunGold = Color(0xFFF2B33D);
  static const Color sunGoldSoft = Color(0xFFFCEFCE);

  static const Color rose = Color(0xFFE85D75);
  static const Color roseSoft = Color(0xFFFBD9E0);

  static const Color sky = Color(0xFF5AA9E6);
  static const Color skySoft = Color(0xFFD6E9F7);

  static const Color plum = Color(0xFF7A5AA8);
  static const Color plumSoft = Color(0xFFE5DDF0);

  // ─────────────────────────────────────────────────────────────────────────
  // LIGHT SURFACES
  // ─────────────────────────────────────────────────────────────────────────

  /// Warm canvas. Never replace with pure white.
  static const Color sand = Color(0xFFF5F1EA);

  static const Color sandDeep = Color(0xFFEDE7DC);
  static const Color paper = Color(0xFFFBF9F5);

  /// Reserve for small elevated surfaces and exceptional highlights.
  static const Color cloud = Color(0xFFFFFFFF);

  static const Color ink = Color(0xFF1A1F1D);
  static const Color inkSoft = Color(0xFF5A6663);
  static const Color inkMuted = Color(0xFF98A29E);

  // ─────────────────────────────────────────────────────────────────────────
  // DARK SURFACES
  // ─────────────────────────────────────────────────────────────────────────

  static const Color night = Color(0xFF0A0F0D);
  static const Color nightSoft = Color(0xFF151B19);
  static const Color nightElevated = Color(0xFF1F2724);

  /// True AMOLED black.
  static const Color amoled = Color(0xFF000000);

  // ─────────────────────────────────────────────────────────────────────────
  // THEME-AWARE SEMANTIC SURFACES
  // ─────────────────────────────────────────────────────────────────────────

  /// Main page background for the selected theme.
  static Color background(Brightness brightness, {bool isAmoled = false}) {
    if (isAmoled) return amoled;

    return brightness == Brightness.light ? sand : night;
  }

  /// Standard card surface.
  static Color surface(Brightness brightness, {bool isAmoled = false}) {
    if (isAmoled) return nightSoft;

    return brightness == Brightness.light ? paper : nightSoft;
  }

  /// Elevated card, dialog, or sheet surface.
  static Color elevatedSurface(
    Brightness brightness, {
    bool isAmoled = false,
  }) {
    if (isAmoled) return nightElevated;

    return brightness == Brightness.light ? cloud : nightElevated;
  }

  /// Primary readable text.
  static Color primaryText(
    Brightness brightness, {
    bool isAmoled = false,
  }) {
    if (brightness == Brightness.light) return ink;

    return isAmoled ? cloud : Color(0xFFF0F4F1);
  }

  /// Secondary readable text.
  static Color secondaryText(
    Brightness brightness, {
    bool isAmoled = false,
  }) {
    if (brightness == Brightness.light) return inkSoft;

    return isAmoled ? Color(0xFFB0BBB5) : Color(0xFFABB7B0);
  }

  /// Subtle borders and dividers.
  static Color outline(Brightness brightness, {bool isAmoled = false}) {
    if (brightness == Brightness.light) return sandDeep;

    return isAmoled ? Color(0xFF292F2C) : Color(0xFF303A35);
  }

  /// Low-emphasis disabled content.
  static Color disabledContent(
    Brightness brightness, {
    bool isAmoled = false,
  }) {
    if (brightness == Brightness.light) return inkMuted;

    return isAmoled ? Color(0xFF666D69) : Color(0xFF737E77);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // GRADIENTS
  // ─────────────────────────────────────────────────────────────────────────

  /// The signature dawn atmosphere.
  static const LinearGradient dawnGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFBEEF5),
      Color(0xFFE5F5EE),
      Color(0xFFF5F1EA),
    ],
    stops: [0.0, 0.5, 1.0],
  );

  /// Primary actions and restrained garden accents.
  static const LinearGradient gardenGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [mint, brandPrimary],
  );

  /// Rewards and celebration moments.
  static const LinearGradient sunriseGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [sunGold, rose],
  );

  /// A quieter header treatment for light screens.
  static const LinearGradient headerGradientLight = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFBEEF5),
      Color(0xFFF5F1EA),
    ],
  );

  // ─────────────────────────────────────────────────────────────────────────
  // PRIORITIES
  // ─────────────────────────────────────────────────────────────────────────

  /// P0 = urgent, P1 = high, P2 = normal, P3 = low.
  // Priority colors
  static const Map<int, Color> priority = {
    0: rose,
    1: sunGold,
    2: sky,
    3: inkMuted,
  };

  // (theme-aware text color helpers already exist above — see lines 99-135)

  static Color priorityColor(int level) => priority[level] ?? inkMuted;

  // ─────────────────────────────────────────────────────────────────────────
  // FEEDBACK & STATUS
  // ─────────────────────────────────────────────────────────────────────────

  static const Color success = mint;
  static const Color successSurface = mintSoft;

  static const Color warning = sunGold;
  static const Color warningSurface = sunGoldSoft;

  static const Color error = rose;
  static const Color errorSurface = roseSoft;

  static const Color information = sky;
  static const Color informationSurface = skySoft;

  // ─────────────────────────────────────────────────────────────────────────
  // AMBIENT SHADOWS
  //
  // These are immutable presets. Avoid black shadows and heavy elevation.
  // ─────────────────────────────────────────────────────────────────────────

  static const List<BoxShadow> cardGlow = [
    BoxShadow(
      color: Color(0x0D0F5132),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> mintGlow = [
    BoxShadow(
      color: Color(0x5200C896),
      blurRadius: 32,
      offset: Offset(0, 12),
    ),
  ];

  static const List<BoxShadow> goldGlow = [
    BoxShadow(
      color: Color(0x4DF2B33D),
      blurRadius: 28,
      offset: Offset(0, 10),
    ),
  ];

  static const List<BoxShadow> floatingShadow = [
    BoxShadow(
      color: Color(0x1A0F5132),
      blurRadius: 40,
      offset: Offset(0, 16),
    ),
  ];

  // ─────────────────────────────────────────────────────────────────────────
  // ACCESSIBILITY HELPERS
  // ─────────────────────────────────────────────────────────────────────────

  /// Select a readable foreground for common solid brand surfaces.
  ///
  /// Use this for known brand fills; it is not a general contrast calculator.
  static Color onBrandSurface(Color background) {
    if (background == sunGold ||
        background == mint ||
        background == mintSoft ||
        background == sunGoldSoft ||
        background == brandPrimarySoft) {
      return ink;
    }

    return cloud;
  }
}
