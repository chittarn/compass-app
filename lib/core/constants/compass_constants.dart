class CompassConstants {
  // Heading sector labels (16-point cardinal compass rose)
  static const List<String> cardinalPoints = [
    'N', 'NNE', 'NE', 'ENE',
    'E', 'ESE', 'SE', 'SSE',
    'S', 'SSW', 'SW', 'WSW',
    'W', 'WNW', 'NW', 'NNW',
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
}
