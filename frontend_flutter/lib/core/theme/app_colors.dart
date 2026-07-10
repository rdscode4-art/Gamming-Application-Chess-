import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color navy = Color(0xFF0B1220);
  static const Color navyDeep = Color(0xFF070D18);
  static const Color purple = Color(0xFF3D2B7A);
  static const Color purpleLight = Color(0xFF6C3FC5);
  static const Color gold = Color(0xFFF5A623);
  static const Color goldLight = Color(0xFFFFCF5C);
  
  // Status / Feedback
  static const Color green = Color(0xFF22C55E);
  static const Color red = Color(0xFFE53935);
  static const Color blue = Color(0xFF3B82F6);
  
  // Typography
  static const Color textLight = Color(0xFFE8EDF8);
  static const Color textMuted = Color(0xFF8A94A6);

  // Gradients
  static const LinearGradient goldGrad = LinearGradient(
    colors: [gold, goldLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient purpleGrad = LinearGradient(
    colors: [purple, purpleLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient navyGrad = LinearGradient(
    colors: [Color(0xFF0F1A2E), navy],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Glass styles
  static const Color glassBg = Color(0x0FFFFFFF); // white with ~0.06 opacity
  static const Color glassBorder = Color(0x19FFFFFF); // white with ~0.10 opacity
}

extension BuildContextTheme on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  Color get bgColor => Theme.of(this).scaffoldBackgroundColor;
  Color get surfaceColor => Theme.of(this).colorScheme.surface;
  
  Color get textPrimary => Theme.of(this).textTheme.bodyLarge?.color ?? Colors.black;
  Color get textSecondary => Theme.of(this).textTheme.labelMedium?.color ?? Colors.black54;

  Color get glassBgColor => isDark ? AppColors.glassBg : Colors.white.withValues(alpha: 0.85);
  Color get glassBorderColor => isDark ? AppColors.glassBorder : Colors.grey.withValues(alpha: 0.3);

  LinearGradient get bgGradient => isDark 
      ? AppColors.navyGrad 
      : const LinearGradient(colors: [Colors.white, Color(0xFFF5F5F5)], begin: Alignment.topLeft, end: Alignment.bottomRight);
}
