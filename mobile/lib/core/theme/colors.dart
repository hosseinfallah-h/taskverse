import 'package:flutter/material.dart';

/// TaskVerse color tokens — "Garden at Dawn"
/// Never use raw hex in widgets. Always reference these.
class TvColors {
  TvColors._();

  // Brand
  static const Color brandPrimary = Color(0xFF0F5132);
  static const Color brandPrimaryDeep = Color(0xFF083D24);
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

  // Light surfaces
  static const Color sand = Color(0xFFF5F1EA);
  static const Color paper = Color(0xFFFBF9F5);
  static const Color cloud = Color(0xFFFFFFFF);
  static const Color ink = Color(0xFF1A1F1D);
  static const Color inkSoft = Color(0xFF5A6663);
  static const Color inkMuted = Color(0xFF98A29E);

  // Dark surfaces
  static const Color night = Color(0xFF0A0F0D);
  static const Color nightSoft = Color(0xFF151B19);
  static const Color nightElevated = Color(0xFF1F2724);
  static const Color amoled = Color(0xFF000000);

  // Gradients
  static const LinearGradient sunriseGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [sunGold, rose],
  );

  static const LinearGradient gardenGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [mint, brandPrimary],
  );

  static const LinearGradient dawnGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [sand, mintSoft],
  );

  // Priority colors
  static const Map<int, Color> priority = {
    0: rose,
    1: sunGold,
    2: sky,
    3: inkMuted,
  };
}