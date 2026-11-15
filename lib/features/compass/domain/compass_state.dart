import 'heading_type.dart';

class CompassState {
  final double heading;              // 0..360 for display readout
  final double unwrappedHeading;     // continuous angle for smooth animation controller
  final HeadingType headingType;
  final SensorAccuracyLevel accuracy;
  final double pitch;
  final double roll;
  final bool isLevel;
  final bool hasLocationPermission;
  final double? trueHeading;          // True north heading if GPS available
  final double? magneticDeclination;  // Difference between True and Magnetic
  final double? latitude;
  final double? longitude;
  final double? altitude;             // Elevation in meters above sea level

  const CompassState({
    required this.heading,
    required this.unwrappedHeading,
    required this.headingType,
    required this.accuracy,
    required this.pitch,
    required this.roll,
    required this.isLevel,
    required this.hasLocationPermission,
    this.trueHeading,
    this.magneticDeclination,
    this.latitude,
    this.longitude,
    this.altitude,
  });

  String get formattedCoordinates {
    if (latitude == null || longitude == null) {
      return '--°--\'--" N  --°--\'--" E';
    }
    return '${_toDms(latitude!, isLat: true)}   ${_toDms(longitude!, isLat: false)}';
  }

  String get formattedAltitude {
    if (altitude == null) {
      return '-- m MSL';
    }
    return '${altitude!.round()} m MSL';
  }

  static String _toDms(double val, {required bool isLat}) {
    final direction = isLat
        ? (val >= 0 ? 'N' : 'S')
        : (val >= 0 ? 'E' : 'W');
    final absVal = val.abs();
    final degrees = absVal.floor();
    final minutesDouble = (absVal - degrees) * 60.0;
    final minutes = minutesDouble.floor();
    final seconds = ((minutesDouble - minutes) * 60.0).round();

    return '$degrees°$minutes\'$seconds" $direction';
  }

  CompassState copyWith({
    double? heading,
    double? unwrappedHeading,
    HeadingType? headingType,
    SensorAccuracyLevel? accuracy,
    double? pitch,
    double? roll,
    bool? isLevel,
    bool? hasLocationPermission,
    double? trueHeading,
    double? magneticDeclination,
    double? latitude,
    double? longitude,
    double? altitude,
  }) {
    return CompassState(
      heading: heading ?? this.heading,
      unwrappedHeading: unwrappedHeading ?? this.unwrappedHeading,
      headingType: headingType ?? this.headingType,
      accuracy: accuracy ?? this.accuracy,
      pitch: pitch ?? this.pitch,
      roll: roll ?? this.roll,
      isLevel: isLevel ?? this.isLevel,
      hasLocationPermission: hasLocationPermission ?? this.hasLocationPermission,
      trueHeading: trueHeading ?? this.trueHeading,
      magneticDeclination: magneticDeclination ?? this.magneticDeclination,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      altitude: altitude ?? this.altitude,
    );
  }
}
