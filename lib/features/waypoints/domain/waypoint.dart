import 'dart:math' as math;

enum WaypointCategory {
  custom('Custom', '📍'),
  home('Home', '🏠'),
  work('Work', '💼'),
  travel('Travel', '✈️');

  final String label;
  final String emoji;
  const WaypointCategory(this.label, this.emoji);
}

class Waypoint {
  final String id;
  final String title;
  final double latitude;
  final double longitude;
  final double? altitude;
  final DateTime createdAt;
  final WaypointCategory category;
  final String? notes;

  const Waypoint({
    required this.id,
    required this.title,
    required this.latitude,
    required this.longitude,
    this.altitude,
    required this.createdAt,
    this.category = WaypointCategory.custom,
    this.notes,
  });

  /// Computes forward bearing in degrees [0, 360) from current location to this waypoint
  double bearingFrom(double fromLat, double fromLng) {
    final phi1 = fromLat * (math.pi / 180.0);
    final phi2 = latitude * (math.pi / 180.0);
    final deltaLambda = (longitude - fromLng) * (math.pi / 180.0);

    final y = math.sin(deltaLambda) * math.cos(phi2);
    final x =
        math.cos(phi1) * math.sin(phi2) -
        math.sin(phi1) * math.cos(phi2) * math.cos(deltaLambda);

    final theta = math.atan2(y, x);
    return (theta * (180.0 / math.pi) + 360.0) % 360.0;
  }

  /// Computes relative bearing in degrees [-180, +180] relative to phone's current heading.
  /// Negative = Turn Left, Positive = Turn Right.
  double relativeBearingFrom(
    double fromLat,
    double fromLng,
    double currentHeading,
  ) {
    final targetBearing = bearingFrom(fromLat, fromLng);
    double diff = (targetBearing - currentHeading) % 360.0;
    if (diff > 180.0) diff -= 360.0;
    if (diff < -180.0) diff += 360.0;
    return diff;
  }

  /// Computes Haversine geodesic distance in meters from current location to this waypoint
  double distanceFromMeters(double fromLat, double fromLng) {
    const double earthRadiusMeters = 6371000.0;
    final phi1 = fromLat * (math.pi / 180.0);
    final phi2 = latitude * (math.pi / 180.0);
    final deltaPhi = (latitude - fromLat) * (math.pi / 180.0);
    final deltaLambda = (longitude - fromLng) * (math.pi / 180.0);

    final a =
        math.sin(deltaPhi / 2) * math.sin(deltaPhi / 2) +
        math.cos(phi1) *
            math.cos(phi2) *
            math.sin(deltaLambda / 2) *
            math.sin(deltaLambda / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusMeters * c;
  }

  /// Whether user has reached destination, considering GPS accuracy and hysteresis to prevent status flickering.
  bool isArrived(
    double fromLat,
    double fromLng, {
    double? locationAccuracyMeters,
    double arrivalRadiusMeters = 25.0,
    double maxPermissibleAccuracyMeters = 40.0,
    bool previouslyArrived = false,
    double hysteresisMeters = 10.0,
  }) {
    // If GPS accuracy is too poor (e.g. > 40m uncertainty), avoid false arrival claims
    if (locationAccuracyMeters != null &&
        locationAccuracyMeters > maxPermissibleAccuracyMeters) {
      return false;
    }

    final dist = distanceFromMeters(fromLat, fromLng);

    // Hysteresis: If already arrived, stay arrived until user moves beyond arrivalRadius + hysteresis
    if (previouslyArrived) {
      return dist <= (arrivalRadiusMeters + hysteresisMeters);
    }

    return dist <= arrivalRadiusMeters;
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

  Waypoint copyWith({
    String? title,
    double? latitude,
    double? longitude,
    double? altitude,
    WaypointCategory? category,
    String? notes,
    bool clearNotes = false,
  }) {
    return Waypoint(
      id: id,
      title: title ?? this.title,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      altitude: altitude ?? this.altitude,
      createdAt: createdAt,
      category: category ?? this.category,
      notes: clearNotes ? null : (notes ?? this.notes),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'latitude': latitude,
    'longitude': longitude,
    'altitude': altitude,
    'createdAt': createdAt.toIso8601String(),
    'category': category.name,
    'notes': notes,
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
    category: json['category'] != null
        ? WaypointCategory.values.firstWhere(
            (c) => c.name == json['category'],
            orElse: () => WaypointCategory.custom,
          )
        : WaypointCategory.custom,
    notes: json['notes'] as String?,
  );
}
