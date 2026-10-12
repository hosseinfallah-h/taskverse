import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';

/// Four seasons of the Persian year.
enum TvSeason {
  spring, // بهار
  summer, // تابستان
  autumn, // پاییز
  winter; // زمستان

  /// Auto-detect the season from the current Jalali date.
  static TvSeason fromJalaliDate(Jalali j) {
    final m = j.month; // 1..12
    if (m >= 1 && m <= 3) return TvSeason.spring; // Farvardin–Khordad
    if (m >= 4 && m <= 6) return TvSeason.summer; // Tir–Shahrivar
    if (m >= 7 && m <= 9) return TvSeason.autumn; // Mehr–Azar
    return TvSeason.winter; // Dey–Esfand
  }

  static TvSeason current() => fromJalaliDate(Jalali.now());

  String get faLabel {
    switch (this) {
      case TvSeason.spring:
        return 'بهار';
      case TvSeason.summer:
        return 'تابستان';
      case TvSeason.autumn:
        return 'پاییز';
      case TvSeason.winter:
        return 'زمستان';
    }
  }

  String get faTagline {
    switch (this) {
      case TvSeason.spring:
        return 'شکوفه‌ها و شروع تازه';
      case TvSeason.summer:
        return 'گرما و انرژی';
      case TvSeason.autumn:
        return 'برگ‌ریزان و آرامش';
      case TvSeason.winter:
        return 'سکوت و درون‌نگری';
    }
  }

  IconData get icon {
    switch (this) {
      case TvSeason.spring:
        return Icons.local_florist_rounded;
      case TvSeason.summer:
        return Icons.wb_sunny_rounded;
      case TvSeason.autumn:
        return Icons.park_rounded;
      case TvSeason.winter:
        return Icons.ac_unit_rounded;
    }
  }
}

/// Palette tokens that change per season.
/// These override the base TvColors in the active theme.
@immutable
class TvSeasonPalette {
  const TvSeasonPalette({
    required this.season,
    required this.brandPrimary,
    required this.brandPrimaryDeep,
    required this.brandPrimarySoft,
    required this.accent,
    required this.accentSoft,
    required this.background,
    required this.surface,
    required this.surfaceElevated,
    required this.ink,
    required this.inkSoft,
    required this.inkMuted,
    required this.headerGradient,
    required this.heroGlow,
    required this.heroAsset,
  });

  final TvSeason season;
  final Color brandPrimary;
  final Color brandPrimaryDeep;
  final Color brandPrimarySoft;
  final Color accent;
  final Color accentSoft;
  final Color background;
  final Color surface;
  final Color surfaceElevated;
  final Color ink;
  final Color inkSoft;
  final Color inkMuted;
  final LinearGradient headerGradient;
  final Color heroGlow;
  final String heroAsset; // path under assets/illustrations/ (Block C)

  // ---------------------------------------------------------------------------
  // SPRING — fresh, blooming, Persian New Year energy
  // ---------------------------------------------------------------------------
  static const spring = TvSeasonPalette(
    season: TvSeason.spring,
    brandPrimary: Color(0xFF4C8B54), // leaf green
    brandPrimaryDeep: Color(0xFF356B3D),
    brandPrimarySoft: Color(0xFFDDEBD8),
    accent: Color(0xFFF48FB1), // blossom pink
    accentSoft: Color(0xFFFCE4EC),
    background: Color(0xFFF7F4EA), // warm cream
    surface: Color(0xFFFDFBF5),
    surfaceElevated: Color(0xFFFFFFFF),
    ink: Color(0xFF1E2620),
    inkSoft: Color(0xFF5A665C),
    inkMuted: Color(0xFF98A29A),
    headerGradient: LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: [
        Color(0xFFA8D5BA), // soft mint sky
        Color(0xFFF4C2D7), // blossom pink
        Color(0xFFF7F4EA),
      ],
      stops: [0.0, 0.55, 1.0],
    ),
    heroGlow: Color(0xFFF48FB1),
    heroAsset: 'assets/illustrations/spring_hero.png',
  );

  // ---------------------------------------------------------------------------
  // SUMMER — warm, bright, high energy
  // ---------------------------------------------------------------------------
  static const summer = TvSeasonPalette(
    season: TvSeason.summer,
    brandPrimary: Color(0xFFE89536), // warm orange
    brandPrimaryDeep: Color(0xFFB36F1F),
    brandPrimarySoft: Color(0xFFFCE9C9),
    accent: Color(0xFF00C896), // fresh mint
    accentSoft: Color(0xFFCCF2E5),
    background: Color(0xFFFFF7EA),
    surface: Color(0xFFFFFDF7),
    surfaceElevated: Color(0xFFFFFFFF),
    ink: Color(0xFF2A2018),
    inkSoft: Color(0xFF6B5B47),
    inkMuted: Color(0xFFA89A85),
    headerGradient: LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: [
        Color(0xFFF9C57A), // golden hour
        Color(0xFFF38D5A), // warm sunset
        Color(0xFFFFF7EA),
      ],
      stops: [0.0, 0.55, 1.0],
    ),
    heroGlow: Color(0xFFE89536),
    heroAsset: 'assets/illustrations/summer_hero.png',
  );

  // ---------------------------------------------------------------------------
  // AUTUMN — warm golden, cozy, falling leaves
  // ---------------------------------------------------------------------------
  static const autumn = TvSeasonPalette(
    season: TvSeason.autumn,
    brandPrimary: Color(0xFFB36F1F), // burnt sienna
    brandPrimaryDeep: Color(0xFF7A4A12),
    brandPrimarySoft: Color(0xFFF5DDBA),
    accent: Color(0xFFC95C3A), // maple red
    accentSoft: Color(0xFFF7D9CC),
    background: Color(0xFFF5EEE1),
    surface: Color(0xFFFBF6ED),
    surfaceElevated: Color(0xFFFFFFFF),
    ink: Color(0xFF2A2018),
    inkSoft: Color(0xFF6B5B47),
    inkMuted: Color(0xFFA89A85),
    headerGradient: LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: [
        Color(0xFFE0A66B), // warm amber
        Color(0xFFB36F1F), // deep amber
        Color(0xFFF5EEE1),
      ],
      stops: [0.0, 0.55, 1.0],
    ),
    heroGlow: Color(0xFFC95C3A),
    heroAsset: 'assets/illustrations/autumn_hero.png',
  );

  // ---------------------------------------------------------------------------
  // WINTER — cool, serene, quiet
  // ---------------------------------------------------------------------------
  static const winter = TvSeasonPalette(
    season: TvSeason.winter,
    brandPrimary: Color(0xFF4A6E96), // slate blue
    brandPrimaryDeep: Color(0xFF2F4C6E),
    brandPrimarySoft: Color(0xFFD9E3EE),
    accent: Color(0xFF7FB8D9), // ice blue
    accentSoft: Color(0xFFD9E9F3),
    background: Color(0xFFF2F4F8),
    surface: Color(0xFFFAFBFD),
    surfaceElevated: Color(0xFFFFFFFF),
    ink: Color(0xFF1B2430),
    inkSoft: Color(0xFF55606E),
    inkMuted: Color(0xFF939CAB),
    headerGradient: LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: [
        Color(0xFFB8CCDD), // frosty sky
        Color(0xFF7A93B8), // slate dusk
        Color(0xFFF2F4F8),
      ],
      stops: [0.0, 0.55, 1.0],
    ),
    heroGlow: Color(0xFF7FB8D9),
    heroAsset: 'assets/illustrations/winter_hero.png',
  );

  static TvSeasonPalette of(TvSeason s) {
    switch (s) {
      case TvSeason.spring:
        return spring;
      case TvSeason.summer:
        return summer;
      case TvSeason.autumn:
        return autumn;
      case TvSeason.winter:
        return winter;
    }
  }
}
