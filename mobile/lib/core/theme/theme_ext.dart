import 'package:flutter/material.dart';

import 'seasons/tv_season.dart';

/// Context-aware color access. Reads from the active ThemeData so
/// seasonal palettes propagate to every widget automatically.
extension TvThemeX on BuildContext {
  ColorScheme get scheme => Theme.of(this).colorScheme;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  /// Dominant background (sand / night / amoled).
  Color get bg => Theme.of(this).scaffoldBackgroundColor;

  /// Card surface.
  Color get surface => scheme.surface;

  /// Elevated surface.
  Color get surfaceHi => scheme.surfaceContainerHigh;

  /// Primary text.
  Color get ink => scheme.onSurface;

  /// Secondary text.
  Color get inkSoft => scheme.onSurfaceVariant;

  /// Tertiary / muted text.
  Color get inkMuted => scheme.onSurfaceVariant.withValues(alpha: 0.75);

  /// Brand primary (changes per season).
  Color get brand => scheme.primary;

  /// Brand deep variant.
  Color get brandDeep => scheme.onPrimaryContainer;

  /// Brand soft surface.
  Color get brandSoft => scheme.primaryContainer;

  /// Accent (season-specific: mint / coral / amber / ice).
  Color get accent => scheme.secondary;

  /// Accent soft surface.
  Color get accentSoft => scheme.secondaryContainer;

  /// Currently active season.
  TvSeason get season => TvSeasonPalette.of(_seasonFromScheme(scheme)).season;

  TvSeason _seasonFromScheme(ColorScheme s) {
    // Reverse-engineer season from primary color (cheap + safe).
    final p = s.primary.toARGB32();
    for (final season in TvSeason.values) {
      if (TvSeasonPalette.of(season).brandPrimary.toARGB32() == p) {
        return season;
      }
    }
    return TvSeason.spring;
  }
}
