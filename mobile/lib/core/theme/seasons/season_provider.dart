import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'tv_season.dart';

/// User's season preference.
/// null = auto-detect from Jalali date.
final seasonOverrideProvider = StateProvider<TvSeason?>((ref) => null);

/// Active season (auto or overridden).
final activeSeasonProvider = Provider<TvSeason>((ref) {
  final override = ref.watch(seasonOverrideProvider);
  return override ?? TvSeason.current();
});

/// Active season palette.
final activePaletteProvider = Provider<TvSeasonPalette>((ref) {
  return TvSeasonPalette.of(ref.watch(activeSeasonProvider));
});
