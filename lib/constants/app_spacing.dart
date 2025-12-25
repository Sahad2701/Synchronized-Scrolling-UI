import 'package:flutter/material.dart';

/// Application spacing constants
/// Standardized spacing values for consistent layout across the app
/// Only actively used spacing constants are defined here.
class AppSpacing {
  AppSpacing._();

  // Padding values
  static const double paddingS = 8.0;
  static const double paddingM = 12.0;
  static const double paddingL = 16.0;
  static const double paddingXXXL = 80.0;

  // Margin values
  static const double marginM = 16.0;

  // Gap values
  static const double gapXS = 5.0;
  static const double gapS = 8.0;
  static const double gapM = 12.0;

  // Edge insets shortcuts
  static const EdgeInsets paddingHorizontalM = EdgeInsets.symmetric(horizontal: paddingL);
  static const EdgeInsets marginAllM = EdgeInsets.all(marginM);
  static const EdgeInsets marginBottomS = EdgeInsets.only(bottom: 12.0);
  static const EdgeInsets marginHorizontalM = EdgeInsets.symmetric(horizontal: marginM);
}

