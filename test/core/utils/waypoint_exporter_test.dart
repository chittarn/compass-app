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

    group('GPX 1.1 XML Hardening & Validation', () {
      test('exports to standard GPX 1.1 format with strict XML escaping', () {
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

      test('validates GPX XML tag pairing and balanced structure', () {
        final gpx = WaypointExporter.toGpx(sampleWaypoints);

        // Check root tags
        expect(gpx.indexOf('<gpx'), isNonNegative);
        expect(gpx.indexOf('</gpx>'), isNonNegative);

        // Check metadata tags
        expect(gpx.indexOf('<metadata>'), isNonNegative);
        expect(gpx.indexOf('</metadata>'), isNonNegative);

        // Check wpt element pairing count
        final openWptCount = '<wpt'.allMatches(gpx).length;
        final closeWptCount = '</wpt>'.allMatches(gpx).length;
        expect(openWptCount, sampleWaypoints.length);
        expect(closeWptCount, sampleWaypoints.length);

        // Check name tag pairing
        final openNameCount = '<name>'.allMatches(gpx).length;
        final closeNameCount = '</name>'.allMatches(gpx).length;
        expect(openNameCount, closeNameCount);

        // Ensure no unescaped dangerous XML entities exist inside text
        expect(gpx, isNot(contains('<danger zone>')));
        expect(gpx, isNot(contains('Camp & Tent')));
      });
    });

    group('CSV Formatting & Formula Injection Hardening (CWE-1236)', () {
      test('neutralizes formula injection characters (=, +, -, @, tab, cr)', () {
        final injectionWaypoints = [
          Waypoint(
            id: 'inj_1',
            title: '=cmd|\'/C calc\'!A0',
            latitude: 10.0,
            longitude: 20.0,
            createdAt: DateTime.now(),
            category: WaypointCategory.custom,
            notes: '+1234567890 Phone Number',
          ),
          Waypoint(
            id: 'inj_2',
            title: '@SUM(A1:A10)',
            latitude: 11.0,
            longitude: 21.0,
            createdAt: DateTime.now(),
            category: WaypointCategory.work,
            notes: '-Sensitive Discount Code',
          ),
        ];

        final csv = WaypointExporter.toCsv(injectionWaypoints);

        // Formula triggers must be prefixed with single quote
        expect(csv, contains('\'=cmd|'));
        expect(csv, contains('\'+1234567890'));
        expect(csv, contains('\'@SUM'));
        expect(csv, contains('\'-Sensitive'));
      });

      test('properly escapes quotes, commas, and line breaks per RFC 4180', () {
        final specialWaypoints = [
          Waypoint(
            id: 'spec_1',
            title: 'Store "A & B", Ltd.',
            latitude: 10.0,
            longitude: 20.0,
            createdAt: DateTime.utc(2026, 11, 16),
            category: WaypointCategory.work,
            notes: 'Line 1\nLine 2 with "quotes", and commas',
          ),
        ];

        final csv = WaypointExporter.toCsv(specialWaypoints);

        // Quoted string with internal quotes doubled
        expect(csv, contains('"Store ""A & B"", Ltd."'));
        expect(csv, contains('""quotes"", and commas'));
      });
    });
  });
}
