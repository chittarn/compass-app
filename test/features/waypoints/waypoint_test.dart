import 'package:flutter_test/flutter_test.dart';
import 'package:compass_app/features/waypoints/domain/waypoint.dart';

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

    group('Relative Steering & North Reference Scenarios', () {
      // Waypoint directly North (0°) of user
      final northWp = Waypoint(
        id: 'north_wp',
        title: 'North Point',
        latitude: 1.0,
        longitude: 0.0,
        createdAt: DateTime.now(),
      );

      // Waypoint directly East (90°) of user
      final eastWp = Waypoint(
        id: 'east_wp',
        title: 'East Point',
        latitude: 0.0,
        longitude: 1.0,
        createdAt: DateTime.now(),
      );

      test('Directly ahead: target 0°, heading 0° -> relBearing = 0°', () {
        final rel = northWp.relativeBearingFrom(0.0, 0.0, 0.0);
        expect(rel.abs(), lessThan(0.5));
      });

      test('Directly behind: target 0°, heading 180° -> relBearing = ±180°', () {
        final rel = northWp.relativeBearingFrom(0.0, 0.0, 180.0);
        expect(rel.abs(), closeTo(180.0, 0.5));
      });

      test('Target to the right: target 90° (East), heading 0° (North) -> relBearing = +90°', () {
        final rel = eastWp.relativeBearingFrom(0.0, 0.0, 0.0);
        expect(rel, closeTo(90.0, 0.5)); // Positive = Steer Right
      });

      test('Target to the left: target 0° (North), heading 90° (East) -> relBearing = -90°', () {
        final rel = northWp.relativeBearingFrom(0.0, 0.0, 90.0);
        expect(rel, closeTo(-90.0, 0.5)); // Negative = Steer Left
      });

      test('Wraparound: target 10°, heading 350° -> relBearing = +20° (Steer Right)', () {
        // Point at lat 1.0, bearing ~10°
        final wp = Waypoint(
          id: 'wrap_wp',
          title: 'Wrap Point',
          latitude: 1.0,
          longitude: 0.1763, // approx 10° bearing
          createdAt: DateTime.now(),
        );
        final targetBearing = wp.bearingFrom(0.0, 0.0);
        expect(targetBearing, closeTo(10.0, 0.5));

        final rel = wp.relativeBearingFrom(0.0, 0.0, 350.0);
        expect(rel, closeTo(20.0, 0.5));
      });

      test('Wraparound: target 350°, heading 10° -> relBearing = -20° (Steer Left)', () {
        final wp = Waypoint(
          id: 'wrap_wp2',
          title: 'Wrap Point 2',
          latitude: 1.0,
          longitude: -0.1763, // approx 350° bearing
          createdAt: DateTime.now(),
        );
        final targetBearing = wp.bearingFrom(0.0, 0.0);
        expect(targetBearing, closeTo(350.0, 0.5));

        final rel = wp.relativeBearingFrom(0.0, 0.0, 10.0);
        expect(rel, closeTo(-20.0, 0.5));
      });
    });

    group('Arrival Detection & GPS Accuracy & Hysteresis', () {
      // Waypoint placed approx 20 meters away
      // 1 deg lat is ~111,000 m, so 20 m is ~0.00018 deg
      final nearWp = Waypoint(
        id: 'near_wp',
        title: 'Near Point',
        latitude: 0.00018, // ~20.0m North
        longitude: 0.0,
        createdAt: DateTime.now(),
      );

      test('Arrived when distance <= 25m and GPS accuracy is good', () {
        final arrived = nearWp.isArrived(
          0.0,
          0.0,
          locationAccuracyMeters: 8.0,
          arrivalRadiusMeters: 25.0,
        );
        expect(arrived, isTrue);
      });

      test('Not arrived when distance > 25m', () {
        final farWp = Waypoint(
          id: 'far_wp',
          title: 'Far Point',
          latitude: 0.00045, // ~50m
          longitude: 0.0,
          createdAt: DateTime.now(),
        );
        final arrived = farWp.isArrived(
          0.0,
          0.0,
          locationAccuracyMeters: 8.0,
          arrivalRadiusMeters: 25.0,
        );
        expect(arrived, isFalse);
      });

      test('Suppresses false arrival when GPS accuracy is poor (> 40m uncertainty)', () {
        final arrived = nearWp.isArrived(
          0.0,
          0.0,
          locationAccuracyMeters: 65.0, // High GPS jitter / uncertainty
          arrivalRadiusMeters: 25.0,
          maxPermissibleAccuracyMeters: 40.0,
        );
        expect(arrived, isFalse, reason: 'Poor GPS accuracy must suppress false arrival');
      });

      test('Hysteresis prevents flickering: remains arrived between 25m and 35m', () {
        // Point at 30 meters distance (between entry 25m and exit 35m)
        final boundaryWp = Waypoint(
          id: 'boundary_wp',
          title: 'Boundary Point',
          latitude: 0.00027, // ~30.0m
          longitude: 0.0,
          createdAt: DateTime.now(),
        );

        // Case A: Fresh approach from outside -> Not arrived (requires <= 25m)
        final freshApproach = boundaryWp.isArrived(
          0.0,
          0.0,
          locationAccuracyMeters: 5.0,
          arrivalRadiusMeters: 25.0,
          previouslyArrived: false,
          hysteresisMeters: 10.0,
        );
        expect(freshApproach, isFalse);

        // Case B: Already arrived user stepping back to 30m -> Stays arrived (within 25m + 10m hysteresis)
        final alreadyArrived = boundaryWp.isArrived(
          0.0,
          0.0,
          locationAccuracyMeters: 5.0,
          arrivalRadiusMeters: 25.0,
          previouslyArrived: true,
          hysteresisMeters: 10.0,
        );
        expect(alreadyArrived, isTrue, reason: 'Hysteresis prevents rapid on/off flickering at boundary');

        // Case C: User steps clearly beyond 35m (e.g. 40m) -> Exits arrived state
        final exitWp = Waypoint(
          id: 'exit_wp',
          title: 'Exit Point',
          latitude: 0.00036, // ~40.0m
          longitude: 0.0,
          createdAt: DateTime.now(),
        );
        final exited = exitWp.isArrived(
          0.0,
          0.0,
          locationAccuracyMeters: 5.0,
          arrivalRadiusMeters: 25.0,
          previouslyArrived: true,
          hysteresisMeters: 10.0,
        );
        expect(exited, isFalse, reason: 'Exits arrived status once beyond hysteresis threshold');
      });
    });

    group('Persistence & Backward Compatibility', () {
      test('Legacy JSON without category or notes parses cleanly with defaults', () {
        final legacyJson = {
          'id': 'legacy_101',
          'title': 'My Old Car Spot',
          'latitude': 37.7749,
          'longitude': -122.4194,
          'altitude': 15.0,
          'createdAt': '2025-10-01T10:00:00.000Z',
        };

        final wp = Waypoint.fromJson(legacyJson);
        expect(wp.id, 'legacy_101');
        expect(wp.title, 'My Old Car Spot');
        expect(wp.latitude, 37.7749);
        expect(wp.longitude, -122.4194);
        expect(wp.altitude, 15.0);
        expect(wp.category, WaypointCategory.custom, reason: 'Defaults to custom category');
        expect(wp.notes, isNull, reason: 'Defaults to null notes');
      });

      test('Modern JSON with category and notes serializes and deserializes losslessly', () {
        final wp = Waypoint(
          id: 'modern_202',
          title: 'Home Base',
          latitude: 28.6139,
          longitude: 77.2090,
          altitude: 216.5,
          createdAt: DateTime(2026, 11, 16, 22, 0),
          category: WaypointCategory.home,
          notes: 'Gate code #4491. Park near pillar B3.',
        );

        final jsonMap = wp.toJson();
        final restored = Waypoint.fromJson(jsonMap);

        expect(restored.id, wp.id);
        expect(restored.title, wp.title);
        expect(restored.category, WaypointCategory.home);
        expect(restored.notes, 'Gate code #4491. Park near pillar B3.');
      });

      test('Waypoint editing retains id and updates title, category, and notes', () {
        final original = Waypoint(
          id: 'edit_303',
          title: 'Camp Site',
          latitude: 34.0522,
          longitude: -118.2437,
          createdAt: DateTime.now(),
          category: WaypointCategory.travel,
          notes: 'Tent pitched near creek',
        );

        final updated = original.copyWith(
          title: 'Base Camp Alpha',
          category: WaypointCategory.work,
          notes: 'Emergency satellite comms tested',
        );

        expect(updated.id, original.id);
        expect(updated.title, 'Base Camp Alpha');
        expect(updated.category, WaypointCategory.work);
        expect(updated.notes, 'Emergency satellite comms tested');
      });
    });
  });
}
