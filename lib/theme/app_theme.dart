import 'package:flutter/material.dart';

import 'app_typography.dart';

/// Application theme configuration
/// Provides centralized theme definitions for consistent visual appearance
/// across the entire application using Material Design 3
class AppTheme {
  AppTheme._();

  /// Light theme configuration
  static ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    textTheme: AppTypography.textTheme,
  );

  /// Dark theme configuration
  static ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    textTheme: AppTypography.textTheme.apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    ),
  );
}
