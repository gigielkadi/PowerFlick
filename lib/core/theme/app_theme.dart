import 'package:flutter/material.dart';

import '../constants/k_colors.dart';
import '../constants/k_sizes.dart';

/// Theme configuration for the PowerFlick app
class AppTheme {
  /// Light theme configuration
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF4CD964),
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: KColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: KColors.background,
        foregroundColor: KColors.textLight,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: KColors.primary,
          foregroundColor: KColors.textDark,
          padding: const EdgeInsets.symmetric(
            horizontal: KSize.md,
            vertical: KSize.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(KSize.radiusMd),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: KColors.accent,
          padding: const EdgeInsets.symmetric(
            horizontal: KSize.md,
            vertical: KSize.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(KSize.radiusMd),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: KSize.md,
          vertical: KSize.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(KSize.radiusMd),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(KSize.radiusMd),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(KSize.radiusMd),
          borderSide: const BorderSide(color: KColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(KSize.radiusMd),
          borderSide: const BorderSide(color: KColors.error),
        ),
        prefixIconColor: Colors.black26,
        hintStyle: TextStyle(
          color: Colors.black.withOpacity(0.3),
          fontSize: 16,
        ),
      ),
    );
  }

  /// Dark theme configuration
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF4CD964),
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: KColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: KColors.background,
        foregroundColor: KColors.textLight,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: KColors.primary,
          foregroundColor: KColors.textDark,
          padding: const EdgeInsets.symmetric(
            horizontal: KSize.md,
            vertical: KSize.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(KSize.radiusMd),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: KColors.accent,
          padding: const EdgeInsets.symmetric(
            horizontal: KSize.md,
            vertical: KSize.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(KSize.radiusMd),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: KSize.md,
          vertical: KSize.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(KSize.radiusMd),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(KSize.radiusMd),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(KSize.radiusMd),
          borderSide: const BorderSide(color: KColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(KSize.radiusMd),
          borderSide: const BorderSide(color: KColors.error),
        ),
        prefixIconColor: Colors.white54,
        hintStyle: TextStyle(
          color: Colors.white.withOpacity(0.5),
          fontSize: 16,
        ),
      ),
    );
  }
} 