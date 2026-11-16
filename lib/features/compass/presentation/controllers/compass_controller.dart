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
import '../../../../core/constants/compass_constants.dart';
import '../../../../core/utils/vastu_calculator.dart';
import '../../../../core/utils/heading_calculator.dart';

final compassControllerProvider =
    StateNotifierProvider<CompassController, CompassState>((ref) {
  return CompassController();
});

class CompassController extends StateNotifier<CompassState> {
  static const String _keyHeadingType = 'compass_heading_type';
  static const String _keyQiblaMode = 'compass_qibla_mode';
  static const String _keyVastuMode = 'compass_vastu_mode';

  final AngleUnwrapper _unwrapper = AngleUnwrapper();
  final HapticThrottler _hapticThrottler = HapticThrottler();

  StreamSubscription? _compassSub;
  StreamSubscription? _accelerometerSub;
  StreamSubscription? _magnetometerSub;
  StreamSubscription? _positionSub;
  Timer? _celestialTimer;
  DateTime _lastTimestamp = DateTime.now();
  double _lastHeading = 0.0;
  double? _lastRawHeading;
  bool _lastQiblaAligned = false;
  bool _lastVastuAligned = false;
  DateTime? _lastFlutterCompassEventTime;
  double? _filteredAx;
  double? _filteredAy;
  double? _filteredAz;
  double? _filteredMx;
  double? _filteredMy;
  double? _filteredMz;
  double? _filteredPitch;
  double? _filteredRoll;
  double? _filteredEmf;

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
      final savedVastu = prefs.getBool(_keyVastuMode) ?? false;
      if (savedVastu) {
        state = state.copyWith(isVastuMode: true);
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

  /// Explicitly requests location permission and acquires an active GPS fix
  Future<bool> requestGpsPermissionAndFix() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        return false;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        await Geolocator.openAppSettings();
        return false;
      }
      if (permission == LocationPermission.denied) {
        return false;
      }

      state = state.copyWith(hasLocationPermission: true);
      _startGpsStream();

      // Quick last known position
      final lastPos = await Geolocator.getLastKnownPosition();
      if (lastPos != null) {
        _updatePosition(lastPos);
      }

      // High accuracy current position
      final currentPos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 8),
      );
      _updatePosition(currentPos);
      return true;
    } catch (_) {
      return state.latitude != null && state.longitude != null;
    }
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
    final dec = HeadingCalculator.calculateDeclination(
      pos.latitude,
      pos.longitude,
      altitudeMeters: pos.altitude,
      date: nowLocal,
    );

    state = state.copyWith(
      latitude: pos.latitude,
      longitude: pos.longitude,
      altitude: pos.altitude,
      locationAccuracy: pos.accuracy,
      hasLocationPermission: true,
      magneticDeclination: dec,
      qiblaBearing: qBearing,
      qiblaDistanceKm: qDist,
      sunAzimuth: sunAz,
      moonAzimuth: moonAz,
      sunriseTime: sunTimes.sunrise,
      sunsetTime: sunTimes.sunset,
    );

    // If currently in True North mode, update heading with the newly calculated declination
    if (state.headingType == HeadingType.trueNorth && _lastRawHeading != null) {
      _processHeading(_lastRawHeading!);
    }
  }

  void _onCompassEvent(CompassEvent event) {
    if (event.heading == null) return;
    _lastFlutterCompassEventTime = DateTime.now();
    _processHeading(event.heading!, accuracyVal: event.accuracy);
  }

  void _processHeading(double rawHeadingVal, {double? accuracyVal}) {
    _lastRawHeading = rawHeadingVal;
    final now = DateTime.now();
    final dt = now.difference(_lastTimestamp).inMilliseconds / 1000.0;
    _lastTimestamp = now;

    // Use magnetic heading by default, or true heading if requested and declination known
    double chosenHeading = rawHeadingVal;
    if (state.headingType == HeadingType.trueNorth && state.magneticDeclination != null) {
      chosenHeading = chosenHeading + state.magneticDeclination!;
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
      final effectiveTrueHeading = (state.headingType == HeadingType.trueNorth || state.magneticDeclination == null)
          ? rawHeading
          : ((rawHeading + state.magneticDeclination!) % 360.0 + 360.0) % 360.0;
      final isNowAligned = QiblaCalculator.isAligned(effectiveTrueHeading, state.qiblaBearing!);
      if (!_lastQiblaAligned && isNowAligned) {
        HapticFeedback.heavyImpact();
      }
      _lastQiblaAligned = isNowAligned;
    }

    // Vastu Room Target Alignment Haptic Pulse
    if (state.isVastuMode && state.activeVastuRoom != null) {
      final effectiveTrueHeading = (state.headingType == HeadingType.trueNorth || state.magneticDeclination == null)
          ? rawHeading
          : ((rawHeading + state.magneticDeclination!) % 360.0 + 360.0) % 360.0;
      final isNowAligned = VastuCalculator.isAlignedWithRoom(effectiveTrueHeading, state.activeVastuRoom!);
      if (!_lastVastuAligned && isNowAligned) {
        HapticFeedback.mediumImpact();
      }
      _lastVastuAligned = isNowAligned;
    }

    final accuracy = accuracyVal != null ? _mapAccuracy(accuracyVal) : state.accuracy;

    state = state.copyWith(
      heading: rawHeading,
      unwrappedHeading: unwrapped,
      accuracy: accuracy,
      trueHeading: state.magneticDeclination != null
          ? ((rawHeadingVal + state.magneticDeclination!) % 360.0 + 360.0) % 360.0
          : null,
    );
  }

  void _onAccelerometerEvent(AccelerometerEvent event) {
    if (_filteredAx == null) {
      _filteredAx = event.x;
      _filteredAy = event.y;
      _filteredAz = event.z;
    } else {
      _filteredAx = (_filteredAx! * 0.82) + (event.x * 0.18);
      _filteredAy = (_filteredAy! * 0.82) + (event.y * 0.18);
      _filteredAz = (_filteredAz! * 0.82) + (event.z * 0.18);
    }

    final tilt = TiltCalculator.fromAccelerometer(event.x, event.y, event.z);

    // 1. Exponential Moving Average (EMA) Low-Pass Filter
    if (_filteredPitch == null || _filteredRoll == null) {
      _filteredPitch = tilt.pitch;
      _filteredRoll = tilt.roll;
    } else {
      // 0.88 previous + 0.12 new: smooths out MEMS Brownian thermal noise & desk vibrations
      _filteredPitch = (_filteredPitch! * 0.88) + (tilt.pitch * 0.12);
      _filteredRoll = (_filteredRoll! * 0.88) + (tilt.roll * 0.12);
    }

    // 2. Deadband threshold (hysteresis):
    // Ignore micro-vibrations under ±0.25° to keep the display rock-solid on a table
    double displayPitch = state.pitch;
    double displayRoll = state.roll;

    if ((_filteredPitch! - state.pitch).abs() > 0.25) {
      if (_filteredPitch!.abs() < 0.2) {
        displayPitch = 0.0;
      } else {
        displayPitch = ((_filteredPitch! * 10).round()) / 10.0;
      }
    }

    if ((_filteredRoll! - state.roll).abs() > 0.25) {
      if (_filteredRoll!.abs() < 0.2) {
        displayRoll = 0.0;
      } else {
        displayRoll = ((_filteredRoll! * 10).round()) / 10.0;
      }
    }

    final isLevel = (displayPitch.abs() <= CompassConstants.levelToleranceDegrees) &&
                    (displayRoll.abs() <= CompassConstants.levelToleranceDegrees);

    state = state.copyWith(
      pitch: displayPitch,
      roll: displayRoll,
      isLevel: isLevel,
    );
  }

  void _onMagnetometerEvent(MagnetometerEvent event) {
    final rawMag = math.sqrt(event.x * event.x + event.y * event.y + event.z * event.z);

    if (_filteredMx == null) {
      _filteredMx = event.x;
      _filteredMy = event.y;
      _filteredMz = event.z;
    } else {
      _filteredMx = (_filteredMx! * 0.82) + (event.x * 0.18);
      _filteredMy = (_filteredMy! * 0.82) + (event.y * 0.18);
      _filteredMz = (_filteredMz! * 0.82) + (event.z * 0.18);
    }

    // 1. Exponential Moving Average Low-Pass Filter
    if (_filteredEmf == null) {
      _filteredEmf = rawMag;
    } else {
      // 0.90 previous + 0.10 new: smooths 50/60Hz AC ambient noise & internal battery drift
      _filteredEmf = (_filteredEmf! * 0.90) + (rawMag * 0.10);
    }

    // 2. Deadband threshold:
    // If the ambient field changes by less than 0.35 μT, hold steady to prevent decimal jitter
    final currentVal = state.magneticFieldStrength ?? _filteredEmf!;
    double displayEmf = currentVal;
    if ((_filteredEmf! - currentVal).abs() > 0.35) {
      displayEmf = ((_filteredEmf! * 10).round()) / 10.0;
    }

    state = state.copyWith(magneticFieldStrength: displayEmf);

    // DUAL-ENGINE SENSOR FUSION FALLBACK:
    // When FlutterCompass does not emit valid non-null headings (common on OEM ROMs),
    // compute real-time tilt-compensated azimuth from raw accelerometer + magnetometer.
    final now = DateTime.now();
    final bool flutterCompassStale = _lastFlutterCompassEventTime == null ||
        now.difference(_lastFlutterCompassEventTime!).inMilliseconds > 1200;

    if (flutterCompassStale && _filteredAx != null) {
      final fusionHeading = HeadingCalculator.calculateAzimuth(
        ax: _filteredAx!,
        ay: _filteredAy!,
        az: _filteredAz!,
        mx: _filteredMx!,
        my: _filteredMy!,
        mz: _filteredMz!,
      );
      _processHeading(fusionHeading);
    }
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
      }
      if (permission == LocationPermission.deniedForever) {
        await Geolocator.openAppSettings();
        return false;
      }
      if (permission == LocationPermission.denied) {
        return false;
      }

      state = state.copyWith(
        headingType: HeadingType.trueNorth,
        hasLocationPermission: true,
      );

      // 1. Immediately retrieve cached last known position for instant declination
      try {
        final lastPos = await Geolocator.getLastKnownPosition();
        if (lastPos != null) {
          _updatePosition(lastPos);
        }
      } catch (_) {}

      // 2. Start GPS stream for real-time positional updates
      _startGpsStream();

      // 3. Immediately re-process heading so dialer updates right away without waiting
      if (_lastRawHeading != null) {
        _processHeading(_lastRawHeading!);
      }

      // 4. In background, request fresh GPS fix
      Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 6),
      ).then((pos) {
        _updatePosition(pos);
      }).catchError((_) {});

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

      // Immediately re-process heading so dialer smoothly animates back to Magnetic North
      if (_lastRawHeading != null) {
        _processHeading(_lastRawHeading!);
      }

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

  Future<bool> toggleVastuMode() async {
    final newMode = !state.isVastuMode;
    state = state.copyWith(
      isVastuMode: newMode,
      // Deactivate Qibla if Vastu is turned on to avoid HUD conflicts
      isQiblaMode: newMode ? false : state.isQiblaMode,
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyVastuMode, newMode);
      if (newMode) {
        await prefs.setBool(_keyQiblaMode, false);
      }
    } catch (_) {}

    return newMode;
  }

  void setActiveVastuRoom(VastuRoomType? room) {
    if (room == null) {
      state = state.copyWith(clearVastuRoom: true);
    } else {
      state = state.copyWith(activeVastuRoom: room);
    }
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
