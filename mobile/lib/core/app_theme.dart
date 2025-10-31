import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Mandated color palette from the product brief.
  static const Color primary = Color(0xFF005F73);
  static const Color secondary = Color(0xFF0A9396);
  static const Color accent = Color(0xFF94D2BD);
  static const Color background = Color(0xFFE9F5F2);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF001219);
  static const Color textLight = Color(0xFFFFFFFF);
}

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => ThemeData(
        primaryColor: AppColors.primary,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.surface,
          background: AppColors.background,
        ),
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textLight,
          elevation: 0,
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(color: AppColors.textDark),
          bodyMedium: TextStyle(color: AppColors.textDark),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.secondary,
        ),
      );

  static ThemeData get darkTheme => ThemeData(
        primaryColor: AppColors.primary,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.accent,
          surface: AppColors.textDark,
          background: AppColors.textDark,
        ),
        scaffoldBackgroundColor: AppColors.textDark,
      );
}
