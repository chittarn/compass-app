import 'package:flutter/material.dart';
import '../../domain/heading_type.dart';
import '../../../../core/theme/app_colors.dart';

class AccuracyBadge extends StatelessWidget {
  final SensorAccuracyLevel accuracy;
  final VoidCallback onTap;

  const AccuracyBadge({
    super.key,
    required this.accuracy,
    required this.onTap,
  });

  Color get _badgeColor {
    switch (accuracy) {
      case SensorAccuracyLevel.high:
        return AppColors.accuracyHigh;
      case SensorAccuracyLevel.medium:
        return AppColors.accuracyMedium;
      case SensorAccuracyLevel.low:
        return AppColors.accuracyLow;
      case SensorAccuracyLevel.unreliable:
        return AppColors.accuracyUnreliable;
    }
  }

  String get _badgeText {
    switch (accuracy) {
      case SensorAccuracyLevel.high:
        return 'Accurate';
      case SensorAccuracyLevel.medium:
        return 'Moderate';
      case SensorAccuracyLevel.low:
        return 'Calibrate';
      case SensorAccuracyLevel.unreliable:
        return 'Interference';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _badgeColor.withOpacity(0.5),
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: _badgeColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _badgeColor.withOpacity(0.6),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Text(
              _badgeText,
              style: TextStyle(
                color: _badgeColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
