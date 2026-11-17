/// Circular Adaptive Low-Pass Filter with Deadband Suppression.
///
/// Filters noisy magnetometer heading readings while preserving responsiveness
/// during physical device rotation. Uses shortest-path geodesic interpolation
/// on the S1 circle [0, 360) to eliminate discontinuity artifacts across 359° ↔ 0°.
class CircularHeadingFilter {
  final double deadbandDegrees;
  double? _filteredHeading;

  CircularHeadingFilter({this.deadbandDegrees = 0.6});

  double? get filteredHeading => _filteredHeading;
  bool get isInitialized => _filteredHeading != null;

  /// Filters a raw heading input [rawDegrees] in [0, 360).
  ///
  /// Returns the smoothed heading in [0, 360).
  double filter(double rawDegrees) {
    final normalizedRaw = (rawDegrees % 360.0 + 360.0) % 360.0;
    if (_filteredHeading == null) {
      _filteredHeading = normalizedRaw;
      return _filteredHeading!;
    }

    // Shortest-path signed angular difference in [-180°, +180°)
    final diff = (normalizedRaw - _filteredHeading! + 540.0) % 360.0 - 180.0;
    final absDiff = diff.abs();

    // Deadband suppression: when micro-jitter is within noise floor, hold steady
    if (absDiff < deadbandDegrees) {
      return _filteredHeading!;
    }

    // Adaptive EMA alpha: high smoothing near target/settling, responsive when turning
    final double alpha;
    if (absDiff > 25.0) {
      alpha = 0.75; // Fast motion / sudden turn
    } else if (absDiff > 10.0) {
      alpha = 0.45; // Moderate turn
    } else if (absDiff > 3.0) {
      alpha = 0.25; // Gentle rotation
    } else {
      alpha = 0.12; // Slow drift / approach
    }

    final step = diff * alpha;
    _filteredHeading = ((_filteredHeading! + step) % 360.0 + 360.0) % 360.0;
    return _filteredHeading!;
  }

  void reset([double? initialDegrees]) {
    if (initialDegrees != null) {
      _filteredHeading = (initialDegrees % 360.0 + 360.0) % 360.0;
    } else {
      _filteredHeading = null;
    }
  }
}
