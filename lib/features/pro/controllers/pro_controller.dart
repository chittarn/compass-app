import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/pro_state.dart';

final proControllerProvider =
    StateNotifierProvider<ProController, ProState>((ref) {
  return ProController();
});

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

  Future<void> togglePro() async {
    HapticFeedback.mediumImpact();
    final newPro = !state.isPro;
    state = state.copyWith(isPro: newPro);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyIsPro, newPro);
    } catch (_) {}
  }

  Future<void> setPro(bool value) async {
    state = state.copyWith(isPro: value);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyIsPro, value);
    } catch (_) {}
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
