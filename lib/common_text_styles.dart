import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  AppTypography._(); // prevent instantiation

  static final TextTheme textTheme = TextTheme(
    displayLarge: GoogleFonts.plusJakartaSans(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      height: 1.25,
    ),
    displayMedium: GoogleFonts.plusJakartaSans(
      fontSize: 28,
      fontWeight: FontWeight.w600,
    ),
    titleLarge: GoogleFonts.plusJakartaSans(
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
    bodyLarge: GoogleFonts.plusJakartaSans(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.5,
    ),
    bodyMedium: GoogleFonts.plusJakartaSans(
      fontSize: 14,
      fontWeight: FontWeight.w400,
    ),
    labelLarge: GoogleFonts.plusJakartaSans(
      fontSize: 14,
      fontWeight: FontWeight.w600,
    ),
  );

  /// Rare use cases only
  static TextStyle custom({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color? color,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }
}
