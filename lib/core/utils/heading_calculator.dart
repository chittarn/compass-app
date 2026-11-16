import 'dart:math' as math;

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
    final normAy = ay * invA;
    final normAz = az * invA;

    // 3. North vector M = A x H
    final myNorm = normAz * hx - normAx * hz;

    // 4. Azimuth = atan2(Hy, My) in Android coordinates
    final azimuthRad = math.atan2(hy, myNorm);
    final azimuthDeg = azimuthRad * 180.0 / math.pi;

    return (azimuthDeg % 360.0 + 360.0) % 360.0;
  }

  /// Calculates the magnetic declination in degrees for a given latitude and longitude.
  /// Positive = East, Negative = West.
  static double calculateDeclination(double latDeg, double lonDeg) {
    // Geomagnetic North Pole approximation (~80.5° N, 72.6° W)
    const double poleLat = 80.5 * math.pi / 180.0;
    const double poleLon = -72.6 * math.pi / 180.0;

    final lat = latDeg * math.pi / 180.0;
    final lon = lonDeg * math.pi / 180.0;

    final dLon = poleLon - lon;
    final y = math.sin(dLon) * math.cos(poleLat);
    final x = math.cos(lat) * math.sin(poleLat) -
        math.sin(lat) * math.cos(poleLat) * math.cos(dLon);

    final bearingToPole = math.atan2(y, x) * 180.0 / math.pi;
    double dec = -bearingToPole;
    if (dec > 180) dec -= 360;
    if (dec < -180) dec += 360;
    return dec;
  }
}
