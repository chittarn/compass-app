import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class CompassDialPainter extends CustomPainter {
  final double heading; // Current heading in degrees
  final double? lockedBearing; // Target bearing for Pro users
  final double? qiblaBearing; // Qibla azimuth in degrees
  final bool isQiblaMode; // Whether Qibla navigation is active
  final double? sunAzimuth; // Solar azimuth in degrees [0, 360)
  final double? moonAzimuth; // Lunar azimuth in degrees [0, 360)
  final double? waypointBearing; // Waypoint azimuth in degrees [0, 360)
  final String? waypointTitle; // Waypoint label (e.g. "Car")
  final bool isVastuMode; // Whether Vastu Shastra mode is active
  final double? vastuTargetBearing; // Target room azimuth in degrees [0, 360)
  final CompassTheme theme;

  CompassDialPainter({
    required this.heading,
    this.lockedBearing,
    this.qiblaBearing,
    this.isQiblaMode = false,
    this.sunAzimuth,
    this.moonAzimuth,
    this.waypointBearing,
    this.waypointTitle,
    this.isVastuMode = false,
    this.vastuTargetBearing,
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
    _drawCardinalText(
      canvas,
      'N',
      0,
      cardinalRadius,
      theme.northRed,
      isBold: true,
      fontSize: 18,
    );
    _drawCardinalText(
      canvas,
      'E',
      90,
      cardinalRadius,
      theme.textPrimary,
      isBold: true,
      fontSize: 16,
    );
    _drawCardinalText(
      canvas,
      'S',
      180,
      cardinalRadius,
      theme.textPrimary,
      isBold: true,
      fontSize: 16,
    );
    _drawCardinalText(
      canvas,
      'W',
      270,
      cardinalRadius,
      theme.textPrimary,
      isBold: true,
      fontSize: 16,
    );

    // Draw Sub-cardinals (NE, SE, SW, NW)
    final subCardinalRadius = radius - 55;
    _drawCardinalText(
      canvas,
      'NE',
      45,
      subCardinalRadius,
      theme.textSecondary,
      isBold: false,
      fontSize: 11,
    );
    _drawCardinalText(
      canvas,
      'SE',
      135,
      subCardinalRadius,
      theme.textSecondary,
      isBold: false,
      fontSize: 11,
    );
    _drawCardinalText(
      canvas,
      'SW',
      225,
      subCardinalRadius,
      theme.textSecondary,
      isBold: false,
      fontSize: 11,
    );
    _drawCardinalText(
      canvas,
      'NW',
      315,
      subCardinalRadius,
      theme.textSecondary,
      isBold: false,
      fontSize: 11,
    );

    // If Target Bearing is Locked (PRO feature), draw Target Beacon on dial rim
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

    // If Qibla Mode is active, draw the Emerald Green / Gold Kaaba Marker on the dial rim!
    if (isQiblaMode && qiblaBearing != null) {
      final qRad = qiblaBearing! * (math.pi / 180.0);
      final qR = radius - 16;
      final qX = qR * math.sin(qRad);
      final qY = -qR * math.cos(qRad);

      canvas.save();
      canvas.translate(qX, qY);
      canvas.rotate(qRad); // Align marker radially outward

      // Outer glowing aura
      final qiblaGlow = Paint()
        ..color = const Color(0xFF00E676).withOpacity(0.35)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset.zero, 13, qiblaGlow);

      // Kaaba Cube Body (Black/Dark Slate with Gold Border)
      final kaabaBodyPaint = Paint()
        ..color = const Color(0xFF111317)
        ..style = PaintingStyle.fill;
      final kaabaBorderPaint = Paint()
        ..color = const Color(0xFFFFD700)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: 14, height: 14),
        const Radius.circular(2.5),
      );
      canvas.drawRRect(rect, kaabaBodyPaint);
      canvas.drawRRect(rect, kaabaBorderPaint);

      // Golden Kiswah Top Stripe
      final stripePaint = Paint()
        ..color = const Color(0xFFFFD700)
        ..strokeWidth = 1.8
        ..style = PaintingStyle.stroke;
      canvas.drawLine(const Offset(-6, -3), const Offset(6, -3), stripePaint);

      // Emerald Pointer Arrow towards Kaaba rim
      final arrowPaint = Paint()
        ..color = const Color(0xFF00E676)
        ..style = PaintingStyle.fill;
      final arrowPath = Path()
        ..moveTo(0, -9)
        ..lineTo(-4, -6)
        ..lineTo(4, -6)
        ..close();
      canvas.drawPath(arrowPath, arrowPaint);

      canvas.restore();
    }

    // Solar Azimuth Marker (Golden Sun Disc + Rays)
    if (sunAzimuth != null) {
      final sunRad = sunAzimuth! * (math.pi / 180.0);
      final sunR = radius - 16;
      final sunX = sunR * math.sin(sunRad);
      final sunY = -sunR * math.cos(sunRad);

      canvas.save();
      canvas.translate(sunX, sunY);

      // Warm golden glow
      final sunGlow = Paint()
        ..color = const Color(0xFFFFD54F).withOpacity(0.35)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset.zero, 11, sunGlow);

      // Sun core disc
      final sunCore = Paint()
        ..color = const Color(0xFFFFC107)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset.zero, 5, sunCore);

      // 4 solar rays
      final rayPaint = Paint()
        ..color = const Color(0xFFFFE082)
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(const Offset(0, -9), const Offset(0, -6.5), rayPaint);
      canvas.drawLine(const Offset(0, 6.5), const Offset(0, 9), rayPaint);
      canvas.drawLine(const Offset(-9, 0), const Offset(-6.5, 0), rayPaint);
      canvas.drawLine(const Offset(6.5, 0), const Offset(9, 0), rayPaint);

      canvas.restore();
    }

    // Lunar Azimuth Marker (Silvery Crescent Moon)
    if (moonAzimuth != null) {
      final moonRad = moonAzimuth! * (math.pi / 180.0);
      final moonR = radius - 16;
      final moonX = moonR * math.sin(moonRad);
      final moonY = -moonR * math.cos(moonRad);

      canvas.save();
      canvas.translate(moonX, moonY);

      // Silver moonlight glow
      final moonGlow = Paint()
        ..color = const Color(0xFF90CAF9).withOpacity(0.28)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset.zero, 10, moonGlow);

      // Crescent Moon shape
      final moonPaint = Paint()
        ..color = const Color(0xFFECEFF1)
        ..style = PaintingStyle.fill;

      final cPath = Path()
        ..moveTo(0, -5.5)
        ..arcToPoint(
          const Offset(0, 5.5),
          radius: const Radius.circular(5.5),
          clockwise: false,
        )
        ..arcToPoint(
          const Offset(0, -5.5),
          radius: const Radius.circular(7.5),
          clockwise: true,
        )
        ..close();
      canvas.drawPath(cPath, moonPaint);

      canvas.restore();
    }

    // Waypoint Beacon Marker (High-visibility Cyan Pointer for Backtracking)
    if (waypointBearing != null) {
      final wpRad = waypointBearing! * (math.pi / 180.0);
      final wpR = radius - 16;
      final wpX = wpR * math.sin(wpRad);
      final wpY = -wpR * math.cos(wpRad);

      canvas.save();
      canvas.translate(wpX, wpY);
      canvas.rotate(wpRad); // Point radial arrow outward

      // Cyan neon aura
      final wpGlow = Paint()
        ..color = const Color(0xFF00E5FF).withOpacity(0.35)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset.zero, 13, wpGlow);

      // Cyan pin head
      final wpPin = Paint()
        ..color = const Color(0xFF00E5FF)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset.zero, 4.5, wpPin);

      // Center white pip
      final centerDot = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset.zero, 2.0, centerDot);

      // Triangular arrow pointer pointing outward to rim
      final pointerPath = Path()
        ..moveTo(0, -10)
        ..lineTo(-4.5, -5.5)
        ..lineTo(4.5, -5.5)
        ..close();
      canvas.drawPath(pointerPath, wpPin);

      canvas.restore();
    }

    // Vastu Target Beacon Marker (Golden Om Sacred Needle)
    if (isVastuMode && vastuTargetBearing != null) {
      final vRad = vastuTargetBearing! * (math.pi / 180.0);
      final vR = radius - 16;
      final vX = vR * math.sin(vRad);
      final vY = -vR * math.cos(vRad);

      canvas.save();
      canvas.translate(vX, vY);
      canvas.rotate(vRad);

      // Gold aura
      final vGlow = Paint()
        ..color = const Color(0xFFFFD700).withOpacity(0.38)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset.zero, 13, vGlow);

      // Gold pin head
      final vPin = Paint()
        ..color = const Color(0xFFFFD700)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset.zero, 4.5, vPin);

      // Gold radial pointer arrow
      final vArrow = Path()
        ..moveTo(0, -10)
        ..lineTo(-4.5, -5.5)
        ..lineTo(4.5, -5.5)
        ..close();
      canvas.drawPath(vArrow, vPin);

      canvas.restore();
    }

    // Vastu Sanskrit Sub-Cardinal Labels on Dial Rim
    if (isVastuMode) {
      _drawCardinalText(
        canvas,
        'ईशान',
        45,
        radius - 46,
        const Color(0xFFFFD700),
        isBold: true,
        fontSize: 8.5,
      );
      _drawCardinalText(
        canvas,
        'आग्नेय',
        135,
        radius - 46,
        const Color(0xFFFFD700),
        isBold: true,
        fontSize: 8.5,
      );
      _drawCardinalText(
        canvas,
        'नैऋत्य',
        225,
        radius - 46,
        const Color(0xFFFFD700),
        isBold: true,
        fontSize: 8.5,
      );
      _drawCardinalText(
        canvas,
        'वायव्य',
        315,
        radius - 46,
        const Color(0xFFFFD700),
        isBold: true,
        fontSize: 8.5,
      );
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

  void _drawDegreeText(
    Canvas canvas,
    String text,
    int deg,
    double r,
    Color color,
  ) {
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
    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, -textPainter.height / 2),
    );
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
        oldDelegate.qiblaBearing != qiblaBearing ||
        oldDelegate.isQiblaMode != isQiblaMode ||
        oldDelegate.sunAzimuth != sunAzimuth ||
        oldDelegate.moonAzimuth != moonAzimuth ||
        oldDelegate.waypointBearing != waypointBearing ||
        oldDelegate.waypointTitle != waypointTitle ||
        oldDelegate.isVastuMode != isVastuMode ||
        oldDelegate.vastuTargetBearing != vastuTargetBearing ||
        oldDelegate.theme != theme;
  }
}
