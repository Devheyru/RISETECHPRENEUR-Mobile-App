import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primaryBlue = Color(0xFF155DFC); // Primary Blue #155DFC
  static const Color secondaryNavy = Color(0xFF1E293B); // Dark text
  static const Color textGrey = Color(0xFF64748B); // Subtitles
  static const Color background = Color(0xFFF8FAFC); // Light grey/white bg
  static const Color accentYellow = Color(0xFFFBBF24); // Stars
  static const Color footerBg = Color(0xFF0F172A); // Dark footer
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: AppColors.primaryBlue,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryBlue,
      ).copyWith(primary: AppColors.primaryBlue),
      scaffoldBackgroundColor: AppColors.background,
      useMaterial3: true,
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: AppColors.secondaryNavy,
          height: 1.2,
        ),
        displayMedium: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.secondaryNavy,
        ),
        titleMedium: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.secondaryNavy,
        ),
        bodyLarge: const TextStyle(
          fontSize: 16,
          color: AppColors.textGrey,
          height: 1.5,
        ),
        bodyMedium: const TextStyle(fontSize: 14, color: AppColors.textGrey),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
    );
  }
}
