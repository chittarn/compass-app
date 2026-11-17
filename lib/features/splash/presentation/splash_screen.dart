import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../compass/presentation/compass_screen.dart';
import '../../../core/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeInOut),
      ),
    );

    _animController.forward();

    // Smooth transition to main compass screen
    Timer(const Duration(milliseconds: 1800), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 500),
            pageBuilder: (context, animation, secondaryAnimation) =>
                const CompassScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1115),
      body: Center(
        child: AnimatedBuilder(
          animation: _animController,
          builder: (context, child) {
            return Opacity(
              opacity: _opacityAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Glowing Tactical Compass Emblem
                    Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer Neon Aura
                          Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.accentCyan.withOpacity(0.18),
                                  blurRadius: 40,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                          ),
                          // Outer Ring
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.dialRing,
                                width: 2.0,
                              ),
                              gradient: RadialGradient(
                                colors: [
                                  AppColors.surface,
                                  const Color(0xFF0F1115),
                                ],
                              ),
                            ),
                            child: CustomPaint(
                              painter: _SplashCompassPainter(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 36),

                    // App Title
                    const Text(
                      'COMPASS',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 6.0,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Subtitle
                    Text(
                      'PRECISION NAVIGATION & TELEMETRY',
                      style: TextStyle(
                        color: AppColors.textSecondary.withOpacity(0.7),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2.2,
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Minimalist sensor loading indicator
                    SizedBox(
                      width: 120,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          minHeight: 2,
                          backgroundColor: AppColors.dialRing.withOpacity(0.4),
                          color: AppColors.accentCyan,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'INITIALIZING SENSORS',
                      style: TextStyle(
                        color: AppColors.dialTick,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SplashCompassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Tick marks
    final tickPaint = Paint()
      ..color = AppColors.dialTick.withOpacity(0.6)
      ..strokeWidth = 1.0;

    for (int deg = 0; deg < 360; deg += 30) {
      final rad = deg * (math.pi / 180.0);
      final outerX = center.dx + (radius - 4) * math.sin(rad);
      final outerY = center.dy - (radius - 4) * math.cos(rad);
      final innerX = center.dx + (radius - 10) * math.sin(rad);
      final innerY = center.dy - (radius - 10) * math.cos(rad);
      canvas.drawLine(
        Offset(innerX, innerY),
        Offset(outerX, outerY),
        tickPaint,
      );
    }

    // North Needle (Red)
    final northPath = Path()
      ..moveTo(center.dx, center.dy - radius + 12)
      ..lineTo(center.dx - 8, center.dy)
      ..lineTo(center.dx, center.dy - 4)
      ..close();
    final northPaint = Paint()
      ..color = AppColors.northRed
      ..style = PaintingStyle.fill;
    canvas.drawPath(northPath, northPaint);

    // South Needle (Silver/Cyan)
    final southPath = Path()
      ..moveTo(center.dx, center.dy + radius - 12)
      ..lineTo(center.dx + 8, center.dy)
      ..lineTo(center.dx, center.dy + 4)
      ..close();
    final southPaint = Paint()
      ..color = AppColors.textSecondary
      ..style = PaintingStyle.fill;
    canvas.drawPath(southPath, southPaint);

    // Center pivot
    final pivotPaint = Paint()
      ..color = const Color(0xFF0F1115)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 5, pivotPaint);

    final dotPaint = Paint()
      ..color = AppColors.accentCyan
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 2.5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
