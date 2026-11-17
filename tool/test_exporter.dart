import '../lib/core/utils/waypoint_exporter.dart';
import '../lib/features/waypoints/domain/waypoint.dart';

void main() {
  print('=== TESTING WAYPOINT EXPORTER HARDENING (GPX & CSV) ===\n');

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
      title: '=cmd|\'/C calc\'!A0',
      latitude: 37.774929,
      longitude: -122.419416,
      altitude: 15.0,
      createdAt: DateTime.utc(2026, 11, 15, 8, 30, 0),
      category: WaypointCategory.home,
      notes: '+44 123 4567 "Garage entry"',
    ),
  ];

  // 1. GPX Test
  final gpx = WaypointExporter.toGpx(sampleWaypoints);
  assert(
    gpx.contains('<?xml version="1.0" encoding="UTF-8"?>'),
    'Must contain XML declaration',
  );
  assert(gpx.contains('<gpx version="1.1"'), 'Must contain GPX 1.1 root');
  assert(
    gpx.contains('<name>Base Camp &amp; Tent</name>'),
    'Must escape ampersand',
  );
  assert(gpx.contains('&lt;danger zone&gt;'), 'Must escape angle brackets');
  assert(!gpx.contains('<danger zone>'), 'Must not contain unescaped XML');
  print('  [PASS] GPX 1.1 XML structure and entity escaping validated!');

  // 2. CSV Test with CWE-1236 Formula Injection Hardening
  final csv = WaypointExporter.toCsv(sampleWaypoints);
  assert(csv.contains('\'=cmd|'), 'Must neutralize = formula injection');
  assert(csv.contains('\'+44 123'), 'Must neutralize + formula injection');
  assert(csv.contains('""Garage entry""'), 'Must escape quotes per RFC 4180');
  print('  [PASS] CSV format validated with formula injection mitigation!');

  print('\n=== ALL EXPORTER HARDENING CHECKS PASSED (100%) ===');
}
