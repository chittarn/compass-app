import '../lib/core/utils/qibla_calculator.dart';

void main() {
  print('Testing QiblaCalculator...');

  // Test 1: New York (40.7128 N, 74.0060 W)
  final nyBearing = QiblaCalculator.calculateBearing(40.7128, -74.0060);
  final nyDist = QiblaCalculator.calculateDistanceKm(40.7128, -74.0060);
  print(
    'New York -> Bearing: ${nyBearing.toStringAsFixed(2)}°, Distance: ${nyDist.round()} km',
  );
  assert(nyBearing > 58.0 && nyBearing < 59.0, 'NY bearing should be ~58.5°');

  // Test 2: London (51.5074 N, 0.1278 W)
  final lonBearing = QiblaCalculator.calculateBearing(51.5074, -0.1278);
  final lonDist = QiblaCalculator.calculateDistanceKm(51.5074, -0.1278);
  print(
    'London -> Bearing: ${lonBearing.toStringAsFixed(2)}°, Distance: ${lonDist.round()} km',
  );
  assert(
    lonBearing > 118.0 && lonBearing < 120.0,
    'London bearing should be ~119°',
  );

  // Test 3: New Delhi (28.6139 N, 77.2090 E)
  final delhiBearing = QiblaCalculator.calculateBearing(28.6139, 77.2090);
  final delhiDist = QiblaCalculator.calculateDistanceKm(28.6139, 77.2090);
  print(
    'New Delhi -> Bearing: ${delhiBearing.toStringAsFixed(2)}°, Distance: ${delhiDist.round()} km',
  );
  assert(
    delhiBearing > 266.0 && delhiBearing < 269.0,
    'Delhi bearing should be ~267.8°',
  );

  // Test 4: Alignment check
  assert(QiblaCalculator.isAligned(268.0, 267.8), 'Should be aligned');
  assert(!QiblaCalculator.isAligned(280.0, 267.8), 'Should not be aligned');

  print('All Qibla math checks passed successfully!');
}
