import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../domain/heading_type.dart';
import '../../../../core/theme/app_colors.dart';

class CalibrationModal extends StatefulWidget {
  final SensorAccuracyLevel accuracy;

  const CalibrationModal({super.key, required this.accuracy});

  static Future<void> show(BuildContext context, SensorAccuracyLevel accuracy) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => CalibrationModal(accuracy: accuracy),
    );
  }

  @override
  State<CalibrationModal> createState() => _CalibrationModalState();
}

class _CalibrationModalState extends State<CalibrationModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.dialRing, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.dialTick,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.sensors, color: AppColors.accentCyan, size: 24),
              SizedBox(width: 8),
              Text(
                'Compass Calibration',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Magnetic interference detected. Gently wave your phone in a Figure-8 motion until the sensor recalibrates.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          // Animated Figure-8 Canvas
          SizedBox(
            width: 200,
            height: 100,
            child: AnimatedBuilder(
              animation: _animController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _Figure8Painter(progress: _animController.value),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.surfaceElevated,
                foregroundColor: AppColors.textPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.dialRing),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Got it', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

class _Figure8Painter extends CustomPainter {
  final double progress;

  _Figure8Painter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final a = size.width * 0.40; // horizontal lobe radius
    final b = size.height * 0.38; // vertical lobe radius

    // 1. Draw Figure-8 Lemniscate of Bernoulli track
    final trackPath = Path();
    for (double t = 0; t <= 2 * math.pi; t += 0.05) {
      // Lemniscate formula: x = a*cos(t)/(1+sin^2(t)), y = b*sin(t)*cos(t)/(1+sin^2(t))
      final denom = 1 + math.pow(math.sin(t), 2);
      final x = center.dx + (a * math.cos(t)) / denom;
      final y = center.dy + (b * math.sin(t) * math.cos(t)) / denom;

      if (t == 0) {
        trackPath.moveTo(x, y);
      } else {
        trackPath.lineTo(x, y);
      }
    }
    trackPath.close();

    final trackPaint = Paint()
      ..color = AppColors.dialRing
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    canvas.drawPath(trackPath, trackPaint);

    // 2. Draw Moving Phone Node along the Lemniscate
    final tNode = progress * 2 * math.pi;
    final denomNode = 1 + math.pow(math.sin(tNode), 2);
    final nodeX = center.dx + (a * math.cos(tNode)) / denomNode;
    final nodeY = center.dy + (b * math.sin(tNode) * math.cos(tNode)) / denomNode;
    final nodePos = Offset(nodeX, nodeY);

    // Node glow
    canvas.drawCircle(
      nodePos,
      12,
      Paint()
        ..color = AppColors.accentCyan.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // Node body (representing device moving along path)
    canvas.drawCircle(
      nodePos,
      7,
      Paint()
        ..color = AppColors.accentCyan
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant _Figure8Painter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
