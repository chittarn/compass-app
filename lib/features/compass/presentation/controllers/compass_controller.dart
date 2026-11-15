import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/compass_state.dart';
import '../../domain/heading_type.dart';
import '../../../../core/utils/angle_unwrapper.dart';
import '../../../../core/utils/haptic_throttler.dart';
import '../../../../core/utils/tilt_calculator.dart';
import '../../../../core/utils/qibla_calculator.dart';
import '../../../../core/utils/solar_calculator.dart';

final compassControllerProvider =
    StateNotifierProvider<CompassController, CompassState>((ref) {
  return CompassController();
});

class CompassController extends StateNotifier<CompassState> {
  static const String _keyHeadingType = 'compass_heading_type';
  static const String _keyQiblaMode = 'compass_qibla_mode';

  final AngleUnwrapper _unwrapper = AngleUnwrapper();
  final HapticThrottler _hapticThrottler = HapticThrottler();

  StreamSubscription? _compassSub;
  StreamSubscription? _accelerometerSub;
  StreamSubscription? _magnetometerSub;
  StreamSubscription? _positionSub;
  Timer? _celestialTimer;
  DateTime _lastTimestamp = DateTime.now();
  double _lastHeading = 0.0;
  bool _lastQiblaAligned = false;

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
    _loadPreferences();
    _initStreams();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTypeIndex = prefs.getInt(_keyHeadingType);
      if (savedTypeIndex != null && savedTypeIndex < HeadingType.values.length) {
        final savedType = HeadingType.values[savedTypeIndex];
        state = state.copyWith(headingType: savedType);
      }
      final savedQibla = prefs.getBool(_keyQiblaMode) ?? false;
      if (savedQibla) {
        state = state.copyWith(isQiblaMode: true);
      }
    } catch (_) {}
  }

  void _initStreams() {
    try {
      _compassSub = FlutterCompass.events?.listen(_onCompassEvent);
    } catch (_) {}

    try {
      _accelerometerSub = accelerometerEventStream().listen(_onAccelerometerEvent);
    } catch (_) {}

    try {
      _magnetometerSub = magnetometerEventStream().listen(_onMagnetometerEvent);
    } catch (_) {}

    _celestialTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _recomputeCelestial();
    });

    _checkAndStartGps();
  }

  void _recomputeCelestial() {
    if (state.latitude == null || state.longitude == null) return;
    final nowUtc = DateTime.now().toUtc();
    final nowLocal = DateTime.now();
    final sunAz = SolarCalculator.calculateSunAzimuth(state.latitude!, state.longitude!, nowUtc);
    final moonAz = SolarCalculator.calculateMoonAzimuth(state.latitude!, state.longitude!, nowUtc);
    final sunTimes = SolarCalculator.calculateSunriseSunset(state.latitude!, state.longitude!, nowLocal);

    state = state.copyWith(
      sunAzimuth: sunAz,
      moonAzimuth: moonAz,
      sunriseTime: sunTimes.sunrise,
      sunsetTime: sunTimes.sunset,
    );
  }

  Future<void> _checkAndStartGps() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        state = state.copyWith(hasLocationPermission: true);
        final lastPos = await Geolocator.getLastKnownPosition();
        if (lastPos != null) {
          _updatePosition(lastPos);
        }
        _startGpsStream();
      }
    } catch (_) {}
  }

  void _startGpsStream() {
    _positionSub?.cancel();
    try {
      _positionSub = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 2,
        ),
      ).listen((Position pos) {
        _updatePosition(pos);
      });
    } catch (_) {}
  }

  void _updatePosition(Position pos) {
    final qBearing = QiblaCalculator.calculateBearing(pos.latitude, pos.longitude);
    final qDist = QiblaCalculator.calculateDistanceKm(pos.latitude, pos.longitude);

    final nowUtc = DateTime.now().toUtc();
    final nowLocal = DateTime.now();
    final sunAz = SolarCalculator.calculateSunAzimuth(pos.latitude, pos.longitude, nowUtc);
    final moonAz = SolarCalculator.calculateMoonAzimuth(pos.latitude, pos.longitude, nowUtc);
    final sunTimes = SolarCalculator.calculateSunriseSunset(pos.latitude, pos.longitude, nowLocal);

    state = state.copyWith(
      latitude: pos.latitude,
      longitude: pos.longitude,
      altitude: pos.altitude,
      hasLocationPermission: true,
      qiblaBearing: qBearing,
      qiblaDistanceKm: qDist,
      sunAzimuth: sunAz,
      moonAzimuth: moonAz,
      sunriseTime: sunTimes.sunrise,
      sunsetTime: sunTimes.sunset,
    );
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

    // Trigger tactical haptics if cardinal/sub-cardinal criteria met
    _hapticThrottler.evaluateHeading(
      headingDegrees: rawHeading,
      angularVelocityDegPerSec: velocity,
      currentTime: now,
    );

    // Qibla Alignment Haptic Pulse
    if (state.isQiblaMode && state.qiblaBearing != null) {
      final isNowAligned = QiblaCalculator.isAligned(rawHeading, state.qiblaBearing!);
      if (!_lastQiblaAligned && isNowAligned) {
        HapticFeedback.heavyImpact();
      }
      _lastQiblaAligned = isNowAligned;
    }

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

  void _onMagnetometerEvent(MagnetometerEvent event) {
    final rawMag = math.sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
    final current = state.magneticFieldStrength;
    final smoothed = current == null ? rawMag : (current * 0.85 + rawMag * 0.15);
    state = state.copyWith(magneticFieldStrength: smoothed);
  }

  SensorAccuracyLevel _mapAccuracy(double? accuracyVal) {
    if (accuracyVal == null) return SensorAccuracyLevel.medium;

    if (accuracyVal <= 0) {
      return SensorAccuracyLevel.unreliable;
    } else if (accuracyVal <= 1.0) {
      return SensorAccuracyLevel.low;
    } else if (accuracyVal <= 2.0) {
      return SensorAccuracyLevel.medium;
    } else if (accuracyVal <= 15.0) {
      return SensorAccuracyLevel.high;
    } else if (accuracyVal <= 30.0) {
      return SensorAccuracyLevel.medium;
    } else {
      return SensorAccuracyLevel.low;
    }
  }

  Future<bool> toggleHeadingType() async {
    if (state.headingType == HeadingType.magnetic) {
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
      _startGpsStream();

      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(_keyHeadingType, HeadingType.trueNorth.index);
      } catch (_) {}

      return true;
    } else {
      state = state.copyWith(headingType: HeadingType.magnetic);
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(_keyHeadingType, HeadingType.magnetic.index);
      } catch (_) {}

      return true;
    }
  }

  Future<bool> toggleQiblaMode() async {
    final newMode = !state.isQiblaMode;
    state = state.copyWith(isQiblaMode: newMode);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyQiblaMode, newMode);
    } catch (_) {}

    if (newMode && (state.latitude == null || state.longitude == null)) {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        state = state.copyWith(hasLocationPermission: true);
        final lastPos = await Geolocator.getLastKnownPosition();
        if (lastPos != null) {
          _updatePosition(lastPos);
        }
        _startGpsStream();
      }
    }

    return newMode;
  }

  @override
  void dispose() {
    _celestialTimer?.cancel();
    _compassSub?.cancel();
    _accelerometerSub?.cancel();
    _magnetometerSub?.cancel();
    _positionSub?.cancel();
    super.dispose();
  }
}
