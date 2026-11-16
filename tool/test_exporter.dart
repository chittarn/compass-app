import '../lib/core/utils/waypoint_exporter.dart';
import '../lib/features/waypoints/domain/waypoint.dart';

void main() {
  print('=== TESTING WAYPOINT EXPORTER (GPX & CSV) ===\n');

  final sampleWaypoints = [
    Waypoint(
      id: '1',
      title: 'Base Camp & Tent',
      latitude: 27.988056,
      longitude: 86.925278,
      altitude: 5364.0,
      createdAt: DateTime.utc(2026, 11, 16, 12, 0, 0),
      category: WaypointCategory.travel,
      notes: 'South Col Route departure point <danger zone>',
    ),
    Waypoint(
      id: '2',
      title: 'Home Office "HQ"',
      latitude: 37.774929,
      longitude: -122.419416,
      altitude: 15.0,
      createdAt: DateTime.utc(2026, 11, 15, 8, 30, 0),
      category: WaypointCategory.home,
      notes: 'Garage door entry, PIN #4921',
    ),
  ];

  // 1. Verify GPX Export
  final gpx = WaypointExporter.toGpx(sampleWaypoints);
  assert(gpx.contains('<?xml version="1.0" encoding="UTF-8"?>'), 'GPX must have XML declaration');
  assert(gpx.contains('<gpx version="1.1"'), 'GPX must have 1.1 version tag');
  assert(gpx.contains('<wpt lat="27.9880560" lon="86.9252780">'), 'GPX must contain waypoint coordinates');
  assert(gpx.contains('<name>Base Camp &amp; Tent</name>'), 'GPX must escape XML entities like &');
  assert(gpx.contains('&lt;danger zone&gt;'), 'GPX must escape XML entities like < and >');
  assert(gpx.contains('<ele>5364.0</ele>'), 'GPX must include elevation');
  assert(gpx.contains('<sym>travel</sym>'), 'GPX must include category symbol');
  print('  [PASS] GPX 1.1 format verified with valid XML escaping and metadata!');

  // 2. Verify CSV Export
  final csv = WaypointExporter.toCsv(sampleWaypoints);
  assert(csv.startsWith('Name,Category,Latitude,Longitude,Elevation_m,Notes,Created_At_UTC'), 'CSV header mismatch');
  assert(csv.contains('"Base Camp & Tent",Travel,27.9880560,86.9252780,5364.0,"South Col Route departure point <danger zone>"'), 'CSV row 1 format');
  assert(csv.contains('"Home Office ""HQ""",Home,37.7749290,-122.4194160,15.0,"Garage door entry, PIN #4921"'), 'CSV row 2 quotes escaping');
  print('  [PASS] CSV format verified with proper quotes escaping and commas!');

  print('\n=== ALL EXPORTER TESTS PASSED (100%) ===');
}
