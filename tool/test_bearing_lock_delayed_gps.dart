enum TestHeadingType { magnetic, trueNorth }

void main() {
  print('=== STARTING BEARING LOCK & DELAYED GPS VERIFICATION ===\n');

  // Simulator for ProController bearing reference frame logic
  double? lockedBearing;
  double? lockedMagneticBearing;

  void lockBearing(double currentHeading, {TestHeadingType headingType = TestHeadingType.magnetic, double? declination}) {
    double mag = currentHeading;
    if (headingType == TestHeadingType.trueNorth && declination != null) {
      mag = (currentHeading - declination) % 360.0;
      if (mag < 0) mag += 360.0;
    }
    lockedMagneticBearing = mag;
    lockedBearing = currentHeading;
  }

  void updateReferenceFrame({required TestHeadingType headingType, double? declination}) {
    if (lockedMagneticBearing == null) return;
    if (headingType == TestHeadingType.trueNorth && declination != null) {
      double effective = (lockedMagneticBearing! + declination) % 360.0;
      if (effective < 0) effective += 360.0;
      lockedBearing = effective;
    } else {
      lockedBearing = lockedMagneticBearing;
    }
  }

  // 1. Magnetic to True with declination available
  print('1. Testing Magnetic to True with declination available (+10°)...');
  lockBearing(45.0, headingType: TestHeadingType.magnetic);
  assert(lockedBearing == 45.0);
  assert(lockedMagneticBearing == 45.0);

  updateReferenceFrame(headingType: TestHeadingType.trueNorth, declination: 10.0);
  print('  Locked bearing in True North: $lockedBearing° (Expected: 55.0°)');
  assert(lockedBearing == 55.0, 'Magnetic to True should shift by +10°');
  assert(lockedMagneticBearing == 45.0, 'Underlying magnetic bearing must remain 45°');
  print('  [PASS] Scenario 1 verified!\n');

  // 2. True to Magnetic with declination available
  print('2. Testing True to Magnetic with declination available (+10°)...');
  lockBearing(55.0, headingType: TestHeadingType.trueNorth, declination: 10.0);
  assert(lockedBearing == 55.0);
  assert(lockedMagneticBearing == 45.0);

  updateReferenceFrame(headingType: TestHeadingType.magnetic, declination: 10.0);
  print('  Locked bearing in Magnetic North: $lockedBearing° (Expected: 45.0°)');
  assert(lockedBearing == 45.0, 'True to Magnetic should shift back to 45°');
  print('  [PASS] Scenario 2 verified!\n');

  // 3. Magnetic to True while declination is null (GPS fix pending)
  print('3. Testing Magnetic to True while declination is null...');
  lockBearing(120.0, headingType: TestHeadingType.magnetic);
  updateReferenceFrame(headingType: TestHeadingType.trueNorth, declination: null);
  print('  Locked bearing with pending GPS: $lockedBearing° (Expected: 120.0°)');
  assert(lockedBearing == 120.0, 'Pending GPS must preserve base bearing without corruption');
  assert(lockedMagneticBearing == 120.0);
  print('  [PASS] Scenario 3 verified!\n');

  // 4. GPS declination arriving after the mode switch
  print('4. Testing GPS declination arriving after mode switch (-12.5° W)...');
  // Declination arrives from WMM (-12.5°)
  updateReferenceFrame(headingType: TestHeadingType.trueNorth, declination: -12.5);
  print('  Locked bearing after delayed GPS: $lockedBearing° (Expected: 107.5°)');
  assert(lockedBearing == 107.5, 'Delayed GPS should correctly update locked bearing to 107.5°');
  assert(lockedMagneticBearing == 120.0, 'Magnetic bearing must remain 120.0°');
  print('  [PASS] Scenario 4 verified!\n');

  // 5. Bearing Lock already active when declination arrives across north wrap-around
  print('5. Testing Bearing Lock across North boundary wrap-around (355° + 10°)...');
  lockBearing(355.0, headingType: TestHeadingType.magnetic);
  updateReferenceFrame(headingType: TestHeadingType.trueNorth, declination: 10.0);
  print('  Locked bearing after wrap-around: $lockedBearing° (Expected: 5.0°)');
  assert((lockedBearing! - 5.0).abs() < 0.001, 'Wrap-around should produce 5.0°');
  print('  [PASS] Scenario 5 verified!\n');

  // 6. Repeated GPS updates without repeated bearing adjustments
  print('6. Testing repeated GPS stream updates (100 ticks)...');
  lockBearing(200.0, headingType: TestHeadingType.magnetic);
  updateReferenceFrame(headingType: TestHeadingType.trueNorth, declination: null);
  // GPS update 1
  updateReferenceFrame(headingType: TestHeadingType.trueNorth, declination: 5.0);
  assert(lockedBearing == 205.0);
  // GPS update 2, 3, ... 100
  for (int i = 0; i < 100; i++) {
    updateReferenceFrame(headingType: TestHeadingType.trueNorth, declination: 5.0);
  }
  print('  Locked bearing after 100 repeated GPS updates: $lockedBearing° (Expected: 205.0°)');
  assert(lockedBearing == 205.0, 'Repeated updates must NEVER accumulate bearing offsets');
  assert(lockedMagneticBearing == 200.0);
  print('  [PASS] Scenario 6 verified!\n');

  print('=== ALL 6 BEARING LOCK EDGE-CASE SCENARIOS PASSED (100%) ===');
}
