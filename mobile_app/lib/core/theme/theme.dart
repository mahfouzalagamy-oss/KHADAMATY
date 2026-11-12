import 'package:flutter/material.dart';

class AppColors {
  // هوية تطبيق صيانة (Syaanh Qatar Style: Royal Navy + Vibrant Orange)
  static const Color customerPrimary = Color(0xFF0C2D48); // كحلي صيانة الملكي
  static const Color syaanhOrange = Color(0xFFFF6B00); // برتقالي صيانة المميز
  static const Color technicianPrimary = Color(0xFF145DA0);
  static const Color adminPrimary = Color(0xFF991B1B);

  static const Color accentAmber = Color(0xFFFF6B00);
  static const Color background = Color(0xFFF4F7FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color border = Color(0xFFE2E8F0);
  static const Color success = Color(0xFF16A34A);
  static const Color danger = Color(0xFFDC2626);

  static Color byRole(int roleIndex) {
    if (roleIndex == 1) return technicianPrimary;
    if (roleIndex == 2) return adminPrimary;
    return customerPrimary;
  }
}

class AppTheme {
  static ThemeData build(int roleIndex) {
    final Color primary = AppColors.byRole(roleIndex);
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Cairo',
      fontFamilyFallback: const ['Segoe UI', 'Tahoma', 'Arial', 'sans-serif'],
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: AppColors.syaanhOrange,
        surface: AppColors.surface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.customerPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.syaanhOrange,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w800),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: BorderSide(color: primary, width: 1.4),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.syaanhOrange, width: 2)),
      ),
    );
  }
}