import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class BubbleLevelPainter extends CustomPainter {
  final double pitch; // X tilt (-90 to 90)
  final double roll;  // Y tilt (-180 to 180)
  final bool isLevel;

  BubbleLevelPainter({
    required this.pitch,
    required this.roll,
    required this.isLevel,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;
    final targetRadius = maxRadius * 0.28;

    // 1. Level container background
    final bgPaint = Paint()
      ..color = AppColors.surfaceElevated.withOpacity(0.9)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, maxRadius, bgPaint);

    final borderPaint = Paint()
      ..color = AppColors.dialRing
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, maxRadius, borderPaint);

    // 2. Center Target Crosshairs
    final crosshairPaint = Paint()
      ..color = isLevel
          ? AppColors.bubbleLevel.withOpacity(0.6)
          : AppColors.dialTick.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawLine(
      Offset(center.dx - maxRadius * 0.7, center.dy),
      Offset(center.dx + maxRadius * 0.7, center.dy),
      crosshairPaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - maxRadius * 0.7),
      Offset(center.dx, center.dy + maxRadius * 0.7),
      crosshairPaint,
    );

    // Center target ring (sweet spot)
    final targetRingPaint = Paint()
      ..color = isLevel
          ? AppColors.bubbleLevel.withOpacity(0.5)
          : AppColors.bubbleTargetRing
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, targetRadius, targetRingPaint);

    // 3. Calculate Bubble Position from Pitch and Roll
    // Scale factor: +/- 15 degrees maps to edge of the bubble level circle
    const maxDegreeRange = 15.0;
    final clampedRoll = roll.clamp(-maxDegreeRange, maxDegreeRange);
    final clampedPitch = pitch.clamp(-maxDegreeRange, maxDegreeRange);

    final maxTravel = maxRadius - (targetRadius * 0.8);
    final dx = (clampedRoll / maxDegreeRange) * maxTravel;
    // Invert pitch so tilting device forward moves bubble up
    final dy = (-clampedPitch / maxDegreeRange) * maxTravel;

    final bubblePos = Offset(center.dx + dx, center.dy + dy);

    // 4. Draw Bubble Indicator
    final bubbleColor = isLevel ? AppColors.bubbleLevel : AppColors.bubbleDefault;

    // Bubble shadow/glow
    final glowPaint = Paint()
      ..color = bubbleColor.withOpacity(0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(bubblePos, targetRadius * 0.7, glowPaint);

    // Bubble body
    final bubblePaint = Paint()
      ..color = bubbleColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(bubblePos, targetRadius * 0.65, bubblePaint);

    // Bubble highlight reflection
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(bubblePos.dx - 2.5, bubblePos.dy - 2.5),
      targetRadius * 0.22,
      highlightPaint,
    );
  }

  @override
  bool shouldRepaint(covariant BubbleLevelPainter oldDelegate) {
    return oldDelegate.pitch != pitch ||
        oldDelegate.roll != roll ||
        oldDelegate.isLevel != isLevel;
  }
}
