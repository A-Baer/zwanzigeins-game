import 'package:flutter/material.dart';

abstract final class AppColors {
  // The product palette is derived from the three colors of the 21 -> logo.
  static const Color green = Color(0xFF2DCE78);
  static const Color darkGreen = Color(0xFF087443);
  static const Color lime = Color(0xFF9BE8BB);
  static const Color ink = Color(0xFF191B1A);
  static const Color muted = Color(0xFF647069);
  static const Color canvas = Color(0xFFF4F6F3);
  static const Color surfaceGreen = Color(0xFFE7F8EE);
  static const Color border = Color(0xFFD8E1DC);
  static const Color success = Color(0xFF087443);
  static const Color error = Color(0xFFA52A2A);
  static const Color warning = Color(0xFF8A5600);

  // Kept as semantic aliases for existing informational and reward accents.
  static const Color violet = Color(0xFF39715A);
  static const Color orange = Color(0xFFB87512);
  static const Color darkOrange = warning;
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
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.canvas,
        foregroundColor: AppColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.ink,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),
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
          borderRadius: BorderRadius.all(Radius.circular(22)),
          side: BorderSide(color: AppColors.border),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.green,
          foregroundColor: AppColors.ink,
          disabledBackgroundColor: AppColors.border,
          disabledForegroundColor: AppColors.muted,
          minimumSize: const Size(160, 56),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.ink,
          foregroundColor: Colors.white,
          minimumSize: const Size(160, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.ink,
          minimumSize: const Size(48, 54),
          side: const BorderSide(color: AppColors.border, width: 1.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      chipTheme: const ChipThemeData(
        backgroundColor: Colors.white,
        selectedColor: AppColors.surfaceGreen,
        side: BorderSide(color: AppColors.border),
        shape: StadiumBorder(),
        labelStyle: TextStyle(
          color: AppColors.ink,
          fontWeight: FontWeight.w700,
        ),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: AppColors.surfaceGreen,
        height: 76,
        elevation: 0,
        shadowColor: Colors.transparent,
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
      ),
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: Colors.white,
        indicatorColor: AppColors.surfaceGreen,
        selectedIconTheme: IconThemeData(color: AppColors.darkGreen),
        selectedLabelTextStyle: TextStyle(
          color: AppColors.ink,
          fontWeight: FontWeight.w800,
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.darkGreen,
        linearTrackColor: AppColors.border,
      ),
    );
  }
}
