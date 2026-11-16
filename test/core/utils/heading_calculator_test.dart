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

    test('Declination calculation returns reasonable angle within [-180, 180]', () {
      final dec = HeadingCalculator.calculateDeclination(28.6, 77.2);
      expect(dec, greaterThanOrEqualTo(-180.0));
      expect(dec, lessThanOrEqualTo(180.0));
    });
  });
}
