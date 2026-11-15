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
  cashSafe,      // Locker / Treasury
  sleepingHead,  // Optimal Head Direction while Sleeping
  mainDoor,      // Primary Entrance
  livingRoom,    // Drawing Room / Hall
  childrenRoom,  // Study / Kids Bedroom
  guestRoom,     // Guest Bedroom
  toilets,       // Waste & Restroom
}

class VastuZoneInfo {
  final String direction;        // e.g. "NE"
  final String englishName;       // e.g. "North-East"
  final String sanskritName;      // e.g. "Ishan (ईशान)"
  final String rulingDeity;       // e.g. "Lord Shiva"
  final VastuElement element;     // e.g. VastuElement.water
  final String elementLabel;      // e.g. "WATER (जल)"
  final String plainLabel;       // e.g. "POOJA ROOM & WATER"
  final String emoji;            // e.g. "🛕"
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
    required this.plainLabel,
    required this.emoji,
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
  final String emoji;
  final String idealDirection;
  final double targetHeading;
  final String plainPurpose;
  final String description;
  final String reason;
  final List<String> dos;
  final List<String> donts;

  const VastuRoomGuideline({
    required this.type,
    required this.title,
    required this.emoji,
    required this.idealDirection,
    required this.targetHeading,
    required this.plainPurpose,
    required this.description,
    required this.reason,
    required this.dos,
    required this.donts,
  });
}

class VastuGridCell {
  final String directionCode; // "NW", "N", "NE", "W", "CENTER", "E", "SW", "S", "SE"
  final String label;         // e.g. "NE 045°"
  final String roomName;      // e.g. "Pooja Room"
  final String emoji;         // e.g. "🛕"
  final VastuRoomType? roomType;
  final double? targetHeading;
  final int colorValue;

  const VastuGridCell({
    required this.directionCode,
    required this.label,
    required this.roomName,
    required this.emoji,
    this.roomType,
    this.targetHeading,
    required this.colorValue,
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
      plainLabel: 'CASH LOCKER & WEALTH',
      emoji: '💰',
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
        'Heavy Storage & Clutter',
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
      plainLabel: 'POOJA ROOM & WATER',
      emoji: '🛕',
      centerDegrees: 45.0,
      startDegrees: 22.5,
      endDegrees: 67.5,
      bestFor: [
        'Pooja Room (Mandir)',
        'Meditation & Yoga Area',
        'Drinking Water / Borewell',
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
      plainLabel: 'MAIN DOOR & LIVING',
      emoji: '🚪',
      centerDegrees: 90.0,
      startDegrees: 67.5,
      endDegrees: 112.5,
      bestFor: [
        'Main Entrance Door',
        'Living Room & Foyer',
        'Balcony & Morning Sunlight',
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
      plainLabel: 'KITCHEN & FIRE STOVE',
      emoji: '🍳',
      centerDegrees: 135.0,
      startDegrees: 112.5,
      endDegrees: 157.5,
      bestFor: [
        'Kitchen (Cooking Stove)',
        'Inverters & Electrical Meters',
        'Generators & Boilers',
        'Microwaves & Heaters',
      ],
      avoid: [
        'Master Bedroom (Anxiety)',
        'Water Tanks & Sinks',
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
      rulingDeity: 'Lord of Rest & Justice',
      element: VastuElement.earth,
      elementLabel: 'EARTH (पृथ्वी)',
      plainLabel: 'SLEEPING HEAD & WARDROBE',
      emoji: '🛌',
      centerDegrees: 180.0,
      startDegrees: 157.5,
      endDegrees: 202.5,
      bestFor: [
        'Bed Headboard (Head towards South)',
        'Heavy Wardrobes & Almirahs',
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
      plainLabel: 'MASTER BEDROOM & SAFE',
      emoji: '🛏️',
      centerDegrees: 225.0,
      startDegrees: 202.5,
      endDegrees: 247.5,
      bestFor: [
        'Master Bedroom (Head of House)',
        'Cash Safe / Jewelry Locker (Opens North)',
        'Heaviest Furniture & Pillars',
        'Overhead Water Tank (Elevated)',
      ],
      avoid: [
        'Underground Water Tanks (Critical Defect)',
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
      rulingDeity: 'Lord of Space & Prosperity',
      element: VastuElement.space,
      elementLabel: 'SPACE / WATER (आकाश)',
      plainLabel: 'STUDY ROOM & CHILDREN',
      emoji: '📚',
      centerDegrees: 270.0,
      startDegrees: 247.5,
      endDegrees: 292.5,
      bestFor: [
        'Dining Room (Family Harmony)',
        'Children’s Bedroom & Study Desk',
        'Overhead Water Storage Tank',
        'Conference & Discussion Room',
      ],
      avoid: [
        'Underground Water Sump',
        'Main Entrance (unless calibrated)',
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
      plainLabel: 'GUEST ROOM & TOILET',
      emoji: '💨',
      centerDegrees: 315.0,
      startDegrees: 292.5,
      endDegrees: 337.5,
      bestFor: [
        'Guest Bedroom',
        'Vehicle Parking (Movement)',
        'Toilets & Septic Tanks (Outer wall)',
        'Finished Goods Inventory',
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
      title: 'Pooja Room / Mandir',
      emoji: '🛕',
      idealDirection: 'North-East (045°)',
      targetHeading: 45.0,
      plainPurpose: 'Sacred Mandir, Prayer & Meditation',
      description: 'Place the mandir in the NE corner. Pray facing East or North. Keeps the home spiritually energized.',
      reason: 'North-East receives the purest morning sunlight and positive cosmic energy.',
      dos: [
        'Face East or North while praying',
        'Keep the altar clean, well-lit, and uncluttered',
        'Place drinking water or holy water in this corner',
      ],
      donts: [
        'Never under or above a staircase',
        'Never share a common wall with a toilet',
        'Avoid heavy cupboards or junk in this zone',
      ],
    ),
    VastuRoomGuideline(
      type: VastuRoomType.kitchen,
      title: 'Kitchen & Gas Stove',
      emoji: '🍳',
      idealDirection: 'South-East (135°)',
      targetHeading: 135.0,
      plainPurpose: 'Cooking Stove, Oven & Inverter',
      description: 'Cook facing East. Place cooking stove in the South-East corner. Keep sink (water) away from stove (fire).',
      reason: 'South-East is ruled by the Fire Element (Agni). Brings digestive health and family abundance.',
      dos: [
        'Cook facing East towards the morning sun',
        'Keep electrical appliances in South-East',
        'Maintain distance between fire stove and water sink',
      ],
      donts: [
        'Never place kitchen directly under or over Pooja Room',
        'Never place cooking stove in North-East (water zone)',
        'Avoid black granite countertops in kitchen',
      ],
    ),
    VastuRoomGuideline(
      type: VastuRoomType.masterBedroom,
      title: 'Master Bedroom',
      emoji: '🛏️',
      idealDirection: 'South-West (225°)',
      targetHeading: 225.0,
      plainPurpose: 'Head of Family / Owner Suite',
      description: 'The head of the family should occupy the South-West room. Sleep with your head toward South or East.',
      reason: 'South-West provides heavy earth energy, leadership authority, and deep restorative sleep.',
      dos: [
        'Position bed with head toward South or East',
        'Place heavy wardrobes against South or West walls',
        'Keep bedroom restful and softly lit',
      ],
      donts: [
        'Never sleep with your head pointing North',
        'Never place mirror directly reflecting the bed',
        'Avoid placing master bed in North-East (Ishan)',
      ],
    ),
    VastuRoomGuideline(
      type: VastuRoomType.cashSafe,
      title: 'Cash Safe & Jewelry Locker',
      emoji: '💰',
      idealDirection: 'South-West (Opens North)',
      targetHeading: 225.0,
      plainPurpose: 'Locker, Vault & Wealth Storage',
      description: 'Place heavy safe against South wall so its door opens toward the North (Kubera’s direction).',
      reason: 'Lord Kubera resides in the North. Opening the locker toward North preserves and multiplies wealth.',
      dos: [
        'Face North when opening the cash locker',
        'Place against South or West wall for physical stability',
        'Keep safe clean and place a gold/silver coin inside',
      ],
      donts: [
        'Never place locker in South-East (fire burns wealth)',
        'Never place locker in North-West (wind creates outflow)',
        'Never keep locker under an exposed ceiling beam',
      ],
    ),
    VastuRoomGuideline(
      type: VastuRoomType.sleepingHead,
      title: 'Sleep Head Direction',
      emoji: '🛌',
      idealDirection: 'South (Best) or East',
      targetHeading: 180.0,
      plainPurpose: 'Headboard Orientation for Sleep',
      description: 'Sleep with head South and feet North, or head East and feet West. Never sleep with head to the North.',
      reason: 'Human body has magnetic polarity. Sleeping head North causes magnetic friction, nightmares, and high blood pressure.',
      dos: [
        'South direction provides deepest REM sleep',
        'East direction boosts memory and concentration',
        'Keep electronic chargers away from pillow',
      ],
      donts: [
        'STRICTLY FORBIDDEN: Head pointing North',
        'Avoid sleeping under an exposed concrete beam',
        'Do not sleep facing sharp room corners',
      ],
    ),
    VastuRoomGuideline(
      type: VastuRoomType.mainDoor,
      title: 'Main Entrance Door',
      emoji: '🚪',
      idealDirection: 'North or East (045°)',
      targetHeading: 45.0,
      plainPurpose: 'Front Entry & Positive Prana Gateway',
      description: 'Best in North (Kubera) or East (Indra). The door should open inward clockwise and be well lit.',
      reason: 'The main door is the mouth of the home, inviting positive cosmic prana and prosperity.',
      dos: [
        'Door should open inward clockwise',
        'Keep threshold bright, clean and welcoming',
        'Place an attractive nameplate and auspicious symbol',
      ],
      donts: [
        'Never have shoe racks cluttering the entrance doorway',
        'Avoid squeaky or cracked doors',
        'Avoid entrance facing directly into a bathroom',
      ],
    ),
    VastuRoomGuideline(
      type: VastuRoomType.livingRoom,
      title: 'Living Room / Drawing Hall',
      emoji: '🛋️',
      idealDirection: 'East or North (090°)',
      targetHeading: 90.0,
      plainPurpose: 'Family Hall & Guest Welcoming',
      description: 'Heavy sofas in South/West. Keep North and East light and open for natural morning breeze and light.',
      reason: 'Welcomes guests with solar vitality and ensures harmonious family conversations.',
      dos: [
        'Head of family should sit facing East or North',
        'Place heavy furniture in South or West',
        'Place TV or electrical equipment in South-East',
      ],
      donts: [
        'Avoid dim, gloomy, or windowless living spaces',
        'Never keep dried flowers or thorny cactus plants',
        'Avoid circular or oval furniture',
      ],
    ),
    VastuRoomGuideline(
      type: VastuRoomType.childrenRoom,
      title: 'Study & Children Bedroom',
      emoji: '📚',
      idealDirection: 'West or North-East (270°)',
      targetHeading: 270.0,
      plainPurpose: 'Study Desk, Books & Kids Bedroom',
      description: 'Children should study facing East or North. Study desk in West or North-East with bright natural light.',
      reason: 'Governed by Varuna & Mercury, promoting sharp intellect, memory retention and exam success.',
      dos: [
        'Student should face East or North while studying',
        'Keep study desk clean and clutter-free',
        'Bed headboard toward East or South',
      ],
      donts: [
        'Never face a blank dark wall while studying',
        'Avoid mirrors reflecting study books or desk',
        'Never store clutter under the study table',
      ],
    ),
    VastuRoomGuideline(
      type: VastuRoomType.guestRoom,
      title: 'Guest Bedroom',
      emoji: '💨',
      idealDirection: 'North-West (315°)',
      targetHeading: 315.0,
      plainPurpose: 'Visitors & Married Daughters',
      description: 'North-West (Air zone) ensures dynamic movement, preventing guests from overstaying.',
      reason: 'Governed by Vayu (Wind). Keeps energy flowing harmoniously without emotional conflict.',
      dos: [
        'Keep bed in South or West of the room',
        'Ensure fresh air circulation and windows',
        'Provide wardrobe on South or West wall',
      ],
      donts: [
        'Never use as the permanent master bedroom',
        'Never install permanent cash safes here',
        'Avoid dark heavy colors in this room',
      ],
    ),
    VastuRoomGuideline(
      type: VastuRoomType.toilets,
      title: 'Bathrooms & Toilets',
      emoji: '🚽',
      idealDirection: 'North-West or West (315°)',
      targetHeading: 315.0,
      plainPurpose: 'Waste Drainage & Commode',
      description: 'Place on outer walls of North-West or West. Toilet seat should face North-South axis.',
      reason: 'Negative disposal energy must be safely ventilated outdoors without contaminating water or fire zones.',
      dos: [
        'Toilet seat aligned North-South',
        'Ventilate well with exhaust fan on outer wall',
        'Always keep bathroom door closed',
      ],
      donts: [
        'STRICTLY FORBIDDEN in North-East (Ishan defect)',
        'STRICTLY FORBIDDEN in South-West (destroys stability)',
        'Never place toilet seat opposite the main entrance',
      ],
    ),
  ];

  /// 3x3 Vastu House Floor Plan Matrix (Vastu Purusha Mandala layout)
  /// Row 0 (Top / North): NW, N, NE
  /// Row 1 (Mid):         W,  CENTER (Brahmasthan), E
  /// Row 2 (Bottom / South): SW, S, SE
  static const List<VastuGridCell> houseGrid = [
    // Row 0
    VastuGridCell(
      directionCode: 'NW',
      label: 'NW 315°',
      roomName: 'Guest & Toilet',
      emoji: '💨',
      roomType: VastuRoomType.guestRoom,
      targetHeading: 315.0,
      colorValue: 0xFF64FFDA,
    ),
    VastuGridCell(
      directionCode: 'N',
      label: 'N 000°',
      roomName: 'Cash & Wealth',
      emoji: '💰',
      roomType: VastuRoomType.cashSafe,
      targetHeading: 0.0,
      colorValue: 0xFF00E5FF,
    ),
    VastuGridCell(
      directionCode: 'NE',
      label: 'NE 045°',
      roomName: 'Pooja & Water',
      emoji: '🛕',
      roomType: VastuRoomType.poojaRoom,
      targetHeading: 45.0,
      colorValue: 0xFF80D8FF,
    ),

    // Row 1
    VastuGridCell(
      directionCode: 'W',
      label: 'W 270°',
      roomName: 'Study & Kids',
      emoji: '📚',
      roomType: VastuRoomType.childrenRoom,
      targetHeading: 270.0,
      colorValue: 0xFFB388FF,
    ),
    VastuGridCell(
      directionCode: 'CENTER',
      label: 'CENTER',
      roomName: 'Open Courtyard',
      emoji: '✨',
      roomType: null,
      targetHeading: null,
      colorValue: 0xFFFFD700,
    ),
    VastuGridCell(
      directionCode: 'E',
      label: 'E 090°',
      roomName: 'Door & Living',
      emoji: '🚪',
      roomType: VastuRoomType.mainDoor,
      targetHeading: 90.0,
      colorValue: 0xFF00E676,
    ),

    // Row 2
    VastuGridCell(
      directionCode: 'SW',
      label: 'SW 225°',
      roomName: 'Master Bed & Safe',
      emoji: '🛏️',
      roomType: VastuRoomType.masterBedroom,
      targetHeading: 225.0,
      colorValue: 0xFFFFD700,
    ),
    VastuGridCell(
      directionCode: 'S',
      label: 'S 180°',
      roomName: 'Sleep Head',
      emoji: '🛌',
      roomType: VastuRoomType.sleepingHead,
      targetHeading: 180.0,
      colorValue: 0xFFFF5252,
    ),
    VastuGridCell(
      directionCode: 'SE',
      label: 'SE 135°',
      roomName: 'Kitchen & Fire',
      emoji: '🍳',
      roomType: VastuRoomType.kitchen,
      targetHeading: 135.0,
      colorValue: 0xFFFF9100,
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
