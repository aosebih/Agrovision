import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  static TextStyle get headlineLarge => GoogleFonts.ibmPlexSansArabic(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: -0.3);
  static TextStyle get headlineMedium => GoogleFonts.ibmPlexSansArabic(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary);
  static TextStyle get titleLarge => GoogleFonts.ibmPlexSansArabic(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary);
  static TextStyle get valueLarge => GoogleFonts.ibmPlexSansArabic(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textPrimary);
  static TextStyle get bigPercent => GoogleFonts.ibmPlexSansArabic(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.textPrimary);
  static TextStyle get bodyMedium => GoogleFonts.ibmPlexSansArabic(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textSecondary);
  static TextStyle get bodySmall => GoogleFonts.ibmPlexSansArabic(fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.textSecondary);
  static TextStyle get labelMedium => GoogleFonts.ibmPlexSansArabic(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textMuted);
  static TextStyle get labelSmall => GoogleFonts.ibmPlexSansArabic(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textMuted);
  static TextStyle get caption => GoogleFonts.ibmPlexSansArabic(fontSize: 11, fontWeight: FontWeight.w400, color: AppColors.textMuted);
  static TextStyle get buttonText => GoogleFonts.ibmPlexSansArabic(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white);
  static TextStyle get successPercentage => GoogleFonts.ibmPlexSansArabic(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.success);
  static TextStyle get errorText => GoogleFonts.ibmPlexSansArabic(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.error);
}
