import 'package:flutter/services.dart';

typedef HapticCallback = Future<void> Function();

/// Throttles and triggers tactical haptic feedback.
///
/// Prevents haptic motor saturation, rapid battery drain, and harsh buzzing
/// during high-speed device rotation by enforcing a minimum deadband interval
/// and suppressing triggers above an angular velocity cutoff.
class HapticThrottler {
  final Duration minInterval;
  final double maxAngularVelocity;

  final HapticCallback? onHeavy;
  final HapticCallback? onMedium;
  final HapticCallback? onLight;

  DateTime _lastHapticTime = DateTime.fromMillisecondsSinceEpoch(0);
  int _lastTriggeredSector = -1;

  HapticThrottler({
    this.minInterval = const Duration(milliseconds: 65),
    this.maxAngularVelocity = 135.0,
    this.onHeavy,
    this.onMedium,
    this.onLight,
  });

  /// Evaluates the new heading and emits appropriate haptic feedback if eligible.
  Future<bool> evaluateHeading({
    required double headingDegrees,
    required double angularVelocityDegPerSec,
    DateTime? currentTime,
  }) async {
    // 1. Velocity threshold check: suppress if spinning too fast
    if (angularVelocityDegPerSec.abs() > maxAngularVelocity) {
      return false;
    }

    final now = currentTime ?? DateTime.now();

    // 2. Cooldown deadband
    if (now.difference(_lastHapticTime) < minInterval) {
      return false;
    }

    // 3. Sector determination (every 15 degrees, 24 sectors total)
    final normalized = (headingDegrees % 360.0 + 360.0) % 360.0;
    final sector = (normalized / 15.0).round() % 24;

    if (sector != _lastTriggeredSector) {
      _lastTriggeredSector = sector;
      _lastHapticTime = now;

      final degree = sector * 15;
      if (degree == 0) {
        if (onHeavy != null) {
          await onHeavy!();
        } else {
          await HapticFeedback.heavyImpact();
        }
      } else if (degree == 90 || degree == 180 || degree == 270) {
        if (onMedium != null) {
          await onMedium!();
        } else {
          await HapticFeedback.mediumImpact();
        }
      } else {
        if (onLight != null) {
          await onLight!();
        } else {
          await HapticFeedback.selectionClick();
        }
      }
      return true;
    }

    return false;
  }

  void reset() {
    _lastTriggeredSector = -1;
    _lastHapticTime = DateTime.fromMillisecondsSinceEpoch(0);
  }
}
