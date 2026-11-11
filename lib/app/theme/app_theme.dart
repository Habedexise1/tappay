import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';

/// App theme configurations providing distinct ThemeData for Light and Dark modes.
class AppTheme {
  AppTheme._();

  // --- Light Theme ---
  static ThemeData get lightTheme {
    final textTheme = TextTheme(
      displayLarge: AppTypography.displayLarge.copyWith(color: AppColors.lightTextPrimary),
      displayMedium: AppTypography.displayMedium.copyWith(color: AppColors.lightTextPrimary),
      displaySmall: AppTypography.displaySmall.copyWith(color: AppColors.lightTextPrimary),
      headlineMedium: AppTypography.headlineMedium.copyWith(color: AppColors.lightTextPrimary),
      titleLarge: AppTypography.titleLarge.copyWith(color: AppColors.lightTextPrimary),
      titleMedium: AppTypography.titleMedium.copyWith(color: AppColors.lightTextPrimary),
      bodyLarge: AppTypography.bodyLarge.copyWith(color: AppColors.lightTextPrimary),
      bodyMedium: AppTypography.bodyMedium.copyWith(color: AppColors.lightTextSecondary),
      bodySmall: AppTypography.bodySmall.copyWith(color: AppColors.lightTextMuted),
      labelLarge: AppTypography.labelLarge.copyWith(color: AppColors.lightTextPrimary),
      labelSmall: AppTypography.labelSmall.copyWith(color: AppColors.lightTextMuted),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.lightBackground,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.secondary,
        onSecondary: Colors.white,
        surface: AppColors.lightSurface,
        onSurface: AppColors.lightTextPrimary,
        error: AppColors.accentRed,
        onError: Colors.white,
        outline: AppColors.lightBorder,
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightBackground,
        foregroundColor: AppColors.lightTextPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTypography.titleLarge.copyWith(color: AppColors.lightTextPrimary),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.lightBorder, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: AppTypography.labelLarge.copyWith(fontSize: 16),
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.lightBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.lightBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.lightBorderFocus, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.accentRed, width: 1.5),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.lightBorder,
        thickness: 1,
        space: 1,
      ),
    );
  }

  // --- Dark Theme ---
  static ThemeData get darkTheme {
    final textTheme = TextTheme(
      displayLarge: AppTypography.displayLarge.copyWith(color: AppColors.darkTextPrimary),
      displayMedium: AppTypography.displayMedium.copyWith(color: AppColors.darkTextPrimary),
      displaySmall: AppTypography.displaySmall.copyWith(color: AppColors.darkTextPrimary),
      headlineMedium: AppTypography.headlineMedium.copyWith(color: AppColors.darkTextPrimary),
      titleLarge: AppTypography.titleLarge.copyWith(color: AppColors.darkTextPrimary),
      titleMedium: AppTypography.titleMedium.copyWith(color: AppColors.darkTextPrimary),
      bodyLarge: AppTypography.bodyLarge.copyWith(color: AppColors.darkTextPrimary),
      bodyMedium: AppTypography.bodyMedium.copyWith(color: AppColors.darkTextSecondary),
      bodySmall: AppTypography.bodySmall.copyWith(color: AppColors.darkTextMuted),
      labelLarge: AppTypography.labelLarge.copyWith(color: AppColors.darkTextPrimary),
      labelSmall: AppTypography.labelSmall.copyWith(color: AppColors.darkTextMuted),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.secondary,
        onSecondary: Colors.white,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkTextPrimary,
        error: AppColors.accentRed,
        onError: Colors.white,
        outline: AppColors.darkBorder,
      ),
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTypography.titleLarge.copyWith(color: AppColors.darkTextPrimary),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.darkBorder, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: AppTypography.labelLarge.copyWith(fontSize: 16),
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurfaceVariant,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.darkBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.darkBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.darkBorderFocus, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.accentRed, width: 1.5),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkBorder,
        thickness: 1,
        space: 1,
      ),
    );
  }
}

