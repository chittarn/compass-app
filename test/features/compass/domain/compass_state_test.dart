import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:compass_app/features/compass/domain/compass_state.dart';
import 'package:compass_app/features/compass/domain/heading_type.dart';
import 'package:compass_app/core/constants/compass_constants.dart';
import 'package:compass_app/core/utils/wmm_calculator.dart';

void main() {
  group('CompassState & Constants Tests', () {
    test('CompassConstants.getDirectionLabel resolves 16-point compass rose', () {
      expect(CompassConstants.getDirectionLabel(0.0), 'N');
      expect(CompassConstants.getDirectionLabel(355.0), 'N');
      expect(CompassConstants.getDirectionLabel(5.0), 'N');
      expect(CompassConstants.getDirectionLabel(45.0), 'NE');
      expect(CompassConstants.getDirectionLabel(90.0), 'E');
      expect(CompassConstants.getDirectionLabel(135.0), 'SE');
      expect(CompassConstants.getDirectionLabel(180.0), 'S');
      expect(CompassConstants.getDirectionLabel(225.0), 'SW');
      expect(CompassConstants.getDirectionLabel(270.0), 'W');
      expect(CompassConstants.getDirectionLabel(315.0), 'NW');
    });

    test('CompassState copyWith updates immutably', () {
      const state = CompassState(
        heading: 180.0,
        unwrappedHeading: 180.0,
        headingType: HeadingType.magnetic,
        accuracy: SensorAccuracyLevel.medium,
        pitch: 2.0,
        roll: 1.0,
        isLevel: false,
        hasLocationPermission: false,
      );

      final updated = state.copyWith(
        heading: 0.0,
        unwrappedHeading: 360.0,
        isLevel: true,
        accuracy: SensorAccuracyLevel.high,
      );

      expect(updated.heading, 0.0);
      expect(updated.unwrappedHeading, 360.0);
      expect(updated.isLevel, isTrue);
      expect(updated.accuracy, SensorAccuracyLevel.high);
      expect(updated.headingType, HeadingType.magnetic);
    });

    test('CompassState formats GPS coordinates and altitude datum properly', () {
      const stateWithGps = CompassState(
        heading: 0.0,
        unwrappedHeading: 0.0,
        headingType: HeadingType.trueNorth,
        accuracy: SensorAccuracyLevel.high,
        pitch: 0.0,
        roll: 0.0,
        isLevel: true,
        hasLocationPermission: true,
        latitude: 37.7749,
        longitude: -122.4194,
        altitude: 142.6,
      );

      expect(stateWithGps.formattedCoordinates, contains('37°46\'30" N'));
      expect(stateWithGps.formattedCoordinates, contains('122°25\'10" W'));

      const stateWithoutGps = CompassState(
        heading: 0.0,
        unwrappedHeading: 0.0,
        headingType: HeadingType.magnetic,
        accuracy: SensorAccuracyLevel.high,
        pitch: 0.0,
        roll: 0.0,
        isLevel: true,
        hasLocationPermission: false,
      );

      expect(stateWithoutGps.formattedCoordinates, contains('--°--\'--" N'));

      // Test Android platform datum: WGS-84 ellipsoidal height
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      expect(stateWithGps.formattedAltitude, '143 m WGS-84');
      expect(stateWithoutGps.formattedAltitude, '-- m WGS-84');

      // Test iOS platform datum: MSL
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      expect(stateWithGps.formattedAltitude, '143 m MSL');
      expect(stateWithoutGps.formattedAltitude, '-- m MSL');

      debugDefaultTargetPlatformOverride = null;
    });

    test('CompassState validates isTrueNorthAvailable and wmmReliability', () {
      const stateMag = CompassState(
        heading: 0.0,
        unwrappedHeading: 0.0,
        headingType: HeadingType.magnetic,
        accuracy: SensorAccuracyLevel.high,
        pitch: 0.0,
        roll: 0.0,
        isLevel: true,
        hasLocationPermission: true,
        magneticDeclination: 5.0,
      );
      // In Magnetic mode, True North is not active
      expect(stateMag.isTrueNorthAvailable, isFalse);

      final stateTrueNoDec = stateMag.copyWith(
        headingType: HeadingType.trueNorth,
        clearDeclination: true,
      );
      // In True North mode without declination (pending GPS fix), True North is not available
      expect(stateTrueNoDec.isTrueNorthAvailable, isFalse);

      final stateTrueWithDec = stateMag.copyWith(
        headingType: HeadingType.trueNorth,
        magneticDeclination: 5.0,
        wmmReliability: WmmReliabilityLevel.normal,
      );
      // In True North mode with valid declination, True North is available
      expect(stateTrueWithDec.isTrueNorthAvailable, isTrue);
      expect(stateTrueWithDec.wmmReliability, WmmReliabilityLevel.normal);
    });

    test('CompassState formats magnetic field and Qibla telemetry properly', () {
      const stateWithTelemetry = CompassState(
        heading: 58.5,
        unwrappedHeading: 58.5,
        headingType: HeadingType.magnetic,
        accuracy: SensorAccuracyLevel.high,
        pitch: 0.0,
        roll: 0.0,
        isLevel: true,
        hasLocationPermission: true,
        magneticFieldStrength: 48.24,
        isQiblaMode: true,
        qiblaBearing: 58.48,
        qiblaDistanceKm: 10306.0,
      );

      expect(stateWithTelemetry.formattedMagneticField, '48.2 μT');
      expect(stateWithTelemetry.magneticFieldStatus, 'NORMAL');
      expect(stateWithTelemetry.isHighInterference, isFalse);
      expect(stateWithTelemetry.formattedQiblaDistance, '10306 km');
      expect(stateWithTelemetry.isQiblaAligned, isTrue);

      final stateWithInterference = stateWithTelemetry.copyWith(
        magneticFieldStrength: 135.0,
      );
      expect(stateWithInterference.isHighInterference, isTrue);
      expect(stateWithInterference.magneticFieldStatus, 'HIGH INTERFERENCE');
    });

    test('CompassState formats celestial ephemeris (Sunrise/Sunset) properly', () {
      final stateWithEphemeris = const CompassState(
        heading: 0.0,
        unwrappedHeading: 0.0,
        headingType: HeadingType.magnetic,
        accuracy: SensorAccuracyLevel.high,
        pitch: 0.0,
        roll: 0.0,
        isLevel: true,
        hasLocationPermission: true,
      ).copyWith(
        sunAzimuth: 128.5,
        moonAzimuth: 245.2,
        sunriseTime: DateTime(2026, 6, 21, 6, 14),
        sunsetTime: DateTime(2026, 6, 21, 20, 32),
      );

      expect(stateWithEphemeris.sunAzimuth, 128.5);
      expect(stateWithEphemeris.moonAzimuth, 245.2);
      expect(stateWithEphemeris.formattedSunrise, '06:14');
      expect(stateWithEphemeris.formattedSunset, '20:32');
    });

    test('CompassState computes current Vastu zone and room alignment', () {
      const stateAtNE = CompassState(
        heading: 45.0,
        unwrappedHeading: 45.0,
        headingType: HeadingType.magnetic,
        accuracy: SensorAccuracyLevel.high,
        pitch: 0.0,
        roll: 0.0,
        isLevel: true,
        hasLocationPermission: false,
        isVastuMode: true,
      );

      expect(stateAtNE.currentVastuZone.direction, 'NE');
      expect(stateAtNE.currentVastuZone.sanskritName, contains('Ishan'));
    });

    test('CompassState formats magnetic declination correctly', () {
      const stateNoDec = CompassState(
        heading: 0.0,
        unwrappedHeading: 0.0,
        headingType: HeadingType.magnetic,
        accuracy: SensorAccuracyLevel.high,
        pitch: 0.0,
        roll: 0.0,
        isLevel: true,
        hasLocationPermission: false,
      );
      expect(stateNoDec.formattedDeclination, '--°');

      final stateEast = stateNoDec.copyWith(magneticDeclination: 12.3);
      expect(stateEast.formattedDeclination, '12.3° E');

      final stateWest = stateNoDec.copyWith(magneticDeclination: -3.6);
      expect(stateWest.formattedDeclination, '3.6° W');
    });
  });
}
