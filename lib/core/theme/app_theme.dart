import 'package:flutter/material.dart';

/// Material 3 application theme.
///
/// Light palette built from the project palette (no outside colours):
/// - `ink`       `#041122` — near-black navy; used for text on light surfaces
/// - `primary`   `#7FDA89` — mid green
/// - `accent`    `#E6F99D` — lime
/// - `teal`      `#259073` — teal (seed / tertiary)
///
/// The light surfaces below are the palette colours blended with white, so the
/// AppBar, bottom nav and cards share the theme's own tones rather than a hard
/// `Colors.white`. AppBar and the bottom navigation bar are light chrome that
/// floats over a slightly teal-tinted body.
abstract final class AppTheme {
  // --- palette ---
  static const Color ink = Color(0xFF041122);
  static const Color primary = Color(0xFF7FDA89);
  static const Color accent = Color(0xFFE6F99D);
  static const Color teal = Color(0xFF259073);

  /// Light tints of the palette (palette alpha-blended over white).
  /// Body: soft teal-mint. Chrome and cards: pale lime-cream so they stand off
  /// the body while staying within the theme.
  static Color get backgroundLight =>
      Color.alphaBlend(const Color(0x14259073), Colors.white); // teal 8%
  static Color get surfaceLight =>
      Color.alphaBlend(const Color(0x0A7FDA89), Colors.white); // green 4%
  static Color get surfaceContainerLight =>
      Color.alphaBlend(const Color(0x1AE6F99D), Colors.white); // lime 10%

  /// Soft teal divider that separates the AppBar / bottom nav from the body.
  static const Color softTealBorder = Color(0x40259073);

  static ThemeData get light {
    final scheme = ColorScheme(
      brightness: Brightness.light,
      primary: teal,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFE6F99D),
      onPrimaryContainer: ink,
      secondary: primary,
      onSecondary: ink,
      tertiary: teal,
      onTertiary: Colors.white,
      error: const Color(0xFFBA1A1A),
      onError: Colors.white,
      surface: surfaceLight,
      onSurface: ink,
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: surfaceLight,
      surfaceContainer: surfaceContainerLight,
      surfaceContainerHigh: surfaceContainerLight,
      surfaceContainerHighest: const Color(0xFFE8F0EC),
      onSurfaceVariant: const Color(0xFF3E5A4F),
      outline: const Color(0xFF8FA59B),
      outlineVariant: softTealBorder,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: ink,
      onInverseSurface: accent,
      inversePrimary: primary,
    );

    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      brightness: Brightness.light,

      // Body: soft teal-mint tint from the palette.
      scaffoldBackgroundColor: backgroundLight,

      // AppBar: light chrome; soft teal bottom border.
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        backgroundColor: surfaceLight,
        foregroundColor: ink,
        shape: const Border(
          bottom: BorderSide(color: softTealBorder),
        ),
      ),

      // Bottom navigation bar: light chrome; soft teal top border.
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceLight,
        surfaceTintColor: Colors.transparent,
        indicatorColor: const Color(0x4D7FDA89), // mid green, 30% alpha
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),

      // Cards: pale lime-cream so they read as surfaces without hard white.
      cardTheme: CardThemeData(
        color: surfaceContainerLight,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),

      dividerColor: softTealBorder,

      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),

      textTheme: const TextTheme().apply(
        bodyColor: ink,
        displayColor: ink,
      ),
    );
  }
}
