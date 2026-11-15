import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'controllers/compass_controller.dart';
import '../domain/heading_type.dart';
import 'widgets/compass_dial_painter.dart';
import 'widgets/bubble_level_painter.dart';
import 'widgets/accuracy_badge.dart';
import 'widgets/calibration_modal.dart';
import 'widgets/telemetry_guide_modal.dart';
import '../../pro/controllers/pro_controller.dart';
import '../../pro/presentation/pro_upgrade_modal.dart';
import '../../pro/presentation/widgets/navigation_ad_banner.dart';
import '../../waypoints/controllers/waypoints_controller.dart';
import '../../waypoints/presentation/waypoint_modal.dart';
import '../../../core/constants/compass_constants.dart';
import '../../../core/theme/app_colors.dart';

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
    final proState = ref.watch(proControllerProvider);
    final proNotifier = ref.read(proControllerProvider.notifier);
    final wpState = ref.watch(waypointsControllerProvider);
    final wpNotifier = ref.read(waypointsControllerProvider.notifier);

    final theme = proState.isNightVision ? CompassTheme.nightVision : CompassTheme.normal;

    _checkCalibrationAlert(state.accuracy);

    final directionLabel = CompassConstants.getDirectionLabel(state.heading);
    final isTrueNorth = state.headingType == HeadingType.trueNorth;

    // Active Waypoint tracking calculation
    final activeWp = wpState.activeWaypoint;
    final bool hasGps = state.latitude != null && state.longitude != null;
    double? waypointBearing;
    String? waypointDistance;
    if (activeWp != null && hasGps) {
      waypointBearing = activeWp.bearingFrom(state.latitude!, state.longitude!);
      waypointDistance = activeWp.formattedDistanceFrom(state.latitude!, state.longitude!);
    }

    // Calculate Bearing Deviation if Bearing is Locked (PRO)
    double? driftAngle;
    String driftLabel = '';
    if (proState.lockedBearing != null) {
      double diff = (state.heading - proState.lockedBearing!) % 360;
      if (diff > 180) diff -= 360;
      if (diff < -180) diff += 360;
      driftAngle = diff;
      driftLabel = diff >= 0
          ? '+${diff.round()}° RIGHT'
          : '${diff.round()}° LEFT';
    }

    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar: Title, Field Guide, Night Vision, PRO Badge, Accuracy Badge
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'COMPASS',
                        style: TextStyle(
                          color: theme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        icon: Icon(
                          Icons.info_outline_rounded,
                          color: theme.accentCyan,
                          size: 20,
                        ),
                        tooltip: 'Field Guide & Telemetry Glossary',
                        onPressed: () => TelemetryGuideModal.show(context),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      // Red OLED Night Vision Toggle (Pro only)
                      if (proState.isPro)
                        IconButton(
                          icon: Icon(
                            proState.isNightVision ? Icons.lightbulb_rounded : Icons.nightlight_round,
                            color: proState.isNightVision ? theme.northRed : theme.textSecondary,
                            size: 20,
                          ),
                          tooltip: 'Red OLED Night Vision',
                          onPressed: () => proNotifier.toggleNightVision(),
                        ),

                      // PRO / UPGRADE Badge
                      InkWell(
                        onTap: () => ProUpgradeModal.show(context),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            gradient: proState.isPro
                                ? LinearGradient(colors: [
                                    theme.accentCyan.withOpacity(0.25),
                                    theme.accentCyan.withOpacity(0.08)
                                  ])
                                : LinearGradient(colors: [
                                    theme.goldPro.withOpacity(0.3),
                                    theme.accentAmber.withOpacity(0.15)
                                  ]),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: proState.isPro ? theme.accentCyan : theme.goldPro,
                              width: 1.0,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                proState.isPro ? Icons.verified_rounded : Icons.workspace_premium_rounded,
                                color: proState.isPro ? theme.accentCyan : theme.goldPro,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                proState.isPro ? 'PRO' : 'GET PRO',
                                style: TextStyle(
                                  color: proState.isPro ? theme.accentCyan : theme.goldPro,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Accuracy Badge
                      AccuracyBadge(
                        accuracy: state.accuracy,
                        onTap: () => CalibrationModal.show(context, state.accuracy),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Spacer(flex: 1),

            // Heading & Cardinal Readout (Tap to Lock Target Bearing)
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                if (proState.isPro) {
                  if (proState.hasLockedBearing) {
                    proNotifier.clearLockedBearing();
                  } else {
                    proNotifier.lockBearing(state.heading);
                  }
                } else {
                  ProUpgradeModal.show(context);
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          state.heading.round().toString().padLeft(3, '0'),
                          style: TextStyle(
                            color: theme.textPrimary,
                            fontSize: 64,
                            fontWeight: FontWeight.w300,
                            fontFamily: 'monospace',
                            letterSpacing: -1.0,
                          ),
                        ),
                        Text(
                          '°',
                          style: TextStyle(
                            color: theme.northRed,
                            fontSize: 42,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          directionLabel,
                          style: TextStyle(
                            color: theme.textSecondary,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),

                    // Target Bearing Lock HUD Chip (PRO)
                    if (proState.lockedBearing != null) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.goldPro.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: theme.goldPro.withOpacity(0.4)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.my_location_rounded, color: theme.goldPro, size: 14),
                            const SizedBox(width: 6),
                            Text(
                              'TARGET: ${proState.lockedBearing!.round().toString().padLeft(3, '0')}°  |  $driftLabel',
                              style: TextStyle(
                                color: theme.goldPro,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(Icons.cancel_rounded, color: theme.goldPro, size: 14),
                          ],
                        ),
                      ),
                    ],

                    // Qibla Navigation Ribbon (When Qibla Mode is active)
                    if (state.isQiblaMode) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(
                          color: state.isQiblaAligned
                              ? const Color(0xFF00E676).withOpacity(0.2)
                              : const Color(0xFF00E676).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: state.isQiblaAligned
                                ? const Color(0xFF00E676)
                                : const Color(0xFF00E676).withOpacity(0.4),
                            width: state.isQiblaAligned ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              state.isQiblaAligned ? Icons.check_circle_rounded : Icons.explore_rounded,
                              color: const Color(0xFF00E676),
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              state.qiblaBearing != null
                                  ? 'KAABA: ${state.qiblaBearing!.round().toString().padLeft(3, '0')}°  |  ${state.formattedQiblaDistance}  ${state.isQiblaAligned ? "• ALIGNED 🕋" : ""}'
                                  : 'ACQUIRING GPS FIX FOR QIBLA...',
                              style: const TextStyle(
                                color: Color(0xFF00E676),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Waypoint Backtrack Navigation Ribbon
                    if (activeWp != null) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00E5FF).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF00E5FF).withOpacity(0.6),
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.pin_drop_rounded,
                              color: Color(0xFF00E5FF),
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              hasGps && waypointBearing != null
                                  ? '${activeWp.title.toUpperCase()}: $waypointDistance  |  ${waypointBearing.round().toString().padLeft(3, '0')}°'
                                  : '${activeWp.title.toUpperCase()}: ACQUIRING GPS...',
                              style: const TextStyle(
                                color: Color(0xFF00E5FF),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => wpNotifier.setActive(null),
                              child: const Icon(
                                Icons.cancel_rounded,
                                color: Color(0xFF00E5FF),
                                size: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Mode Selector Controls (Magnetic / True North + Qibla Mode Toggle)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Heading Mode Toggle (Magnetic vs True North)
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
                      color: theme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isTrueNorth ? theme.accentCyan : theme.dialRing,
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isTrueNorth ? Icons.navigation : Icons.explore,
                          size: 14,
                          color: isTrueNorth ? theme.accentCyan : theme.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isTrueNorth ? 'True North' : 'Magnetic North',
                          style: TextStyle(
                            color: isTrueNorth ? theme.accentCyan : theme.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                // Qibla Mode Toggle Pill
                GestureDetector(
                  onTap: () async {
                    final active = await controller.toggleQiblaMode();
                    if (active && state.latitude == null && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('GPS required to compute geodesic direction to Mecca.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: state.isQiblaMode
                          ? const Color(0xFF00E676).withOpacity(0.18)
                          : theme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: state.isQiblaMode
                            ? const Color(0xFF00E676)
                            : theme.dialRing,
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🕋', style: TextStyle(fontSize: 12)),
                        const SizedBox(width: 6),
                        Text(
                          'Qibla Mode',
                          style: TextStyle(
                            color: state.isQiblaMode
                                ? const Color(0xFF00E676)
                                : theme.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                // Waypoint Navigation / Mark Spot Pill
                GestureDetector(
                  onTap: () {
                    controller.requestGpsPermissionAndFix();
                    WaypointModal.show(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: wpState.hasActiveWaypoint
                          ? const Color(0xFF00E5FF).withOpacity(0.18)
                          : theme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: wpState.hasActiveWaypoint
                            ? const Color(0xFF00E5FF)
                            : theme.dialRing,
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.pin_drop_rounded,
                          size: 13,
                          color: wpState.hasActiveWaypoint
                              ? const Color(0xFF00E5FF)
                              : theme.textSecondary,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          wpState.hasActiveWaypoint ? 'Backtrack' : 'Mark Spot',
                          style: TextStyle(
                            color: wpState.hasActiveWaypoint
                                ? const Color(0xFF00E5FF)
                                : theme.textSecondary,
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
                            painter: CompassDialPainter(
                              heading: animatedHeading,
                              lockedBearing: proState.lockedBearing,
                              qiblaBearing: state.qiblaBearing,
                              isQiblaMode: state.isQiblaMode,
                              sunAzimuth: state.sunAzimuth,
                              moonAzimuth: state.moonAzimuth,
                              waypointBearing: waypointBearing,
                              waypointTitle: activeWp?.title,
                              theme: theme,
                            ),
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
                          color: state.isQiblaMode && state.isQiblaAligned
                              ? const Color(0xFF00E676)
                              : theme.northRed,
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: [
                            BoxShadow(
                              color: (state.isQiblaMode && state.isQiblaAligned
                                      ? const Color(0xFF00E676)
                                      : theme.northRed)
                                  .withOpacity(0.8),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Center 2D Artificial Horizon / Bubble Level
                    RepaintBoundary(
                      child: CustomPaint(
                        size: const Size(120, 120),
                        painter: BubbleLevelPainter(
                          pitch: state.pitch,
                          roll: state.roll,
                          isLevel: state.isLevel,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(flex: 1),

            // Live GPS Coordinates & Altitude HUD Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.dialRing.withOpacity(0.6)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.location_on_rounded, color: theme.accentCyan, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          state.formattedCoordinates,
                          style: TextStyle(
                            color: theme.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'monospace',
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        if (state.sunriseTime != null && state.sunsetTime != null) ...[
                          Text(
                            '☀️ ${state.formattedSunrise}',
                            style: const TextStyle(
                              color: Color(0xFFFFD54F),
                              fontSize: 10,
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '🌙 ${state.formattedSunset}',
                            style: const TextStyle(
                              color: Color(0xFF90CAF9),
                              fontSize: 10,
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Icon(Icons.terrain_rounded, color: theme.accentGreen, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          state.formattedAltitude,
                          style: TextStyle(
                            color: theme.textPrimary,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Telemetry Bar: PITCH | ROLL | EMF (μT) | LEVEL STATUS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => TelemetryGuideModal.show(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: theme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: state.isHighInterference ? theme.northRed : theme.dialRing,
                      width: state.isHighInterference ? 1.5 : 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildTelemetryItem(
                        theme: theme,
                        label: 'PITCH',
                        value: '${state.pitch >= 0 ? '+' : ''}${state.pitch.toStringAsFixed(1)}°',
                        isLevel: state.isLevel,
                      ),
                      Container(width: 1, height: 28, color: theme.dialRing),
                      _buildTelemetryItem(
                        theme: theme,
                        label: 'ROLL',
                        value: '${state.roll >= 0 ? '+' : ''}${state.roll.toStringAsFixed(1)}°',
                        isLevel: state.isLevel,
                      ),
                      Container(width: 1, height: 28, color: theme.dialRing),
                      _buildTelemetryItem(
                        theme: theme,
                        label: 'EMF (μT)',
                        value: state.formattedMagneticField,
                        isLevel: state.isLevel,
                        customValColor: state.isHighInterference
                            ? theme.northRed
                            : (state.magneticFieldStrength != null && state.magneticFieldStrength! > 70.0
                                ? theme.accentAmber
                                : theme.textPrimary),
                      ),
                      Container(width: 1, height: 28, color: theme.dialRing),
                      _buildTelemetryItem(
                        theme: theme,
                        label: 'STATUS',
                        value: state.isLevel ? 'LEVEL' : 'TILTED',
                        isLevel: state.isLevel,
                        isStatus: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Navigation Ad Banner (Free Tier only, vanishes in Pro!)
            const NavigationAdBanner(),

            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  Widget _buildTelemetryItem({
    required CompassTheme theme,
    required String label,
    required String value,
    required bool isLevel,
    bool isStatus = false,
    Color? customValColor,
  }) {
    Color valColor = customValColor ?? theme.textPrimary;
    if (isStatus) {
      valColor = isLevel ? theme.bubbleLevel : theme.dialTick;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            color: theme.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            color: valColor,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}
