import 'package:flutter/material.dart';

class AppColors {
  // Backgrounds & Surface
  static const Color background = Color(0xFF0F1115);
  static const Color surface = Color(0xFF181B22);
  static const Color surfaceElevated = Color(0xFF222631);
  static const Color cardBackground = Color(0xFF222631);

  // Tactical Accents
  static const Color northRed = Color(0xFFFF3B30);
  static const Color accentCyan = Color(0xFF00E5FF);
  static const Color accentGreen = Color(0xFF00E676);
  static const Color accentAmber = Color(0xFFFF9100);
  static const Color goldPro = Color(0xFFFFB300);
  static const Color dialRing = Color(0xFF2E3440);
  static const Color dialTick = Color(0xFF6B7280);
  static const Color dialTickMajor = Color(0xFFE5E7EB);
  static const Color textPrimary = Color(0xFFF9FAFB);
  static const Color textSecondary = Color(0xFF9CA3AF);

  // Inclinometer / Bubble Level
  static const Color bubbleDefault = Color(0xFF00E5FF);
  static const Color bubbleLevel = Color(0xFF00E676);
  static const Color bubbleTargetRing = Color(0x3300E5FF);

  // Sensor Accuracy Badges
  static const Color accuracyHigh = Color(0xFF00E676);
  static const Color accuracyMedium = Color(0xFFFFD600);
  static const Color accuracyLow = Color(0xFFFF9100);
  static const Color accuracyUnreliable = Color(0xFFFF1744);
}

class CompassTheme {
  final Color background;
  final Color surface;
  final Color surfaceElevated;
  final Color cardBackground;
  final Color northRed;
  final Color accentCyan;
  final Color accentGreen;
  final Color accentAmber;
  final Color dialRing;
  final Color dialTick;
  final Color dialTickMajor;
  final Color textPrimary;
  final Color textSecondary;
  final Color bubbleDefault;
  final Color bubbleLevel;
  final Color bubbleTargetRing;
  final Color goldPro;

  const CompassTheme({
    required this.background,
    required this.surface,
    required this.surfaceElevated,
    required this.cardBackground,
    required this.northRed,
    required this.accentCyan,
    required this.accentGreen,
    required this.accentAmber,
    required this.dialRing,
    required this.dialTick,
    required this.dialTickMajor,
    required this.textPrimary,
    required this.textSecondary,
    required this.bubbleDefault,
    required this.bubbleLevel,
    required this.bubbleTargetRing,
    required this.goldPro,
  });

  static const normal = CompassTheme(
    background: Color(0xFF0F1115),
    surface: Color(0xFF181B22),
    surfaceElevated: Color(0xFF222631),
    cardBackground: Color(0xFF222631),
    northRed: Color(0xFFFF3B30),
    accentCyan: Color(0xFF00E5FF),
    accentGreen: Color(0xFF00E676),
    accentAmber: Color(0xFFFF9100),
    dialRing: Color(0xFF2E3440),
    dialTick: Color(0xFF6B7280),
    dialTickMajor: Color(0xFFE5E7EB),
    textPrimary: Color(0xFFF9FAFB),
    textSecondary: Color(0xFF9CA3AF),
    bubbleDefault: Color(0xFF00E5FF),
    bubbleLevel: Color(0xFF00E676),
    bubbleTargetRing: Color(0x3300E5FF),
    goldPro: Color(0xFFFFB300),
  );

  static const nightVision = CompassTheme(
    background: Color(0xFF050000),
    surface: Color(0xFF150404),
    surfaceElevated: Color(0xFF240808),
    cardBackground: Color(0xFF240808),
    northRed: Color(0xFFFF1E1E),
    accentCyan: Color(0xFFFF4D4D),
    accentGreen: Color(0xFFFF3333),
    accentAmber: Color(0xFFFF6666),
    dialRing: Color(0xFF381010),
    dialTick: Color(0xFF702020),
    dialTickMajor: Color(0xFFCC3333),
    textPrimary: Color(0xFFFF4D4D),
    textSecondary: Color(0xFFAA2A2A),
    bubbleDefault: Color(0xFFFF3333),
    bubbleLevel: Color(0xFFFF1E1E),
    bubbleTargetRing: Color(0x44FF1E1E),
    goldPro: Color(0xFFFF4444),
  );
}
