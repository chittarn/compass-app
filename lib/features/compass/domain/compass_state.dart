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
  });

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
    );
  }
}
