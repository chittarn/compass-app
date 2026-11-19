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
/// Enforces genuine Google Play purchase verification with isolated in-memory debug testing.
class ProController extends StateNotifier<ProState> {
  // Entitlement storage keys
  static const String keyLegacyIsPro = 'compass_is_pro';
  static const String keyProEntitlementCacheV2 =
      'compass_pro_entitlement_cache_v2';
  static const String keyEntitlementSchemaVersion =
      'compass_entitlement_schema_version';
  static const int currentSchemaVersion = 2;

  // Preferences keys
  static const String _keyNightVision = 'compass_night_vision';
  static const String _keyThemeMode = 'compass_theme_mode';

  final BillingService _billingService;
  bool _isGenuinePro = false;
  bool _debugProOverride = false;

  int _lastDriftStep = 0;
  DateTime _lastDriftHapticTime = DateTime.fromMillisecondsSinceEpoch(0);

  ProController({BillingService? billingService})
    : _billingService = billingService ?? BillingService(),
      super(const ProState(isBillingLoading: true)) {
    _init();
  }

  /// Evaluates effective Pro status: genuine verified purchase or debug in-memory override.
  bool get isEffectivePro => _isGenuinePro || (kDebugMode && _debugProOverride);

  /// Initializes entitlement migration and Google Play billing in deterministic order.
  Future<void> _init() async {
    await _migrateAndLoadPreferences();
    _initBilling();
  }

  /// Migrates legacy test entitlements safely and loads new-schema confirmed cache.
  Future<void> _migrateAndLoadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 1. Check schema version for entitlement migration
      final schemaVersion = prefs.getInt(keyEntitlementSchemaVersion) ?? 0;
      if (schemaVersion < currentSchemaVersion) {
        // Legacy schema detected: DO NOT trust legacy test switch compass_is_pro
        await prefs.remove(keyLegacyIsPro);
        // Initialize v2 entitlement cache as false (Free)
        await prefs.setBool(keyProEntitlementCacheV2, false);
        // Mark migration as completed so it never repeats on subsequent launches
        await prefs.setInt(keyEntitlementSchemaVersion, currentSchemaVersion);
      }

      // 2. Read only valid new-schema confirmed entitlement cache
      _isGenuinePro = prefs.getBool(keyProEntitlementCacheV2) ?? false;

      // 3. Read other preferences without resetting them
      final isNightVision = prefs.getBool(_keyNightVision) ?? false;
      final themeIndex = prefs.getInt(_keyThemeMode) ?? 0;
      final themeMode =
          (themeIndex >= 0 && themeIndex < AppThemeMode.values.length)
          ? AppThemeMode.values[themeIndex]
          : AppThemeMode.tacticalDark;

      if (!mounted) return;
      state = state.copyWith(
        isPro: isEffectivePro,
        isNightVision: isEffectivePro ? isNightVision : false,
        themeMode: isEffectivePro ? themeMode : AppThemeMode.tacticalDark,
      );
    } catch (_) {
      // Graceful degradation in mock / testing environments
    }
  }

  /// Subscribes to BillingService events and registers callbacks.
  void _initBilling() {
    _billingService.initialize(
      onEntitlementChanged: (isPurchased) {
        _onGenuinePurchaseConfirmed(isPurchased);
      },
      onPriceLoaded: (price) {
        if (!mounted) return;
        state = state.copyWith(
          productPrice: price,
          isBillingLoading: false,
          isStoreUnavailable: false,
          isProductNotFound: false,
        );
      },
      onLoadingChanged: (isLoading) {
        if (!mounted) return;
        state = state.copyWith(isBillingLoading: isLoading);
      },
      onStoreUnavailable: (isUnavailable) {
        if (!mounted) return;
        state = state.copyWith(
          isStoreUnavailable: isUnavailable,
          isBillingLoading: false,
        );
      },
      onProductNotFound: (isNotFound) {
        if (!mounted) return;
        state = state.copyWith(
          isProductNotFound: isNotFound,
          isBillingLoading: false,
        );
      },
      onPendingChanged: (isPending) {
        if (!mounted) return;
        state = state.copyWith(isPurchasePending: isPending);
      },
      onError: (error) {
        if (!mounted) return;
        state = state.copyWith(
          billingErrorMessage: error,
          isBillingLoading: false,
        );
      },
    );
  }

  /// Handles store-verified purchase/restore events. Updates genuine Pro cache.
  Future<void> _onGenuinePurchaseConfirmed(bool isPurchased) async {
    _isGenuinePro = isPurchased;
    if (!mounted) return;
    state = state.copyWith(
      isPro: isEffectivePro,
      isNightVision: isEffectivePro ? state.isNightVision : false,
      themeMode: isEffectivePro ? state.themeMode : AppThemeMode.tacticalDark,
      isPurchasePending: false,
    );
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(keyProEntitlementCacheV2, isPurchased);
    } catch (_) {}
  }

  /// Initiates purchase of the lifetime Pro license via Google Play.
  Future<bool> buyProLifetime() async {
    return await _billingService.buyProLifetime();
  }

  /// Restores previous Google Play purchases across devices.
  Future<void> restorePurchases() async {
    await _billingService.restorePurchases();
  }

  /// Retries querying product details from Google Play.
  Future<void> retryProductQuery() async {
    clearBillingError();
    state = state.copyWith(
      isBillingLoading: true,
      isStoreUnavailable: false,
      isProductNotFound: false,
    );
    await _billingService.retryProductQuery();
  }

  /// Clears active billing error message.
  void clearBillingError() {
    state = state.copyWith(clearBillingError: true);
  }

  /// In-memory developer toggle for testing Pro UI/features in debug builds.
  /// Strictly disabled in release builds. Does NOT write to persistent storage or fake purchases.
  void debugTogglePro() {
    if (!kDebugMode) return;
    HapticFeedback.mediumImpact();
    _debugProOverride = !_debugProOverride;
    state = state.copyWith(
      isPro: isEffectivePro,
      isNightVision: isEffectivePro ? state.isNightVision : false,
      themeMode: isEffectivePro ? state.themeMode : AppThemeMode.tacticalDark,
    );
  }

  /// Sets in-memory debug Pro override. For automated testing and QA fixtures only.
  @visibleForTesting
  void debugSetPro(bool value) {
    if (kDebugMode) {
      _debugProOverride = value;
      state = state.copyWith(
        isPro: isEffectivePro,
        isNightVision: isEffectivePro ? state.isNightVision : false,
        themeMode: isEffectivePro ? state.themeMode : AppThemeMode.tacticalDark,
      );
    }
  }

  /// Sets genuine Pro entitlement for testing verified billing callbacks.
  @visibleForTesting
  Future<void> setEntitledForTesting(bool value) async {
    await _onGenuinePurchaseConfirmed(value);
  }

  /// Backward-compatible test helper for bearing lock unit tests.
  @visibleForTesting
  Future<void> setEntitled(bool isEntitled) async {
    await setEntitledForTesting(isEntitled);
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
