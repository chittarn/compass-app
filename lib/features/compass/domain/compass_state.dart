import 'heading_type.dart';
import '../../../core/utils/qibla_calculator.dart';

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
  final double? magneticFieldStrength; // Live magnetic flux density in microteslas (μT)
  final bool isQiblaMode;             // Whether Qibla navigation mode is active
  final double? qiblaBearing;         // Forward azimuth to Kaaba in degrees [0, 360)
  final double? qiblaDistanceKm;      // Great-circle distance to Kaaba in km
  final double? sunAzimuth;           // Solar azimuth in degrees [0, 360) clockwise from True North
  final double? moonAzimuth;          // Lunar azimuth in degrees [0, 360) clockwise from True North
  final DateTime? sunriseTime;        // Local Sunrise time
  final DateTime? sunsetTime;         // Local Sunset time

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
    this.magneticFieldStrength,
    this.isQiblaMode = false,
    this.qiblaBearing,
    this.qiblaDistanceKm,
    this.sunAzimuth,
    this.moonAzimuth,
    this.sunriseTime,
    this.sunsetTime,
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

  String get formattedMagneticField {
    if (magneticFieldStrength == null) {
      return '-- μT';
    }
    return '${magneticFieldStrength!.toStringAsFixed(1)} μT';
  }

  String get magneticFieldStatus {
    if (magneticFieldStrength == null) return 'NORMAL';
    if (magneticFieldStrength! > 110.0) return 'HIGH INTERFERENCE';
    if (magneticFieldStrength! > 70.0) return 'ELEVATED';
    return 'NORMAL';
  }

  bool get isHighInterference {
    return magneticFieldStrength != null && magneticFieldStrength! > 110.0;
  }

  String get formattedQiblaDistance {
    if (qiblaDistanceKm == null) {
      return '-- km';
    }
    return '${qiblaDistanceKm!.round()} km';
  }

  bool get isQiblaAligned {
    if (qiblaBearing == null) return false;
    return QiblaCalculator.isAligned(heading, qiblaBearing!);
  }

  String get formattedSunrise {
    if (sunriseTime == null) return '--:--';
    final hour = sunriseTime!.hour.toString().padLeft(2, '0');
    final min = sunriseTime!.minute.toString().padLeft(2, '0');
    return '$hour:$min';
  }

  String get formattedSunset {
    if (sunsetTime == null) return '--:--';
    final hour = sunsetTime!.hour.toString().padLeft(2, '0');
    final min = sunsetTime!.minute.toString().padLeft(2, '0');
    return '$hour:$min';
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
    double? magneticFieldStrength,
    bool? isQiblaMode,
    double? qiblaBearing,
    double? qiblaDistanceKm,
    double? sunAzimuth,
    double? moonAzimuth,
    DateTime? sunriseTime,
    DateTime? sunsetTime,
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
      magneticFieldStrength: magneticFieldStrength ?? this.magneticFieldStrength,
      isQiblaMode: isQiblaMode ?? this.isQiblaMode,
      qiblaBearing: qiblaBearing ?? this.qiblaBearing,
      qiblaDistanceKm: qiblaDistanceKm ?? this.qiblaDistanceKm,
      sunAzimuth: sunAzimuth ?? this.sunAzimuth,
      moonAzimuth: moonAzimuth ?? this.moonAzimuth,
      sunriseTime: sunriseTime ?? this.sunriseTime,
      sunsetTime: sunsetTime ?? this.sunsetTime,
    );
  }
}
