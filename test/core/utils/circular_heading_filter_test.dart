import 'package:flutter_test/flutter_test.dart';
import 'package:compass_app/core/utils/circular_heading_filter.dart';

void main() {
  group('CircularHeadingFilter Unit Tests', () {
    late CircularHeadingFilter filter;

    setUp(() {
      filter = CircularHeadingFilter(deadbandDegrees: 0.6);
    });

    test('Initializes with first raw reading', () {
      expect(filter.isInitialized, isFalse);
      expect(filter.filteredHeading, isNull);

      final result = filter.filter(45.0);
      expect(filter.isInitialized, isTrue);
      expect(result, closeTo(45.0, 0.001));
      expect(filter.filteredHeading, closeTo(45.0, 0.001));
    });

    test('Suppresses micro-jitter when phone is stationary on a table (EMF noise simulation)', () {
      // Simulate resting at 001° with observed EMF noise causing ±0.4° fluctuations
      filter.filter(1.0);

      final noisyReadings = [1.2, 0.8, 1.4, 0.7, 1.1, 0.9, 1.3, 0.65, 1.35];
      for (final raw in noisyReadings) {
        final filtered = filter.filter(raw);
        // Because all deviations from 1.0 are < 0.6° deadband, output must stay rock-solid at 1.0°
        expect(filtered, closeTo(1.0, 0.0001));
      }
      expect(filter.filteredHeading, closeTo(1.0, 0.0001));
    });

    test(
      'Engages adaptive EMA when user physically turns phone past deadband',
      () {
        filter.filter(0.0);

        // User turns by 2.0° (greater than 0.6° deadband)
        final step1 = filter.filter(2.0);
        // Small diff (2.0°) uses alpha = 0.12 -> step = 2.0 * 0.12 = 0.24°
        expect(step1, closeTo(0.24, 0.05));
      },
    );

    test('Responsive tracking during fast physical rotation (90° turn)', () {
      filter.filter(0.0);

      // Sudden 90° turn
      final step1 = filter.filter(90.0);
      // Large diff (> 25°) uses responsive alpha = 0.75 -> step = 90.0 * 0.75 = 67.5°
      expect(step1, closeTo(67.5, 0.5));

      final step2 = filter.filter(90.0);
      // Diff is now 90 - 67.5 = 22.5° -> alpha = 0.45 -> step = 22.5 * 0.45 = 10.125° -> 77.625°
      expect(step2, closeTo(77.625, 0.5));

      // After ~300ms of sensor events (15 ticks at 50Hz), it smoothly converges to 90°
      for (int i = 0; i < 15; i++) {
        filter.filter(90.0);
      }
      expect(filter.filteredHeading, closeTo(90.0, 0.6));
    });

    test('Handles circular wrap-around seamlessly across 359° -> 001° (clockwise shortest path)', () {
      filter.filter(359.0);

      // Phone rotates clockwise past North to 1.0° (arc distance is 2.0°, NOT 358°)
      final result = filter.filter(1.0);

      // Shortest-path signed diff is +2.0°. Step = 2.0 * 0.12 = +0.24°.
      // Heading should move clockwise to 359.24°, NOT counter-clockwise.
      expect(result, closeTo(359.24, 0.05));

      // Continuing to 1.0°
      double current = result;
      for (int i = 0; i < 15; i++) {
        current = filter.filter(1.0);
      }
      // Should cleanly wrap past 360/0 to ~1.0°
      expect(current, closeTo(1.0, 0.6));
    });

    test('Handles circular wrap-around seamlessly across 001° -> 359° (counter-clockwise shortest path)', () {
      filter.filter(1.0);

      // Phone rotates counter-clockwise past North to 359.0° (arc distance is -2.0°)
      final result = filter.filter(359.0);

      // Shortest-path signed diff is -2.0°. Step = -2.0 * 0.12 = -0.24°.
      // Heading should move to (1.0 - 0.24) = 0.76°.
      expect(result, closeTo(0.76, 0.05));
    });

    test('Reset clears filter history or sets initial angle', () {
      filter.filter(120.0);
      expect(filter.filteredHeading, closeTo(120.0, 0.001));

      filter.reset();
      expect(filter.isInitialized, isFalse);
      expect(filter.filteredHeading, isNull);

      filter.reset(270.0);
      expect(filter.isInitialized, isTrue);
      expect(filter.filteredHeading, closeTo(270.0, 0.001));
    });

    test('Handles negative angle inputs cleanly via normalization', () {
      final result = filter.filter(-90.0);
      expect(result, closeTo(270.0, 0.001));
    });
  });
}
