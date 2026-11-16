import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/pro_state.dart';

final proControllerProvider =
    StateNotifierProvider<ProController, ProState>((ref) {
  return ProController();
});

/// ProController manages the user's lifetime Pro entitlement status and Pro-tier tools.
/// Prepared for Google Play Billing in-app purchase integration.
class ProController extends StateNotifier<ProState> {
  static const String _keyIsPro = 'compass_is_pro';
  static const String _keyNightVision = 'compass_night_vision';

  ProController() : super(const ProState()) {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isPro = prefs.getBool(_keyIsPro) ?? false;
      final isNightVision = prefs.getBool(_keyNightVision) ?? false;
      state = state.copyWith(
        isPro: isPro,
        isNightVision: isPro ? isNightVision : false,
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

  /// Wrapper around debugTogglePro to preserve backwards compatibility in debug mode
  Future<void> togglePro() async {
    await debugTogglePro();
  }

  Future<void> toggleNightVision() async {
    if (!state.isPro) return;
    HapticFeedback.heavyImpact();
    final newNight = !state.isNightVision;
    state = state.copyWith(isNightVision: newNight);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyNightVision, newNight);
    } catch (_) {}
  }

  void lockBearing(double currentHeading) {
    if (!state.isPro) return;
    HapticFeedback.selectionClick();
    state = state.copyWith(lockedBearing: currentHeading);
  }

  void clearLockedBearing() {
    HapticFeedback.selectionClick();
    state = state.copyWith(clearBearing: true);
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
}
