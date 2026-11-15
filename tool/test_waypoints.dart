import '../lib/features/waypoints/domain/waypoint.dart';

void main() {
  print('Testing Waypoint domain logic...');

  // From Times Square (40.7580, -73.9855) to Empire State Building (40.7484, -73.9857)
  // Distance is ~1.07 km almost due South (~180°)
  final wp = Waypoint(
    id: 'esb_1',
    title: 'Empire State',
    latitude: 40.7484,
    longitude: -73.9857,
    createdAt: DateTime.now(),
  );

  final dist = wp.distanceFromMeters(40.7580, -73.9855);
  final bearing = wp.bearingFrom(40.7580, -73.9855);
  final formatted = wp.formattedDistanceFrom(40.7580, -73.9855);

  print('Distance: ${dist.round()}m, Formatted: $formatted');
  print('Bearing: ${bearing.round()}°');

  assert(dist > 1000 && dist < 1200, 'Distance should be ~1070m');
  assert(bearing > 175 && bearing < 185, 'Bearing should be ~180° (South)');

  // JSON test
  final json = wp.toJson();
  final reconstructed = Waypoint.fromJson(json);
  assert(reconstructed.id == wp.id);
  assert(reconstructed.title == wp.title);
  assert(reconstructed.latitude == wp.latitude);
  assert(reconstructed.longitude == wp.longitude);

  print('Waypoint tests passed successfully!');
}
