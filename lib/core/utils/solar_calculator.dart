import 'dart:math' as math;

/// Astronomical calculations for Solar & Lunar coordinates and Sunrise/Sunset times
/// using standard NOAA and Jean Meeus astronomical algorithms.
/// 100% offline, zero internet or API dependency.
class SolarCalculator {
  /// Converts degrees to radians
  static double _degToRad(double deg) => deg * (math.pi / 180.0);

  /// Converts radians to degrees
  static double _radToDeg(double rad) => rad * (180.0 / math.pi);

  /// Normalizes angle to [0, 360) degrees
  static double _normalizeDeg(double deg) => (deg % 360.0 + 360.0) % 360.0;

  /// Calculates Solar Azimuth in degrees [0, 360) clockwise from True North
  /// for a given latitude, longitude, and DateTime (UTC).
  static double calculateSunAzimuth(double lat, double lng, DateTime timeUtc) {
    final julianDay = _getJulianDay(timeUtc);
    final d = julianDay - 2451545.0; // Days since J2000.0

    // Mean anomaly of the Sun
    final g = _normalizeDeg(357.529 + 0.98560028 * d);
    final gRad = _degToRad(g);

    // Mean longitude of the Sun
    final q = _normalizeDeg(280.459 + 0.98564736 * d);

    // Ecliptic longitude of the Sun
    final l = _normalizeDeg(q + 1.915 * math.sin(gRad) + 0.020 * math.sin(2 * gRad));
    final lRad = _degToRad(l);

    // Obliquity of the ecliptic
    final e = 23.439 - 0.00000036 * d;
    final eRad = _degToRad(e);

    // Right ascension and declination
    final sinDec = math.sin(eRad) * math.sin(lRad);
    final decRad = math.asin(sinDec);

    final raRad = math.atan2(math.cos(eRad) * math.sin(lRad), math.cos(lRad));

    // Greenwich Mean Sidereal Time in degrees
    final gmst = _normalizeDeg(280.46061837 + 360.98564736629 * d);
    // Local Sidereal Time
    final lst = _normalizeDeg(gmst + lng);
    final lstRad = _degToRad(lst);

    // Hour angle
    final haRad = lstRad - raRad;

    final latRad = _degToRad(lat);

    // Calculate solar azimuth
    final y = -math.sin(haRad);
    final x = math.tan(decRad) * math.cos(latRad) - math.sin(latRad) * math.cos(haRad);
    final azimuthRad = math.atan2(y, x);

    return _normalizeDeg(_radToDeg(azimuthRad));
  }

  /// Calculates Approximate Lunar Azimuth in degrees [0, 360) from True North
  static double calculateMoonAzimuth(double lat, double lng, DateTime timeUtc) {
    final julianDay = _getJulianDay(timeUtc);
    final d = julianDay - 2451545.0;

    // Moon's mean longitude
    final l0 = _normalizeDeg(218.316 + 13.176396 * d);
    // Moon's mean anomaly
    final m = _normalizeDeg(134.963 + 13.064993 * d);
    final mRad = _degToRad(m);

    // Moon's ecliptic longitude (first-order approximation)
    final lambda = _normalizeDeg(l0 + 6.289 * math.sin(mRad));
    final lambdaRad = _degToRad(lambda);

    // Obliquity
    final epsRad = _degToRad(23.439);

    final sinDec = math.sin(epsRad) * math.sin(lambdaRad);
    final decRad = math.asin(sinDec);
    final raRad = math.atan2(math.cos(epsRad) * math.sin(lambdaRad), math.cos(lambdaRad));

    final gmst = _normalizeDeg(280.46061837 + 360.98564736629 * d);
    final lstRad = _degToRad(_normalizeDeg(gmst + lng));

    final haRad = lstRad - raRad;
    final latRad = _degToRad(lat);

    final y = -math.sin(haRad);
    final x = math.tan(decRad) * math.cos(latRad) - math.sin(latRad) * math.cos(haRad);
    final azimuthRad = math.atan2(y, x);

    return _normalizeDeg(_radToDeg(azimuthRad));
  }

  /// Calculates local Sunrise and Sunset times for a given day and coordinates
  static ({DateTime? sunrise, DateTime? sunset}) calculateSunriseSunset(
      double lat, double lng, DateTime localDate) {
    final year = localDate.year;
    final month = localDate.month;
    final day = localDate.day;

    final n = _dayOfYear(year, month, day);

    // Approximate time
    final lngHour = lng / 15.0;

    DateTime? computeTime(bool isSunrise) {
      final t = n + ((isSunrise ? 6.0 : 18.0) - lngHour) / 24.0;
      final m = (0.9856 * t) - 3.289;
      final mRad = _degToRad(m);

      var l = m + (1.916 * math.sin(mRad)) + (0.020 * math.sin(2 * mRad)) + 282.634;
      l = _normalizeDeg(l);
      final lRad = _degToRad(l);

      var ra = _radToDeg(math.atan(0.91764 * math.tan(lRad)));
      ra = _normalizeDeg(ra);

      final lQuadrant = (l / 90.0).floor() * 90.0;
      final raQuadrant = (ra / 90.0).floor() * 90.0;
      ra = ra + (lQuadrant - raQuadrant);
      ra = ra / 15.0; // hours

      final sinDec = 0.39782 * math.sin(lRad);
      final cosDec = math.cos(math.asin(sinDec));

      // Official zenith for sunrise/sunset is 90° 50' = 90.833°
      const zenithRad = 1.58534; // 90.833° in radians
      final latRad = _degToRad(lat);

      final cosH = (math.cos(zenithRad) - (sinDec * math.sin(latRad))) /
          (cosDec * math.cos(latRad));

      if (cosH > 1.0 || cosH < -1.0) {
        // Polar day or polar night
        return null;
      }

      final h = isSunrise
          ? 360.0 - _radToDeg(math.acos(cosH))
          : _radToDeg(math.acos(cosH));
      final hHours = h / 15.0;

      final utHours = hHours + ra - (0.06571 * t) - 6.622 - lngHour;
      final normalizedUt = (utHours % 24.0 + 24.0) % 24.0;

      final utHour = normalizedUt.floor();
      final utMinute = ((normalizedUt - utHour) * 60.0).round();

      final utcDateTime = DateTime.utc(year, month, day, utHour, utMinute);
      return utcDateTime.toLocal();
    }

    return (
      sunrise: computeTime(true),
      sunset: computeTime(false),
    );
  }

  static double _getJulianDay(DateTime utc) {
    int y = utc.year;
    int m = utc.month;
    final d = utc.day +
        (utc.hour / 24.0) +
        (utc.minute / 1440.0) +
        (utc.second / 86400.0);

    if (m <= 2) {
      y -= 1;
      m += 12;
    }

    final a = (y / 100).floor();
    final b = 2 - a + (a / 4).floor();

    return (365.25 * (y + 4716)).floor() +
        (30.6001 * (m + 1)).floor() +
        d +
        b -
        1524.5;
  }

  static int _dayOfYear(int year, int month, int day) {
    final n1 = (275 * month / 9).floor();
    final n2 = ((month + 9) / 12).floor();
    final n3 = (1 + ((year - 4 * (year / 4).floor() + 2) / 3)).floor();
    return n1 - (n2 * n3) + day - 30;
  }
}
