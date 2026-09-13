import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color green = Color(0xFF27C96F);
  static const Color darkGreen = Color(0xFF12663D);
  static const Color lime = Color(0xFF8FD14F);
  static const Color violet = Color(0xFF7157D9);
  static const Color orange = Color(0xFFF59D3D);
  static const Color ink = Color(0xFF202C29);
  static const Color muted = Color(0xFF66756F);
  static const Color canvas = Color(0xFFF7F8F2);
  static const Color border = Color(0xFFDCE6E1);
  static const Color success = Color(0xFF086342);
  static const Color error = Color(0xFFA52A2A);
  static const Color darkOrange = Color(0xFF854700);
}

abstract final class AppTheme {
  static ThemeData light() {
    final ColorScheme colors = ColorScheme.fromSeed(
      seedColor: AppColors.green,
      brightness: Brightness.light,
      surface: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colors,
      scaffoldBackgroundColor: AppColors.canvas,
      textTheme: const TextTheme(
        displaySmall: TextStyle(
          color: AppColors.ink,
          fontSize: 34,
          fontWeight: FontWeight.w800,
          height: 1.08,
        ),
        headlineMedium: TextStyle(
          color: AppColors.ink,
          fontSize: 28,
          fontWeight: FontWeight.w800,
          height: 1.15,
        ),
        headlineSmall: TextStyle(
          color: AppColors.ink,
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
        titleLarge: TextStyle(
          color: AppColors.ink,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
        titleMedium: TextStyle(
          color: AppColors.ink,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: TextStyle(color: AppColors.ink, fontSize: 17, height: 1.45),
        bodyMedium: TextStyle(
          color: AppColors.muted,
          fontSize: 15,
          height: 1.4,
        ),
        labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
      ),
      cardTheme: const CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(24)),
          side: BorderSide(color: AppColors.border),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkGreen,
          foregroundColor: Colors.white,
          minimumSize: const Size(160, 54),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: Color(0xFFDDF5EC),
        height: 72,
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.green,
        linearTrackColor: AppColors.border,
      ),
    );
  }
}
