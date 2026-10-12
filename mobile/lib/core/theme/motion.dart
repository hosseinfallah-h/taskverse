
import 'package:flutter/material.dart';

/// TaskVerse — Garden at Dawn
///
/// Centralized motion design system.
///
/// Principles:
/// - Motion communicates hierarchy, causality, and state.
/// - Small interactions remain fast and tactile.
/// - Large transitions feel fluid without delaying the user.
/// - Repeated animations use predictable timing.
/// - Celebration motion is reserved for meaningful achievements.
///
/// Use these tokens instead of hardcoded durations and curves.
abstract final class TvMotion {
  TvMotion._();

  // ─────────────────────────────────────────────────────────────────────────
  // CORE DURATIONS
  // ─────────────────────────────────────────────────────────────────────────

  /// Immediate visual acknowledgment.
  static const Duration instant = Duration(milliseconds: 100);

  /// Buttons, chips, toggles, and lightweight feedback.
  static const Duration quick = Duration(milliseconds: 200);

  /// Standard UI transitions and component state changes.
  static const Duration standard = Duration(milliseconds: 300);

  /// Hero transitions, larger containers, and emphasized interactions.
  static const Duration emphasized = Duration(milliseconds: 450);

  /// Achievements, level-ups, and important celebrations.
  static const Duration celebrate = Duration(milliseconds: 700);

  // ─────────────────────────────────────────────────────────────────────────
  // CURVES
  // ─────────────────────────────────────────────────────────────────────────

  /// Natural deceleration for everyday UI.
  static const Curve easeOut = Curves.easeOut;

  /// Confident entrance with a smooth finish.
  static const Curve easeOutCubic = Curves.easeOutCubic;

  /// Balanced movement between two states.
  static const Curve easeInOutCubic = Curves.easeInOutCubic;

  /// Fast entrance with a long, subtle finish.
  static const Curve easeOutExpo = Curves.easeOutExpo;

  /// Playful spring-like feedback.
  ///
  /// Reserve for small, expressive interactions.
  static const Curve elasticOut = Curves.elasticOut;

  // ─────────────────────────────────────────────────────────────────────────
  // SEMANTIC DURATIONS
  // ─────────────────────────────────────────────────────────────────────────

  static const Duration tap = instant;
  static const Duration press = quick;
  static const Duration toggle = quick;
  static const Duration tooltip = quick;

  static const Duration cardExpand = standard;
  static const Duration cardCollapse = standard;
  static const Duration progressUpdate = standard;
  static const Duration tabSwitch = standard;
  static const Duration filterChange = standard;

  static const Duration pageTransition = emphasized;
  static const Duration heroTransition = emphasized;
  static const Duration sheetEnter = emphasized;
  static const Duration sheetExit = standard;
  static const Duration dialogEnter = standard;
  static const Duration dialogExit = quick;

  static const Duration taskComplete = emphasized;
  static const Duration achievementReveal = celebrate;
  static const Duration levelUp = celebrate;

  // ─────────────────────────────────────────────────────────────────────────
  // SEMANTIC CURVES
  // ─────────────────────────────────────────────────────────────────────────

  static const Curve enter = easeOutCubic;
  static const Curve exit = easeOut;
  static const Curve page = easeInOutCubic;
  static const Curve container = easeInOutCubic;
  static const Curve progress = easeOutCubic;
  static const Curve reveal = easeOutExpo;
  static const Curve bounce = elasticOut;

  // ─────────────────────────────────────────────────────────────────────────
  // STAGGERED ENTRANCES
  // ─────────────────────────────────────────────────────────────────────────

  /// Delay between adjacent elements in a staggered sequence.
  static const Duration stagger = Duration(milliseconds: 20);

  /// Slightly more pronounced stagger for major sections.
  static const Duration sectionStagger = Duration(milliseconds: 40);

  /// Maximum recommended delay for ordinary list entrances.
  static const Duration maxStaggerDelay = Duration(milliseconds: 240);

  /// Calculates a capped stagger delay for a zero-based item index.
  ///
  /// Example:
  /// TvMotion.staggerDelay(index)
  static Duration staggerDelay(int index) {
    final safeIndex = index < 0 ? 0 : index;
    final delay = stagger.inMilliseconds * safeIndex;
    final cappedDelay = delay > maxStaggerDelay.inMilliseconds
        ? maxStaggerDelay.inMilliseconds
        : delay;

    return Duration(milliseconds: cappedDelay);
  }

  /// Calculates a capped delay for major screen sections.
  static Duration sectionDelay(int index) {
    final safeIndex = index < 0 ? 0 : index;
    final delay = sectionStagger.inMilliseconds * safeIndex;
    final cappedDelay = delay > maxStaggerDelay.inMilliseconds
        ? maxStaggerDelay.inMilliseconds
        : delay;

    return Duration(milliseconds: cappedDelay);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // INTERACTION SCALE
  // ─────────────────────────────────────────────────────────────────────────

  /// Scale applied while a control is pressed.
  static const double pressScale = 0.97;

  /// Subtle scale for cards during touch feedback.
  static const double cardPressScale = 0.985;

  /// Resting scale for standard interactive controls.
  static const double restingScale = 1.0;

  /// Slight overshoot for expressive success feedback.
  static const double celebrationScale = 1.045;

  // ─────────────────────────────────────────────────────────────────────────
  // SLIDE DISTANCES
  // ─────────────────────────────────────────────────────────────────────────

  /// Small vertical offset for content entrances.
  static const double slideSmall = 8;

  /// Standard offset for cards and list items.
  static const double slideMedium = 16;

  /// Larger offset for prominent surfaces.
  static const double slideLarge = 28;

  // ─────────────────────────────────────────────────────────────────────────
  // REPEATABLE MOTION
  // ─────────────────────────────────────────────────────────────────────────

  /// A restrained breathing cycle for floating actions.
  static const Duration breathe = Duration(milliseconds: 3000);

  /// Ambient shimmer duration.
  static const Duration shimmer = Duration(milliseconds: 1400);

  /// Soft loading pulse.
  static const Duration loadingPulse = Duration(milliseconds: 1200);

  /// Progress-ring animation.
  static const Duration progressRing = emphasized;

  /// Ambient glow transition.
  static const Duration glow = emphasized;

  // ─────────────────────────────────────────────────────────────────────────
  // ACCESSIBILITY
  // ─────────────────────────────────────────────────────────────────────────

  /// Returns a zero-duration animation when reduced motion is requested.
  ///
  /// Check MediaQuery.disableAnimations at the call site and pass its value.
  static Duration accessibleDuration(
    Duration duration, {
    required bool reduceMotion,
  }) {
    return reduceMotion ? Duration.zero : duration;
  }

  /// Chooses an appropriate curve when reduced motion is requested.
  static Curve accessibleCurve({
    required bool reduceMotion,
    Curve fallback = easeOutCubic,
  }) {
    return reduceMotion ? Curves.linear : fallback;
  }
}
