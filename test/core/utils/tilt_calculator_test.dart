import 'package:flutter_test/flutter_test.dart';
import 'package:compass_app/core/utils/tilt_calculator.dart';

void main() {
  group('TiltCalculator Tests', () {
    test('Flat horizontal device on table (gravity along +Z) is Level', () {
      // Normal gravity resting flat: x=0, y=0, z=9.8
      final tilt = TiltCalculator.fromAccelerometer(0.0, 0.0, 9.8);
      expect(tilt.pitch, closeTo(0.0, 0.01));
      expect(tilt.roll, closeTo(0.0, 0.01));
      expect(tilt.isLevel, isTrue);
    });

    test('Device tilted nose up (Pitch +30°)', () {
      // Pitch up around X axis
      final tilt = TiltCalculator.fromAccelerometer(0.0, 4.9, 8.487);
      expect(tilt.pitch, closeTo(30.0, 0.5));
      expect(tilt.roll, closeTo(0.0, 0.01));
      expect(tilt.isLevel, isFalse);
    });

    test('Device tilted bank right (Roll +30°)', () {
      // Roll right around Y axis (-x positive)
      final tilt = TiltCalculator.fromAccelerometer(-4.9, 0.0, 8.487);
      expect(tilt.pitch, closeTo(0.0, 0.01));
      expect(tilt.roll, closeTo(30.0, 0.5));
      expect(tilt.isLevel, isFalse);
    });

    test('Device tilted within 1.0 degree tolerance remains isLevel == true', () {
      // Slight imperfect resting angle (0.8 degrees)
      final tilt = TiltCalculator.fromAccelerometer(0.1, 0.1, 9.8);
      expect(tilt.isLevel, isTrue);
    });
  });
}
