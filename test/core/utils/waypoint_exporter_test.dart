import 'package:flutter_test/flutter_test.dart';
import 'package:compass_app/core/utils/waypoint_exporter.dart';
import 'package:compass_app/features/waypoints/domain/waypoint.dart';

void main() {
  group('WaypointExporter Tests', () {
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

    test('exports to standard GPX 1.1 format with XML escaping', () {
      final gpx = WaypointExporter.toGpx(sampleWaypoints);

      expect(gpx, contains('<?xml version="1.0" encoding="UTF-8"?>'));
      expect(gpx, contains('<gpx version="1.1"'));
      expect(gpx, contains('<wpt lat="27.9880560" lon="86.9252780">'));
      expect(gpx, contains('<name>Base Camp &amp; Tent</name>'));
      expect(gpx, contains('&lt;danger zone&gt;'));
      expect(gpx, contains('<ele>5364.0</ele>'));
      expect(gpx, contains('<sym>travel</sym>'));
      expect(gpx, contains('<type>Travel</type>'));
    });

    test('exports to standard CSV format with quotation escaping', () {
      final csv = WaypointExporter.toCsv(sampleWaypoints);

      expect(csv, startsWith('Name,Category,Latitude,Longitude,Elevation_m,Notes,Created_At_UTC'));
      expect(csv, contains('"Base Camp & Tent",Travel,27.9880560,86.9252780,5364.0,"South Col Route departure point <danger zone>"'));
      expect(csv, contains('"Home Office ""HQ""",Home,37.7749290,-122.4194160,15.0,"Garage door entry, PIN #4921"'));
    });
  });
}
