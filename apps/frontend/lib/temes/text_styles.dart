// lib/constants/app_text_styles.dart
// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTextStyles {
  static const String fontFamily = 'IBM_Plex_Sans_Arabic';

  static TextStyle headlineLarge = GoogleFonts.ibmPlexSansArabic(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.c0f172a,
    letterSpacing: -0.3,
  );

  static TextStyle headlineMedium = GoogleFonts.ibmPlexSansArabic(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.c0f172a,
  );

  static TextStyle titleLarge = GoogleFonts.ibmPlexSansArabic(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.c0f172a,
  );

  static TextStyle valueLarge = GoogleFonts.ibmPlexSansArabic(
    fontSize: 26,
    fontWeight: FontWeight.w800,
    color: AppColors.c0f172a,
  );

  static TextStyle successPercentage = GoogleFonts.ibmPlexSansArabic(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.c22c55e,
  );

  static TextStyle errorText = GoogleFonts.ibmPlexSansArabic(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.cef4444,
  );

  static TextStyle bodyMedium = GoogleFonts.ibmPlexSansArabic(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.c334155,
  );

  static TextStyle bodySmall = GoogleFonts.ibmPlexSansArabic(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.c64748b,
  );

  static TextStyle labelMedium = GoogleFonts.ibmPlexSansArabic(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.c64748b,
  );

  static TextStyle labelSmall = GoogleFonts.ibmPlexSansArabic(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.c94a3b8,
  );

  static TextStyle buttonText = GoogleFonts.ibmPlexSansArabic(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static TextStyle buttonTextGreen = GoogleFonts.ibmPlexSansArabic(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
}
