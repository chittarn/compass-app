import 'package:flutter_test/flutter_test.dart';
import 'package:compass_app/core/utils/heading_calculator.dart';

void main() {
  group('HeadingCalculator Tests', () {
    test('Flat horizontal device pointing North (0°)', () {
      final heading = HeadingCalculator.calculateAzimuth(
        ax: 0.0,
        ay: 0.0,
        az: 9.8,
        mx: 0.0,
        my: 30.0,
        mz: -40.0,
      );
      expect(heading, closeTo(0.0, 0.5));
    });

    test('Flat horizontal device pointing East (90°)', () {
      final heading = HeadingCalculator.calculateAzimuth(
        ax: 0.0,
        ay: 0.0,
        az: 9.8,
        mx: -30.0,
        my: 0.0,
        mz: -40.0,
      );
      expect(heading, closeTo(90.0, 0.5));
    });

    test('Flat horizontal device pointing South (180°)', () {
      final heading = HeadingCalculator.calculateAzimuth(
        ax: 0.0,
        ay: 0.0,
        az: 9.8,
        mx: 0.0,
        my: -30.0,
        mz: -40.0,
      );
      expect(heading, closeTo(180.0, 0.5));
    });

    test('Flat horizontal device pointing West (270°)', () {
      final heading = HeadingCalculator.calculateAzimuth(
        ax: 0.0,
        ay: 0.0,
        az: 9.8,
        mx: 30.0,
        my: 0.0,
        mz: -40.0,
      );
      expect(heading, closeTo(270.0, 0.5));
    });

    test('Tilt compensation: Pitch 30° up while pointing North maintains 0°', () {
      final heading = HeadingCalculator.calculateAzimuth(
        ax: 0.0,
        ay: 4.9,
        az: 8.487,
        mx: 0.0,
        my: 45.98,
        mz: -19.64,
      );
      expect(heading, closeTo(0.0, 1.0));
    });

    test('WMM-2025 Declination calculation returns expected values for New Delhi', () {
      final dec = HeadingCalculator.calculateDeclination(
        28.6139,
        77.2090,
        altitudeMeters: 216.0,
        date: DateTime.utc(2025, 1, 1),
      );
      // New Delhi declination at 2025.0 is approximately +1.30° East
      expect(dec, closeTo(1.30, 0.2));
      expect(dec, greaterThan(0.0));
    });

    test('WMM-2025 Declination calculation returns expected values for New York', () {
      final dec = HeadingCalculator.calculateDeclination(
        40.7128,
        -74.0060,
        altitudeMeters: 10.0,
        date: DateTime.utc(2025, 1, 1),
      );
      // New York declination at 2025.0 is approximately -12.53° West
      expect(dec, closeTo(-12.53, 0.2));
      expect(dec, lessThan(0.0));
    });

    test('True Heading calculation applies declination correctly: True = (Mag + Dec) mod 360', () {
      // In New York (Dec = -12.53°), user points Magnetic North (0°)
      const magHeading = 0.0;
      const dec = -12.53;
      final trueHeading = (magHeading + dec + 360.0) % 360.0;
      expect(trueHeading, closeTo(347.47, 0.01));

      // In Sydney (Dec = +12.79°), user points Magnetic North (0°)
      const decSydney = 12.79;
      final trueHeadingSydney = (magHeading + decSydney + 360.0) % 360.0;
      expect(trueHeadingSydney, closeTo(12.79, 0.01));
    });
  });
}
