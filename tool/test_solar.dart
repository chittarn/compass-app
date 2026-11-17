import '../lib/core/utils/solar_calculator.dart';

void main() {
  print('Testing SolarCalculator...');

  // Test at New York (40.7128 N, -74.0060 W) at local solar noon (~17:00 UTC)
  final testDate = DateTime.utc(
    2026,
    6,
    21,
    16,
    56,
    0,
  ); // Summer solstice noon NYC
  final sunAz = SolarCalculator.calculateSunAzimuth(
    40.7128,
    -74.0060,
    testDate,
  );
  print(
    'NYC Summer Solstice Noon -> Sun Azimuth: ${sunAz.toStringAsFixed(1)}° (Expected: ~180°)',
  );
  assert(
    (sunAz - 180.0).abs() < 5.0,
    'Solar noon azimuth should point nearly due South (~180°)',
  );

  // Test Sunrise / Sunset for London (51.5074 N, -0.1278 W) on 2026-06-21
  final londonSun = SolarCalculator.calculateSunriseSunset(
    51.5074,
    -0.1278,
    DateTime(2026, 6, 21),
  );
  print(
    'London Summer Solstice -> Sunrise: ${londonSun.sunrise}, Sunset: ${londonSun.sunset}',
  );
  assert(
    londonSun.sunrise != null && londonSun.sunset != null,
    'Sunrise and Sunset should exist',
  );

  // Moon azimuth test
  final moonAz = SolarCalculator.calculateMoonAzimuth(
    40.7128,
    -74.0060,
    testDate,
  );
  print('Moon Azimuth: ${moonAz.toStringAsFixed(1)}°');
  assert(moonAz >= 0 && moonAz < 360, 'Moon azimuth should be in [0, 360)');

  print('SolarCalculator tests passed successfully!');
}
