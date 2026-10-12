
import 'package:flutter/services.dart';

/// Premium haptic feedback for TaskVerse.
///
/// Keeps haptic interactions consistent across the app:
/// - Subtle feedback for navigation and selection.
/// - Clear feedback for task actions.
/// - Strong feedback for celebrations and important moments.
///
/// Haptics are intentionally lightweight. They complement the UI
/// without interrupting the user's flow.
class TvHaptics {
  TvHaptics._();

  // ─────────────────────────────────────────────────────────────────────────
  // Core interactions
  // ─────────────────────────────────────────────────────────────────────────

  /// Subtle feedback for a regular tap.
  static Future<void> tap() => HapticFeedback.selectionClick();

  /// Slightly stronger feedback for a deliberate long press.
  static Future<void> longPress() => HapticFeedback.lightImpact();

  /// Subtle feedback for swipe-based interactions.
  static Future<void> swipe() => HapticFeedback.selectionClick();

  /// Confirmation feedback after completing a task.
  static Future<void> taskComplete() => HapticFeedback.mediumImpact();

  /// Strong feedback for celebrations and major achievements.
  static Future<void> celebrate() => HapticFeedback.heavyImpact();

  /// Error feedback for invalid or unsuccessful actions.
  static Future<void> error() => HapticFeedback.vibrate();

  // ─────────────────────────────────────────────────────────────────────────
  // Semantic interactions
  // ─────────────────────────────────────────────────────────────────────────

  /// Selecting a tab, filter, or navigation destination.
  static Future<void> selection() => HapticFeedback.selectionClick();

  /// Toggling a switch, checkbox, or similar control.
  static Future<void> toggle() => HapticFeedback.selectionClick();

  /// Reordering an item or entering a drag interaction.
  static Future<void> dragStart() => HapticFeedback.lightImpact();

  /// Dropping an item into its new position.
  static Future<void> dragEnd() => HapticFeedback.mediumImpact();

  /// Adding a new task or creating an item.
  static Future<void> itemCreated() => HapticFeedback.lightImpact();

  /// Saving changes or confirming a successful action.
  static Future<void> success() => HapticFeedback.mediumImpact();

  /// A lightweight acknowledgement for secondary actions.
  static Future<void> confirm() => HapticFeedback.selectionClick();

  /// Opening a contextual menu or secondary action panel.
  static Future<void> contextAction() => HapticFeedback.lightImpact();

  /// A warning that requires attention but is not a failure.
  static Future<void> warning() => HapticFeedback.mediumImpact();

  /// A destructive action, such as deleting an item.
  static Future<void> destructiveAction() => HapticFeedback.heavyImpact();

  // ─────────────────────────────────────────────────────────────────────────
  // Convenience aliases
  // ─────────────────────────────────────────────────────────────────────────

  /// Alias for [taskComplete], useful in achievement-related flows.
  static Future<void> achievement() => taskComplete();

  /// Alias for [tap], useful for buttons and compact controls.
  static Future<void> buttonTap() => tap();
}
