import 'package:flutter/material.dart';

enum AppTheme {
  forestGreen,
  desertSand,
  oceanBlue,
  sunsetOrange,
  royalPurple,
}

extension AppThemeExtension on AppTheme {
  String get label {
    switch (this) {
      case AppTheme.forestGreen:
        return 'Forest Green';
      case AppTheme.desertSand:
        return 'Desert Sand';
      case AppTheme.oceanBlue:
        return 'Ocean Blue';
      case AppTheme.sunsetOrange:
        return 'Sunset Orange';
      case AppTheme.royalPurple:
        return 'Royal Purple';
    }
  }

  Color get primaryColor {
    switch (this) {
      case AppTheme.forestGreen:
        return const Color(0xFF2E7D32);
      case AppTheme.desertSand:
        return const Color(0xFFC19A6B);
      case AppTheme.oceanBlue:
        return const Color(0xFF0277BD);
      case AppTheme.sunsetOrange:
        return const Color(0xFFE65100);
      case AppTheme.royalPurple:
        return const Color(0xFF6A1B9A);
    }
  }

  Color get secondaryColor {
    switch (this) {
      case AppTheme.forestGreen:
        return const Color(0xFF81C784);
      case AppTheme.desertSand:
        return const Color(0xFFE8C99A);
      case AppTheme.oceanBlue:
        return const Color(0xFF4FC3F7);
      case AppTheme.sunsetOrange:
        return const Color(0xFFFFB74D);
      case AppTheme.royalPurple:
        return const Color(0xFFCE93D8);
    }
  }
}

class AppThemes {
  static ThemeData buildTheme(AppTheme appTheme) {
    final primary = appTheme.primaryColor;
    final secondary = appTheme.secondaryColor;

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: secondary,
        brightness: Brightness.light,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    );
  }
}
