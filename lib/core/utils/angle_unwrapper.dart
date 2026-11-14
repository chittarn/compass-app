/// Mathematical continuous angle unwrapper.
///
/// Prevents the angular discontinuity problem where rotating between 359° and 0°
/// causes interpolation sweeps of 359° in the wrong direction.
/// Calculates the minimum signed angular step in the range [-180°, +180°).
class AngleUnwrapper {
  double _currentUnwrappedAngle;
  bool _isInitialized = false;

  AngleUnwrapper([this._currentUnwrappedAngle = 0.0]);

  double get currentAngle => _currentUnwrappedAngle;
  bool get isInitialized => _isInitialized;

  /// Given a target angle [rawTargetDegrees] in [0, 360), computes the continuous unwrapped angle.
  double unwrap(double rawTargetDegrees) {
    if (!_isInitialized) {
      _currentUnwrappedAngle = (rawTargetDegrees % 360.0 + 360.0) % 360.0;
      _isInitialized = true;
      return _currentUnwrappedAngle;
    }

    final currentMod = (_currentUnwrappedAngle % 360.0 + 360.0) % 360.0;
    // Shortest-path signed angular difference in [-180°, 180°)
    var diff = (rawTargetDegrees - currentMod + 540.0) % 360.0 - 180.0;
    _currentUnwrappedAngle += diff;
    return _currentUnwrappedAngle;
  }

  void reset(double initialDegrees) {
    _currentUnwrappedAngle = (initialDegrees % 360.0 + 360.0) % 360.0;
    _isInitialized = true;
  }
}
