import 'package:flutter_test/flutter_test.dart';
import 'package:compass_app/core/utils/haptic_throttler.dart';

void main() {
  group('HapticThrottler Tests', () {
    test('Triggers heavy haptic when reaching North sector (0°)', () async {
      int heavyCalls = 0;
      int mediumCalls = 0;
      int lightCalls = 0;

      final throttler = HapticThrottler(
        minInterval: const Duration(milliseconds: 50),
        maxAngularVelocity: 120.0,
        onHeavy: () async => heavyCalls++,
        onMedium: () async => mediumCalls++,
        onLight: () async => lightCalls++,
      );

      final triggered = await throttler.evaluateHeading(
        headingDegrees: 0.5,
        angularVelocityDegPerSec: 10.0,
        currentTime: DateTime(2026, 1, 1, 12, 0, 0, 0),
      );

      expect(triggered, isTrue);
      expect(heavyCalls, 1);
      expect(mediumCalls, 0);
      expect(lightCalls, 0);
    });

    test('Triggers medium haptic on Cardinal headings (90°, 180°, 270°)', () async {
      int heavyCalls = 0;
      int mediumCalls = 0;
      int lightCalls = 0;

      final throttler = HapticThrottler(
        minInterval: const Duration(milliseconds: 50),
        maxAngularVelocity: 120.0,
        onHeavy: () async => heavyCalls++,
        onMedium: () async => mediumCalls++,
        onLight: () async => lightCalls++,
      );

      // 90° (East)
      await throttler.evaluateHeading(
        headingDegrees: 90.0,
        angularVelocityDegPerSec: 15.0,
        currentTime: DateTime(2026, 1, 1, 12, 0, 0, 0),
      );

      expect(mediumCalls, 1);
      expect(heavyCalls, 0);

      // 180° (South) after cooldown
      await throttler.evaluateHeading(
        headingDegrees: 180.0,
        angularVelocityDegPerSec: 15.0,
        currentTime: DateTime(2026, 1, 1, 12, 0, 0, 100),
      );

      expect(mediumCalls, 2);
    });

    test('Suppresses haptics when angular velocity exceeds threshold (spinning fast)', () async {
      int heavyCalls = 0;
      final throttler = HapticThrottler(
        maxAngularVelocity: 100.0,
        onHeavy: () async => heavyCalls++,
      );

      final triggered = await throttler.evaluateHeading(
        headingDegrees: 0.0,
        angularVelocityDegPerSec: 150.0, // Exceeds 100 deg/sec
        currentTime: DateTime(2026, 1, 1, 12, 0, 0, 0),
      );

      expect(triggered, isFalse);
      expect(heavyCalls, 0);
    });

    test('Suppresses haptics within minimum cooldown deadband', () async {
      int lightCalls = 0;
      final throttler = HapticThrottler(
        minInterval: const Duration(milliseconds: 100),
        onLight: () async => lightCalls++,
      );

      final time1 = DateTime(2026, 1, 1, 12, 0, 0, 0);
      final triggered1 = await throttler.evaluateHeading(
        headingDegrees: 15.0,
        angularVelocityDegPerSec: 10.0,
        currentTime: time1,
      );
      expect(triggered1, isTrue);
      expect(lightCalls, 1);

      // Immediate subsequent heading event within 30ms (< 100ms interval)
      final time2 = time1.add(const Duration(milliseconds: 30));
      final triggered2 = await throttler.evaluateHeading(
        headingDegrees: 30.0,
        angularVelocityDegPerSec: 10.0,
        currentTime: time2,
      );
      expect(triggered2, isFalse);
      expect(lightCalls, 1); // Not incremented
    });
  });
}
