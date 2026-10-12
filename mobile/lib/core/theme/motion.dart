import 'package:flutter/material.dart';

/// Motion tokens — every transition in the app references these.
class TvMotion {
  TvMotion._();

  static const Duration instant = Duration(milliseconds: 100);
  static const Duration quick = Duration(milliseconds: 200);
  static const Duration standard = Duration(milliseconds: 300);
  static const Duration emphasized = Duration(milliseconds: 450);
  static const Duration celebrate = Duration(milliseconds: 700);

  static const Curve easeOut = Curves.easeOut;
  static const Curve easeOutCubic = Curves.easeOutCubic;
  static const Curve easeInOutCubic = Curves.easeInOutCubic;
  static const Curve easeOutExpo = Curves.easeOutExpo;
  static const Curve elasticOut = Curves.elasticOut;
}