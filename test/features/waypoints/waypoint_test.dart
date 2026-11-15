import 'package:flutter_test/flutter_test.dart';
import 'package:compass_app/features/waypoints/domain/waypoint.dart';
import 'package:compass_app/features/waypoints/domain/waypoints_state.dart';

void main() {
  group('Waypoint & Backtracking Tests', () {
    test('Calculates distance and bearing from origin to destination', () {
      // From Times Square (40.7580, -73.9855) to Empire State Building (40.7484, -73.9857)
      final wp = Waypoint(
        id: 'esb_1',
        title: 'Empire State',
        latitude: 40.7484,
        longitude: -73.9857,
        createdAt: DateTime(2026, 11, 15),
      );

      final dist = wp.distanceFromMeters(40.7580, -73.9855);
      final bearing = wp.bearingFrom(40.7580, -73.9855);
      final formatted = wp.formattedDistanceFrom(40.7580, -73.9855);

      expect(dist, greaterThan(1000));
      expect(dist, lessThan(1200));
      expect(bearing, greaterThan(175));
      expect(bearing, lessThan(185));
      expect(formatted, '1.1 km');
    });

    test('Waypoint JSON serialization & deserialization', () {
      final wp = Waypoint(
        id: 'spot_123',
        title: 'Parked Spot',
        latitude: 37.7749,
        longitude: -122.4194,
        altitude: 50.0,
        createdAt: DateTime(2026, 11, 15, 12, 0),
      );

      final json = wp.toJson();
      final restored = Waypoint.fromJson(json);

      expect(restored.id, wp.id);
      expect(restored.title, wp.title);
      expect(restored.latitude, wp.latitude);
      expect(restored.longitude, wp.longitude);
      expect(restored.altitude, wp.altitude);
    });

    test('WaypointsState active waypoint selector', () {
      final wp1 = Waypoint(
        id: '1',
        title: 'Spot 1',
        latitude: 10,
        longitude: 10,
        createdAt: DateTime.now(),
      );
      final wp2 = Waypoint(
        id: '2',
        title: 'Spot 2',
        latitude: 20,
        longitude: 20,
        createdAt: DateTime.now(),
      );

      final state = WaypointsState(
        waypoints: [wp1, wp2],
        activeWaypointId: '2',
      );

      expect(state.hasActiveWaypoint, isTrue);
      expect(state.activeWaypoint?.title, 'Spot 2');

      final cleared = state.copyWith(clearActive: true);
      expect(cleared.hasActiveWaypoint, isFalse);
    });
  });
}
