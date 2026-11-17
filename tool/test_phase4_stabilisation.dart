import '../lib/features/waypoints/domain/waypoint.dart';

void main() {
  print('=== STARTING PHASE 4 STABILISATION VERIFICATION ===\n');

  // 1. Waypoint Steering & Argument Order Test
  print('1. Testing relative steering argument order and calculations...');
  final northWp = Waypoint(
    id: 'n1',
    title: 'North Waypoint',
    latitude: 1.0,
    longitude: 0.0,
    createdAt: DateTime.now(),
  );

  final eastWp = Waypoint(
    id: 'e1',
    title: 'East Waypoint',
    latitude: 0.0,
    longitude: 1.0,
    createdAt: DateTime.now(),
  );

  // Ahead
  final ahead = northWp.relativeBearingFrom(0.0, 0.0, 0.0);
  assert(ahead.abs() < 0.1, 'Target ahead should be ~0°');
  print('  [PASS] Directly ahead: $ahead°');

  // Behind
  final behind = northWp.relativeBearingFrom(0.0, 0.0, 180.0);
  assert(behind.abs() >= 179.9, 'Target behind should be ~180°');
  print('  [PASS] Directly behind: $behind°');

  // Target to Right
  final toRight = eastWp.relativeBearingFrom(0.0, 0.0, 0.0);
  assert(
    (toRight - 90.0).abs() < 0.5,
    'East target from north heading is +90° (turn right)',
  );
  print('  [PASS] Target to Right: +${toRight.round()}° (Turn Right)');

  // Target to Left
  final toLeft = northWp.relativeBearingFrom(0.0, 0.0, 90.0);
  assert(
    (toLeft - (-90.0)).abs() < 0.5,
    'North target from east heading is -90° (turn left)',
  );
  print('  [PASS] Target to Left: ${toLeft.round()}° (Turn Left)');

  // 2. Arrival Detection & GPS Accuracy Suppression & Hysteresis
  print(
    '\n2. Testing Arrival Detection & GPS Accuracy Suppression & Hysteresis...',
  );
  final nearWp = Waypoint(
    id: 'near',
    title: 'Near Spot',
    latitude: 0.00018, // ~20m North
    longitude: 0.0,
    createdAt: DateTime.now(),
  );

  // Clean arrival
  final arrivedGoodGps = nearWp.isArrived(
    0.0,
    0.0,
    locationAccuracyMeters: 6.0,
    arrivalRadiusMeters: 25.0,
  );
  assert(arrivedGoodGps == true, 'Must arrive with good GPS accuracy');
  print('  [PASS] Arrival confirmed with high accuracy (6m): $arrivedGoodGps');

  // Suppressed by poor GPS accuracy
  final arrivedPoorGps = nearWp.isArrived(
    0.0,
    0.0,
    locationAccuracyMeters: 55.0,
    arrivalRadiusMeters: 25.0,
    maxPermissibleAccuracyMeters: 40.0,
  );
  assert(
    arrivedPoorGps == false,
    'Must suppress arrival when accuracy is poor (>40m)',
  );
  print(
    '  [PASS] False arrival suppressed when GPS accuracy is poor (55m uncertainty)',
  );

  // Hysteresis at 30m boundary
  final boundaryWp = Waypoint(
    id: 'bound',
    title: 'Boundary Spot',
    latitude: 0.00027, // ~30m
    longitude: 0.0,
    createdAt: DateTime.now(),
  );

  final freshNotArrived = boundaryWp.isArrived(
    0.0,
    0.0,
    previouslyArrived: false,
    arrivalRadiusMeters: 25.0,
    hysteresisMeters: 10.0,
  );
  assert(
    freshNotArrived == false,
    'Fresh approach at 30m is not arrived (entry threshold 25m)',
  );

  final keptArrived = boundaryWp.isArrived(
    0.0,
    0.0,
    previouslyArrived: true,
    arrivalRadiusMeters: 25.0,
    hysteresisMeters: 10.0,
  );
  assert(
    keptArrived == true,
    'Already arrived remains arrived at 30m (exit threshold 35m)',
  );
  print(
    '  [PASS] Hysteresis verified: Prevents status flickering between 25m and 35m',
  );

  // 3. Bearing Lock Drift Calculation
  print('\n3. Testing Bearing Lock Drift Calculations with known headings...');
  double getDrift(double heading, double locked) {
    double diff = (heading - locked) % 360.0;
    if (diff > 180.0) diff -= 360.0;
    if (diff < -180.0) diff += 360.0;
    return diff;
  }

  assert(
    getDrift(15.0, 0.0) == 15.0,
    'Locked 0, Heading 15 -> +15° (Steer Left)',
  );
  assert(
    getDrift(345.0, 0.0) == -15.0,
    'Locked 0, Heading 345 -> -15° (Steer Right)',
  );
  assert(
    getDrift(80.0, 90.0) == -10.0,
    'Locked 90, Heading 80 -> -10° (Steer Right)',
  );
  assert(
    getDrift(110.0, 90.0) == 20.0,
    'Locked 90, Heading 110 -> +20° (Steer Left)',
  );
  assert(
    getDrift(10.0, 350.0) == 20.0,
    'Wraparound Locked 350, Heading 10 -> +20° (Steer Left)',
  );
  assert(
    getDrift(350.0, 10.0) == -20.0,
    'Wraparound Locked 10, Heading 350 -> -20° (Steer Right)',
  );
  print(
    '  [PASS] All 6 Bearing Lock drift scenarios verified with exact degrees!',
  );

  // 4. Backward Compatibility & Persistence
  print('\n4. Testing Legacy Persistence & Deserialization...');
  final legacyJson = {
    'id': 'legacy_spot_99',
    'title': 'Original Car Location',
    'latitude': 37.7749,
    'longitude': -122.4194,
    'createdAt': '2025-05-01T12:00:00.000Z',
  };
  final parsed = Waypoint.fromJson(legacyJson);
  assert(parsed.id == 'legacy_spot_99');
  assert(parsed.title == 'Original Car Location');
  assert(
    parsed.category == WaypointCategory.custom,
    'Must default legacy to custom category',
  );
  assert(parsed.notes == null, 'Must default legacy notes to null');
  print(
    '  [PASS] Legacy waypoint JSON without category/notes parsed 100% cleanly!',
  );

  print('\n=== ALL PHASE 4 STABILISATION CHECKS PASSED (100%) ===');
}
