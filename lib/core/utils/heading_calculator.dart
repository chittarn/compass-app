import 'dart:math' as math;
import 'wmm_calculator.dart';

class HeadingCalculator {
  /// Computes a 3D tilt-compensated magnetic azimuth in degrees [0, 360) using Android's
  /// SensorManager rotation matrix algorithm.
  /// 
  /// [ax], [ay], [az]: Accelerometer measurements in m/s^2.
  /// [mx], [my], [mz]: Magnetometer measurements in µT.
  static double calculateAzimuth({
    required double ax,
    required double ay,
    required double az,
    required double mx,
    required double my,
    required double mz,
  }) {
    // 1. Gravity vector norm
    final normA = math.sqrt(ax * ax + ay * ay + az * az);
    if (normA < 0.1) return 0.0;

    // 2. East vector H = E x A (geomagnetic vector cross gravity vector)
    double hx = my * az - mz * ay;
    double hy = mz * ax - mx * az;
    double hz = mx * ay - my * ax;
    final normH = math.sqrt(hx * hx + hy * hy + hz * hz);
    if (normH < 0.1) return 0.0;

    final invH = 1.0 / normH;
    hx *= invH;
    hy *= invH;
    hz *= invH;

    final invA = 1.0 / normA;
    final normAx = ax * invA;
    final normAz = az * invA;

    // 3. North vector M = A x H
    final myNorm = normAz * hx - normAx * hz;

    // 4. Azimuth = atan2(Hy, My) in Android coordinates
    final azimuthRad = math.atan2(hy, myNorm);
    final azimuthDeg = azimuthRad * 180.0 / math.pi;

    return (azimuthDeg % 360.0 + 360.0) % 360.0;
  }

  /// Calculates magnetic declination in degrees for a given latitude, longitude,
  /// altitude and observation date using the official NOAA/BGS World Magnetic Model (WMM-2025).
  ///
  /// Positive (+) = East declination (Magnetic North is East of True North).
  /// Negative (-) = West declination (Magnetic North is West of True North).
  ///
  /// [latDeg]: WGS84 Geodetic latitude [-90.0, 90.0].
  /// [lonDeg]: WGS84 Geodetic longitude [-180.0, 180.0].
  /// [altitudeMeters]: Altitude above WGS84 ellipsoid in meters (default: 0.0).
  /// [date]: Observation date (default: DateTime.now()).
  static double calculateDeclination(
    double latDeg,
    double lonDeg, {
    double altitudeMeters = 0.0,
    DateTime? date,
  }) {
    return WmmCalculator.calculateDeclination(
      latitudeDeg: latDeg,
      longitudeDeg: lonDeg,
      altitudeMeters: altitudeMeters,
      date: date,
    );
  }

  /// Computes the complete 7-component WMM-2025 result including reliability level
  static WmmResult calculateWmm(
    double latDeg,
    double lonDeg, {
    double altitudeMeters = 0.0,
    DateTime? date,
  }) {
    return WmmCalculator.calculate(
      latitudeDeg: latDeg,
      longitudeDeg: lonDeg,
      altitudeMeters: altitudeMeters,
      date: date,
    );
  }
}
