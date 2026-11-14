import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/compass_controller.dart';
import '../domain/heading_type.dart';
import 'widgets/compass_dial_painter.dart';
import 'widgets/bubble_level_painter.dart';
import 'widgets/accuracy_badge.dart';
import 'widgets/calibration_modal.dart';
import '../../../../core/constants/compass_constants.dart';
import '../../../../core/theme/app_colors.dart';

class CompassScreen extends ConsumerStatefulWidget {
  const CompassScreen({super.key});

  @override
  ConsumerState<CompassScreen> createState() => _CompassScreenState();
}

class _CompassScreenState extends ConsumerState<CompassScreen> {
  bool _modalShownForUnreliable = false;

  void _checkCalibrationAlert(SensorAccuracyLevel accuracy) {
    if ((accuracy == SensorAccuracyLevel.unreliable || accuracy == SensorAccuracyLevel.low) &&
        !_modalShownForUnreliable) {
      _modalShownForUnreliable = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          CalibrationModal.show(context, accuracy);
        }
      });
    } else if (accuracy == SensorAccuracyLevel.high || accuracy == SensorAccuracyLevel.medium) {
      _modalShownForUnreliable = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(compassControllerProvider);
    final controller = ref.read(compassControllerProvider.notifier);

    _checkCalibrationAlert(state.accuracy);

    final directionLabel = CompassConstants.getDirectionLabel(state.heading);
    final isTrueNorth = state.headingType == HeadingType.trueNorth;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar: App Title & Accuracy Badge
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'COMPASS',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2.0,
                    ),
                  ),
                  AccuracyBadge(
                    accuracy: state.accuracy,
                    onTap: () => CalibrationModal.show(context, state.accuracy),
                  ),
                ],
              ),
            ),

            const Spacer(flex: 1),

            // Heading & Cardinal Readout
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      state.heading.round().toString().padLeft(3, '0'),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 64,
                        fontWeight: FontWeight.w300,
                        fontFamily: 'monospace',
                        letterSpacing: -1.0,
                      ),
                    ),
                    const Text(
                      '°',
                      style: TextStyle(
                        color: AppColors.northRed,
                        fontSize: 42,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      directionLabel,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Heading Mode Toggle Pill (Magnetic vs True North)
                GestureDetector(
                  onTap: () async {
                    final success = await controller.toggleHeadingType();
                    if (!success && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Location permission required for True North declination.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isTrueNorth ? AppColors.accentCyan : AppColors.dialRing,
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isTrueNorth ? Icons.navigation : Icons.explore,
                          size: 14,
                          color: isTrueNorth ? AppColors.accentCyan : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isTrueNorth ? 'True North (GPS)' : 'Magnetic North',
                          style: TextStyle(
                            color: isTrueNorth ? AppColors.accentCyan : AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const Spacer(flex: 1),

            // Compass Dial & Integrated Center Bubble Level
            Center(
              child: SizedBox(
                width: 320,
                height: 320,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Smooth 60/120fps Rotating Dial
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(end: state.unwrappedHeading),
                      duration: const Duration(milliseconds: 140),
                      curve: Curves.easeOutCubic,
                      builder: (context, animatedHeading, child) {
                        return RepaintBoundary(
                          child: CustomPaint(
                            size: const Size(320, 320),
                            painter: CompassDialPainter(heading: animatedHeading),
                          ),
                        );
                      },
                    ),

                    // Top Pointer Index Mark (Static Red Line pointing to current heading)
                    Positioned(
                      top: 4,
                      child: Container(
                        width: 3,
                        height: 14,
                        decoration: BoxDecoration(
                          color: AppColors.northRed,
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.northRed.withOpacity(0.8),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Central 2D Bubble Level / Inclinometer
                    SizedBox(
                      width: 90,
                      height: 90,
                      child: RepaintBoundary(
                        child: CustomPaint(
                          painter: BubbleLevelPainter(
                            pitch: state.pitch,
                            roll: state.roll,
                            isLevel: state.isLevel,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(flex: 1),

            // Bottom Pitch & Roll / Attitude Telemetry Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.dialRing),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildTelemetryItem(
                      label: 'PITCH',
                      value: '${state.pitch >= 0 ? '+' : ''}${state.pitch.toStringAsFixed(1)}°',
                      isLevel: state.isLevel,
                    ),
                    Container(width: 1, height: 28, color: AppColors.dialRing),
                    _buildTelemetryItem(
                      label: 'ROLL',
                      value: '${state.roll >= 0 ? '+' : ''}${state.roll.toStringAsFixed(1)}°',
                      isLevel: state.isLevel,
                    ),
                    Container(width: 1, height: 28, color: AppColors.dialRing),
                    _buildTelemetryItem(
                      label: 'STATUS',
                      value: state.isLevel ? 'LEVEL' : 'TILTED',
                      isLevel: state.isLevel,
                      isStatus: true,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildTelemetryItem({
    required String label,
    required String value,
    required bool isLevel,
    bool isStatus = false,
  }) {
    Color valColor = AppColors.textPrimary;
    if (isStatus) {
      valColor = isLevel ? AppColors.bubbleLevel : AppColors.dialTick;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            color: valColor,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}
