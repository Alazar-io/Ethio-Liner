import 'package:flutter/material.dart';

/// EthioLiner color palette.
///
/// Colors are inspired by the Ethiopian flag:
/// - Green (#009B3A) — Land and hope
/// - Yellow (#FCDD09) — Peace and harmony
/// - Red (#EF3340) — Strength and sacrifice
///
/// These are used as the foundation for the Material 3 color scheme.
class AppColors {
  AppColors._();

  // === Primary (Ethiopian Green) ===
  static const Color primary = Color(0xFF009B3A);
  static const Color primaryLight = Color(0xFF4CAF6E);
  static const Color primaryDark = Color(0xFF007A2E);
  static const Color onPrimary = Color(0xFFFFFFFF);

  // === Secondary (Ethiopian Yellow) ===
  static const Color secondary = Color(0xFFFCDD09);
  static const Color secondaryLight = Color(0xFFFFF176);
  static const Color secondaryDark = Color(0xFFC9AB00);
  static const Color onSecondary = Color(0xFF1A1A1A);

  // === Accent (Ethiopian Red) ===
  static const Color accent = Color(0xFFEF3340);
  static const Color accentLight = Color(0xFFFF6659);
  static const Color accentDark = Color(0xFFB71C1C);
  static const Color onAccent = Color(0xFFFFFFFF);

  // === Neutrals ===
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  static const Color onBackground = Color(0xFF1A1A1A);
  static const Color onSurface = Color(0xFF1A1A1A);
  static const Color onSurfaceVariant = Color(0xFF666666);

  // === Text Colors ===
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textHint = Color(0xFF999999);
  static const Color textDisabled = Color(0xFFBDBDBD);

  // === Semantic Colors ===
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFE53935);
  static const Color info = Color(0xFF2196F3);

  // === Dividers & Borders ===
  static const Color divider = Color(0xFFE0E0E0);
  static const Color border = Color(0xFFE0E0E0);
  static const Color borderLight = Color(0xFFF0F0F0);

  // === Dark Theme ===
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkSurfaceVariant = Color(0xFF2C2C2C);
  static const Color darkOnBackground = Color(0xFFE0E0E0);
  static const Color darkOnSurface = Color(0xFFE0E0E0);
}
