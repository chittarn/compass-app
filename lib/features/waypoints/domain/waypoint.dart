import 'dart:math' as math;

class Waypoint {
  final String id;
  final String title;
  final double latitude;
  final double longitude;
  final double? altitude;
  final DateTime createdAt;

  const Waypoint({
    required this.id,
    required this.title,
    required this.latitude,
    required this.longitude,
    this.altitude,
    required this.createdAt,
  });

  /// Computes forward bearing in degrees [0, 360) from current location to this waypoint
  double bearingFrom(double fromLat, double fromLng) {
    final phi1 = fromLat * (math.pi / 180.0);
    final phi2 = latitude * (math.pi / 180.0);
    final deltaLambda = (longitude - fromLng) * (math.pi / 180.0);

    final y = math.sin(deltaLambda) * math.cos(phi2);
    final x = math.cos(phi1) * math.sin(phi2) -
        math.sin(phi1) * math.cos(phi2) * math.cos(deltaLambda);

    final theta = math.atan2(y, x);
    return (theta * (180.0 / math.pi) + 360.0) % 360.0;
  }

  /// Computes Haversine geodesic distance in meters from current location to this waypoint
  double distanceFromMeters(double fromLat, double fromLng) {
    const double earthRadiusMeters = 6371000.0;
    final phi1 = fromLat * (math.pi / 180.0);
    final phi2 = latitude * (math.pi / 180.0);
    final deltaPhi = (latitude - fromLat) * (math.pi / 180.0);
    final deltaLambda = (longitude - fromLng) * (math.pi / 180.0);

    final a = math.sin(deltaPhi / 2) * math.sin(deltaPhi / 2) +
        math.cos(phi1) *
            math.cos(phi2) *
            math.sin(deltaLambda / 2) *
            math.sin(deltaLambda / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusMeters * c;
  }

  /// Formatted distance string (e.g. "320 m" or "4.2 km")
  String formattedDistanceFrom(double fromLat, double fromLng) {
    final distM = distanceFromMeters(fromLat, fromLng);
    if (distM < 1000.0) {
      return '${distM.round()} m';
    } else {
      return '${(distM / 1000.0).toStringAsFixed(1)} km';
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'latitude': latitude,
        'longitude': longitude,
        'altitude': altitude,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Waypoint.fromJson(Map<String, dynamic> json) => Waypoint(
        id: json['id'] as String,
        title: json['title'] as String,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        altitude: json['altitude'] != null
            ? (json['altitude'] as num).toDouble()
            : null,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
