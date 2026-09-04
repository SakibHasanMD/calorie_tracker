import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Material 3 application theme.
///
/// All colours are sourced from [AppColors] so a single-file change ripples
/// everywhere. AppBar and the bottom navigation bar use light chrome surfaces
/// that float over a slightly teal-tinted body.
abstract final class AppTheme {
  static ThemeData get light {
    final scheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.teal,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.ink,
      secondary: AppColors.primary,
      onSecondary: AppColors.ink,
      tertiary: AppColors.teal,
      onTertiary: Colors.white,
      error: AppColors.error,
      onError: Colors.white,
      surface: AppColors.surfaceLight,
      onSurface: AppColors.ink,
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: AppColors.surfaceLight,
      surfaceContainer: AppColors.surfaceContainerLight,
      surfaceContainerHigh: AppColors.surfaceContainerLight,
      surfaceContainerHighest: AppColors.surfaceContainerHighest,
      onSurfaceVariant: AppColors.onSurfaceVariant,
      outline: AppColors.outline,
      outlineVariant: AppColors.softTealBorder,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: AppColors.ink,
      onInverseSurface: AppColors.accent,
      inversePrimary: AppColors.primary,
    );

    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      brightness: Brightness.light,

      // Body: soft teal-mint tint from the palette.
      scaffoldBackgroundColor: AppColors.backgroundLight,

      // AppBar: light chrome; grey bottom border.
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        backgroundColor: AppColors.surfaceLight,
        foregroundColor: AppColors.ink,
        shape: const Border(
          bottom: BorderSide(color: AppColors.chromeBorder),
        ),
      ),

      // Bottom navigation bar: light chrome.
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surfaceLight,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.navIndicator,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),

      // Cards: pale lime-cream so they read as surfaces without hard white.
      cardTheme: CardThemeData(
        color: AppColors.surfaceContainerLight,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),

      dividerColor: AppColors.chromeBorder,

      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),

      textTheme: const TextTheme().apply(
        bodyColor: AppColors.ink,
        displayColor: AppColors.ink,
      ),
    );
  }
}
