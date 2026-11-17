import 'package:flutter_test/flutter_test.dart';
import 'package:compass_app/features/pro/controllers/pro_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Bearing Lock Drift Calculations', () {
    double calculateDrift(double heading, double lockedBearing) {
      double diff = (heading - lockedBearing) % 360.0;
      if (diff > 180.0) diff -= 360.0;
      if (diff < -180.0) diff += 360.0;
      return diff;
    }

    String getDriftGuidance(double diff) {
      if (diff.abs() <= 3.0) {
        return 'ON_COURSE';
      } else if (diff > 3.0) {
        return 'STEER_LEFT';
      } else {
        return 'STEER_RIGHT';
      }
    }

    test('Locked 0° (North), Current 15° (facing right of target) -> diff +15° (Steer Left)', () {
      final diff = calculateDrift(15.0, 0.0);
      expect(diff, 15.0);
      expect(getDriftGuidance(diff), 'STEER_LEFT');
    });

    test('Locked 0° (North), Current 345° (facing left of target) -> diff -15° (Steer Right)', () {
      final diff = calculateDrift(345.0, 0.0);
      expect(diff, -15.0);
      expect(getDriftGuidance(diff), 'STEER_RIGHT');
    });

    test('Locked 90° (East), Current 80° -> diff -10° (Steer Right)', () {
      final diff = calculateDrift(80.0, 90.0);
      expect(diff, -10.0);
      expect(getDriftGuidance(diff), 'STEER_RIGHT');
    });

    test('Locked 90° (East), Current 110° -> diff +20° (Steer Left)', () {
      final diff = calculateDrift(110.0, 90.0);
      expect(diff, 20.0);
      expect(getDriftGuidance(diff), 'STEER_LEFT');
    });

    test('Wraparound: Locked 350°, Current 10° -> diff +20° (Steer Left)', () {
      final diff = calculateDrift(10.0, 350.0);
      expect(diff, 20.0);
      expect(getDriftGuidance(diff), 'STEER_LEFT');
    });

    test('Wraparound: Locked 10°, Current 350° -> diff -20° (Steer Right)', () {
      final diff = calculateDrift(350.0, 10.0);
      expect(diff, -20.0);
      expect(getDriftGuidance(diff), 'STEER_RIGHT');
    });

    test(
      'Dead on target: Locked 180°, Current 180° -> diff 0° (On Course)',
      () {
        final diff = calculateDrift(180.0, 180.0);
        expect(diff, 0.0);
        expect(getDriftGuidance(diff), 'ON_COURSE');
      },
    );
  });

  group('Bearing Lock Haptic Transitions & Throttling', () {
    late ProController controller;

    setUp(() {
      controller = ProController();
    });

    test('Transitions, Throttling and Reset Behavior', () {
      // Free users do not trigger bearing lock haptics
      controller.evaluateDriftHaptics(15.0);
      expect(controller.state.lockedBearing, isNull);

      // Entitle as Pro and lock at 0°
      controller.setEntitled(true);
      controller.lockBearing(0.0);
      expect(controller.state.lockedBearing, 0.0);

      var t0 = DateTime(2026, 11, 16, 12, 0, 0);

      // 1. Drift to 14° (Step 1): fires haptic at t0
      controller.evaluateDriftHaptics(14.0, now: t0);

      // 2. Immediate jitter to 15° 50ms later: suppressed by 400ms throttler
      final tRapid = t0.add(const Duration(milliseconds: 50));
      controller.evaluateDriftHaptics(15.0, now: tRapid);

      // 3. Drift to 25° (Step 2) after 500ms: fires step 2 haptic
      final tStep2 = t0.add(const Duration(milliseconds: 500));
      controller.evaluateDriftHaptics(25.0, now: tStep2);

      // 4. Correct back towards course to 15° (Step 1) after 500ms: fires corrective tick
      final tStep1 = tStep2.add(const Duration(milliseconds: 500));
      controller.evaluateDriftHaptics(15.0, now: tStep1);

      // 5. Return on-course to 4° (Step 0) after 500ms: fires confirmation tick and resets step to 0
      final tOnCourse = tStep1.add(const Duration(milliseconds: 500));
      controller.evaluateDriftHaptics(4.0, now: tOnCourse);

      // 6. Drift out AGAIN to 14° (Step 1) after 500ms: must properly fire because step was reset to 0!
      final tDriftAgain = tOnCourse.add(const Duration(milliseconds: 500));
      controller.evaluateDriftHaptics(14.0, now: tDriftAgain);

      // 7. Clear locked bearing: resets all state
      controller.clearLockedBearing();
      expect(controller.state.lockedBearing, isNull);
    });
  });
}
