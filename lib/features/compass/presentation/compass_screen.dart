import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'controllers/compass_controller.dart';
import '../domain/heading_type.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'widgets/gps_onboarding_modal.dart';
import 'widgets/compass_dial_painter.dart';
import 'widgets/bubble_level_painter.dart';
import 'widgets/accuracy_badge.dart';
import 'widgets/calibration_modal.dart';
import 'widgets/telemetry_guide_modal.dart';
import 'widgets/vastu_guide_modal.dart';
import '../../../core/utils/vastu_calculator.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _checkFirstLaunchGps();
      }
    });
  }

  Future<void> _checkFirstLaunchGps() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasPrompted = prefs.getBool('has_prompted_gps_onboarding') ?? false;
      if (hasPrompted) return;

      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        await GpsOnboardingModal.show(context, ref);
        await prefs.setBool('has_prompted_gps_onboarding', true);
      }
    } catch (_) {}
  }

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
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'COMPASS',
                        style: TextStyle(
                          color: theme.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.8,
                        ),
                      ),
                      const SizedBox(width: 2),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: Icon(
                          Icons.info_outline_rounded,
                          color: theme.accentCyan,
                          size: 18,
                        ),
                        tooltip: 'Field Guide & Telemetry Glossary',
                        onPressed: () => TelemetryGuideModal.show(context),
                      ),
                    ],
                  ),
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Red OLED Night Vision Toggle (Pro only)
                        if (proState.isPro) ...[
                          IconButton(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            constraints: const BoxConstraints(),
                            icon: Icon(
                              proState.isNightVision ? Icons.lightbulb_rounded : Icons.nightlight_round,
                              color: proState.isNightVision ? theme.northRed : theme.textSecondary,
                              size: 18,
                            ),
                            tooltip: 'Red OLED Night Vision',
                            onPressed: () => proNotifier.toggleNightVision(),
                          ),
                          const SizedBox(width: 4),
                        ],

                        // PRO / UPGRADE Badge
                        InkWell(
                          onTap: () => ProUpgradeModal.show(context),
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                              borderRadius: BorderRadius.circular(14),
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
                                  size: 13,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  proState.isPro ? 'PRO' : 'GET PRO',
                                  style: TextStyle(
                                    color: proState.isPro ? theme.accentCyan : theme.goldPro,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.6,
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
                  ),
                ],
              ),
            ),

            const Spacer(flex: 1),

            // Heading & Cardinal Readout (Clean Readout - No accidental clicks)
            Padding(
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
                          fontSize: 60,
                          fontWeight: FontWeight.w300,
                          fontFamily: 'monospace',
                          letterSpacing: -1.0,
                        ),
                      ),
                      Text(
                        '°',
                        style: TextStyle(
                          color: theme.northRed,
                          fontSize: 38,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        directionLabel,
                        style: TextStyle(
                          color: theme.textSecondary,
                          fontSize: 26,
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
                        constraints: const BoxConstraints(maxWidth: 340),
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
                            Flexible(
                              child: Text(
                                state.qiblaBearing != null
                                    ? 'KAABA: ${state.qiblaBearing!.round().toString().padLeft(3, '0')}° | ${state.formattedQiblaDistance} ${state.isQiblaAligned ? "• ALIGNED 🕋" : ""}'
                                    : 'ACQUIRING GPS FIX...',
                                style: const TextStyle(
                                  color: Color(0xFF00E676),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace',
                                ),
                                overflow: TextOverflow.ellipsis,
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
                        constraints: const BoxConstraints(maxWidth: 340),
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
                            Flexible(
                              child: Text(
                                hasGps && waypointBearing != null
                                    ? '${activeWp.title.toUpperCase()}: $waypointDistance | ${waypointBearing.round().toString().padLeft(3, '0')}°'
                                    : '${activeWp.title.toUpperCase()}: ACQUIRING GPS...',
                                style: const TextStyle(
                                  color: Color(0xFF00E5FF),
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace',
                                ),
                                overflow: TextOverflow.ellipsis,
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

                    // Vastu Shastra Architectural Ribbon
                    if (state.isVastuMode) ...[
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: () => VastuGuideModal.show(context),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          constraints: const BoxConstraints(maxWidth: 350),
                          decoration: BoxDecoration(
                            color: Color(state.currentVastuZone.colorValue).withOpacity(0.14),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Color(state.currentVastuZone.colorValue).withOpacity(0.55),
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(state.currentVastuZone.emoji, style: const TextStyle(fontSize: 13)),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  'AIM: ${state.currentVastuZone.direction} (${state.heading.round().toString().padLeft(3, '0')}°) ➔ ${state.currentVastuZone.plainLabel}',
                                  style: TextStyle(
                                    color: Color(state.currentVastuZone.colorValue),
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'monospace',
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(
                                Icons.info_outline_rounded,
                                color: Color(state.currentVastuZone.colorValue),
                                size: 13,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (state.activeVastuRoom != null) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          constraints: const BoxConstraints(maxWidth: 350),
                          decoration: BoxDecoration(
                            color: state.isVastuRoomAligned
                                ? const Color(0xFFFFD700).withOpacity(0.25)
                                : const Color(0xFFFFD700).withOpacity(0.10),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: state.isVastuRoomAligned
                                  ? const Color(0xFFFFD700)
                                  : const Color(0xFFFFD700).withOpacity(0.4),
                              width: state.isVastuRoomAligned ? 1.5 : 1.0,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                state.isVastuRoomAligned ? Icons.check_circle_rounded : Icons.explore_rounded,
                                color: const Color(0xFFFFD700),
                                size: 13,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  'AIM: ${VastuCalculator.getGuideline(state.activeVastuRoom!).emoji} ${VastuCalculator.getGuideline(state.activeVastuRoom!).title.toUpperCase()} (${VastuCalculator.getGuideline(state.activeVastuRoom!).targetHeading.round()}°) ${state.isVastuRoomAligned ? "• ALIGNED 🕉️" : ""}',
                                  style: const TextStyle(
                                    color: Color(0xFFFFD700),
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'monospace',
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: () => controller.setActiveVastuRoom(null),
                                child: const Icon(
                                  Icons.cancel_rounded,
                                  color: Color(0xFFFFD700),
                                  size: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),

            const SizedBox(height: 8),

            // Mode Selector Controls (Magnetic / True North, Qibla, Waypoint)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
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
                      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
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
                            size: 13,
                            color: isTrueNorth ? theme.accentCyan : theme.textSecondary,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            isTrueNorth ? 'True North' : 'Magnetic North',
                            style: TextStyle(
                              color: isTrueNorth ? theme.accentCyan : theme.textSecondary,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

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
                      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
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
                          const Text('🕋', style: TextStyle(fontSize: 11)),
                          const SizedBox(width: 5),
                          Text(
                            'Qibla Mode',
                            style: TextStyle(
                              color: state.isQiblaMode
                                  ? const Color(0xFF00E676)
                                  : theme.textSecondary,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Waypoint Navigation / Mark Spot Pill
                  GestureDetector(
                    onTap: () {
                      controller.requestGpsPermissionAndFix();
                      WaypointModal.show(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
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
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Vastu Shastra Mode Toggle Pill
                  GestureDetector(
                    onTap: () {
                      controller.toggleVastuMode();
                      if (!state.isVastuMode) {
                        VastuGuideModal.show(context);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
                      decoration: BoxDecoration(
                        color: state.isVastuMode
                            ? const Color(0xFFFFD700).withOpacity(0.18)
                            : theme.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: state.isVastuMode
                              ? const Color(0xFFFFD700)
                              : theme.dialRing,
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🕉️', style: TextStyle(fontSize: 11)),
                          const SizedBox(width: 5),
                          Text(
                            'Vastu',
                            style: TextStyle(
                              color: state.isVastuMode
                                  ? const Color(0xFFFFD700)
                                  : theme.textSecondary,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
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
                              isVastuMode: state.isVastuMode,
                              vastuTargetBearing: state.activeVastuRoom != null
                                  ? VastuCalculator.getGuideline(state.activeVastuRoom!).targetHeading
                                  : null,
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
                              : (state.isVastuMode && state.isVastuRoomAligned
                                  ? const Color(0xFFFFD700)
                                  : theme.northRed),
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: [
                            BoxShadow(
                              color: ((state.isQiblaMode && state.isQiblaAligned)
                                      ? const Color(0xFF00E676)
                                      : (state.isVastuMode && state.isVastuRoomAligned
                                          ? const Color(0xFFFFD700)
                                          : theme.northRed))
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.dialRing.withOpacity(0.6)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Row 1: Coordinates & Elevation
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.location_on_rounded, color: theme.accentCyan, size: 13),
                              const SizedBox(width: 5),
                              Flexible(
                                child: Text(
                                  state.formattedCoordinates,
                                  style: TextStyle(
                                    color: theme.textSecondary,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'monospace',
                                    letterSpacing: 0.3,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.terrain_rounded, color: theme.accentGreen, size: 13),
                            const SizedBox(width: 4),
                            Text(
                              state.formattedAltitude,
                              style: TextStyle(
                                color: theme.textPrimary,
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Row 2: Live Celestial Ephemeris (Sunrise, Sun Heading, Sunset)
                    if (state.sunriseTime != null && state.sunsetTime != null) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.only(top: 5),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: theme.dialRing.withOpacity(0.4), width: 0.8),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('☀️', style: TextStyle(fontSize: 10)),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        'DAWN ${state.formattedSunrise}',
                                        style: const TextStyle(
                                          color: Color(0xFFFFD54F),
                                          fontSize: 10,
                                          fontFamily: 'monospace',
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (state.sunAzimuth != null)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: Text(
                                  'SUN AZ ${state.sunAzimuth!.round()}°',
                                  style: TextStyle(
                                    color: theme.textSecondary.withOpacity(0.7),
                                    fontSize: 9.5,
                                    fontFamily: 'monospace',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            Flexible(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('🌙', style: TextStyle(fontSize: 10)),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        'DUSK ${state.formattedSunset}',
                                        style: const TextStyle(
                                          color: Color(0xFF90CAF9),
                                          fontSize: 10,
                                          fontFamily: 'monospace',
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
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

            // Bottom Telemetry Bar: PITCH | ROLL | EMF (μT) | LEVEL STATUS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => TelemetryGuideModal.show(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                    color: theme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: state.isHighInterference ? theme.northRed : theme.dialRing,
                      width: state.isHighInterference ? 1.5 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildTelemetryItem(
                          theme: theme,
                          label: 'PITCH',
                          value: '${state.pitch >= 0 ? '+' : ''}${state.pitch.toStringAsFixed(1)}°',
                          isLevel: state.isLevel,
                        ),
                      ),
                      Container(width: 1, height: 26, color: theme.dialRing),
                      Expanded(
                        child: _buildTelemetryItem(
                          theme: theme,
                          label: 'ROLL',
                          value: '${state.roll >= 0 ? '+' : ''}${state.roll.toStringAsFixed(1)}°',
                          isLevel: state.isLevel,
                        ),
                      ),
                      Container(width: 1, height: 26, color: theme.dialRing),
                      Expanded(
                        child: _buildTelemetryItem(
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
                      ),
                      Container(width: 1, height: 26, color: theme.dialRing),
                      Expanded(
                        child: _buildTelemetryItem(
                          theme: theme,
                          label: 'STATUS',
                          value: state.isLevel ? 'LEVEL' : 'TILTED',
                          isLevel: state.isLevel,
                          isStatus: true,
                        ),
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
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: TextStyle(
              color: theme.textSecondary,
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: TextStyle(
              color: valColor,
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ],
    );
  }
}
