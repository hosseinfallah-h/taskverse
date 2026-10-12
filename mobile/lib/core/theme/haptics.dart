import 'package:flutter/services.dart';

/// Haptic helpers. Every meaningful tap feels like something happened.
class TvHaptics {
  TvHaptics._();

  static Future<void> tap() => HapticFeedback.selectionClick();
  static Future<void> longPress() => HapticFeedback.lightImpact();
  static Future<void> swipe() => HapticFeedback.selectionClick();
  static Future<void> taskComplete() => HapticFeedback.mediumImpact();
  static Future<void> celebrate() => HapticFeedback.heavyImpact();
  static Future<void> error() => HapticFeedback.vibrate();
}