import 'package:flutter/material.dart';

/// Semantic color tokens matching the TapPay Figma design.
class AppColors {
  AppColors._();

  // --- Brand / Primary Palette ---
  static const Color primary = Color(0xFF00D084); // Vibrant TapPay Green
  static const Color primaryGreen = Color(0xFF00D084);
  static const Color primaryGreenDark = Color(0xFF00A86B);
  static const Color primaryYellow = Color(0xFFFFCE00); // TapPay Card Yellow
  static const Color splashGreen = Color(0xFF00D084); // Splash background

  // --- Dark Mode Palette ---
  static const Color darkBackground = Color(0xFF07150F); // Deep dark forest green-black
  static const Color darkSurface = Color(0xFF0E1F18);
  static const Color darkSurfaceVariant = Color(0xFF162B21);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFA1B3AA);
  static const Color darkTextMuted = Color(0xFF6B7280);
  static const Color darkBorder = Color(0xFF1E352B);

  // --- Light Mode Palette ---
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFF9FAFB);
  static const Color lightSurfaceVariant = Color(0xFFF3F4F6);
  static const Color lightTextPrimary = Color(0xFF081711);
  static const Color lightTextSecondary = Color(0xFF4B5563);
  static const Color lightTextMuted = Color(0xFF9CA3AF);
  static const Color lightBorder = Color(0xFF081711); // Clean dark stroke for buttons
  static const Color lightBorderSubtle = Color(0xFFE5E7EB);

  // --- Accents ---
  static const Color accentRed = Color(0xFFEB001B); // Mastercard Red
  static const Color accentOrange = Color(0xFFFF5F00); // Mastercard Orange
  static const Color cardBlack = Color(0xFF0D1311);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color cardYellow = Color(0xFFFFCE00);
}
