import 'package:flutter_test/flutter_test.dart';
import 'package:compass_app/core/utils/solar_calculator.dart';

void main() {
  group('SolarCalculator Tests', () {
    test('Calculates Solar Azimuth at Summer Solstice noon', () {
      // Summer Solstice (June 21, 2026) at NYC (40.7128°N, 74.0060°W) at 16:56 UTC (Solar Noon)
      final timeUtc = DateTime.utc(2026, 6, 21, 16, 56);
      final sunAzimuth = SolarCalculator.calculateSunAzimuth(40.7128, -74.0060, timeUtc);

      // Solar noon azimuth should face almost due South (~180°)
      expect(sunAzimuth, greaterThan(170.0));
      expect(sunAzimuth, lessThan(190.0));
    });

    test('Calculates Sunrise and Sunset times for London', () {
      final localDate = DateTime(2026, 6, 21);
      final result = SolarCalculator.calculateSunriseSunset(51.5074, -0.1278, localDate);

      expect(result.sunrise, isNotNull);
      expect(result.sunset, isNotNull);
    });

    test('Calculates Moon Azimuth within valid angle range [0, 360)', () {
      final timeUtc = DateTime.utc(2026, 6, 21, 12, 0);
      final moonAz = SolarCalculator.calculateMoonAzimuth(40.7128, -74.0060, timeUtc);

      expect(moonAz, greaterThanOrEqualTo(0.0));
      expect(moonAz, lessThan(360.0));
    });
  });
}
