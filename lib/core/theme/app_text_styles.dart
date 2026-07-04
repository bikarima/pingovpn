import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

// Google Fonts با allowRuntimeFetching=false — از cache یا system font
class AppTextStyles {
  static TextStyle _p(double size, FontWeight weight, Color color,
      {double? height, double? letterSpacing}) {
    try {
      return GoogleFonts.poppins(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      );
    } catch (_) {
      return TextStyle(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
        fontFamily: 'sans-serif',
      );
    }
  }

  static TextStyle _mono(double size, FontWeight weight, Color color) {
    try {
      return GoogleFonts.robotoMono(
          fontSize: size, fontWeight: weight, color: color);
    } catch (_) {
      return TextStyle(
          fontSize: size,
          fontWeight: weight,
          color: color,
          fontFamily: 'monospace');
    }
  }

  static TextStyle get h1 =>
      _p(32, FontWeight.w700, AppColors.textPrimary, height: 1.2);

  static TextStyle get h2 =>
      _p(18, FontWeight.w600, AppColors.textPrimary, letterSpacing: 1.0);

  static TextStyle get h3 =>
      _p(20, FontWeight.w700, AppColors.textPrimary);

  static TextStyle get bodyLarge =>
      _p(16, FontWeight.w500, AppColors.textPrimary);

  static TextStyle get body =>
      _p(14, FontWeight.w400, AppColors.textPrimary);

  static TextStyle get caption =>
      _p(12, FontWeight.w400, AppColors.textSecondary);

  static TextStyle get micro =>
      _p(10, FontWeight.w700, AppColors.textPrimary, letterSpacing: 0.5);

  static TextStyle get sectionLabel =>
      _p(13, FontWeight.w400, AppColors.textTertiary, letterSpacing: 1.0);

  static TextStyle get serverName =>
      _p(22, FontWeight.w700, AppColors.textPrimary);

  static TextStyle get monoLarge =>
      _mono(16, FontWeight.w700, AppColors.textPrimary);

  static TextStyle get monoSmall =>
      _mono(13, FontWeight.w400, AppColors.textSecondary);

  static TextStyle get timerText =>
      _mono(13, FontWeight.w500, AppColors.textSecondary);

  static TextStyle get brandName =>
      _p(28, FontWeight.w800, AppColors.textPrimary, letterSpacing: 2.0);

  static TextStyle get statNumber =>
      _p(18, FontWeight.w700, AppColors.textPrimary);

  static TextStyle get percentLarge =>
      _p(36, FontWeight.w800, AppColors.textPrimary);
}
