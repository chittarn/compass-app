import 'package:flutter_test/flutter_test.dart';
import 'package:compass_app/core/utils/wmm_calculator.dart';

void main() {
  group('NOAA WMM-2025 Ground Truth Test Vectors', () {
    // Official test vector points from NOAA WMM2025 specification
    test('Vector 1: Arctic high latitude (89°N, -121°W, 28km, 2025.0)', () {
      final res = WmmCalculator.calculate(
        latitudeDeg: 89.0,
        longitudeDeg: -121.0,
        altitudeMeters: 28000.0,
        date: DateTime.utc(2025, 1, 1),
      );
      expect(res.declinationDeg, closeTo(-99.77, 0.02));
      expect(res.inclinationDeg, closeTo(88.47, 0.02));
      expect(res.totalIntensityNt, closeTo(56214.4, 5.0));
    });

    test('Vector 2: Northern Canada (80°N, -96°W, 48km, 2025.0)', () {
      final res = WmmCalculator.calculate(
        latitudeDeg: 80.0,
        longitudeDeg: -96.0,
        altitudeMeters: 48000.0,
        date: DateTime.utc(2025, 1, 1),
      );
      expect(res.declinationDeg, closeTo(-29.91, 0.02));
      expect(res.inclinationDeg, closeTo(87.77, 0.02));
    });

    test('Vector 3: Siberia (82°N, 87°E, 54km, 2025.0)', () {
      final res = WmmCalculator.calculate(
        latitudeDeg: 82.0,
        longitudeDeg: 87.0,
        altitudeMeters: 54000.0,
        date: DateTime.utc(2025, 1, 1),
      );
      expect(res.declinationDeg, closeTo(54.89, 0.02));
      expect(res.inclinationDeg, closeTo(87.68, 0.02));
    });

    test('Vector 4: Central Asia (43°N, 93°E, 65km, 2025.0)', () {
      final res = WmmCalculator.calculate(
        latitudeDeg: 43.0,
        longitudeDeg: 93.0,
        altitudeMeters: 65000.0,
        date: DateTime.utc(2025, 1, 1),
      );
      expect(res.declinationDeg, closeTo(0.50, 0.02));
      expect(res.inclinationDeg, closeTo(64.10, 0.02));
    });

    test('Vector 5: Indian Ocean (-33°S, 109°E, 51km, 2025.0)', () {
      final res = WmmCalculator.calculate(
        latitudeDeg: -33.0,
        longitudeDeg: 109.0,
        altitudeMeters: 51000.0,
        date: DateTime.utc(2025, 1, 1),
      );
      expect(res.declinationDeg, closeTo(-5.49, 0.02));
      expect(res.inclinationDeg, closeTo(-67.50, 0.02));
    });

    test('Vector 6: South Atlantic (-59°S, -8°W, 39km, 2025.0)', () {
      final res = WmmCalculator.calculate(
        latitudeDeg: -59.0,
        longitudeDeg: -8.0,
        altitudeMeters: 39000.0,
        date: DateTime.utc(2025, 1, 1),
      );
      expect(res.declinationDeg, closeTo(-15.75, 0.02));
      expect(res.inclinationDeg, closeTo(-58.55, 0.02));
    });

    test('Vector 7: South Pacific (-50°S, -103°W, 3km, 2025.0)', () {
      final res = WmmCalculator.calculate(
        latitudeDeg: -50.0,
        longitudeDeg: -103.0,
        altitudeMeters: 3000.0,
        date: DateTime.utc(2025, 1, 1),
      );
      expect(res.declinationDeg, closeTo(27.96, 0.02));
      expect(res.inclinationDeg, closeTo(-54.89, 0.02));
    });

    test('Vector 8: West of Chile (-29°S, -110°W, 94km, 2025.0)', () {
      final res = WmmCalculator.calculate(
        latitudeDeg: -29.0,
        longitudeDeg: -110.0,
        altitudeMeters: 94000.0,
        date: DateTime.utc(2025, 1, 1),
      );
      expect(res.declinationDeg, closeTo(15.74, 0.02));
      expect(res.inclinationDeg, closeTo(-38.25, 0.02));
    });

    test('Vector 9: Micronesia (14°N, 143°E, 66km, 2025.0)', () {
      final res = WmmCalculator.calculate(
        latitudeDeg: 14.0,
        longitudeDeg: 143.0,
        altitudeMeters: 66000.0,
        date: DateTime.utc(2025, 1, 1),
      );
      expect(res.declinationDeg, closeTo(-0.19, 0.02));
      expect(res.inclinationDeg, closeTo(12.82, 0.02));
    });

    test('Vector 10: Equatorial Africa (0°N, 21°E, 18km, 2025.0)', () {
      final res = WmmCalculator.calculate(
        latitudeDeg: 0.0,
        longitudeDeg: 21.0,
        altitudeMeters: 18000.0,
        date: DateTime.utc(2025, 1, 1),
      );
      expect(res.declinationDeg, closeTo(1.29, 0.02));
      expect(res.inclinationDeg, closeTo(-26.06, 0.02));
    });

    test('Vector 11: Mid-epoch 2025.5 secular variation (-36°S, -137°W, 6km)', () {
      final res = WmmCalculator.calculate(
        latitudeDeg: -36.0,
        longitudeDeg: -137.0,
        altitudeMeters: 6000.0,
        date: DateTime.utc(2025, 7, 2),
      );
      expect(res.declinationDeg, closeTo(20.28, 0.02));
      expect(res.inclinationDeg, closeTo(-52.11, 0.02));
    });

    test('Vector 12: Mid-epoch 2025.5 (26°N, 81°E, 63km)', () {
      final res = WmmCalculator.calculate(
        latitudeDeg: 26.0,
        longitudeDeg: 81.0,
        altitudeMeters: 63000.0,
        date: DateTime.utc(2025, 7, 2),
      );
      expect(res.declinationDeg, closeTo(0.51, 0.02));
      expect(res.inclinationDeg, closeTo(41.07, 0.02));
    });

    test('Vector 13: Mid-epoch 2025.5 (38°N, -144°W, 69km)', () {
      final res = WmmCalculator.calculate(
        latitudeDeg: 38.0,
        longitudeDeg: -144.0,
        altitudeMeters: 69000.0,
        date: DateTime.utc(2025, 7, 2),
      );
      expect(res.declinationDeg, closeTo(12.93, 0.02));
      expect(res.inclinationDeg, closeTo(56.97, 0.02));
    });

    test('Vector 14: Epoch 2026.0 secular variation (-57°S, 3°E, 74km)', () {
      final res = WmmCalculator.calculate(
        latitudeDeg: -57.0,
        longitudeDeg: 3.0,
        altitudeMeters: 74000.0,
        date: DateTime.utc(2026, 1, 1),
      );
      expect(res.declinationDeg, closeTo(-22.51, 0.02));
      expect(res.inclinationDeg, closeTo(-58.65, 0.02));
    });
  });

  group('WMM-2025 Major Reference Cities & Convention Tests', () {
    final epochDate = DateTime.utc(2025, 1, 1);

    test('New York, USA: ~12.5° West (-12.53°)', () {
      final dec = WmmCalculator.calculateDeclination(
        latitudeDeg: 40.7128,
        longitudeDeg: -74.0060,
        altitudeMeters: 10.0,
        date: epochDate,
      );
      expect(dec, closeTo(-12.53, 0.2));
      // West declination must be negative
      expect(dec, lessThan(0.0));
    });

    test('London, UK: ~0.9° East (+0.91°)', () {
      final dec = WmmCalculator.calculateDeclination(
        latitudeDeg: 51.5074,
        longitudeDeg: -0.1278,
        altitudeMeters: 11.0,
        date: epochDate,
      );
      expect(dec, closeTo(0.91, 0.2));
      // East declination must be positive
      expect(dec, greaterThan(0.0));
    });

    test('New Delhi, India: ~1.3° East (+1.30°)', () {
      final dec = WmmCalculator.calculateDeclination(
        latitudeDeg: 28.6139,
        longitudeDeg: 77.2090,
        altitudeMeters: 216.0,
        date: epochDate,
      );
      expect(dec, closeTo(1.30, 0.2));
      expect(dec, greaterThan(0.0));
    });

    test('Tokyo, Japan: ~7.9° West (-7.87°)', () {
      final dec = WmmCalculator.calculateDeclination(
        latitudeDeg: 35.6762,
        longitudeDeg: 139.6503,
        altitudeMeters: 40.0,
        date: epochDate,
      );
      expect(dec, closeTo(-7.87, 0.2));
      expect(dec, lessThan(0.0));
    });

    test('Sydney, Australia: ~12.8° East (+12.79°)', () {
      final dec = WmmCalculator.calculateDeclination(
        latitudeDeg: -33.8688,
        longitudeDeg: 151.2093,
        altitudeMeters: 19.0,
        date: epochDate,
      );
      expect(dec, closeTo(12.79, 0.2));
      expect(dec, greaterThan(0.0));
    });

    test('Mecca (Kaaba), Saudi Arabia: ~3.5° East (+3.52°)', () {
      final dec = WmmCalculator.calculateDeclination(
        latitudeDeg: 21.4225,
        longitudeDeg: 39.8262,
        altitudeMeters: 277.0,
        date: epochDate,
      );
      expect(dec, closeTo(3.52, 0.2));
      expect(dec, greaterThan(0.0));
    });

    test('Bhubaneswar, Odisha, India: Official NOAA WMM-2025 Reference Test', () {
      // Bhubaneswar Coordinates: 20.2961° N, 85.8245° E, Elevation: 45.0m WGS-84
      // Epoch 2025.0: Expected Dec: -0.43° W (-0.4279°), Inc: 30.40°, H: 38,980.5 nT, F: 45,196.0 nT
      final res2025 = WmmCalculator.calculate(
        latitudeDeg: 20.2961,
        longitudeDeg: 85.8245,
        altitudeMeters: 45.0,
        date: DateTime.utc(2025, 1, 1),
      );
      expect(res2025.declinationDeg, closeTo(-0.43, 0.05));
      expect(res2025.inclinationDeg, closeTo(30.40, 0.1));
      expect(res2025.totalIntensityNt, closeTo(45196.0, 10.0));
      expect(res2025.horizontalIntensityNt, closeTo(38980.5, 10.0));
      expect(res2025.reliabilityLevel, equals(WmmReliabilityLevel.normal));

      // Epoch 2026.0 (Secular variation drift rate validation):
      // Expected Dec: -0.40° W (-0.4032°), Inc: 30.43°, H: 38,998.6 nT, F: 45,230.0 nT
      final res2026 = WmmCalculator.calculate(
        latitudeDeg: 20.2961,
        longitudeDeg: 85.8245,
        altitudeMeters: 45.0,
        date: DateTime.utc(2026, 1, 1),
      );
      expect(res2026.declinationDeg, closeTo(-0.40, 0.05));
      expect(res2026.inclinationDeg, closeTo(30.43, 0.1));
      expect(res2026.totalIntensityNt, closeTo(45230.0, 10.0));
      expect(res2026.horizontalIntensityNt, closeTo(38998.6, 10.0));
      expect(res2026.reliabilityLevel, equals(WmmReliabilityLevel.normal));
    });
  });

  group('WMM-2025 Reliability Warnings & Field Strength Thresholds', () {
    test('Normal reliability: Horizontal intensity H > 6000 nT', () {
      final res = WmmCalculator.calculate(
        latitudeDeg: 28.6139,
        longitudeDeg: 77.2090,
        altitudeMeters: 216.0,
        date: DateTime.utc(2025, 1, 1),
      );
      expect(res.horizontalIntensityNt, greaterThan(6000.0));
      expect(res.reliabilityLevel, equals(WmmReliabilityLevel.normal));
    });

    test('Caution zone: Horizontal intensity 2000 nT <= H <= 6000 nT', () {
      // High magnetic latitude near Canadian Arctic: 80°N, -96°W
      final res = WmmCalculator.calculate(
        latitudeDeg: 80.0,
        longitudeDeg: -96.0,
        altitudeMeters: 48000.0,
        date: DateTime.utc(2025, 1, 1),
      );
      expect(res.horizontalIntensityNt, greaterThanOrEqualTo(2000.0));
      expect(res.horizontalIntensityNt, lessThanOrEqualTo(6000.0));
      expect(res.reliabilityLevel, equals(WmmReliabilityLevel.caution));
    });

    test('Blackout zone: Horizontal intensity H < 2000 nT near magnetic dip pole', () {
      // 89°N, -121°W has H ≈ 1500 nT
      final res = WmmCalculator.calculate(
        latitudeDeg: 89.0,
        longitudeDeg: -121.0,
        altitudeMeters: 28000.0,
        date: DateTime.utc(2025, 1, 1),
      );
      expect(res.horizontalIntensityNt, lessThan(2000.0));
      expect(res.reliabilityLevel, equals(WmmReliabilityLevel.blackout));
    });
  });

  group('Boundary & Graceful Handling Tests', () {
    test('Dates before 2025.0 throw ArgumentError', () {
      expect(
        () => WmmCalculator.calculate(
          latitudeDeg: 40.7128,
          longitudeDeg: -74.0060,
          date: DateTime.utc(2024, 12, 31),
        ),
        throwsArgumentError,
      );
    });

    test('Dates after 2030.0 throw ArgumentError', () {
      expect(
        () => WmmCalculator.calculate(
          latitudeDeg: 40.7128,
          longitudeDeg: -74.0060,
          date: DateTime.utc(2030, 2, 1),
        ),
        throwsArgumentError,
      );
    });

    test('Invalid latitude (> 90° or < -90°) throws ArgumentError', () {
      expect(
        () => WmmCalculator.calculate(
          latitudeDeg: 95.0,
          longitudeDeg: 0.0,
          date: DateTime.utc(2025, 1, 1),
        ),
        throwsArgumentError,
      );
      expect(
        () => WmmCalculator.calculate(
          latitudeDeg: -90.5,
          longitudeDeg: 0.0,
          date: DateTime.utc(2025, 1, 1),
        ),
        throwsArgumentError,
      );
    });

    test('Non-finite coordinates or altitude throw ArgumentError', () {
      expect(
        () => WmmCalculator.calculate(
          latitudeDeg: double.nan,
          longitudeDeg: 0.0,
          date: DateTime.utc(2025, 1, 1),
        ),
        throwsArgumentError,
      );
      expect(
        () => WmmCalculator.calculate(
          latitudeDeg: 0.0,
          longitudeDeg: double.infinity,
          date: DateTime.utc(2025, 1, 1),
        ),
        throwsArgumentError,
      );
      expect(
        () => WmmCalculator.calculate(
          latitudeDeg: 0.0,
          longitudeDeg: 0.0,
          altitudeMeters: double.nan,
          date: DateTime.utc(2025, 1, 1),
        ),
        throwsArgumentError,
      );
    });

    test('Exact North Pole (+90.0°) computes cleanly within valid bounds', () {
      final dec = WmmCalculator.calculateDeclination(
        latitudeDeg: 90.0,
        longitudeDeg: 0.0,
        date: DateTime.utc(2025, 1, 1),
      );
      expect(dec.isNaN, isFalse);
      expect(dec.isInfinite, isFalse);
    });

    test('Exact South Pole (-90.0°) computes cleanly within valid bounds', () {
      final dec = WmmCalculator.calculateDeclination(
        latitudeDeg: -90.0,
        longitudeDeg: 0.0,
        date: DateTime.utc(2025, 1, 1),
      );
      expect(dec.isNaN, isFalse);
      expect(dec.isInfinite, isFalse);
    });

    test('Equator (0.0°) computes cleanly', () {
      final dec = WmmCalculator.calculateDeclination(
        latitudeDeg: 0.0,
        longitudeDeg: 0.0,
        date: DateTime.utc(2025, 1, 1),
      );
      expect(dec.isNaN, isFalse);
    });

    test('Date conversion handles leap years and standard years', () {
      final yr2025 = WmmCalculator.dateToDecimalYear(DateTime.utc(2025, 7, 2, 12));
      expect(yr2025, closeTo(2025.5, 0.01));

      final yr2028 = WmmCalculator.dateToDecimalYear(DateTime.utc(2028, 7, 1, 12));
      expect(yr2028, closeTo(2028.5, 0.01));
    });
  });
}
