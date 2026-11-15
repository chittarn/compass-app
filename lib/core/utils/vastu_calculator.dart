import 'dart:math' as math;

enum VastuElement {
  water, // जल
  air,   // वायु
  fire,  // अग्नि
  earth, // पृथ्वी
  space, // आकाश
}

enum VastuRoomType {
  poojaRoom,     // Mandir / Meditation
  kitchen,       // Cooking Stove
  masterBedroom, // Owner's Suite
  mainDoor,      // Primary Entrance
  livingRoom,    // Drawing Room / Hall
  cashSafe,      // Locker / Treasury
  childrenRoom,  // Study / Kids Bedroom
  guestRoom,     // Guest Bedroom
  toilets,       // Waste & Restroom
  sleepingHead,  // Optimal Head Direction while Sleeping
}

class VastuZoneInfo {
  final String direction;        // e.g. "NE"
  final String englishName;       // e.g. "North-East"
  final String sanskritName;      // e.g. "Ishan (ईशान)"
  final String rulingDeity;       // e.g. "Lord Shiva"
  final VastuElement element;     // e.g. VastuElement.water
  final String elementLabel;      // e.g. "WATER (जल)"
  final double centerDegrees;     // e.g. 45.0
  final double startDegrees;      // e.g. 22.5
  final double endDegrees;        // e.g. 67.5
  final List<String> bestFor;     // Optimal placements
  final List<String> avoid;       // Strictly avoid
  final int colorValue;           // ARGB color representation

  const VastuZoneInfo({
    required this.direction,
    required this.englishName,
    required this.sanskritName,
    required this.rulingDeity,
    required this.element,
    required this.elementLabel,
    required this.centerDegrees,
    required this.startDegrees,
    required this.endDegrees,
    required this.bestFor,
    required this.avoid,
    required this.colorValue,
  });
}

class VastuRoomGuideline {
  final VastuRoomType type;
  final String title;
  final String idealDirection;
  final double targetHeading;
  final String description;
  final String reason;

  const VastuRoomGuideline({
    required this.type,
    required this.title,
    required this.idealDirection,
    required this.targetHeading,
    required this.description,
    required this.reason,
  });
}

class VastuCalculator {
  static const List<VastuZoneInfo> zones = [
    // 1. North (Kubera) - 337.5° to 22.5°
    VastuZoneInfo(
      direction: 'N',
      englishName: 'North',
      sanskritName: 'Kubera (कुबेर)',
      rulingDeity: 'Lord of Wealth',
      element: VastuElement.water,
      elementLabel: 'WATER (जल)',
      centerDegrees: 0.0,
      startDegrees: 337.5,
      endDegrees: 22.5,
      bestFor: [
        'Treasury & Cash Locker',
        'Home Office & Desk',
        'Open Balcony & Windows',
        'Main Entrance (Prosperity)',
      ],
      avoid: [
        'Toilets & Septic Tanks',
        'Heavy Storage & Junk',
        'Kitchen (Extinguishes Wealth)',
      ],
      colorValue: 0xFF00E5FF, // Cyan
    ),

    // 2. North-East (Ishan) - 22.5° to 67.5°
    VastuZoneInfo(
      direction: 'NE',
      englishName: 'North-East',
      sanskritName: 'Ishan (ईशान)',
      rulingDeity: 'Supreme Consciousness (Shiva)',
      element: VastuElement.water,
      elementLabel: 'DIVINE / WATER (जल)',
      centerDegrees: 45.0,
      startDegrees: 22.5,
      endDegrees: 67.5,
      bestFor: [
        'Pooja Room (Mandir)',
        'Meditation & Yoga Area',
        'Underground Water Tank / Borewell',
        'Study Space for Children',
      ],
      avoid: [
        'Toilets (Severe Defect)',
        'Kitchen (Fire in Water Zone)',
        'Heavy Staircase & Clutter',
        'Master Bedroom',
      ],
      colorValue: 0xFF80D8FF, // Soft Celestial Cyan/Blue
    ),

    // 3. East (Indra / Surya) - 67.5° to 112.5°
    VastuZoneInfo(
      direction: 'E',
      englishName: 'East',
      sanskritName: 'Indra / Surya (इन्द्र/सूर्य)',
      rulingDeity: 'Sun & Vitality',
      element: VastuElement.air,
      elementLabel: 'AIR / LIGHT (वायु/प्रकाश)',
      centerDegrees: 90.0,
      startDegrees: 67.5,
      endDegrees: 112.5,
      bestFor: [
        'Main Entrance (Auspicious)',
        'Living Room & Foyer',
        'Balcony & Morning Sun Access',
        'Study Room',
      ],
      avoid: [
        'Toilets & Septic Tanks',
        'High Blank Walls without Windows',
        'Heavy Solid Storage',
      ],
      colorValue: 0xFF00E676, // Fresh Emerald
    ),

    // 4. South-East (Agni) - 112.5° to 157.5°
    VastuZoneInfo(
      direction: 'SE',
      englishName: 'South-East',
      sanskritName: 'Agneya (आग्नेय)',
      rulingDeity: 'Lord of Fire (Agni)',
      element: VastuElement.fire,
      elementLabel: 'FIRE (अग्नि)',
      centerDegrees: 135.0,
      startDegrees: 112.5,
      endDegrees: 157.5,
      bestFor: [
        'Kitchen (Cooking Stove facing East)',
        'Inverters & Electrical Panels',
        'Generators & Boilers',
        'Microwaves & Heating Appliances',
      ],
      avoid: [
        'Master Bedroom (Anxiety)',
        'Water Sump & Water Bodies',
        'Pooja Room',
        'Main Entrance',
      ],
      colorValue: 0xFFFF9100, // Fire Amber / Orange
    ),

    // 5. South (Yama) - 157.5° to 202.5°
    VastuZoneInfo(
      direction: 'S',
      englishName: 'South',
      sanskritName: 'Yama (यम)',
      rulingDeity: 'Lord of Justice & Dharma',
      element: VastuElement.earth,
      elementLabel: 'EARTH (पृथ्वी)',
      centerDegrees: 180.0,
      startDegrees: 157.5,
      endDegrees: 202.5,
      bestFor: [
        'Bed Headboard (Sleep with head South)',
        'Heavy Wardrobes & Cabinets',
        'Solid High Boundary Walls',
        'Storage Rooms',
      ],
      avoid: [
        'Underground Water Sump / Wells',
        'Main Entrance (unless calibrated)',
        'Pooja Room',
        'Open low balconies',
      ],
      colorValue: 0xFFFF5252, // Coral Red
    ),

    // 6. South-West (Nairutya) - 202.5° to 247.5°
    VastuZoneInfo(
      direction: 'SW',
      englishName: 'South-West',
      sanskritName: 'Nairutya (नैऋत्य)',
      rulingDeity: 'Lord of Stability & Strength',
      element: VastuElement.earth,
      elementLabel: 'HEAVY EARTH (पृथ्वी)',
      centerDegrees: 225.0,
      startDegrees: 202.5,
      endDegrees: 247.5,
      bestFor: [
        'Master Bedroom (Family Head/Owner)',
        'Cash Safe / Jewelry Locker (Opens North)',
        'Heaviest Structures & Wardrobes',
        'Overhead Water Tank (Elevated)',
      ],
      avoid: [
        'Underground Water Tanks (Critical)',
        'Toilets / Drainage',
        'Pooja Room',
        'Main Entrance',
      ],
      colorValue: 0xFFFFD700, // Gold / Heavy Earth
    ),

    // 7. West (Varuna) - 247.5° to 292.5°
    VastuZoneInfo(
      direction: 'W',
      englishName: 'West',
      sanskritName: 'Varuna (वरुण)',
      rulingDeity: 'Lord of Rains & Space',
      element: VastuElement.space,
      elementLabel: 'SPACE / WATER (आकाश)',
      centerDegrees: 270.0,
      startDegrees: 247.5,
      endDegrees: 292.5,
      bestFor: [
        'Dining Room (Prosperity)',
        'Children’s Bedroom & Study',
        'Overhead Water Storage Tank',
        'Meeting & Discussion Room',
      ],
      avoid: [
        'Underground Water Sump',
        'Main Entrance (unless 3rd/4th Pada)',
        'Large Low Openings',
      ],
      colorValue: 0xFFB388FF, // Purple / Ether Space
    ),

    // 8. North-West (Vayavya) - 292.5° to 337.5°
    VastuZoneInfo(
      direction: 'NW',
      englishName: 'North-West',
      sanskritName: 'Vayavya (वायव्य)',
      rulingDeity: 'Lord of Winds (Vayu)',
      element: VastuElement.air,
      elementLabel: 'AIR / MOVEMENT (वायु)',
      centerDegrees: 315.0,
      startDegrees: 292.5,
      endDegrees: 337.5,
      bestFor: [
        'Guest Bedroom',
        'Finished Goods & Inventory Storage',
        'Vehicle Parking (Movement)',
        'Toilets & Septic Tanks (Outer wall)',
      ],
      avoid: [
        'Master Bedroom (Instability)',
        'Pooja Room',
        'Cash Safe / Treasury',
      ],
      colorValue: 0xFF64FFDA, // Air Teal
    ),
  ];

  static const List<VastuRoomGuideline> roomGuidelines = [
    VastuRoomGuideline(
      type: VastuRoomType.poojaRoom,
      title: 'Pooja Room (Mandir)',
      idealDirection: 'North-East (Ishan)',
      targetHeading: 45.0,
      description: 'Place the mandir in the NE corner. Idols should face West or East so you face East or North while praying.',
      reason: 'North-East is the sacred conduit of positive cosmic vibrations and purest solar energy.',
    ),
    VastuRoomGuideline(
      type: VastuRoomType.kitchen,
      title: 'Kitchen & Cooking Stove',
      idealDirection: 'South-East (Agneya)',
      targetHeading: 135.0,
      description: 'Cook facing East. Place the stove in the South-East corner. Keep sink (water) away from stove (fire).',
      reason: 'South-East is ruled by Agni Dev (Fire Deity). Aligning cooking here ensures good health and digestive vitality.',
    ),
    VastuRoomGuideline(
      type: VastuRoomType.masterBedroom,
      title: 'Master Bedroom',
      idealDirection: 'South-West (Nairutya)',
      targetHeading: 225.0,
      description: 'The head of the family should occupy the South-West room. Sleep with your head toward South or East.',
      reason: 'South-West provides grounding earth energy, leadership authority, and deep, restful sleep.',
    ),
    VastuRoomGuideline(
      type: VastuRoomType.mainDoor,
      title: 'Main Entrance Door',
      idealDirection: 'North, East, or North-East',
      targetHeading: 45.0,
      description: 'Auspicious padas in North (Kubera) or East (Indra). The door should open clockwise inward.',
      reason: 'Brings wealth, health, and abundant life-force energy (Prana) into the home.',
    ),
    VastuRoomGuideline(
      type: VastuRoomType.cashSafe,
      title: 'Cash Safe & Jewelry Locker',
      idealDirection: 'South-West (opening toward North)',
      targetHeading: 225.0,
      description: 'Place heavy locker against South or West wall so its door opens toward the North (Kubera’s direction).',
      reason: 'Kubera, the celestial treasurer, resides in the North. Opening the locker toward North preserves and multiplies wealth.',
    ),
    VastuRoomGuideline(
      type: VastuRoomType.sleepingHead,
      title: 'Optimal Sleeping Headboard',
      idealDirection: 'South (Ideal) or East',
      targetHeading: 180.0,
      description: 'Sleep with your head positioned South and feet North, or head East and feet West. Never head North.',
      reason: 'The human body has a magnetic polarity. Sleeping head North aligns matching poles with Earth, causing sleep disruption and blood pressure fluctuations.',
    ),
    VastuRoomGuideline(
      type: VastuRoomType.livingRoom,
      title: 'Living Room / Drawing Room',
      idealDirection: 'East or North',
      targetHeading: 90.0,
      description: 'Heavy furniture in South and West; keep East and North open for light and guest entertainment.',
      reason: 'Welcomes guests with vibrant solar energy and ensures harmonious family discussions.',
    ),
    VastuRoomGuideline(
      type: VastuRoomType.childrenRoom,
      title: 'Children’s Study & Bedroom',
      idealDirection: 'West or North-West',
      targetHeading: 270.0,
      description: 'Children should study facing East or North. Study table in West/NE, bed headboard toward East.',
      reason: 'West is governed by Varuna, enhancing concentration, memory retention, and intellectual prowess.',
    ),
    VastuRoomGuideline(
      type: VastuRoomType.guestRoom,
      title: 'Guest Bedroom',
      idealDirection: 'North-West (Vayavya)',
      targetHeading: 315.0,
      description: 'Ideal for guests, visitors, or daughters. Fast-moving energy keeps visitors from overstaying.',
      reason: 'Governed by Vayu (Wind). Keeps energy dynamic and flowing without stagnant attachment.',
    ),
    VastuRoomGuideline(
      type: VastuRoomType.toilets,
      title: 'Toilets & Waste Drainage',
      idealDirection: 'North-West or South-of-South-West',
      targetHeading: 315.0,
      description: 'Place along North-West or West outer walls. Never in North-East (Ishan) or South-West.',
      reason: 'Negative disposal energy must be safely ventilated via air corridors without contaminating sacred water/fire zones.',
    ),
  ];

  /// Returns the corresponding Vastu zone for any instantaneous heading in degrees [0, 360).
  static VastuZoneInfo getZone(double headingDegrees) {
    final norm = (headingDegrees % 360.0 + 360.0) % 360.0;

    // Special wrap-around check for North: 337.5° to 22.5°
    if (norm >= 337.5 || norm < 22.5) {
      return zones[0]; // North
    }

    for (int i = 1; i < zones.length; i++) {
      if (norm >= zones[i].startDegrees && norm < zones[i].endDegrees) {
        return zones[i];
      }
    }

    return zones[0];
  }

  /// Returns room guideline information for a specific room type.
  static VastuRoomGuideline getGuideline(VastuRoomType room) {
    return roomGuidelines.firstWhere(
      (g) => g.type == room,
      orElse: () => roomGuidelines.first,
    );
  }

  /// Checks if current heading is aligned with target room heading within tolerance.
  static bool isAlignedWithRoom(double heading, VastuRoomType room, {double tolerance = 15.0}) {
    final guideline = getGuideline(room);
    double diff = (heading - guideline.targetHeading).abs() % 360.0;
    if (diff > 180.0) diff = 360.0 - diff;
    return diff <= tolerance;
  }
}
