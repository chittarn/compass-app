import 'package:flutter/material.dart';

class AppColors {
  // Backgrounds & Surface
  static const Color background = Color(0xFF0F1115);
  static const Color surface = Color(0xFF181B22);
  static const Color surfaceElevated = Color(0xFF222631);

  // Tactical Accents
  static const Color northRed = Color(0xFFFF3B30);
  static const Color accentCyan = Color(0xFF00E5FF);
  static const Color dialRing = Color(0xFF2E3440);
  static const Color dialTick = Color(0xFF6B7280);
  static const Color dialTickMajor = Color(0xFFE5E7EB);
  static const Color textPrimary = Color(0xFFF9FAFB);
  static const Color textSecondary = Color(0xFF9CA3AF);

  // Inclinometer / Bubble Level
  static const Color bubbleDefault = Color(0xFF00E5FF);
  static const Color bubbleLevel = Color(0xFF00E676); // Vibrant green when level (<= 1.5 deg)
  static const Color bubbleTargetRing = Color(0x3300E5FF);

  // Sensor Accuracy Badges
  static const Color accuracyHigh = Color(0xFF00E676);
  static const Color accuracyMedium = Color(0xFFFFD600);
  static const Color accuracyLow = Color(0xFFFF9100);
  static const Color accuracyUnreliable = Color(0xFFFF1744);
}
