import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  static TextStyle get h1 => GoogleFonts.poppins(
        fontSize: 32, fontWeight: FontWeight.w700,
        color: AppColors.textPrimary, height: 1.2);

  static TextStyle get h2 => GoogleFonts.poppins(
        fontSize: 18, fontWeight: FontWeight.w600,
        color: AppColors.textPrimary, letterSpacing: 1.0);

  static TextStyle get h3 => GoogleFonts.poppins(
        fontSize: 20, fontWeight: FontWeight.w700,
        color: AppColors.textPrimary);

  static TextStyle get bodyLarge => GoogleFonts.poppins(
        fontSize: 16, fontWeight: FontWeight.w500,
        color: AppColors.textPrimary);

  static TextStyle get body => GoogleFonts.poppins(
        fontSize: 14, fontWeight: FontWeight.w400,
        color: AppColors.textPrimary);

  static TextStyle get caption => GoogleFonts.poppins(
        fontSize: 12, fontWeight: FontWeight.w400,
        color: AppColors.textSecondary);

  static TextStyle get micro => GoogleFonts.poppins(
        fontSize: 10, fontWeight: FontWeight.w700,
        color: AppColors.textPrimary, letterSpacing: 0.5);

  static TextStyle get sectionLabel => GoogleFonts.poppins(
        fontSize: 13, fontWeight: FontWeight.w400,
        color: AppColors.textTertiary, letterSpacing: 1.0);

  static TextStyle get serverName => GoogleFonts.poppins(
        fontSize: 22, fontWeight: FontWeight.w700,
        color: AppColors.textPrimary);

  static TextStyle get monoLarge => GoogleFonts.robotoMono(
        fontSize: 16, fontWeight: FontWeight.w700,
        color: AppColors.textPrimary);

  static TextStyle get monoSmall => GoogleFonts.robotoMono(
        fontSize: 13, fontWeight: FontWeight.w400,
        color: AppColors.textSecondary);

  static TextStyle get timerText => GoogleFonts.robotoMono(
        fontSize: 13, fontWeight: FontWeight.w500,
        color: AppColors.textSecondary);

  static TextStyle get brandName => GoogleFonts.poppins(
        fontSize: 28, fontWeight: FontWeight.w800,
        color: AppColors.textPrimary, letterSpacing: 2.0);

  static TextStyle get statNumber => GoogleFonts.poppins(
        fontSize: 18, fontWeight: FontWeight.w700,
        color: AppColors.textPrimary);

  static TextStyle get percentLarge => GoogleFonts.poppins(
        fontSize: 36, fontWeight: FontWeight.w800,
        color: AppColors.textPrimary);
}
