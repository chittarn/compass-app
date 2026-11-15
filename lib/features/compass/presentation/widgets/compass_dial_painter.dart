import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class CompassDialPainter extends CustomPainter {
  final double heading; // Current heading in degrees
  final double? lockedBearing; // Target bearing for Pro users
  final CompassTheme theme;

  CompassDialPainter({
    required this.heading,
    this.lockedBearing,
    this.theme = CompassTheme.normal,
  });

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
      ..color = theme.surface
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset.zero, radius - 8, dialBgPaint);

    final outerRingPaint = Paint()
      ..color = theme.dialRing
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(Offset.zero, radius - 10, outerRingPaint);

    final tickPaint = Paint()
      ..color = theme.dialTick
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final majorTickPaint = Paint()
      ..color = theme.dialTickMajor
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final northTickPaint = Paint()
      ..color = theme.northRed
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    // Draw ticks & labels around 360 degrees
    for (int deg = 0; deg < 360; deg++) {
      final rad = deg * (math.pi / 180.0);
      final cosVal = math.cos(rad);
      final sinVal = math.sin(rad);

      final outerR = radius - 12;
      double innerR;

      if (deg == 0) {
        // True North tick
        innerR = radius - 26;
        canvas.drawLine(
          Offset(sinVal * innerR, -cosVal * innerR),
          Offset(sinVal * outerR, -cosVal * outerR),
          northTickPaint,
        );
      } else if (deg % 30 == 0) {
        // Major 30-degree ticks
        innerR = radius - 22;
        canvas.drawLine(
          Offset(sinVal * innerR, -cosVal * innerR),
          Offset(sinVal * outerR, -cosVal * outerR),
          majorTickPaint,
        );

        // Degree numbers
        _drawDegreeText(canvas, '$deg', deg, radius - 36, theme.textSecondary);
      } else if (deg % 5 == 0) {
        // 5-degree intermediate ticks
        innerR = radius - 18;
        tickPaint.strokeWidth = 1.5;
        canvas.drawLine(
          Offset(sinVal * innerR, -cosVal * innerR),
          Offset(sinVal * outerR, -cosVal * outerR),
          tickPaint,
        );
      } else {
        // 1-degree minor ticks
        innerR = radius - 15;
        tickPaint.strokeWidth = 0.8;
        canvas.drawLine(
          Offset(sinVal * innerR, -cosVal * innerR),
          Offset(sinVal * outerR, -cosVal * outerR),
          tickPaint,
        );
      }
    }

    // Draw Cardinal Text (N, E, S, W)
    final cardinalRadius = radius - 56;
    _drawCardinalText(canvas, 'N', 0, cardinalRadius, theme.northRed, isBold: true, fontSize: 18);
    _drawCardinalText(canvas, 'E', 90, cardinalRadius, theme.textPrimary, isBold: true, fontSize: 16);
    _drawCardinalText(canvas, 'S', 180, cardinalRadius, theme.textPrimary, isBold: true, fontSize: 16);
    _drawCardinalText(canvas, 'W', 270, cardinalRadius, theme.textPrimary, isBold: true, fontSize: 16);

    // Draw Sub-cardinals (NE, SE, SW, NW)
    final subCardinalRadius = radius - 55;
    _drawCardinalText(canvas, 'NE', 45, subCardinalRadius, theme.textSecondary, isBold: false, fontSize: 11);
    _drawCardinalText(canvas, 'SE', 135, subCardinalRadius, theme.textSecondary, isBold: false, fontSize: 11);
    _drawCardinalText(canvas, 'SW', 225, subCardinalRadius, theme.textSecondary, isBold: false, fontSize: 11);
    _drawCardinalText(canvas, 'NW', 315, subCardinalRadius, theme.textSecondary, isBold: false, fontSize: 11);

    // If a Target Bearing is Locked (PRO feature), draw the Target Beacon on the dial rim!
    if (lockedBearing != null) {
      final targetRad = lockedBearing! * (math.pi / 180.0);
      final targetR = radius - 12;
      final targetX = targetR * math.sin(targetRad);
      final targetY = -targetR * math.cos(targetRad);

      // Target pointer diamond
      final diamondPaint = Paint()
        ..color = theme.goldPro
        ..style = PaintingStyle.fill;

      final diamondPath = Path();
      const dSize = 8.0;
      diamondPath.moveTo(targetX, targetY - dSize);
      diamondPath.lineTo(targetX + dSize, targetY);
      diamondPath.lineTo(targetX, targetY + dSize);
      diamondPath.lineTo(targetX - dSize, targetY);
      diamondPath.close();

      canvas.drawPath(diamondPath, diamondPaint);

      final glowPaint = Paint()
        ..color = theme.goldPro.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;
      canvas.drawCircle(Offset(targetX, targetY), dSize + 3, glowPaint);
    }

    canvas.restore();

    // Top fixed lubber line indicator (fixed at 12 o'clock outside rotated canvas)
    final lubberPaint = Paint()
      ..color = theme.northRed
      ..style = PaintingStyle.fill;

    final lubberPath = Path()
      ..moveTo(center.dx, center.dy - radius + 4)
      ..lineTo(center.dx - 6, center.dy - radius - 6)
      ..lineTo(center.dx + 6, center.dy - radius - 6)
      ..close();

    canvas.drawPath(lubberPath, lubberPaint);
  }

  void _drawDegreeText(Canvas canvas, String text, int deg, double r, Color color) {
    final rad = deg * (math.pi / 180.0);
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: 9,
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
    return oldDelegate.heading != heading ||
        oldDelegate.lockedBearing != lockedBearing ||
        oldDelegate.theme != theme;
  }
}
