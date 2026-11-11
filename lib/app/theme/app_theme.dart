import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';

/// App theme configurations providing distinct ThemeData for Light and Dark modes matching TapPay Figma.
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
      bodySmall: AppTypography.bodySmall.copyWith(color: AppColors.lightTextSecondary),
      labelLarge: AppTypography.labelLarge.copyWith(color: AppColors.lightTextPrimary),
      labelSmall: AppTypography.labelSmall.copyWith(color: AppColors.lightTextSecondary),
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: AppTypography.fontFamily,
      brightness: Brightness.light,
      primaryColor: AppColors.primaryGreen,
      scaffoldBackgroundColor: AppColors.lightBackground,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryGreen,
        onPrimary: AppColors.lightTextPrimary,
        surface: AppColors.lightSurface,
        onSurface: AppColors.lightTextPrimary,
        error: AppColors.accentRed,
        onError: Colors.white,
        outline: AppColors.lightBorder,
      ),
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.lightTextPrimary,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
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
      bodySmall: AppTypography.bodySmall.copyWith(color: AppColors.darkTextSecondary),
      labelLarge: AppTypography.labelLarge.copyWith(color: AppColors.darkTextPrimary),
      labelSmall: AppTypography.labelSmall.copyWith(color: AppColors.darkTextSecondary),
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: AppTypography.fontFamily,
      brightness: Brightness.dark,
      primaryColor: AppColors.primaryGreen,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryGreen,
        onPrimary: AppColors.darkBackground,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkTextPrimary,
        error: AppColors.accentRed,
        onError: Colors.white,
        outline: AppColors.darkBorder,
      ),
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
    );
  }
}
