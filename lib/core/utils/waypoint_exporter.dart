import '../../features/waypoints/domain/waypoint.dart';

/// Exports waypoints to industry-standard GPS Exchange (GPX 1.1) and Comma-Separated Values (CSV).
class WaypointExporter {
  /// Converts waypoints to standard GPX 1.1 XML string
  static String toGpx(List<Waypoint> waypoints) {
    final buffer = StringBuffer();
    buffer.writeln('<?xml version="1.0" encoding="UTF-8"?>');
    buffer.writeln(
      '<gpx version="1.1" creator="Compass Pro" xmlns="http://www.topografix.com/GPX/1/1">',
    );
    buffer.writeln('  <metadata>');
    buffer.writeln('    <name>Compass Pro Waypoints</name>');
    buffer.writeln(
      '    <desc>Exported from Compass Tactical Navigation Suite</desc>',
    );
    buffer.writeln(
      '    <time>${DateTime.now().toUtc().toIso8601String()}</time>',
    );
    buffer.writeln('  </metadata>');

    for (final wp in waypoints) {
      buffer.write(
        '  <wpt lat="${wp.latitude.toStringAsFixed(7)}" lon="${wp.longitude.toStringAsFixed(7)}">',
      );
      if (wp.altitude != null) {
        buffer.write('<ele>${wp.altitude!.toStringAsFixed(1)}</ele>');
      }
      buffer.write('<time>${wp.createdAt.toUtc().toIso8601String()}</time>');
      buffer.write('<name>${_escapeXml(wp.title)}</name>');
      if (wp.notes != null && wp.notes!.trim().isNotEmpty) {
        buffer.write('<desc>${_escapeXml(wp.notes!.trim())}</desc>');
      }
      buffer.write('<sym>${wp.category.name}</sym>');
      buffer.write('<type>${wp.category.label}</type>');
      buffer.writeln('</wpt>');
    }

    buffer.writeln('</gpx>');
    return buffer.toString();
  }

  /// Converts waypoints to standard CSV format with formula-injection hardening
  static String toCsv(List<Waypoint> waypoints) {
    final buffer = StringBuffer();
    buffer.writeln(
      'Name,Category,Latitude,Longitude,Elevation_m,Notes,Created_At_UTC',
    );

    for (final wp in waypoints) {
      final name = sanitizeCsvField(wp.title);
      final category = sanitizeCsvField(wp.category.label);
      final lat = wp.latitude.toStringAsFixed(7);
      final lng = wp.longitude.toStringAsFixed(7);
      final elevation = wp.altitude != null
          ? wp.altitude!.toStringAsFixed(1)
          : '';
      final notes = sanitizeCsvField(wp.notes ?? '');
      final time = wp.createdAt.toUtc().toIso8601String();

      buffer.writeln('$name,$category,$lat,$lng,$elevation,$notes,$time');
    }

    return buffer.toString();
  }

  /// Neutralizes spreadsheet formula injection (OWASP CWE-1236) and escapes quotes per RFC 4180
  static String sanitizeCsvField(String input) {
    var sanitized = input;
    // Mitigate spreadsheet formula injection
    if (sanitized.isNotEmpty) {
      final firstChar = sanitized[0];
      if (firstChar == '=' ||
          firstChar == '+' ||
          firstChar == '-' ||
          firstChar == '@' ||
          firstChar == '\t' ||
          firstChar == '\r') {
        sanitized = "'$sanitized";
      }
    }
    // Escape quotes per RFC 4180
    return '"${sanitized.replaceAll('"', '""')}"';
  }

  static String _escapeXml(String input) {
    return input
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }
}
