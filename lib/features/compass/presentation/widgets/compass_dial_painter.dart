import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class CompassDialPainter extends CustomPainter {
  final double heading; // Current heading in degrees

  CompassDialPainter({required this.heading});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    // Save canvas state and rotate so North aligns to the current heading
    canvas.save();
    canvas.translate(center.dx, center.dy);
    // Rotate canvas by -heading in radians so heading degree is at top (12 o'clock)
    canvas.rotate(-heading * (math.pi / 180.0));

    final dialBgPaint = Paint()
      ..color = AppColors.surface
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset.zero, radius - 8, dialBgPaint);

    final outerRingPaint = Paint()
      ..color = AppColors.dialRing
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(Offset.zero, radius - 10, outerRingPaint);

    final tickPaint = Paint()
      ..color = AppColors.dialTick
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final majorTickPaint = Paint()
      ..color = AppColors.dialTickMajor
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final northTickPaint = Paint()
      ..color = AppColors.northRed
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    // Draw ticks & labels around 360 degrees
    for (int deg = 0; deg < 360; deg++) {
      final rad = deg * (math.pi / 180.0);
      final isMajor = deg % 15 == 0;
      final isFive = deg % 5 == 0;
      final isNorth = deg == 0;

      double tickLength;
      Paint currentPaint;

      if (isNorth) {
        tickLength = 22.0;
        currentPaint = northTickPaint;
      } else if (isMajor) {
        tickLength = 16.0;
        currentPaint = majorTickPaint;
      } else if (isFive) {
        tickLength = 10.0;
        currentPaint = tickPaint..strokeWidth = 1.5;
      } else {
        tickLength = 5.0;
        currentPaint = tickPaint..strokeWidth = 1.0;
      }

      final startR = radius - 12;
      final endR = startR - tickLength;

      final p1 = Offset(startR * math.sin(rad), -startR * math.cos(rad));
      final p2 = Offset(endR * math.sin(rad), -endR * math.cos(rad));

      canvas.drawLine(p1, p2, currentPaint);

      // Draw numerical labels for major 30-degree intervals (except 0, 90, 180, 270 which have cardinals)
      if (deg % 30 == 0 && deg % 90 != 0) {
        _drawDegreeText(canvas, deg.toString(), rad, radius - 46);
      }
    }

    // Draw Cardinal Points: N, E, S, W
    _drawCardinalText(canvas, 'N', 0.0, radius - 48, AppColors.northRed, isBold: true, fontSize: 22);
    _drawCardinalText(canvas, 'E', 90.0, radius - 48, AppColors.textPrimary, isBold: true, fontSize: 18);
    _drawCardinalText(canvas, 'S', 180.0, radius - 48, AppColors.textPrimary, isBold: true, fontSize: 18);
    _drawCardinalText(canvas, 'W', 270.0, radius - 48, AppColors.textPrimary, isBold: true, fontSize: 18);

    // Draw Subcardinal Points: NE, SE, SW, NW
    _drawCardinalText(canvas, 'NE', 45.0, radius - 46, AppColors.textSecondary, isBold: false, fontSize: 13);
    _drawCardinalText(canvas, 'SE', 135.0, radius - 46, AppColors.textSecondary, isBold: false, fontSize: 13);
    _drawCardinalText(canvas, 'SW', 225.0, radius - 46, AppColors.textSecondary, isBold: false, fontSize: 13);
    _drawCardinalText(canvas, 'NW', 315.0, radius - 46, AppColors.textSecondary, isBold: false, fontSize: 13);

    // North Pointer Triangle at 0°
    final pointerPath = Path()
      ..moveTo(0, -(radius - 12))
      ..lineTo(-8, -(radius - 28))
      ..lineTo(8, -(radius - 28))
      ..close();
    canvas.drawPath(pointerPath, Paint()..color = AppColors.northRed);

    canvas.restore();
  }

  void _drawDegreeText(Canvas canvas, String text, double rad, double r) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          fontFamily: 'monospace',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final x = r * math.sin(rad) - (textPainter.width / 2);
    final y = -r * math.cos(rad) - (textPainter.height / 2);

    canvas.save();
    canvas.translate(x + textPainter.width / 2, y + textPainter.height / 2);
    // Keep numbers upright relative to the dial spoke
    textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
    canvas.restore();
  }

  void _drawCardinalText(
    Canvas canvas,
    String text,
    double deg,
    double r,
    Color color, {
    required bool isBold,
    required double fontSize,
  }) {
    final rad = deg * (math.pi / 180.0);
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final x = r * math.sin(rad) - (textPainter.width / 2);
    final y = -r * math.cos(rad) - (textPainter.height / 2);

    textPainter.paint(canvas, Offset(x, y));
  }

  @override
  bool shouldRepaint(covariant CompassDialPainter oldDelegate) {
    return oldDelegate.heading != heading;
  }
}
