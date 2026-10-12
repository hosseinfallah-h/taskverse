
import 'package:flutter/material.dart';

/// TaskVerse — Garden at Dawn
///
/// Centralized spacing and geometry tokens.
///
/// Rules:
/// - Use spacing tokens instead of arbitrary widget padding.
/// - Use semantic aliases when the intent is clearer than the raw scale.
/// - Use the radius tokens for cards, sheets, inputs, chips, and buttons.
/// - Keep geometry consistent throughout the application.
abstract final class TvSpacing {
  TvSpacing._();

  // ─────────────────────────────────────────────────────────────────────────
  // CORE SPACING SCALE
  // ─────────────────────────────────────────────────────────────────────────

  /// Tight icon-to-label spacing.
  static const double xxs = 4;

  /// Compact spacing within controls and chips.
  static const double xs = 8;

  /// Spacing between closely related elements.
  static const double sm = 12;

  /// Standard spacing within cards and form fields.
  static const double md = 16;

  /// Primary spacing between content blocks.
  static const double lg = 24;

  /// Large section spacing and visual breathing room.
  static const double xl = 32;

  /// Hero sections and major content separation.
  static const double xxl = 48;

  // ─────────────────────────────────────────────────────────────────────────
  // SEMANTIC SPACING ALIASES
  // ─────────────────────────────────────────────────────────────────────────

  /// Gap between an icon and its label.
  static const double iconLabel = xs;

  /// Gap between related controls.
  static const double controlGap = sm;

  /// Standard card content padding.
  static const double cardPadding = md;

  /// Comfortable padding for premium feature cards.
  static const double cardPaddingLarge = lg;

  /// Gap between items in a task list.
  static const double listItemGap = sm;

  /// Gap between distinct screen sections.
  static const double sectionGap = lg;

  /// Gap between major screen sections.
  static const double sectionGapLarge = xl;

  /// Standard horizontal screen inset.
  static const double screenHorizontal = lg;

  /// Standard vertical screen inset.
  static const double screenVertical = lg;

  /// Compact bottom-navigation spacing.
  static const double navigationGap = xs;

  /// Spacing around floating actions.
  static const double floatingActionInset = lg;

  /// Spacing between a field label and its input.
  static const double fieldLabelGap = xs;

  /// Spacing between form fields.
  static const double formFieldGap = lg;

  /// Spacing between a title and its supporting text.
  static const double titleSubtitleGap = xs;

  /// Small badge or status-indicator inset.
  static const double badgeInset = xs;
}

/// TaskVerse — Garden at Dawn
///
/// Centralized corner-radius tokens.
///
/// Use these tokens instead of hardcoded BorderRadius values.
/// Geometry should feel soft, calm, and tactile rather than generic.
abstract final class TvRadius {
  TvRadius._();

  // ─────────────────────────────────────────────────────────────────────────
  // CORE RADII
  // ─────────────────────────────────────────────────────────────────────────

  /// Small controls and compact surfaces.
  static const double sm = 12;

  /// Inputs, buttons, and standard cards.
  static const double md = 16;

  /// Feature cards and prominent containers.
  static const double lg = 20;

  /// Hero cards, bottom sheets, and large surfaces.
  static const double xl = 28;

  /// Pills, circular controls, and fully rounded chips.
  static const double full = 999;

  // ─────────────────────────────────────────────────────────────────────────
  // SEMANTIC RADIUS ALIASES
  // ─────────────────────────────────────────────────────────────────────────

  static const double card = lg;
  static const double heroCard = xl;
  static const double input = md;
  static const double button = md;
  static const double chip = full;
  static const double badge = full;
  static const double bottomSheet = xl;
  static const double dialog = xl;
  static const double bottomNavigation = full;
  static const double floatingActionButton = full;
  static const double avatar = full;

  // ─────────────────────────────────────────────────────────────────────────
  // REUSABLE BORDER GEOMETRY
  // ─────────────────────────────────────────────────────────────────────────

  static const BorderRadius roundedSmall = BorderRadius.all(
    Radius.circular(sm),
  );

  static const BorderRadius roundedMedium = BorderRadius.all(
    Radius.circular(md),
  );

  static const BorderRadius roundedLarge = BorderRadius.all(
    Radius.circular(lg),
  );

  static const BorderRadius roundedExtraLarge = BorderRadius.all(
    Radius.circular(xl),
  );

  static const BorderRadius pill = BorderRadius.all(
    Radius.circular(full),
  );

  /// Large top corners for modal bottom sheets.
  static const BorderRadius sheetTop = BorderRadius.only(
    topLeft: Radius.circular(xl),
    topRight: Radius.circular(xl),
  );

  /// Rounded top corners for smaller floating panels.
  static const BorderRadius panelTop = BorderRadius.only(
    topLeft: Radius.circular(lg),
    topRight: Radius.circular(lg),
  );

  /// Rounded bottom corners for panels when required.
  static const BorderRadius panelBottom = BorderRadius.only(
    bottomLeft: Radius.circular(lg),
    bottomRight: Radius.circular(lg),
  );
}
