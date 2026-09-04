import 'package:flutter/material.dart';

/// Central color palette for the app.
///
/// Every color used across the theme and widgets lives here so a single file
/// change ripples everywhere. Derived (non-const) tints are exposed as getters;
/// everything else is a compile-time constant.
abstract final class AppColors {
  // ─── Core palette ─────────────────────────────────────────────────────────
  /// Near-black navy — body text on light surfaces.
  static const Color ink = Color(0xFF041122);

  /// Mid green — primary actions & accents.
  static const Color primary = Color(0xFF7FDA89);

  /// Lime — highlight / accent.
  static const Color accent = Color(0xFFE6F99D);

  /// Teal — seed color, tertiary, and decorative elements.
  static const Color teal = Color(0xFF259073);

  // ─── Derived surfaces (palette blended with white) ────────────────────────
  /// Scaffold body — teal 8 % over white.
  static Color get backgroundLight =>
      Color.alphaBlend(const Color(0x14259073), Colors.white);

  /// Chrome surfaces (AppBar, BottomNav) — green 4 % over white.
  static Color get surfaceLight =>
      Color.alphaBlend(const Color(0x0A7FDA89), Colors.white);

  /// Cards / containers — lime 10 % over white.
  static Color get surfaceContainerLight =>
      Color.alphaBlend(const Color(0x1AE6F99D), Colors.white);

  // ─── Borders & dividers ───────────────────────────────────────────────────
  /// Light grey — AppBar bottom / BottomNav top border.
  static const Color chromeBorder = Color.fromARGB(255, 215, 215, 215);

  /// Soft teal — outlineVariant / subtle dividers elsewhere.
  static const Color softTealBorder = Color(0x40259073);

  // ─── ColorScheme accents ──────────────────────────────────────────────────
  /// Primary container (same hue as accent).
  static const Color primaryContainer = Color(0xFFE6F99D);

  /// Error red.
  static const Color error = Color(0xFFBA1A1A);

  /// Highest surface container (grey-teal).
  static const Color surfaceContainerHighest = Color(0xFFE8F0EC);

  /// Muted text / icon on surface.
  static const Color onSurfaceVariant = Color(0xFF3E5A4F);

  /// Outline strokes.
  static const Color outline = Color(0xFF8FA59B);

  // ─── Navigation ───────────────────────────────────────────────────────────
  /// NavigationBar selected-indicator fill (primary at 30 %).
  static const Color navIndicator = Color(0x4D7FDA89);
}
