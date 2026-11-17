import 'dart:math' as math;

import '../lib/core/utils/circular_heading_filter.dart';

void main() {
  print('=== STARTING CIRCULAR HEADING FILTER VERIFICATION ===\n');

  final filter = CircularHeadingFilter(deadbandDegrees: 0.6);

  // 1. Initial reading
  final init = filter.filter(45.0);
  assert((init - 45.0).abs() < 0.001, 'Init failed');
  print('[PASS] 1. Initial reading initialized to 45.0°');

  // 2. Stationary suppression (table testing scenario: 001° with EMF noise)
  filter.reset(1.0);
  final noise = [1.2, 0.8, 1.4, 0.7, 1.1, 0.9, 1.3, 0.65, 1.35];
  for (final raw in noise) {
    final out = filter.filter(raw);
    assert(
      (out - 1.0).abs() < 0.0001,
      'Failed stationary deadband check for raw: $raw, out: $out',
    );
  }
  print(
    '[PASS] 2. Stationary phone at 001° with ±0.4° EMF jitter: 100% stable at 1.0000°',
  );

  // 3. Fast rotation (90° turn)
  filter.reset(0.0);
  final step1 = filter.filter(90.0);
  assert((step1 - 67.5).abs() < 0.5, 'Step 1 responsive alpha check failed');
  double current = step1;
  for (int i = 0; i < 7; i++) {
    current = filter.filter(90.0);
  }
  assert((current - 90.0).abs() < 0.6, 'Failed convergence to 90.0°: $current');
  print(
    '[PASS] 3. Fast physical rotation (0° -> 90°): rapid convergence in 8 ticks ($current°)',
  );

  // 4. Wrap-around 359° -> 1°
  filter.reset(359.0);
  final wrapStep = filter.filter(1.0);
  assert(
    (wrapStep - 359.24).abs() < 0.05,
    'Failed clockwise wrap check: $wrapStep',
  );
  for (int i = 0; i < 15; i++) {
    current = filter.filter(1.0);
  }
  assert((current - 1.0).abs() < 0.6, 'Failed wrap convergence: $current');
  print(
    '[PASS] 4. Clockwise wrap-around 359° -> 1.0°: smooth interpolation along shortest arc',
  );

  // 5. Wrap-around 1° -> 359°
  filter.reset(1.0);
  final ccwStep = filter.filter(359.0);
  assert(
    (ccwStep - 0.76).abs() < 0.05,
    'Failed counter-clockwise wrap check: $ccwStep',
  );
  print(
    '[PASS] 5. Counter-clockwise wrap-around 1.0° -> 359°: smooth interpolation along shortest arc',
  );

  print(
    '\n>>> ALL 5 CIRCULAR HEADING FILTER VERIFICATION TESTS PASSED (100%)! <<<',
  );
}
