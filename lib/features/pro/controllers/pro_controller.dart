import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/pro_state.dart';

final proControllerProvider =
    StateNotifierProvider<ProController, ProState>((ref) {
  return ProController();
});

class ProController extends StateNotifier<ProState> {
  ProController() : super(const ProState());

  void togglePro() {
    HapticFeedback.mediumImpact();
    state = state.copyWith(isPro: !state.isPro);
  }

  void setPro(bool value) {
    state = state.copyWith(isPro: value);
  }

  void toggleNightVision() {
    if (!state.isPro) return;
    HapticFeedback.heavyImpact();
    state = state.copyWith(isNightVision: !state.isNightVision);
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
