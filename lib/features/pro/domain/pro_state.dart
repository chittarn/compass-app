class ProState {
  final bool isPro;
  final bool isNightVision;
  final double? lockedBearing;
  final double? waypointLat;
  final double? waypointLng;
  final String? waypointLabel;

  const ProState({
    this.isPro = false,
    this.isNightVision = false,
    this.lockedBearing,
    this.waypointLat,
    this.waypointLng,
    this.waypointLabel,
  });

  bool get hasLockedBearing => lockedBearing != null;
  bool get hasWaypoint => waypointLat != null && waypointLng != null;

  ProState copyWith({
    bool? isPro,
    bool? isNightVision,
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
      lockedBearing: clearBearing ? null : (lockedBearing ?? this.lockedBearing),
      waypointLat: clearWaypoint ? null : (waypointLat ?? this.waypointLat),
      waypointLng: clearWaypoint ? null : (waypointLng ?? this.waypointLng),
      waypointLabel: clearWaypoint ? null : (waypointLabel ?? this.waypointLabel),
    );
  }
}
