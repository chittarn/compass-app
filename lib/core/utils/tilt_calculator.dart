import 'dart:math' as math;

import '../constants/compass_constants.dart';

class DeviceTilt {
  final double pitch; // X tilt in degrees (-90 to 90)
  final double roll; // Y tilt in degrees (-180 to 180)
  final bool isLevel;

  const DeviceTilt({
    required this.pitch,
    required this.roll,
    required this.isLevel,
  });

  @override
  String toString() =>
      'DeviceTilt(pitch: ${pitch.toStringAsFixed(1)}°, roll: ${roll.toStringAsFixed(1)}°, level: $isLevel)';
}

class TiltCalculator {
  /// Converts 3-axis accelerometer readings (in m/s^2) into device pitch and roll angles in degrees.
  static DeviceTilt fromAccelerometer(double x, double y, double z) {
    // Pitch: rotation around X axis (nose up/down)
    final pitchRad = math.atan2(y, math.sqrt(x * x + z * z));
    // Roll: rotation around Y axis (bank left/right)
    final rollRad = math.atan2(-x, z);

    final pitchDeg = pitchRad * (180.0 / math.pi);
    final rollDeg = rollRad * (180.0 / math.pi);

    final isLevel =
        (pitchDeg.abs() <= CompassConstants.levelToleranceDegrees) &&
        (rollDeg.abs() <= CompassConstants.levelToleranceDegrees);

    return DeviceTilt(pitch: pitchDeg, roll: rollDeg, isLevel: isLevel);
  }
}
