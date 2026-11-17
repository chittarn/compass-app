import 'waypoint.dart';

class WaypointsState {
  final List<Waypoint> waypoints;
  final String? activeWaypointId;

  const WaypointsState({this.waypoints = const [], this.activeWaypointId});

  Waypoint? get activeWaypoint {
    if (activeWaypointId == null) return null;
    try {
      return waypoints.firstWhere((w) => w.id == activeWaypointId);
    } catch (_) {
      return null;
    }
  }

  bool get hasActiveWaypoint => activeWaypoint != null;

  WaypointsState copyWith({
    List<Waypoint>? waypoints,
    String? activeWaypointId,
    bool clearActive = false,
  }) {
    return WaypointsState(
      waypoints: waypoints ?? this.waypoints,
      activeWaypointId: clearActive
          ? null
          : (activeWaypointId ?? this.activeWaypointId),
    );
  }
}
