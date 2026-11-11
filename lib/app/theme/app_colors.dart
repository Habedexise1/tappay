import 'package:flutter/material.dart';

/// Semantic color tokens matching the TapPay Figma design.
class AppColors {
  AppColors._();

  // --- Brand / Primary Palette ---
  static const Color primary = Color(0xFF6C2BD9); // Vibrant Purple
  static const Color primaryLight = Color(0xFF8B5CF6);
  static const Color primaryDark = Color(0xFF4C1D95);
  static const Color primaryContainer = Color(0xFFEDE9FE);

  // --- Secondary & Accents ---
  static const Color secondary = Color(0xFF3B82F6); // Electric Blue
  static const Color accentGreen = Color(0xFF10B981); // Emerald Success / Inflow
  static const Color accentOrange = Color(0xFFF59E0B); // Amber Warning
  static const Color accentRed = Color(0xFFEF4444); // Crimson Error / Outflow

  // --- Light Theme Tokens ---
  static const Color lightBackground = Color(0xFFF8F9FD);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF1F3F9);
  static const Color lightBorder = Color(0xFFE5E7EB);
  static const Color lightBorderFocus = Color(0xFF6C2BD9);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextMuted = Color(0xFF94A3B8);

  // --- Dark Theme Tokens ---
  static const Color darkBackground = Color(0xFF0B0D14);
  static const Color darkSurface = Color(0xFF131722);
  static const Color darkSurfaceVariant = Color(0xFF1C2234);
  static const Color darkBorder = Color(0xFF272F45);
  static const Color darkBorderFocus = Color(0xFF8B5CF6);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextMuted = Color(0xFF64748B);

  // --- Gradients ---
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7C3AED), Color(0xFF5B21B6)],
  );

  static const LinearGradient cardGradientDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A1F30), Color(0xFF121522)],
  );

  static const LinearGradient cardGradientLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
  );
}

