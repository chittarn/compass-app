import 'package:flutter_test/flutter_test.dart';
import 'package:compass_app/features/compass/domain/heading_type.dart';
import 'package:compass_app/features/pro/controllers/pro_controller.dart';
import 'package:compass_app/features/pro/domain/pro_state.dart';

void main() {
  group('Bearing Lock & Delayed GPS Reference Frame Edge Cases', () {
    late ProController controller;

    setUp(() {
      controller = ProController();
      // Enable Pro tier for bearing lock
      controller.setEntitled(true);
    });

    test('Scenario 1: Magnetic to True with declination available', () {
      // User locks bearing in Magnetic mode at 45.0°
      const headingMag = 45.0;
      const declination = 10.0; // East (+10°)
      controller.lockBearing(headingMag, headingType: HeadingType.magnetic);

      expect(controller.state.lockedBearing, 45.0);
      expect(controller.state.lockedMagneticBearing, 45.0);

      // User switches to True North mode where declination is +10.0°
      controller.updateReferenceFrame(
        headingType: HeadingType.trueNorth,
        declination: declination,
      );

      // In True North, displayed locked bearing must be (45 + 10) = 55.0°
      expect(controller.state.lockedBearing, 55.0);
      // Invariant magnetic bearing remains 45.0°
      expect(controller.state.lockedMagneticBearing, 45.0);
    });

    test('Scenario 2: True to Magnetic with declination available', () {
      // User locks bearing in True North mode at 55.0° with declination +10.0°
      const headingTrue = 55.0;
      const declination = 10.0;
      controller.lockBearing(
        headingTrue,
        headingType: HeadingType.trueNorth,
        declination: declination,
      );

      expect(controller.state.lockedBearing, 55.0);
      // Underlying magnetic heading is (55 - 10) = 45.0°
      expect(controller.state.lockedMagneticBearing, 45.0);

      // User switches to Magnetic North
      controller.updateReferenceFrame(
        headingType: HeadingType.magnetic,
        declination: declination,
      );

      // In Magnetic North, displayed locked bearing must be 45.0°
      expect(controller.state.lockedBearing, 45.0);
    });

    test('Scenario 3: Magnetic to True while declination is null (GPS fix pending)', () {
      // 1. User locks bearing in Magnetic North mode at 120.0°
      controller.lockBearing(120.0, headingType: HeadingType.magnetic);
      expect(controller.state.lockedBearing, 120.0);
      expect(controller.state.lockedMagneticBearing, 120.0);

      // 2. User switches to True North before GPS acquires fix (declination is null)
      controller.updateReferenceFrame(
        headingType: HeadingType.trueNorth,
        declination: null,
      );

      // Locked bearing must not be corrupted or offset; remains at invariant base
      expect(controller.state.lockedBearing, 120.0);
      expect(controller.state.lockedMagneticBearing, 120.0);
    });

    test('Scenario 4: GPS declination arriving after mode switch', () {
      // 1. User locks in Magnetic at 90.0°
      controller.lockBearing(90.0, headingType: HeadingType.magnetic);

      // 2. Switches to True North before GPS fix
      controller.updateReferenceFrame(
        headingType: HeadingType.trueNorth,
        declination: null,
      );
      expect(controller.state.lockedBearing, 90.0);

      // 3. GPS fix arrives later; WMM calculates declination = -12.5° (West)
      const wmmDeclination = -12.5;
      controller.updateReferenceFrame(
        headingType: HeadingType.trueNorth,
        declination: wmmDeclination,
      );

      // In True North, locked bearing must adjust to (90.0 + (-12.5)) = 77.5°
      expect(controller.state.lockedBearing, 77.5);
      expect(controller.state.lockedMagneticBearing, 90.0);
    });

    test('Scenario 5: Bearing Lock already active when declination arrives', () {
      // User locked bearing in Magnetic North, then GPS arrives
      controller.lockBearing(350.0, headingType: HeadingType.magnetic);

      // Declination arrives while still in True North
      controller.updateReferenceFrame(
        headingType: HeadingType.trueNorth,
        declination: 15.0, // East (+15°)
      );

      // (350.0 + 15.0) % 360.0 = 5.0°
      expect(controller.state.lockedBearing, closeTo(5.0, 0.001));
      expect(controller.state.lockedMagneticBearing, 350.0);
    });

    test('Scenario 6: Repeated GPS updates without repeated bearing adjustments', () {
      // User locks bearing in Magnetic at 200.0°
      controller.lockBearing(200.0, headingType: HeadingType.magnetic);

      // Switched to True North
      controller.updateReferenceFrame(
        headingType: HeadingType.trueNorth,
        declination: null,
      );

      // GPS update 1 arrives: declination = +5.0°
      controller.updateReferenceFrame(
        headingType: HeadingType.trueNorth,
        declination: 5.0,
      );
      expect(controller.state.lockedBearing, 205.0);

      // GPS update 2 arrives (1 second later with same declination)
      controller.updateReferenceFrame(
        headingType: HeadingType.trueNorth,
        declination: 5.0,
      );
      // MUST NOT be 210.0°! Must remain exactly 205.0°!
      expect(controller.state.lockedBearing, 205.0);

      // GPS update 3 arrives (slight micro-drift in declination to +5.02°)
      controller.updateReferenceFrame(
        headingType: HeadingType.trueNorth,
        declination: 5.02,
      );
      expect(controller.state.lockedBearing, closeTo(205.02, 0.001));

      // Multiple stream updates simulated (100 times)
      for (int i = 0; i < 100; i++) {
        controller.updateReferenceFrame(
          headingType: HeadingType.trueNorth,
          declination: 5.02,
        );
      }
      expect(controller.state.lockedBearing, closeTo(205.02, 0.001));
      expect(controller.state.lockedMagneticBearing, 200.0);
    });
  });
}
