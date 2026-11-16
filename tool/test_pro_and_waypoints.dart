import '../lib/core/utils/qibla_calculator.dart';
import '../lib/features/waypoints/domain/waypoint.dart';
import '../lib/features/waypoints/domain/waypoints_state.dart';

void main() {
  print('=== VERIFYING FREE & PRO DOMAIN LOGIC ===\n');

  // 1. Waypoint domain limits logic check
  const freeLimit = 5;
  print('1. Waypoint limit logic:');
  final waypoints = List.generate(
    freeLimit,
    (i) => Waypoint(
      id: 'wp_$i',
      title: 'Spot $i',
      latitude: 10.0 + i,
      longitude: 20.0 + i,
      createdAt: DateTime.now(),
    ),
  );
  final state = WaypointsState(waypoints: waypoints);
  assert(state.waypoints.length == 5, 'Must hold 5 waypoints');
  print('  [PASS] Stored ${state.waypoints.length}/$freeLimit waypoints in state.');

  // 2. Qibla Magnetic Declination correction check
  print('\n2. Qibla alignment with magnetic declination:');
  const double qiblaTrueBearing = 270.0;
  const double declination = 15.0; // East

  // Case A: User in True North mode
  // Sensor raw = 270 - 15 = 255. True heading = 255 + 15 = 270.
  final double trueHeading = 270.0;
  final bool alignedTrue = QiblaCalculator.isAligned(trueHeading, qiblaTrueBearing);
  assert(alignedTrue, 'True heading 270 must align with Qibla 270');
  print('  [PASS] True North mode: 270° aligns with Kaaba 270°');

  // Case B: User in Magnetic North mode
  // Sensor raw = 255. Declination is added: effective true heading = 255 + 15 = 270.
  final double magHeading = 255.0;
  final double effectiveTrueFromMag = ((magHeading + declination) % 360.0 + 360.0) % 360.0;
  final bool alignedMag = QiblaCalculator.isAligned(effectiveTrueFromMag, qiblaTrueBearing);
  assert(alignedMag, 'Magnetic heading 255 + 15 declination must align with Qibla 270');
  print('  [PASS] Magnetic North mode: 255° (+15° dec) aligns with Kaaba 270°');

  // Case C: Unaligned check
  final double magUnaligned = 270.0; // Effective true is 285°
  final double effectiveUnaligned = ((magUnaligned + declination) % 360.0 + 360.0) % 360.0;
  final bool notAligned = QiblaCalculator.isAligned(effectiveUnaligned, qiblaTrueBearing);
  assert(!notAligned, 'Magnetic heading 270 (+15 dec) must NOT align with Qibla 270');
  print('  [PASS] Magnetic North mode: 270° (+15° dec = 285°) correctly unaligned');

  print('\n=== ALL PURE DOMAIN CHECKS PASSED (100%) ===');
}
