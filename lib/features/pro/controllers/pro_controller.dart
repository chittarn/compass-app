import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_colors.dart';
import '../../compass/domain/heading_type.dart';
import '../domain/pro_state.dart';
import '../services/billing_service.dart';

final proControllerProvider = StateNotifierProvider<ProController, ProState>((
  ref,
) {
  return ProController();
});

/// ProController manages the user's lifetime Pro entitlement status and Pro-tier tools.
/// Prepared for Google Play Billing in-app purchase integration.
class ProController extends StateNotifier<ProState> {
  static const String _keyIsPro = 'compass_is_pro';
  static const String _keyNightVision = 'compass_night_vision';
  static const String _keyThemeMode = 'compass_theme_mode';

  final BillingService _billingService;
  int _lastDriftStep = 0;
  DateTime _lastDriftHapticTime = DateTime.fromMillisecondsSinceEpoch(0);

  ProController({BillingService? billingService})
    : _billingService = billingService ?? BillingService(),
      super(const ProState()) {
    _loadPreferences();
    _initBilling();
  }

  void _initBilling() {
    _billingService.initialize(
      onEntitlementChanged: (isPro) {
        setEntitled(isPro);
      },
      onPriceLoaded: (price) {
        state = state.copyWith(productPrice: price);
      },
      onPendingChanged: (isPending) {
        state = state.copyWith(isPurchasePending: isPending);
      },
      onError: (error) {
        state = state.copyWith(billingErrorMessage: error);
      },
    );
  }

  Future<bool> buyProLifetime() async {
    return await _billingService.buyProLifetime();
  }

  Future<void> restorePurchases() async {
    await _billingService.restorePurchases();
  }

  void clearBillingError() {
    state = state.copyWith(clearBillingError: true);
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isPro = prefs.getBool(_keyIsPro) ?? false;
      final isNightVision = prefs.getBool(_keyNightVision) ?? false;
      final themeIndex = prefs.getInt(_keyThemeMode) ?? 0;
      final themeMode =
          (themeIndex >= 0 && themeIndex < AppThemeMode.values.length)
          ? AppThemeMode.values[themeIndex]
          : AppThemeMode.tacticalDark;

      state = state.copyWith(
        isPro: isPro,
        isNightVision: isPro ? isNightVision : false,
        themeMode: isPro ? themeMode : AppThemeMode.tacticalDark,
      );
    } catch (_) {
      // In testing environments where SharedPreferences platform channel is uninitialized
    }
  }

  /// Sets the user's Pro entitlement (to be called by Google Play Billing on verified purchase / restore)
  Future<void> setEntitled(bool isEntitled) async {
    state = state.copyWith(
      isPro: isEntitled,
      isNightVision: isEntitled ? state.isNightVision : false,
      themeMode: isEntitled ? state.themeMode : AppThemeMode.tacticalDark,
    );
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyIsPro, isEntitled);
    } catch (_) {}
  }

  /// Legacy helper for testing or billing callbacks
  Future<void> setPro(bool value) async {
    await setEntitled(value);
  }

  /// Development-only Pro toggle. Strictly disabled in release builds.
  Future<void> debugTogglePro() async {
    if (!kDebugMode) return;
    HapticFeedback.mediumImpact();
    final newPro = !state.isPro;
    await setEntitled(newPro);
  }

  /// Backward-compatible alias for development testing; disabled in release builds.
  Future<void> toggleProMode() async {
    if (!kDebugMode) return;
    await debugTogglePro();
  }

  /// Wrapper around debugTogglePro to preserve backwards compatibility in debug mode
  Future<void> togglePro() async {
    if (!kDebugMode) return;
    await debugTogglePro();
  }

  Future<void> toggleNightVision() async {
    if (!state.isPro) return;
    HapticFeedback.heavyImpact();
    final newNight = !state.isNightVision;
    state = state.copyWith(
      isNightVision: newNight,
      themeMode: newNight
          ? AppThemeMode.nightVision
          : AppThemeMode.tacticalDark,
    );
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyNightVision, newNight);
      await prefs.setInt(_keyThemeMode, state.themeMode.index);
    } catch (_) {}
  }

  Future<bool> setTheme(AppThemeMode mode) async {
    if (!state.isPro && mode != AppThemeMode.tacticalDark) {
      return false;
    }
    HapticFeedback.selectionClick();
    final isNight = mode == AppThemeMode.nightVision;
    state = state.copyWith(themeMode: mode, isNightVision: isNight);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyThemeMode, mode.index);
      await prefs.setBool(_keyNightVision, isNight);
    } catch (_) {}
    return true;
  }

  void lockBearing(
    double currentHeading, {
    HeadingType headingType = HeadingType.magnetic,
    double? declination,
  }) {
    if (!state.isPro) return;
    HapticFeedback.selectionClick();
    _lastDriftStep = 0;
    _lastDriftHapticTime = DateTime.fromMillisecondsSinceEpoch(0);

    // Compute and store underlying invariant physical magnetic heading
    double magBearing = currentHeading;
    if (headingType == HeadingType.trueNorth && declination != null) {
      magBearing = (currentHeading - declination) % 360.0;
      if (magBearing < 0) magBearing += 360.0;
    }

    state = state.copyWith(
      lockedMagneticBearing: magBearing,
      lockedBearing: currentHeading,
    );
  }

  void clearLockedBearing() {
    HapticFeedback.selectionClick();
    _lastDriftStep = 0;
    _lastDriftHapticTime = DateTime.fromMillisecondsSinceEpoch(0);
    state = state.copyWith(clearBearing: true);
  }

  /// Updates the displayed locked bearing when switching between Magnetic and True North
  /// or when GPS acquires / updates declination.
  /// Prevents missing, duplicated or repeated bearing adjustments.
  void updateReferenceFrame({
    required HeadingType headingType,
    double? declination,
  }) {
    if (!state.isPro || state.lockedMagneticBearing == null) return;
    double effective;
    if (headingType == HeadingType.trueNorth && declination != null) {
      effective = (state.lockedMagneticBearing! + declination) % 360.0;
      if (effective < 0) effective += 360.0;
    } else {
      effective = state.lockedMagneticBearing!;
    }
    state = state.copyWith(lockedBearing: effective);
  }

  /// Adjusts the locked bearing by [deltaDegrees] when switching between Magnetic and True North
  /// so that the locked physical course remains identical in the real world.
  void adjustLockedBearing(double deltaDegrees) {
    if (!state.isPro || state.lockedBearing == null) return;
    final adjusted = (state.lockedBearing! + deltaDegrees) % 360.0;
    state = state.copyWith(lockedBearing: (adjusted + 360.0) % 360.0);
  }

  /// Evaluates bearing drift angle and triggers directional haptics when crossing drift thresholds.
  /// Throttled to prevent rapid vibration spam on jittery sensors.
  void evaluateDriftHaptics(double driftAngle, {DateTime? now}) {
    if (!state.isPro || state.lockedBearing == null) return;

    final currentTime = now ?? DateTime.now();
    final int currentStep = (driftAngle.abs() / 10.0).floor();

    // If back on-course (< 10° drift) after being off-course:
    if (currentStep == 0) {
      if (_lastDriftStep > 0) {
        if (currentTime.difference(_lastDriftHapticTime).inMilliseconds >=
            400) {
          HapticFeedback.selectionClick();
          _lastDriftHapticTime = currentTime;
        }
        _lastDriftStep = 0;
      }
      return;
    }

    // Off-course threshold transition (e.g. 10°, 20°, 30°)
    if (currentStep != _lastDriftStep) {
      if (currentTime.difference(_lastDriftHapticTime).inMilliseconds >= 400) {
        if (currentStep > _lastDriftStep) {
          // Drifting further off-course: warning haptic
          HapticFeedback.lightImpact();
        } else {
          // Correcting back towards course: subtle tick
          HapticFeedback.selectionClick();
        }
        _lastDriftHapticTime = currentTime;
      }
      _lastDriftStep = currentStep;
    }
  }

  void setWaypoint(double lat, double lng, String label) {
    if (!state.isPro) return;
    HapticFeedback.mediumImpact();
    state = state.copyWith(
      waypointLat: lat,
      waypointLng: lng,
      waypointLabel: label,
    );
  }

  void clearWaypoint() {
    HapticFeedback.selectionClick();
    state = state.copyWith(clearWaypoint: true);
  }

  @override
  void dispose() {
    _billingService.dispose();
    super.dispose();
  }
}
