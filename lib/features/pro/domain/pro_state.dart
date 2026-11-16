import '../../../core/theme/app_colors.dart';

class ProState {
  final bool isPro;
  final bool isNightVision;
  final AppThemeMode themeMode;
  final double? lockedBearing;
  final double? waypointLat;
  final double? waypointLng;
  final String? waypointLabel;

  const ProState({
    this.isPro = false,
    this.isNightVision = false,
    this.themeMode = AppThemeMode.tacticalDark,
    this.lockedBearing,
    this.waypointLat,
    this.waypointLng,
    this.waypointLabel,
  });

  bool get hasLockedBearing => lockedBearing != null;
  bool get hasWaypoint => waypointLat != null && waypointLng != null;

  CompassTheme get effectiveTheme {
    if (isNightVision || themeMode == AppThemeMode.nightVision) {
      return CompassTheme.nightVision;
    }
    switch (themeMode) {
      case AppThemeMode.tacticalAmber:
        return CompassTheme.tacticalAmber;
      case AppThemeMode.arcticCyan:
        return CompassTheme.arcticCyan;
      case AppThemeMode.nightVision:
        return CompassTheme.nightVision;
      case AppThemeMode.tacticalDark:
      default:
        return CompassTheme.normal;
    }
  }

  ProState copyWith({
    bool? isPro,
    bool? isNightVision,
    AppThemeMode? themeMode,
    double? lockedBearing,
    bool clearBearing = false,
    double? waypointLat,
    double? waypointLng,
    String? waypointLabel,
    bool clearWaypoint = false,
  }) {
    return ProState(
      isPro: isPro ?? this.isPro,
      isNightVision: isNightVision ?? this.isNightVision,
      themeMode: themeMode ?? this.themeMode,
      lockedBearing: clearBearing ? null : (lockedBearing ?? this.lockedBearing),
      waypointLat: clearWaypoint ? null : (waypointLat ?? this.waypointLat),
      waypointLng: clearWaypoint ? null : (waypointLng ?? this.waypointLng),
      waypointLabel: clearWaypoint ? null : (waypointLabel ?? this.waypointLabel),
    );
  }
}
