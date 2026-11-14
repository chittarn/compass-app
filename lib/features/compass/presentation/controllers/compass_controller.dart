import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:geolocator/geolocator.dart';
import '../../domain/compass_state.dart';
import '../../domain/heading_type.dart';
import '../../../../core/utils/angle_unwrapper.dart';
import '../../../../core/utils/haptic_throttler.dart';
import '../../../../core/utils/tilt_calculator.dart';

final compassControllerProvider =
    StateNotifierProvider<CompassController, CompassState>((ref) {
  return CompassController();
});

class CompassController extends StateNotifier<CompassState> {
  final AngleUnwrapper _unwrapper = AngleUnwrapper();
  final HapticThrottler _hapticThrottler = HapticThrottler();

  StreamSubscription? _compassSub;
  StreamSubscription? _accelerometerSub;
  DateTime _lastTimestamp = DateTime.now();
  double _lastHeading = 0.0;

  CompassController()
      : super(const CompassState(
          heading: 0.0,
          unwrappedHeading: 0.0,
          headingType: HeadingType.magnetic,
          accuracy: SensorAccuracyLevel.high,
          pitch: 0.0,
          roll: 0.0,
          isLevel: true,
          hasLocationPermission: false,
        )) {
    _initStreams();
  }

  void _initStreams() {
    try {
      _compassSub = FlutterCompass.events?.listen(_onCompassEvent);
    } catch (_) {
      // In simulator/desktop environments where sensors are unavailable
    }

    try {
      _accelerometerSub = accelerometerEventStream().listen(_onAccelerometerEvent);
    } catch (_) {
      // In simulator/desktop environments where sensors are unavailable
    }
  }

  void _onCompassEvent(CompassEvent event) {
    if (event.heading == null) return;

    final now = DateTime.now();
    final dt = now.difference(_lastTimestamp).inMilliseconds / 1000.0;
    _lastTimestamp = now;

    // Use magnetic heading by default, or true heading if requested and present
    double chosenHeading;
    if (state.headingType == HeadingType.trueNorth && event.headingForCameraMode != null) {
      chosenHeading = event.headingForCameraMode!;
    } else {
      chosenHeading = event.heading!;
    }

    final rawHeading = (chosenHeading % 360.0 + 360.0) % 360.0;
    final unwrapped = _unwrapper.unwrap(rawHeading);

    double velocity = 0.0;
    if (dt > 0.001) {
      velocity = (unwrapped - _lastHeading) / dt;
    }
    _lastHeading = unwrapped;

    // Trigger tactical haptics if criteria met
    _hapticThrottler.evaluateHeading(
      headingDegrees: rawHeading,
      angularVelocityDegPerSec: velocity,
      currentTime: now,
    );

    final accuracy = _mapAccuracy(event.accuracy);

    state = state.copyWith(
      heading: rawHeading,
      unwrappedHeading: unwrapped,
      accuracy: accuracy,
    );
  }

  void _onAccelerometerEvent(AccelerometerEvent event) {
    final tilt = TiltCalculator.fromAccelerometer(event.x, event.y, event.z);
    state = state.copyWith(
      pitch: tilt.pitch,
      roll: tilt.roll,
      isLevel: tilt.isLevel,
    );
  }

  SensorAccuracyLevel _mapAccuracy(double? accuracyVal) {
    if (accuracyVal == null) return SensorAccuracyLevel.medium;

    // Android returns status integer (0=unreliable, 1=low, 2=medium, 3=high)
    // iOS returns maximum deviation error in degrees (>0 valid, <0 invalid)
    if (accuracyVal <= 0) {
      return SensorAccuracyLevel.unreliable;
    } else if (accuracyVal <= 1.0) {
      // Low on Android status code 1
      return SensorAccuracyLevel.low;
    } else if (accuracyVal <= 2.0) {
      return SensorAccuracyLevel.medium;
    } else if (accuracyVal <= 15.0) {
      // iOS degrees <= 15 is high accuracy
      return SensorAccuracyLevel.high;
    } else if (accuracyVal <= 30.0) {
      return SensorAccuracyLevel.medium;
    } else {
      return SensorAccuracyLevel.low;
    }
  }

  Future<bool> toggleHeadingType() async {
    if (state.headingType == HeadingType.magnetic) {
      // User wants True North: check/request location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          return false;
        }
      }

      state = state.copyWith(
        headingType: HeadingType.trueNorth,
        hasLocationPermission: true,
      );
      return true;
    } else {
      state = state.copyWith(headingType: HeadingType.magnetic);
      return true;
    }
  }

  @override
  void dispose() {
    _compassSub?.cancel();
    _accelerometerSub?.cancel();
    super.dispose();
  }
}
