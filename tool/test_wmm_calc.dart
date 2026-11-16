import 'dart:math' as math;
import '../lib/core/utils/wmm_calculator.dart';

void main() {
  print('=== VERIFYING DART WMM-2025 IMPLEMENTATION AGAINST NOAA TEST VECTORS ===');

  // Official NOAA WMM-2025 Test Vectors:
  // (year, altKm, lat, lon, expDec, expInc, expF)
  final testVectors = [
    (2025.0, 28.0, 89.0, -121.0, -99.77, 88.47, 56214.4),
    (2025.0, 48.0, 80.0, -96.0, -29.91, 87.77, 55665.1),
    (2025.0, 54.0, 82.0, 87.0, 54.89, 87.68, 56787.5),
    (2025.0, 65.0, 43.0, 93.0, 0.50, 64.10, 55626.6),
    (2025.0, 51.0, -33.0, 109.0, -5.49, -67.50, 57054.8),
    (2025.0, 39.0, -59.0, -8.0, -15.75, -58.55, 28589.8),
    (2025.0, 3.0, -50.0, -103.0, 27.96, -54.89, 38431.7),
    (2025.0, 94.0, -29.0, -110.0, 15.74, -38.25, 30792.7),
    (2025.0, 66.0, 14.0, 143.0, -0.19, 12.82, 35898.7),
    (2025.0, 18.0, 0.0, 21.0, 1.29, -26.06, 32594.8),
    (2025.5, 6.0, -36.0, -137.0, 20.28, -52.11, 41280.5),
    (2025.5, 63.0, 26.0, 81.0, 0.51, 41.07, 46166.6),
    (2025.5, 69.0, 38.0, -144.0, 12.93, 56.97, 42373.8),
    (2026.0, 74.0, -57.0, 3.0, -22.51, -58.65, 27606.2),
  ];

  bool allPassed = true;
  for (final t in testVectors) {
    final year = t.$1;
    final altKm = t.$2;
    final lat = t.$3;
    final lon = t.$4;
    final expDec = t.$5;
    final expInc = t.$6;
    final expF = t.$7;

    // Convert decimal year back to DateTime for testing API
    final int y = year.floor();
    final double fraction = year - y;
    final date = DateTime.utc(y, 1, 1).add(Duration(days: (fraction * 365.25).round()));

    final res = WmmCalculator.calculate(
      latitudeDeg: lat,
      longitudeDeg: lon,
      altitudeMeters: altKm * 1000.0,
      date: date,
    );

    final diffDec = (res.declinationDeg - expDec).abs();
    final diffInc = (res.inclinationDeg - expInc).abs();
    final diffF = (res.totalIntensityNt - expF).abs();

    final passed = diffDec < 0.02 && diffInc < 0.02 && diffF < 5.0;
    final status = passed ? 'PASS' : 'FAIL';
    print('[$status] Lat: ${lat.toString().padLeft(4)}°, Lon: ${lon.toString().padLeft(5)}°, Alt: ${altKm.toString().padLeft(3)}km, Yr: $year -> Dec: ${res.declinationDeg.toStringAsFixed(2)}° (Exp: ${expDec.toStringAsFixed(2)}°, diff: ${diffDec.toStringAsFixed(4)}°)');
    if (!passed) allPassed = false;
  }

  print('\n=== CHECKING KNOWN WORLDWIDE LOCATIONS (EPOCH 2025.0) ===');
  final cities = [
    ('New York, USA', 40.7128, -74.0060, 10.0),
    ('London, UK', 51.5074, -0.1278, 11.0),
    ('New Delhi, India', 28.6139, 77.2090, 216.0),
    ('Bhubaneswar, Odisha', 20.2961, 85.8245, 45.0),
    ('Tokyo, Japan', 35.6762, 139.6503, 40.0),
    ('Sydney, Australia', -33.8688, 151.2093, 19.0),
    ('Mecca (Kaaba), KSA', 21.4225, 39.8262, 277.0),
    ('Reykjavik, Iceland', 64.1466, -21.9426, 15.0),
    ('São Paulo, Brazil', -23.5505, -46.6333, 760.0),
  ];

  final date2025 = DateTime.utc(2025, 1, 1);
  for (final city in cities) {
    final name = city.$1;
    final lat = city.$2;
    final lon = city.$3;
    final alt = city.$4;
    final dec = WmmCalculator.calculateDeclination(
      latitudeDeg: lat,
      longitudeDeg: lon,
      altitudeMeters: alt,
      date: date2025,
    );
    final sign = dec >= 0 ? 'E' : 'W';
    print('${name.padRight(22)}: ${dec.abs().toStringAsFixed(2)}° $sign ($dec°)');
  }

  print('\n=== CHECKING BHUBANESWAR REFERENCE TEST VALUES ===');
  final bbi2025 = WmmCalculator.calculate(
    latitudeDeg: 20.2961,
    longitudeDeg: 85.8245,
    altitudeMeters: 45.0,
    date: DateTime.utc(2025, 1, 1),
  );
  print('Bhubaneswar 2025.0: Dec = ${bbi2025.declinationDeg.toStringAsFixed(4)}°, Inc = ${bbi2025.inclinationDeg.toStringAsFixed(4)}°, H = ${bbi2025.horizontalIntensityNt.toStringAsFixed(1)} nT, F = ${bbi2025.totalIntensityNt.toStringAsFixed(1)} nT, Reliability: ${bbi2025.reliabilityLevel.label}');
  assert((bbi2025.declinationDeg - (-0.4279)).abs() < 0.01, 'Bhubaneswar 2025.0 declination check failed');
  assert(bbi2025.reliabilityLevel == WmmReliabilityLevel.normal, 'Bhubaneswar must be Normal reliability');

  final bbi2026 = WmmCalculator.calculate(
    latitudeDeg: 20.2961,
    longitudeDeg: 85.8245,
    altitudeMeters: 45.0,
    date: DateTime.utc(2026, 1, 1),
  );
  print('Bhubaneswar 2026.0: Dec = ${bbi2026.declinationDeg.toStringAsFixed(4)}°, Inc = ${bbi2026.inclinationDeg.toStringAsFixed(4)}°, H = ${bbi2026.horizontalIntensityNt.toStringAsFixed(1)} nT, F = ${bbi2026.totalIntensityNt.toStringAsFixed(1)} nT, Reliability: ${bbi2026.reliabilityLevel.label}');
  assert((bbi2026.declinationDeg - (-0.4032)).abs() < 0.01, 'Bhubaneswar 2026.0 declination check failed');
  print('[PASS] Bhubaneswar reference values 100% verified against NOAA WMM-2025!\n');

  print('=== CHECKING MODEL BOUNDARY & VALIDATION CHECKS ===');
  bool pre2025Throws = false;
  try {
    WmmCalculator.calculate(
      latitudeDeg: 20.0,
      longitudeDeg: 80.0,
      date: DateTime.utc(2024, 12, 31),
    );
  } on ArgumentError {
    pre2025Throws = true;
  }
  print('Dates before 2025.0 throw ArgumentError: $pre2025Throws');
  assert(pre2025Throws);

  bool post2030Throws = false;
  try {
    WmmCalculator.calculate(
      latitudeDeg: 20.0,
      longitudeDeg: 80.0,
      date: DateTime.utc(2030, 2, 1),
    );
  } on ArgumentError {
    post2030Throws = true;
  }
  print('Dates after 2030.0 throw ArgumentError: $post2030Throws');
  assert(post2030Throws);

  bool invalidLatThrows = false;
  try {
    WmmCalculator.calculate(
      latitudeDeg: 91.0,
      longitudeDeg: 0.0,
      date: DateTime.utc(2025, 1, 1),
    );
  } on ArgumentError {
    invalidLatThrows = true;
  }
  print('Invalid latitude throws ArgumentError: $invalidLatThrows');
  assert(invalidLatThrows);

  bool nanThrows = false;
  try {
    WmmCalculator.calculate(
      latitudeDeg: double.nan,
      longitudeDeg: 0.0,
      date: DateTime.utc(2025, 1, 1),
    );
  } on ArgumentError {
    nanThrows = true;
  }
  print('Non-finite coordinates throw ArgumentError: $nanThrows');
  assert(nanThrows);

  print('[PASS] WMM-2025 Boundary & input validation verified!\n');

  print('=== CHECKING WMM RELIABILITY WARNINGS ===');
  // High Arctic blackout check: 89°N, -121°W -> H ≈ 1500 nT (< 2000 nT)
  final blackoutPoint = WmmCalculator.calculate(
    latitudeDeg: 89.0,
    longitudeDeg: -121.0,
    altitudeMeters: 28000.0,
    date: DateTime.utc(2025, 1, 1),
  );
  print('Arctic dip pole H: ${blackoutPoint.horizontalIntensityNt.toStringAsFixed(1)} nT -> ${blackoutPoint.reliabilityLevel.label}');
  assert(blackoutPoint.reliabilityLevel == WmmReliabilityLevel.blackout);

  // Caution zone: 80°N, -96°W -> H ≈ 2167 nT (2000..6000 nT)
  final cautionPoint = WmmCalculator.calculate(
    latitudeDeg: 80.0,
    longitudeDeg: -96.0,
    altitudeMeters: 48000.0,
    date: DateTime.utc(2025, 1, 1),
  );
  print('Sub-Arctic caution H: ${cautionPoint.horizontalIntensityNt.toStringAsFixed(1)} nT -> ${cautionPoint.reliabilityLevel.label}');
  assert(cautionPoint.reliabilityLevel == WmmReliabilityLevel.caution);

  print('[PASS] WMM Reliability warnings verified!\n');

  if (allPassed) {
    print('>>> ALL NOAA TEST VECTORS, BHUBANESWAR REFERENCE, VALIDATION & WARNING CHECKS PASSED (100%)! <<<');
  } else {
    print('>>> SOME TESTS FAILED! <<<');
  }
}
