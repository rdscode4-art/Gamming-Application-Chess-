import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: AppColors.navy,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.gold,
        secondary: AppColors.purpleLight,
        surface: AppColors.navyDeep,
        background: AppColors.navy,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.rajdhani(
          textStyle: const TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w900),
        ),
        displayMedium: GoogleFonts.rajdhani(
          textStyle: const TextStyle(color: AppColors.textLight, fontWeight: FontWeight.w800),
        ),
        displaySmall: GoogleFonts.rajdhani(
          textStyle: const TextStyle(color: AppColors.textLight, fontWeight: FontWeight.bold),
        ),
        headlineLarge: GoogleFonts.rajdhani(
          textStyle: const TextStyle(color: AppColors.textLight, fontWeight: FontWeight.bold),
        ),
        headlineMedium: GoogleFonts.rajdhani(
          textStyle: const TextStyle(color: AppColors.textLight, fontWeight: FontWeight.bold),
        ),
        headlineSmall: GoogleFonts.rajdhani(
          textStyle: const TextStyle(color: AppColors.textLight, fontWeight: FontWeight.bold),
        ),
        bodyLarge: const TextStyle(color: AppColors.textLight),
        bodyMedium: const TextStyle(color: AppColors.textLight),
        labelLarge: const TextStyle(color: AppColors.textMuted),
        labelMedium: const TextStyle(color: AppColors.textMuted),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData.light().copyWith(
      scaffoldBackgroundColor: const Color(0xFFF5F5F5), // Light gray background
      colorScheme: const ColorScheme.light(
        primary: AppColors.gold,
        secondary: AppColors.purpleLight,
        surface: Colors.white,
        background: Color(0xFFF5F5F5),
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme).copyWith(
        displayLarge: GoogleFonts.rajdhani(
          textStyle: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w900),
        ),
        displayMedium: GoogleFonts.rajdhani(
          textStyle: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w800),
        ),
        displaySmall: GoogleFonts.rajdhani(
          textStyle: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        headlineLarge: GoogleFonts.rajdhani(
          textStyle: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        headlineMedium: GoogleFonts.rajdhani(
          textStyle: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        headlineSmall: GoogleFonts.rajdhani(
          textStyle: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        bodyLarge: const TextStyle(color: Colors.black87),
        bodyMedium: const TextStyle(color: Colors.black87),
        labelLarge: const TextStyle(color: Colors.black54),
        labelMedium: const TextStyle(color: Colors.black54),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black87),
        titleTextStyle: TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}
