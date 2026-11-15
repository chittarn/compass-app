import 'dart:math' as math;

/// Mathematical utility for calculating geodesic forward azimuth and distance
/// from any GPS coordinate on Earth to the Holy Kaaba in Mecca.
class QiblaCalculator {
  // Exact Kaaba coordinates in Mecca, Saudi Arabia
  static const double kaabaLat = 21.422477;
  static const double kaabaLng = 39.826182;

  /// Earth mean radius in kilometers (WGS 84 spherical approximation)
  static const double earthRadiusKm = 6371.0;

  /// Calculates the forward azimuth (initial bearing) from the user's coordinates
  /// to the Kaaba in degrees [0, 360).
  static double calculateBearing(double userLat, double userLng) {
    final phi1 = userLat * (math.pi / 180.0);
    final phi2 = kaabaLat * (math.pi / 180.0);
    final deltaLambda = (kaabaLng - userLng) * (math.pi / 180.0);

    final y = math.sin(deltaLambda) * math.cos(phi2);
    final x = math.cos(phi1) * math.sin(phi2) -
        math.sin(phi1) * math.cos(phi2) * math.cos(deltaLambda);

    final theta = math.atan2(y, x);
    final bearing = (theta * (180.0 / math.pi) + 360.0) % 360.0;
    return bearing;
  }

  /// Calculates great-circle distance to the Kaaba in kilometers using the Haversine formula.
  static double calculateDistanceKm(double userLat, double userLng) {
    final phi1 = userLat * (math.pi / 180.0);
    final phi2 = kaabaLat * (math.pi / 180.0);
    final deltaPhi = (kaabaLat - userLat) * (math.pi / 180.0);
    final deltaLambda = (kaabaLng - userLng) * (math.pi / 180.0);

    final a = math.sin(deltaPhi / 2) * math.sin(deltaPhi / 2) +
        math.cos(phi1) *
            math.cos(phi2) *
            math.sin(deltaLambda / 2) *
            math.sin(deltaLambda / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  /// Determines if the current heading is aligned with the Qibla bearing
  /// within a specified tolerance band (default 3.0 degrees).
  static bool isAligned(double currentHeading, double qiblaBearing, {double toleranceDeg = 3.0}) {
    double diff = (currentHeading - qiblaBearing) % 360.0;
    if (diff > 180.0) diff -= 360.0;
    if (diff < -180.0) diff += 360.0;
    return diff.abs() <= toleranceDeg;
  }
}
