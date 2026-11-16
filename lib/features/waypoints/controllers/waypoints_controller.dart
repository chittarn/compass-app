import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/waypoint.dart';
import '../domain/waypoints_state.dart';

final waypointsControllerProvider =
    StateNotifierProvider<WaypointsController, WaypointsState>((ref) {
  return WaypointsController();
});

class WaypointsController extends StateNotifier<WaypointsState> {
  static const String _keyWaypoints = 'compass_saved_waypoints';
  static const String _keyActive = 'compass_active_waypoint';
  static const int freeWaypointLimit = 5;

  WaypointsController() : super(const WaypointsState()) {
    _loadFromPrefs();
  }

  bool canAddWaypoint(bool isPro) {
    if (isPro) return true;
    return state.waypoints.length < freeWaypointLimit;
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawJson = prefs.getString(_keyWaypoints);
      final activeId = prefs.getString(_keyActive);

      List<Waypoint> loaded = [];
      if (rawJson != null) {
        final decoded = jsonDecode(rawJson) as List;
        loaded = decoded
            .map((item) => Waypoint.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      state = state.copyWith(
        waypoints: loaded,
        activeWaypointId: activeId,
      );
    } catch (_) {}
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(state.waypoints.map((w) => w.toJson()).toList());
      await prefs.setString(_keyWaypoints, encoded);

      if (state.activeWaypointId != null) {
        await prefs.setString(_keyActive, state.activeWaypointId!);
      } else {
        await prefs.remove(_keyActive);
      }
    } catch (_) {}
  }

  Future<Waypoint?> saveCurrentSpot({
    required String title,
    required double latitude,
    required double longitude,
    double? altitude,
    WaypointCategory category = WaypointCategory.custom,
    String? notes,
    bool isPro = false,
  }) async {
    if (!isPro && state.waypoints.length >= freeWaypointLimit) {
      return null;
    }

    final newId = DateTime.now().millisecondsSinceEpoch.toString();
    final newWaypoint = Waypoint(
      id: newId,
      title: title.isEmpty ? 'Marked Spot' : title,
      latitude: latitude,
      longitude: longitude,
      altitude: altitude,
      createdAt: DateTime.now(),
      category: category,
      notes: notes?.trim().isEmpty == true ? null : notes?.trim(),
    );

    final updated = [...state.waypoints, newWaypoint];

    state = state.copyWith(
      waypoints: updated,
      activeWaypointId: newId,
    );
    await _persist();
    return newWaypoint;
  }

  Future<void> updateWaypoint({
    required String id,
    String? title,
    WaypointCategory? category,
    String? notes,
  }) async {
    final updated = state.waypoints.map((w) {
      if (w.id == id) {
        return w.copyWith(
          title: title,
          category: category,
          notes: notes,
        );
      }
      return w;
    }).toList();
    state = state.copyWith(waypoints: updated);
    await _persist();
  }

  Future<void> setActive(String? id) async {
    state = state.copyWith(activeWaypointId: id, clearActive: id == null);
    await _persist();
  }

  Future<void> deleteWaypoint(String id) async {
    final updated = state.waypoints.where((w) => w.id != id).toList();
    final clearActive = state.activeWaypointId == id;
    state = state.copyWith(
      waypoints: updated,
      clearActive: clearActive,
      activeWaypointId: clearActive ? null : state.activeWaypointId,
    );
    await _persist();
  }

  Future<void> clearActive() async {
    state = state.copyWith(clearActive: true);
    await _persist();
  }
}
