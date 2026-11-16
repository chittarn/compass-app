import 'package:flutter/foundation.dart';
import 'heading_type.dart';
import '../../../core/utils/qibla_calculator.dart';
import '../../../core/utils/vastu_calculator.dart';
import '../../../core/utils/wmm_calculator.dart';

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
  final WmmReliabilityLevel wmmReliability; // Compass horizontal field reliability
  final double? latitude;
  final double? longitude;
  final double? altitude;             // Elevation in meters
  final double? locationAccuracy;     // Horizontal GPS accuracy in meters
  final double? magneticFieldStrength; // Live magnetic flux density in microteslas (μT)
  final bool isQiblaMode;             // Whether Qibla navigation mode is active
  final double? qiblaBearing;         // Forward azimuth to Kaaba in degrees [0, 360)
  final double? qiblaDistanceKm;      // Great-circle distance to Kaaba in km
  final double? sunAzimuth;           // Solar azimuth in degrees [0, 360) clockwise from True North
  final double? moonAzimuth;          // Lunar azimuth in degrees [0, 360) clockwise from True North
  final DateTime? sunriseTime;        // Local Sunrise time
  final DateTime? sunsetTime;         // Local Sunset time
  final bool isVastuMode;             // Whether Vastu Shastra architectural mode is active
  final VastuRoomType? activeVastuRoom; // Selected room target beacon

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
    this.wmmReliability = WmmReliabilityLevel.normal,
    this.latitude,
    this.longitude,
    this.altitude,
    this.locationAccuracy,
    this.magneticFieldStrength,
    this.isQiblaMode = false,
    this.qiblaBearing,
    this.qiblaDistanceKm,
    this.sunAzimuth,
    this.moonAzimuth,
    this.sunriseTime,
    this.sunsetTime,
    this.isVastuMode = false,
    this.activeVastuRoom,
  });

  /// True North is verified and available only when in True North mode AND
  /// a valid magnetic declination has been calculated by WMM from GPS.
  bool get isTrueNorthAvailable => headingType == HeadingType.trueNorth && magneticDeclination != null;

  String get formattedCoordinates {
    if (latitude == null || longitude == null) {
      return '--°--\'--" N  --°--\'--" E';
    }
    return '${_toDms(latitude!, isLat: true)}   ${_toDms(longitude!, isLat: false)}';
  }

  /// Formatted altitude with explicit datum:
  /// - Android: Height above WGS-84 reference ellipsoid (HAE).
  /// - iOS: Height above Mean Sea Level (MSL).
  String get formattedAltitude {
    if (altitude == null) {
      return defaultTargetPlatform == TargetPlatform.android ? '-- m WGS-84' : '-- m MSL';
    }
    final datum = defaultTargetPlatform == TargetPlatform.android ? 'm WGS-84' : 'm MSL';
    return '${altitude!.round()} $datum';
  }

  String get formattedMagneticField {
    if (magneticFieldStrength == null) {
      return '-- μT';
    }
    return '${magneticFieldStrength!.toStringAsFixed(1)} μT';
  }

  String get formattedDeclination {
    if (magneticDeclination == null) return '--°';
    final dir = magneticDeclination! >= 0 ? 'E' : 'W';
    return '${magneticDeclination!.abs().toStringAsFixed(1)}° $dir';
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
    final effectiveTrueHeading = (headingType == HeadingType.trueNorth || magneticDeclination == null)
        ? heading
        : ((heading + magneticDeclination!) % 360.0 + 360.0) % 360.0;
    return QiblaCalculator.isAligned(effectiveTrueHeading, qiblaBearing!);
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

  VastuZoneInfo get currentVastuZone {
    final effectiveHeading = (headingType == HeadingType.trueNorth || magneticDeclination == null)
        ? heading
        : ((heading + magneticDeclination!) % 360.0 + 360.0) % 360.0;
    return VastuCalculator.getZone(effectiveHeading);
  }

  bool get isVastuRoomAligned {
    if (activeVastuRoom == null) return false;
    final effectiveHeading = (headingType == HeadingType.trueNorth || magneticDeclination == null)
        ? heading
        : ((heading + magneticDeclination!) % 360.0 + 360.0) % 360.0;
    return VastuCalculator.isAlignedWithRoom(effectiveHeading, activeVastuRoom!);
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
    WmmReliabilityLevel? wmmReliability,
    double? latitude,
    double? longitude,
    double? altitude,
    double? locationAccuracy,
    double? magneticFieldStrength,
    bool? isQiblaMode,
    double? qiblaBearing,
    double? qiblaDistanceKm,
    double? sunAzimuth,
    double? moonAzimuth,
    DateTime? sunriseTime,
    DateTime? sunsetTime,
    bool? isVastuMode,
    VastuRoomType? activeVastuRoom,
    bool clearVastuRoom = false,
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
      wmmReliability: wmmReliability ?? this.wmmReliability,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      altitude: altitude ?? this.altitude,
      locationAccuracy: locationAccuracy ?? this.locationAccuracy,
      magneticFieldStrength: magneticFieldStrength ?? this.magneticFieldStrength,
      isQiblaMode: isQiblaMode ?? this.isQiblaMode,
      qiblaBearing: qiblaBearing ?? this.qiblaBearing,
      qiblaDistanceKm: qiblaDistanceKm ?? this.qiblaDistanceKm,
      sunAzimuth: sunAzimuth ?? this.sunAzimuth,
      moonAzimuth: moonAzimuth ?? this.moonAzimuth,
      sunriseTime: sunriseTime ?? this.sunriseTime,
      sunsetTime: sunsetTime ?? this.sunsetTime,
      isVastuMode: isVastuMode ?? this.isVastuMode,
      activeVastuRoom: clearVastuRoom ? null : (activeVastuRoom ?? this.activeVastuRoom),
    );
  }
}
