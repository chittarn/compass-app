import 'package:flutter_test/flutter_test.dart';
import 'package:compass_app/core/utils/qibla_calculator.dart';

void main() {
  group('QiblaCalculator Geodesic Tests', () {
    test('Calculates forward azimuth to Kaaba correctly for major global cities', () {
      // New York (40.7128 N, 74.0060 W) -> ~58.48°
      final nyBearing = QiblaCalculator.calculateBearing(40.7128, -74.0060);
      expect((nyBearing - 58.48).abs() < 0.2, isTrue);

      // London (51.5074 N, 0.1278 W) -> ~118.99°
      final lonBearing = QiblaCalculator.calculateBearing(51.5074, -0.1278);
      expect((lonBearing - 118.99).abs() < 0.2, isTrue);

      // New Delhi (28.6139 N, 77.2090 E) -> ~266.60°
      final delhiBearing = QiblaCalculator.calculateBearing(28.6139, 77.2090);
      expect((delhiBearing - 266.60).abs() < 0.2, isTrue);
    });

    test('Calculates distance in km to Mecca accurately', () {
      final nyDist = QiblaCalculator.calculateDistanceKm(40.7128, -74.0060);
      expect(nyDist.round(), inInclusiveRange(10200, 10400));

      final lonDist = QiblaCalculator.calculateDistanceKm(51.5074, -0.1278);
      expect(lonDist.round(), inInclusiveRange(4700, 4900));
    });

    test('isAligned checks tolerance threshold properly', () {
      const qibla = 58.5;
      expect(QiblaCalculator.isAligned(58.5, qibla), isTrue);
      expect(QiblaCalculator.isAligned(60.0, qibla), isTrue);
      expect(QiblaCalculator.isAligned(56.0, qibla), isTrue);
      expect(QiblaCalculator.isAligned(65.0, qibla), isFalse);
      expect(QiblaCalculator.isAligned(0.0, qibla), isFalse);
    });
  });
}
