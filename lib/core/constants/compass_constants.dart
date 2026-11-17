class CompassConstants {
  // Heading sector labels (16-point cardinal compass rose)
  static const List<String> cardinalPoints = [
    'N',
    'NNE',
    'NE',
    'ENE',
    'E',
    'ESE',
    'SE',
    'SSE',
    'S',
    'SSW',
    'SW',
    'WSW',
    'W',
    'WNW',
    'NW',
    'NNW',
  ];

  static String getDirectionLabel(double degrees) {
    final normalized = (degrees % 360.0 + 360.0) % 360.0;
    final index = ((normalized + 11.25) / 22.5).floor() % 16;
    return cardinalPoints[index];
  }

  // Tilt / Bubble level tolerance
  static const double levelToleranceDegrees = 1.5;

  // Haptic limits
  static const Duration minHapticInterval = Duration(milliseconds: 65);
  static const double maxAngularVelocityHapticSuppression = 135.0; // deg/sec

  // App Distribution & Play Store
  static const String appName = 'Compass';
  static const String appPackageId = 'com.chittaranjan.compass';
  // Note: Verify URL is live before public release on Google Play Console
  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=$appPackageId';
  static const String shareMessage =
      'Try Compass — an offline-first compass with True North, Qibla, Vastu and waypoint tools.\n\n$playStoreUrl';
}
