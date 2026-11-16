import 'package:flutter/material.dart';

enum AppThemeMode {
  tacticalDark('Classic Dark', 'Default tactical cyan and dark slate', Color(0xFF00E5FF)),
  tacticalAmber('Tactical Amber', 'Military aviation high-contrast amber', Color(0xFFFFB300)),
  arcticCyan('Arctic Cyan', 'Ice blue high-contrast polar palette', Color(0xFF80DEEA)),
  nightVision('OLED Red Vision', 'Pure scotopic red on true black for darkness', Color(0xFFFF1E1E));

  final String label;
  final String description;
  final Color primaryColor;
  const AppThemeMode(this.label, this.description, this.primaryColor);
}

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

  static const tacticalAmber = CompassTheme(
    background: Color(0xFF100E08),
    surface: Color(0xFF1A160D),
    surfaceElevated: Color(0xFF282114),
    cardBackground: Color(0xFF282114),
    northRed: Color(0xFFFF3D00),
    accentCyan: Color(0xFFFFB300),
    accentGreen: Color(0xFFFFD54F),
    accentAmber: Color(0xFFFF9100),
    dialRing: Color(0xFF382E19),
    dialTick: Color(0xFF806B3E),
    dialTickMajor: Color(0xFFFFE082),
    textPrimary: Color(0xFFFFF8E1),
    textSecondary: Color(0xFFBCAAA4),
    bubbleDefault: Color(0xFFFFB300),
    bubbleLevel: Color(0xFFFFD54F),
    bubbleTargetRing: Color(0x33FFB300),
    goldPro: Color(0xFFFFB300),
  );

  static const arcticCyan = CompassTheme(
    background: Color(0xFF081016),
    surface: Color(0xFF0F1C26),
    surfaceElevated: Color(0xFF162A38),
    cardBackground: Color(0xFF162A38),
    northRed: Color(0xFFFF5252),
    accentCyan: Color(0xFF80DEEA),
    accentGreen: Color(0xFF64FFDA),
    accentAmber: Color(0xFFFFB74D),
    dialRing: Color(0xFF1D3545),
    dialTick: Color(0xFF4C758F),
    dialTickMajor: Color(0xFFB2EBF2),
    textPrimary: Color(0xFFE0F7FA),
    textSecondary: Color(0xFF80DEEA),
    bubbleDefault: Color(0xFF80DEEA),
    bubbleLevel: Color(0xFF64FFDA),
    bubbleTargetRing: Color(0x3380DEEA),
    goldPro: Color(0xFFFFD54F),
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
