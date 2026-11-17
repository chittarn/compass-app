enum VastuElement {
  water, // जल
  air, // वायु
  fire, // अग्नि
  earth, // पृथ्वी
  space, // आकाश
}

enum VastuGridMode {
  eightZone('8 Directions', 'Classical Ashta Dikpala (45° sectors)'),
  sixteenZone('16 Energy Zones', 'Shodasha Mandala (22.5° precision zones)'),
  thirtyTwoZone(
    '32 Devata Padas',
    'Vastu Purusha Mandala (11.25° entrance energy fields)',
  );

  final String label;
  final String description;
  const VastuGridMode(this.label, this.description);
}

enum VastuProfileType {
  residential(
    'Residential (Home)',
    'Living rooms, pooja, bedrooms & domestic areas',
  ),
  commercial(
    'Commercial (Business)',
    'Executive cabins, cash flow, accounts & operations',
  );

  final String label;
  final String description;
  const VastuProfileType(this.label, this.description);
}

class VastuProfile {
  final String id;
  final String name;
  final VastuProfileType type;
  final bool isCustom;

  const VastuProfile({
    required this.id,
    required this.name,
    required this.type,
    this.isCustom = false,
  });

  static const VastuProfile defaultHome = VastuProfile(
    id: 'default_home',
    name: 'My Residence (Home)',
    type: VastuProfileType.residential,
  );

  static const VastuProfile defaultCommercial = VastuProfile(
    id: 'default_commercial',
    name: 'Office & Business Space',
    type: VastuProfileType.commercial,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type.name,
    'isCustom': isCustom,
  };

  factory VastuProfile.fromJson(Map<String, dynamic> json) => VastuProfile(
    id: json['id'] as String,
    name: json['name'] as String,
    type: json['type'] == 'commercial'
        ? VastuProfileType.commercial
        : VastuProfileType.residential,
    isCustom: json['isCustom'] as bool? ?? false,
  );
}

enum VastuRoomType {
  poojaRoom, // Mandir / Meditation
  kitchen, // Cooking Stove
  masterBedroom, // Owner's Suite
  cashSafe, // Locker / Treasury
  sleepingHead, // Optimal Head Direction while Sleeping
  mainDoor, // Primary Entrance
  livingRoom, // Drawing Room / Hall
  childrenRoom, // Study / Kids Bedroom
  guestRoom, // Guest Bedroom
  toilets, // Waste & Restroom
}

enum CommercialRoomType {
  managingDirector, // Owner / MD Cabin
  cashierAccounts, // Billing / Cash Counter
  salesMarketing, // Client Acquisition & Networking
  staffWorkstation, // Operations & Administrative Desks
  receptionWaiting, // Front Desk & Client Lounge
  serversMachinery, // Heavy Equipment & IT Server Racks
  conferenceRoom, // Boardroom & Strategy Meetings
  inventoryStorage, // Raw Materials & Stock Storage
}

class VastuZoneInfo {
  final String direction; // e.g. "NE"
  final String englishName; // e.g. "North-East"
  final String sanskritName; // e.g. "Ishan (ईशान)"
  final String rulingDeity; // e.g. "Lord Shiva"
  final VastuElement element; // e.g. VastuElement.water
  final String elementLabel; // e.g. "WATER (जल)"
  final String plainLabel; // e.g. "POOJA ROOM & WATER"
  final String emoji; // e.g. "🛕"
  final double centerDegrees; // e.g. 45.0
  final double startDegrees; // e.g. 22.5
  final double endDegrees; // e.g. 67.5
  final List<String> bestFor; // Optimal placements
  final List<String> avoid; // Strictly avoid
  final int colorValue; // ARGB color representation

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

class Vastu16ZoneInfo {
  final String code; // e.g. "NNE"
  final String name; // e.g. "North-North-East"
  final String sanskritName;
  final VastuElement element;
  final String attribute; // e.g. "Health & Healing"
  final double centerDegrees;
  final double startDegrees;
  final double endDegrees;
  final String recommendedUsage; // Domestic / Commercial usage
  final String avoidUsage;
  final int colorValue;

  const Vastu16ZoneInfo({
    required this.code,
    required this.name,
    required this.sanskritName,
    required this.element,
    required this.attribute,
    required this.centerDegrees,
    required this.startDegrees,
    required this.endDegrees,
    required this.recommendedUsage,
    required this.avoidUsage,
    required this.colorValue,
  });
}

enum EntranceSuitability {
  auspicious(
    'Highly Auspicious',
    'Brings wealth, prosperity and harmony',
    0xFF00E676,
  ),
  neutral(
    'Moderate / Neutral',
    'Acceptable with balanced interior remedies',
    0xFFFFD54F,
  ),
  inauspicious(
    'Inauspicious / Avoid',
    'May generate conflicts, expenditure or obstacles',
    0xFFFF3B30,
  );

  final String label;
  final String consequence;
  final int colorValue;
  const EntranceSuitability(this.label, this.consequence, this.colorValue);
}

class Vastu32ZoneInfo {
  final String padaCode; // e.g. "E3"
  final String deityName; // e.g. "Jayanta"
  final String quadrant; // e.g. "East"
  final double centerDegrees;
  final double startDegrees;
  final double endDegrees;
  final EntranceSuitability suitability;
  final String traditionalEffect;

  const Vastu32ZoneInfo({
    required this.padaCode,
    required this.deityName,
    required this.quadrant,
    required this.centerDegrees,
    required this.startDegrees,
    required this.endDegrees,
    required this.suitability,
    required this.traditionalEffect,
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

class CommercialGuideline {
  final CommercialRoomType type;
  final String title;
  final String emoji;
  final String idealDirection;
  final double targetHeading;
  final String plainPurpose;
  final String businessImpact;
  final List<String> bestPractices;

  const CommercialGuideline({
    required this.type,
    required this.title,
    required this.emoji,
    required this.idealDirection,
    required this.targetHeading,
    required this.plainPurpose,
    required this.businessImpact,
    required this.bestPractices,
  });
}

class VastuGridCell {
  final String
  directionCode; // "NW", "N", "NE", "W", "CENTER", "E", "SW", "S", "SE"
  final String label; // e.g. "NE 045°"
  final String roomName; // e.g. "Pooja Room"
  final String emoji; // e.g. "🛕"
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
  static const String traditionalDisclaimer =
      'Vastu Shastra recommendations are traditional architectural and directional guidelines rooted in Indian cultural heritage. They are intended for harmonious space planning and do not substitute for certified structural engineering, building codes, or legal permits.';

  // -------------------------------------------------------------
  // 1. Classical 8 Directions (Ashta Dikpala)
  // -------------------------------------------------------------
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
      plainLabel: 'POOJA ROOM & MEDITATION',
      emoji: '🛕',
      centerDegrees: 45.0,
      startDegrees: 22.5,
      endDegrees: 67.5,
      bestFor: [
        'Mandir / Pooja Room',
        'Meditation & Yoga Area',
        'Underground Water Tank',
        'Main Entrance (Spiritual Bliss)',
      ],
      avoid: [
        'Kitchen (Fire in Water Zone)',
        'Master Bedroom',
        'Toilets / Dustbins (Defiles Mind)',
        'Heavy Overhead Tanks',
      ],
      colorValue: 0xFF00E5FF, // Cyan
    ),

    // 3. East (Indra / Surya) - 67.5° to 112.5°
    VastuZoneInfo(
      direction: 'E',
      englishName: 'East',
      sanskritName: 'Indra (इन्द्र / सूर्य)',
      rulingDeity: 'Lord of Solar Energy',
      element: VastuElement.air,
      elementLabel: 'AIR / WOOD (वायु)',
      plainLabel: 'MAIN DOOR & LIVING ROOM',
      emoji: '☀️',
      centerDegrees: 90.0,
      startDegrees: 67.5,
      endDegrees: 112.5,
      bestFor: [
        'Main Entrance Doorway',
        'Living Room & Guest Hall',
        'Study Desk (Facing East)',
        'Verandah & Natural Sunlight',
      ],
      avoid: [
        'Heavy Storage & Cupboards',
        'Toilets',
        'Obstructed Walls without Windows',
      ],
      colorValue: 0xFF00E676, // Green
    ),

    // 4. South-East (Agni) - 112.5° to 157.5°
    VastuZoneInfo(
      direction: 'SE',
      englishName: 'South-East',
      sanskritName: 'Agni (अग्नि)',
      rulingDeity: 'Fire God',
      element: VastuElement.fire,
      elementLabel: 'FIRE (अग्नि)',
      plainLabel: 'KITCHEN & FIRE ENERGY',
      emoji: '🔥',
      centerDegrees: 135.0,
      startDegrees: 112.5,
      endDegrees: 157.5,
      bestFor: [
        'Kitchen Cooktop / Burner',
        'Electrical Panels & Inverters',
        'Gas Cylinders & Geysers',
        'Cash Flow Generation',
      ],
      avoid: [
        'Water Tanks & Sinks under Cooktop',
        'Pooja Room (Excess Heat)',
        'Master Bedroom (Insomnia/Anger)',
      ],
      colorValue: 0xFFFF9100, // Amber
    ),

    // 5. South (Yama) - 157.5° to 202.5°
    VastuZoneInfo(
      direction: 'S',
      englishName: 'South',
      sanskritName: 'Yama (यम)',
      rulingDeity: 'God of Dharma & Rest',
      element: VastuElement.earth,
      elementLabel: 'EARTH / FIRE (पृथ्वी)',
      plainLabel: 'SLEEP HEAD & BEDROOM',
      emoji: '🛏️',
      centerDegrees: 180.0,
      startDegrees: 157.5,
      endDegrees: 202.5,
      bestFor: [
        'Head Pointing While Sleeping (S)',
        'Heavy Storage & Cupboards',
        'Secondary Bedroom',
        'High Compound Walls',
      ],
      avoid: [
        'Underground Water Sump',
        'Main Entrance (Unless checked with 32-Pada)',
        'Pooja Room',
      ],
      colorValue: 0xFFFF3B30, // Red
    ),

    // 6. South-West (Niruthi) - 202.5° to 247.5°
    VastuZoneInfo(
      direction: 'SW',
      englishName: 'South-West',
      sanskritName: 'Niruthi (नैऋत्य)',
      rulingDeity: 'Lord of Stability & Heaviness',
      element: VastuElement.earth,
      elementLabel: 'EARTH (पृथ्वी)',
      plainLabel: 'MASTER BEDROOM & HEAVY',
      emoji: '👑',
      centerDegrees: 225.0,
      startDegrees: 202.5,
      endDegrees: 247.5,
      bestFor: [
        'Master Bedroom (Family Head)',
        'Heavy Wardrobes & Safes',
        'Overhead Water Tank on Roof',
        'Highest Floor Level',
      ],
      avoid: [
        'Underground Water Sump or Wells',
        'Kitchen (Damages Health)',
        'Main Entrance (Instability)',
        'Balcony or Cut Corners',
      ],
      colorValue: 0xFFFFB300, // Gold / Earth
    ),

    // 7. West (Varuna) - 247.5° to 292.5°
    VastuZoneInfo(
      direction: 'W',
      englishName: 'West',
      sanskritName: 'Varuna (वरुण)',
      rulingDeity: 'Lord of Water & Prosperity',
      element: VastuElement.space,
      elementLabel: 'SPACE / METAL (आकाश)',
      plainLabel: 'DINING & STUDY ROOM',
      emoji: '📚',
      centerDegrees: 270.0,
      startDegrees: 247.5,
      endDegrees: 292.5,
      bestFor: [
        'Dining Hall',
        'Children Study Room',
        'Overhead Water Tank',
        'Secondary Bedroom',
      ],
      avoid: [
        'Underground Water Sump',
        'Sloping Roof to West',
        'Main Gate (Unless in Sugriva W3/W4)',
      ],
      colorValue: 0xFFB0BEC5, // Slate Space
    ),

    // 8. North-West (Vayu) - 292.5° to 337.5°
    VastuZoneInfo(
      direction: 'NW',
      englishName: 'North-West',
      sanskritName: 'Vayu (वायव्य)',
      rulingDeity: 'Wind God (Movement & Change)',
      element: VastuElement.air,
      elementLabel: 'AIR / MOVEMENT (वायु)',
      plainLabel: 'GUEST ROOM & VEHICLES',
      emoji: '💨',
      centerDegrees: 315.0,
      startDegrees: 292.5,
      endDegrees: 337.5,
      bestFor: [
        'Guest Bedroom',
        'Garage & Vehicle Parking',
        'Finished Goods Storage',
        'Toilet & Waste Outlets',
      ],
      avoid: [
        'Master Bedroom (Restlessness)',
        'Heavy Permanent Safe',
        'Pooja Room',
      ],
      colorValue: 0xFF81D4FA, // Light Blue / Air
    ),
  ];

  // -------------------------------------------------------------
  // 2. Classical 16 Energy Zones (Shodasha Mandala)
  // -------------------------------------------------------------
  static const List<Vastu16ZoneInfo> sixteenZones = [
    Vastu16ZoneInfo(
      code: 'N',
      name: 'North',
      sanskritName: 'Kubera',
      element: VastuElement.water,
      attribute: 'Money & New Opportunities',
      centerDegrees: 0.0,
      startDegrees: 348.75,
      endDegrees: 11.25,
      recommendedUsage: 'Cash safe, study desk, front door',
      avoidUsage: 'Kitchen, heavy clutter, toilets',
      colorValue: 0xFF00E5FF,
    ),
    Vastu16ZoneInfo(
      code: 'NNE',
      name: 'North-North-East',
      sanskritName: 'Aushadhi',
      element: VastuElement.water,
      attribute: 'Health, Immunity & Healing',
      centerDegrees: 22.5,
      startDegrees: 11.25,
      endDegrees: 33.75,
      recommendedUsage: 'Medicine storage, recovery bedroom, doctor desk',
      avoidUsage: 'Dustbins, toilets, dark heavy storage',
      colorValue: 0xFF00E5FF,
    ),
    Vastu16ZoneInfo(
      code: 'NE',
      name: 'North-East',
      sanskritName: 'Ishan',
      element: VastuElement.water,
      attribute: 'Clarity of Mind & Wisdom',
      centerDegrees: 45.0,
      startDegrees: 33.75,
      endDegrees: 56.25,
      recommendedUsage: 'Pooja room, meditation, clear water feature',
      avoidUsage: 'Kitchen, master bedroom, overhead tank',
      colorValue: 0xFF00E5FF,
    ),
    Vastu16ZoneInfo(
      code: 'ENE',
      name: 'East-North-East',
      sanskritName: 'Jayanta',
      element: VastuElement.air,
      attribute: 'Recreation, Fun & Energy Rejuvenation',
      centerDegrees: 67.5,
      startDegrees: 56.25,
      endDegrees: 78.75,
      recommendedUsage: 'Family lounge, club room, reading corner',
      avoidUsage: 'Toilets, heavy filing cabinets',
      colorValue: 0xFF00E676,
    ),
    Vastu16ZoneInfo(
      code: 'E',
      name: 'East',
      sanskritName: 'Indra',
      element: VastuElement.air,
      attribute: 'Social Connectivity & Networking',
      centerDegrees: 90.0,
      startDegrees: 78.75,
      endDegrees: 101.25,
      recommendedUsage: 'Living room, main entrance, PR & reception',
      avoidUsage: 'Toilets, dead walls without ventilation',
      colorValue: 0xFF00E676,
    ),
    Vastu16ZoneInfo(
      code: 'ESE',
      name: 'East-South-East',
      sanskritName: 'Anila',
      element: VastuElement.air,
      attribute: 'Analytical Churning & Decision Making',
      centerDegrees: 112.5,
      startDegrees: 101.25,
      endDegrees: 123.75,
      recommendedUsage: 'Mixer/grinder, analysis desk, discussion room',
      avoidUsage: 'Master bedroom (causes over-thinking/anxiety)',
      colorValue: 0xFF00E676,
    ),
    Vastu16ZoneInfo(
      code: 'SE',
      name: 'South-East',
      sanskritName: 'Agni',
      element: VastuElement.fire,
      attribute: 'Cash Flow, Passion & Liquid Wealth',
      centerDegrees: 135.0,
      startDegrees: 123.75,
      endDegrees: 146.25,
      recommendedUsage: 'Kitchen cooktop, electrical meter, billing counter',
      avoidUsage: 'Water tanks, underground sumps, bedroom',
      colorValue: 0xFFFF9100,
    ),
    Vastu16ZoneInfo(
      code: 'SSE',
      name: 'South-South-East',
      sanskritName: 'Pushan',
      element: VastuElement.fire,
      attribute: 'Power, Confidence & Mental Stamina',
      centerDegrees: 157.5,
      startDegrees: 146.25,
      endDegrees: 168.75,
      recommendedUsage: 'Gym, security guard cabin, executive training',
      avoidUsage: 'Toilets, boring administrative paperwork',
      colorValue: 0xFFFF9100,
    ),
    Vastu16ZoneInfo(
      code: 'S',
      name: 'South',
      sanskritName: 'Yama',
      element: VastuElement.fire,
      attribute: 'Fame, Relaxation & Public Recognition',
      centerDegrees: 180.0,
      startDegrees: 168.75,
      endDegrees: 191.25,
      recommendedUsage:
          'Sleeping with head to South, rest area, awards display',
      avoidUsage: 'Underground water sumps, kitchen sink',
      colorValue: 0xFFFF3B30,
    ),
    Vastu16ZoneInfo(
      code: 'SSW',
      name: 'South-South-West',
      sanskritName: 'Niruthi-Agni',
      element: VastuElement.earth,
      attribute: 'Disposal, Release & Waste Expulsion',
      centerDegrees: 202.5,
      startDegrees: 191.25,
      endDegrees: 213.75,
      recommendedUsage: 'Toilets, septic tank, scrap storage, dustbin',
      avoidUsage: 'Master bed, pooja, safe, kitchen',
      colorValue: 0xFFFFB300,
    ),
    Vastu16ZoneInfo(
      code: 'SW',
      name: 'South-West',
      sanskritName: 'Niruthi',
      element: VastuElement.earth,
      attribute: 'Stability, Relationships & Mastery of Skills',
      centerDegrees: 225.0,
      startDegrees: 213.75,
      endDegrees: 236.25,
      recommendedUsage: 'Master bedroom, MD executive chair, heavy safe',
      avoidUsage: 'Main door, underground water tanks, toilet',
      colorValue: 0xFFFFB300,
    ),
    Vastu16ZoneInfo(
      code: 'WSW',
      name: 'West-South-West',
      sanskritName: 'Dauvarika',
      element: VastuElement.space,
      attribute: 'Education, Savings & Knowledge Retention',
      centerDegrees: 247.5,
      startDegrees: 236.25,
      endDegrees: 258.75,
      recommendedUsage: 'Children study desk, bookshelf, savings box',
      avoidUsage: 'Toilets (flushes away academic focus)',
      colorValue: 0xFFB0BEC5,
    ),
    Vastu16ZoneInfo(
      code: 'W',
      name: 'West',
      sanskritName: 'Varuna',
      element: VastuElement.space,
      attribute: 'Profits, Gains & Fulfillment of Desires',
      centerDegrees: 270.0,
      startDegrees: 258.75,
      endDegrees: 281.25,
      recommendedUsage: 'Dining hall, sales closure desk, profit locker',
      avoidUsage: 'Underground sumps, slope towards west',
      colorValue: 0xFFB0BEC5,
    ),
    Vastu16ZoneInfo(
      code: 'WNW',
      name: 'West-North-West',
      sanskritName: 'Roga-Mukhya',
      element: VastuElement.space,
      attribute: 'Detoxification, Emotional Release & Venting',
      centerDegrees: 292.5,
      startDegrees: 281.25,
      endDegrees: 303.75,
      recommendedUsage: 'Restroom, counseling room, laundry wash area',
      avoidUsage: 'Pooja room, newly married couple bed',
      colorValue: 0xFF81D4FA,
    ),
    Vastu16ZoneInfo(
      code: 'NW',
      name: 'North-West',
      sanskritName: 'Vayu',
      element: VastuElement.air,
      attribute: 'Banking Support & Helpful Connections',
      centerDegrees: 315.0,
      startDegrees: 303.75,
      endDegrees: 326.25,
      recommendedUsage: 'Guest room, vehicle garage, accounts & banking files',
      avoidUsage: 'Master bedroom (causes instability)',
      colorValue: 0xFF81D4FA,
    ),
    Vastu16ZoneInfo(
      code: 'NNW',
      name: 'North-North-West',
      sanskritName: 'Gandharva-Soma',
      element: VastuElement.water,
      attribute: 'Attraction, Charisma & Marital Harmony',
      centerDegrees: 337.5,
      startDegrees: 326.25,
      endDegrees: 348.75,
      recommendedUsage: 'Married couple bedroom, perfume/wardrobe space',
      avoidUsage: 'Toilets, heavy unmovable clutter',
      colorValue: 0xFF00E5FF,
    ),
  ];

  // -------------------------------------------------------------
  // 3. Classical 32 Devata Energy Fields (Padas) for Entrances
  // -------------------------------------------------------------
  static const List<Vastu32ZoneInfo> thirtyTwoZones = [
    // East Quadrant (E1 to E8)
    Vastu32ZoneInfo(
      padaCode: 'E1',
      deityName: 'Shikhi (शिखी)',
      quadrant: 'East',
      centerDegrees: 354.375,
      startDegrees: 348.75,
      endDegrees: 0.0,
      suitability: EntranceSuitability.inauspicious,
      traditionalEffect: 'Risk of fire accidents, financial drain',
    ),
    Vastu32ZoneInfo(
      padaCode: 'E2',
      deityName: 'Parjanya (पर्जन्य)',
      quadrant: 'East',
      centerDegrees: 5.625,
      startDegrees: 0.0,
      endDegrees: 11.25,
      suitability: EntranceSuitability.neutral,
      traditionalEffect: 'Excess expenditure, female health challenges',
    ),
    Vastu32ZoneInfo(
      padaCode: 'E3',
      deityName: 'Jayanta (जयन्त)',
      quadrant: 'East',
      centerDegrees: 16.875,
      startDegrees: 11.25,
      endDegrees: 22.5,
      suitability: EntranceSuitability.auspicious,
      traditionalEffect: 'Victory, sudden monetary gains, enthusiasm',
    ),
    Vastu32ZoneInfo(
      padaCode: 'E4',
      deityName: 'Indra (इन्द्र)',
      quadrant: 'East',
      centerDegrees: 28.125,
      startDegrees: 22.5,
      endDegrees: 33.75,
      suitability: EntranceSuitability.auspicious,
      traditionalEffect: 'Royal association, state power, prosperity',
    ),
    Vastu32ZoneInfo(
      padaCode: 'E5',
      deityName: 'Surya (सूर्य)',
      quadrant: 'East',
      centerDegrees: 39.375,
      startDegrees: 33.75,
      endDegrees: 45.0,
      suitability: EntranceSuitability.neutral,
      traditionalEffect: 'Extreme temperament, fluctuating anger',
    ),
    Vastu32ZoneInfo(
      padaCode: 'E6',
      deityName: 'Satya (सत्य)',
      quadrant: 'East',
      centerDegrees: 50.625,
      startDegrees: 45.0,
      endDegrees: 56.25,
      suitability: EntranceSuitability.inauspicious,
      traditionalEffect: 'Broken commitments, discord with friends',
    ),
    Vastu32ZoneInfo(
      padaCode: 'E7',
      deityName: 'Bhrisha (भृश)',
      quadrant: 'East',
      centerDegrees: 61.875,
      startDegrees: 56.25,
      endDegrees: 67.5,
      suitability: EntranceSuitability.inauspicious,
      traditionalEffect: 'Cruelty, over-anxiety and anger issues',
    ),
    Vastu32ZoneInfo(
      padaCode: 'E8',
      deityName: 'Antariksha (अन्तरिक्ष)',
      quadrant: 'East',
      centerDegrees: 73.125,
      startDegrees: 67.5,
      endDegrees: 78.75,
      suitability: EntranceSuitability.inauspicious,
      traditionalEffect: 'Theft risks, loss of focus, financial instability',
    ),

    // South Quadrant (S1 to S8)
    Vastu32ZoneInfo(
      padaCode: 'S1',
      deityName: 'Agni (अग्नि)',
      quadrant: 'South',
      centerDegrees: 84.375,
      startDegrees: 78.75,
      endDegrees: 90.0,
      suitability: EntranceSuitability.inauspicious,
      traditionalEffect: 'Children issues, litigation, fiery disputes',
    ),
    Vastu32ZoneInfo(
      padaCode: 'S2',
      deityName: 'Pusha (पूषा)',
      quadrant: 'South',
      centerDegrees: 95.625,
      startDegrees: 90.0,
      endDegrees: 101.25,
      suitability: EntranceSuitability.neutral,
      traditionalEffect: 'Bondage, family servitude, subservience',
    ),
    Vastu32ZoneInfo(
      padaCode: 'S3',
      deityName: 'Vitatha (वितथ)',
      quadrant: 'South',
      centerDegrees: 106.875,
      startDegrees: 101.25,
      endDegrees: 112.5,
      suitability: EntranceSuitability.auspicious,
      traditionalEffect: 'Material wealth, skillfulness, business growth',
    ),
    Vastu32ZoneInfo(
      padaCode: 'S4',
      deityName: 'Grihakshta (गृहक्षत)',
      quadrant: 'South',
      centerDegrees: 118.125,
      startDegrees: 112.5,
      endDegrees: 123.75,
      suitability: EntranceSuitability.auspicious,
      traditionalEffect: 'Prosperity, family growth, fame and renown',
    ),
    Vastu32ZoneInfo(
      padaCode: 'S5',
      deityName: 'Yama (यम)',
      quadrant: 'South',
      centerDegrees: 129.375,
      startDegrees: 123.75,
      endDegrees: 135.0,
      suitability: EntranceSuitability.inauspicious,
      traditionalEffect: 'Debts, heavy liabilities, sudden losses',
    ),
    Vastu32ZoneInfo(
      padaCode: 'S6',
      deityName: 'Gandharva (गन्धर्व)',
      quadrant: 'South',
      centerDegrees: 140.625,
      startDegrees: 135.0,
      endDegrees: 146.25,
      suitability: EntranceSuitability.inauspicious,
      traditionalEffect: 'Humiliation, loss of dignity and status',
    ),
    Vastu32ZoneInfo(
      padaCode: 'S7',
      deityName: 'Bhrigraj (भृङ्गराज)',
      quadrant: 'South',
      centerDegrees: 151.875,
      startDegrees: 146.25,
      endDegrees: 157.5,
      suitability: EntranceSuitability.inauspicious,
      traditionalEffect: 'Poverty, unrewarded physical labor',
    ),
    Vastu32ZoneInfo(
      padaCode: 'S8',
      deityName: 'Mriga (मृग)',
      quadrant: 'South',
      centerDegrees: 163.125,
      startDegrees: 157.5,
      endDegrees: 168.75,
      suitability: EntranceSuitability.inauspicious,
      traditionalEffect: 'Loss of strength, family separation',
    ),

    // West Quadrant (W1 to W8)
    Vastu32ZoneInfo(
      padaCode: 'W1',
      deityName: 'Pitru (पितृ)',
      quadrant: 'West',
      centerDegrees: 174.375,
      startDegrees: 168.75,
      endDegrees: 180.0,
      suitability: EntranceSuitability.inauspicious,
      traditionalEffect: 'Stagnant growth, family friction, poverty',
    ),
    Vastu32ZoneInfo(
      padaCode: 'W2',
      deityName: 'Dauvarika (दौवारिक)',
      quadrant: 'West',
      centerDegrees: 185.625,
      startDegrees: 180.0,
      endDegrees: 191.25,
      suitability: EntranceSuitability.neutral,
      traditionalEffect: 'Relationship volatility, delayed commitments',
    ),
    Vastu32ZoneInfo(
      padaCode: 'W3',
      deityName: 'Sugriva (सुग्रीव)',
      quadrant: 'West',
      centerDegrees: 196.875,
      startDegrees: 191.25,
      endDegrees: 202.5,
      suitability: EntranceSuitability.auspicious,
      traditionalEffect: 'Immense wealth, intellectual sharpness, savings',
    ),
    Vastu32ZoneInfo(
      padaCode: 'W4',
      deityName: 'Pushpadanta (पुष्पदन्त)',
      quadrant: 'West',
      centerDegrees: 208.125,
      startDegrees: 202.5,
      endDegrees: 213.75,
      suitability: EntranceSuitability.auspicious,
      traditionalEffect: 'All-round abundance, child prosperity, fame',
    ),
    Vastu32ZoneInfo(
      padaCode: 'W5',
      deityName: 'Varuna (वरुण)',
      quadrant: 'West',
      centerDegrees: 219.375,
      startDegrees: 213.75,
      endDegrees: 225.0,
      suitability: EntranceSuitability.neutral,
      traditionalEffect: 'Fluctuating luck, ambitious over-spending',
    ),
    Vastu32ZoneInfo(
      padaCode: 'W6',
      deityName: 'Asura (असुर)',
      quadrant: 'West',
      centerDegrees: 230.625,
      startDegrees: 225.0,
      endDegrees: 236.25,
      suitability: EntranceSuitability.inauspicious,
      traditionalEffect: 'Depression, constant daily fatigue, stress',
    ),
    Vastu32ZoneInfo(
      padaCode: 'W7',
      deityName: 'Sosha (शोष)',
      quadrant: 'West',
      centerDegrees: 241.875,
      startDegrees: 236.25,
      endDegrees: 247.5,
      suitability: EntranceSuitability.inauspicious,
      traditionalEffect: 'Addictions, health drainage, muscle loss',
    ),
    Vastu32ZoneInfo(
      padaCode: 'W8',
      deityName: 'Papayakshma (पापयक्ष्मा)',
      quadrant: 'West',
      centerDegrees: 253.125,
      startDegrees: 247.5,
      endDegrees: 258.75,
      suitability: EntranceSuitability.inauspicious,
      traditionalEffect: 'Misfortune, deceit, illegal complications',
    ),

    // North Quadrant (N1 to N8)
    Vastu32ZoneInfo(
      padaCode: 'N1',
      deityName: 'Roga (रोग)',
      quadrant: 'North',
      centerDegrees: 264.375,
      startDegrees: 258.75,
      endDegrees: 270.0,
      suitability: EntranceSuitability.inauspicious,
      traditionalEffect: 'Chronic diseases, mental weakness, enmity',
    ),
    Vastu32ZoneInfo(
      padaCode: 'N2',
      deityName: 'Naga (नाग)',
      quadrant: 'North',
      centerDegrees: 275.625,
      startDegrees: 270.0,
      endDegrees: 281.25,
      suitability: EntranceSuitability.neutral,
      traditionalEffect: 'Suspicion, jealousy, distrust between kin',
    ),
    Vastu32ZoneInfo(
      padaCode: 'N3',
      deityName: 'Mukhya (मुख्य)',
      quadrant: 'North',
      centerDegrees: 286.875,
      startDegrees: 281.25,
      endDegrees: 292.5,
      suitability: EntranceSuitability.auspicious,
      traditionalEffect: 'Financial influx, success in manufacturing, wealth',
    ),
    Vastu32ZoneInfo(
      padaCode: 'N4',
      deityName: 'Bhallata (भल्लाट)',
      quadrant: 'North',
      centerDegrees: 298.125,
      startDegrees: 292.5,
      endDegrees: 303.75,
      suitability: EntranceSuitability.auspicious,
      traditionalEffect: 'Huge wealth accumulation, inheritance, peace',
    ),
    Vastu32ZoneInfo(
      padaCode: 'N5',
      deityName: 'Soma (सोम)',
      quadrant: 'North',
      centerDegrees: 309.375,
      startDegrees: 303.75,
      endDegrees: 315.0,
      suitability: EntranceSuitability.auspicious,
      traditionalEffect: 'Spiritual inclination, calm intellect, riches',
    ),
    Vastu32ZoneInfo(
      padaCode: 'N6',
      deityName: 'Bhujanga (भुजङ्ग)',
      quadrant: 'North',
      centerDegrees: 320.625,
      startDegrees: 315.0,
      endDegrees: 326.25,
      suitability: EntranceSuitability.neutral,
      traditionalEffect: 'Secret enmities, unexpected medical costs',
    ),
    Vastu32ZoneInfo(
      padaCode: 'N7',
      deityName: 'Aditi (अदिति)',
      quadrant: 'North',
      centerDegrees: 331.875,
      startDegrees: 326.25,
      endDegrees: 337.5,
      suitability: EntranceSuitability.neutral,
      traditionalEffect: 'Restlessness in women, frequent relocation',
    ),
    Vastu32ZoneInfo(
      padaCode: 'N8',
      deityName: 'Diti (दिति)',
      quadrant: 'North',
      centerDegrees: 343.125,
      startDegrees: 337.5,
      endDegrees: 348.75,
      suitability: EntranceSuitability.neutral,
      traditionalEffect: 'Visionary ideas but low financial conversion',
    ),
  ];

  // -------------------------------------------------------------
  // 4. Commercial Vastu Guidelines
  // -------------------------------------------------------------
  static const List<CommercialGuideline> commercialGuidelines = [
    CommercialGuideline(
      type: CommercialRoomType.managingDirector,
      title: 'Managing Director / Executive Cabin',
      emoji: '👑',
      idealDirection: 'South-West (SW)',
      targetHeading: 225.0,
      plainPurpose:
          'Authority, leadership stability and firm executive decisions',
      businessImpact:
          'Prevents business turnover, ensures command over staff and clients',
      bestPractices: [
        'MD should face North or East while seated at the desk',
        'Solid brick wall behind the MD chair; never a window or glass pane',
        'Heavy wooden desk without sharp irregular corners',
      ],
    ),
    CommercialGuideline(
      type: CommercialRoomType.cashierAccounts,
      title: 'Cashier Desk & Accounts Department',
      emoji: '💰',
      idealDirection: 'North (N) or North-East (NE)',
      targetHeading: 0.0,
      plainPurpose:
          'Accelerates receivables, cash liquidity and audited profits',
      businessImpact:
          'Ensures steady working capital flow and financial solvency',
      bestPractices: [
        'Cash locker should open towards North (Kubera direction)',
        'Accounts books and computers should be in North or East sector',
        'Keep the cash desk immaculate and clutter-free',
      ],
    ),
    CommercialGuideline(
      type: CommercialRoomType.salesMarketing,
      title: 'Sales, Marketing & PR Division',
      emoji: '🚀',
      idealDirection: 'East (E) or North-West (NW)',
      targetHeading: 90.0,
      plainPurpose:
          'Social networking, rapid outreach and dynamic deal closures',
      businessImpact: 'Maximizes customer inquiries and active sales turnover',
      bestPractices: [
        'Sales personnel should face East or North during calls',
        'Display customer testimonials and awards on the North wall',
      ],
    ),
    CommercialGuideline(
      type: CommercialRoomType.staffWorkstation,
      title: 'General Operations & Staff Workstations',
      emoji: '💻',
      idealDirection: 'West (W) or North-West (NW)',
      targetHeading: 270.0,
      plainPurpose: 'Focus, productive execution and disciplined workflows',
      businessImpact:
          'Reduces operational errors, enhances task turnaround times',
      bestPractices: [
        'Staff should face North or East during work',
        'Avoid beams directly overhead working desks',
      ],
    ),
    CommercialGuideline(
      type: CommercialRoomType.receptionWaiting,
      title: 'Front Reception & Visitor Lounge',
      emoji: '🏢',
      idealDirection: 'North-East (NE) or East (E)',
      targetHeading: 45.0,
      plainPurpose: 'Welcoming energy, positive first impressions and goodwill',
      businessImpact: 'Fosters trust, client retention and commercial goodwill',
      bestPractices: [
        'Receptionist desk facing North or East towards incoming visitors',
        'Keep fresh flowers or a subtle water fountain in North-East',
      ],
    ),
    CommercialGuideline(
      type: CommercialRoomType.serversMachinery,
      title: 'IT Server Room & Heavy Machinery',
      emoji: '⚡',
      idealDirection: 'South-East (SE)',
      targetHeading: 135.0,
      plainPurpose:
          'Fire element housing electrical power, servers and engines',
      businessImpact:
          'Minimizes electrical short-circuits, server downtime and fires',
      bestPractices: [
        'Main circuit breaker, transformers and servers strictly in SE',
        'Ensure proper fire extinguishers and exhaust ventilation',
      ],
    ),
    CommercialGuideline(
      type: CommercialRoomType.conferenceRoom,
      title: 'Conference Room & Strategy Boardroom',
      emoji: '📊',
      idealDirection: 'North-West (NW) or West (W)',
      targetHeading: 315.0,
      plainPurpose:
          'Negotiations, contract finalization and collaborative strategy',
      businessImpact: 'Assists in fruitful compromise and successful partnership agreements',
      bestPractices: [
        'Chairperson seats at SW end of the conference table facing East',
        'Rectangular or oval table; avoid L-shaped or jagged tables',
      ],
    ),
    CommercialGuideline(
      type: CommercialRoomType.inventoryStorage,
      title: 'Raw Material & Finished Goods Storage',
      emoji: '📦',
      idealDirection: 'Raw Material in SW; Finished Goods in NW',
      targetHeading: 225.0,
      plainPurpose: 'Raw materials grounded in SW; finished items ready for dispatch in NW',
      businessImpact: 'Raw stock remains protected; finished stock sells out quickly without delay',
      bestPractices: [
        'Heavy unworked goods in South/South-West',
        'Goods packaged for dispatch in North-West (Air movement)',
      ],
    ),
  ];

  // -------------------------------------------------------------
  // 5. 3x3 House Floor Plan Matrix (House Grid)
  // -------------------------------------------------------------
  static const List<VastuGridCell> houseGrid = [
    // Row 1 (Top / North row): NW, N, NE
    VastuGridCell(
      directionCode: 'NW',
      label: 'NW 315°',
      roomName: 'Guest / Storage',
      emoji: '💨',
      roomType: VastuRoomType.guestRoom,
      targetHeading: 315.0,
      colorValue: 0xFF81D4FA,
    ),
    VastuGridCell(
      directionCode: 'N',
      label: 'N 000°',
      roomName: 'Cash / Main Door',
      emoji: '💰',
      roomType: VastuRoomType.cashSafe,
      targetHeading: 0.0,
      colorValue: 0xFF00E5FF,
    ),
    VastuGridCell(
      directionCode: 'NE',
      label: 'NE 045°',
      roomName: 'Pooja / Temple',
      emoji: '🛕',
      roomType: VastuRoomType.poojaRoom,
      targetHeading: 45.0,
      colorValue: 0xFF00E5FF,
    ),

    // Row 2 (Middle row): W, CENTER (Brahmasthan), E
    VastuGridCell(
      directionCode: 'W',
      label: 'W 270°',
      roomName: 'Dining / Study',
      emoji: '📚',
      roomType: VastuRoomType.childrenRoom,
      targetHeading: 270.0,
      colorValue: 0xFFB0BEC5,
    ),
    VastuGridCell(
      directionCode: 'CENTER',
      label: 'CENTER',
      roomName: 'Brahmasthan',
      emoji: '☸️',
      colorValue: 0xFFFFD700,
    ),
    VastuGridCell(
      directionCode: 'E',
      label: 'E 090°',
      roomName: 'Living Room',
      emoji: '☀️',
      roomType: VastuRoomType.livingRoom,
      targetHeading: 90.0,
      colorValue: 0xFF00E676,
    ),

    // Row 3 (Bottom / South row): SW, S, SE
    VastuGridCell(
      directionCode: 'SW',
      label: 'SW 225°',
      roomName: 'Master Bedroom',
      emoji: '👑',
      roomType: VastuRoomType.masterBedroom,
      targetHeading: 225.0,
      colorValue: 0xFFFFB300,
    ),
    VastuGridCell(
      directionCode: 'S',
      label: 'S 180°',
      roomName: 'Bed (Head South)',
      emoji: '🛏️',
      roomType: VastuRoomType.sleepingHead,
      targetHeading: 180.0,
      colorValue: 0xFFFF3B30,
    ),
    VastuGridCell(
      directionCode: 'SE',
      label: 'SE 135°',
      roomName: 'Kitchen (Fire)',
      emoji: '🔥',
      roomType: VastuRoomType.kitchen,
      targetHeading: 135.0,
      colorValue: 0xFFFF9100,
    ),
  ];

  // -------------------------------------------------------------
  // 6. Domestic Room Guidelines
  // -------------------------------------------------------------
  static const List<VastuRoomGuideline> roomGuidelines = [
    VastuRoomGuideline(
      type: VastuRoomType.poojaRoom,
      title: 'Pooja Room / Mandir',
      emoji: '🛕',
      idealDirection: 'North-East (Ishan)',
      targetHeading: 45.0,
      plainPurpose: 'Meditation, divine energy & clarity of thought',
      description: 'The North-East is the sacred corner where spiritual energy converges.',
      reason: 'Cosmic magnetic lines from North and solar rays from East meet here.',
      dos: [
        'Idols should face West so you face East while praying',
        'Keep light white, soft yellow, or light cyan colors',
        'Store holy water, copper vessels, and pooja literature here',
      ],
      donts: [
        'Never build a toilet above, below, or adjacent to the pooja room',
        'Do not place idols directly touching the wall; leave a 2-inch gap',
        'Never store clutter, heavy junk, or brooms inside the mandir',
      ],
    ),
    VastuRoomGuideline(
      type: VastuRoomType.kitchen,
      title: 'Kitchen Cooktop',
      emoji: '🔥',
      idealDirection: 'South-East (Agni)',
      targetHeading: 135.0,
      plainPurpose: 'Food preparation, metabolic health & vitality',
      description: 'The South-East governs the fire element (Agni Devata).',
      reason: 'Morning infrared sun rays sanitize cooking areas without overheating the house.',
      dos: [
        'Position cooktop so the cook faces East while preparing food',
        'Keep drinking water, sinks, and purifiers in North or North-East',
        'Use warm colors like orange, peach, yellow, or soft wood tones',
      ],
      donts: [
        'Never place sink and gas stove side-by-side (Water vs Fire conflict)',
        'Never position the kitchen directly under or next to a toilet',
        'Avoid black or blue granite countertops in South-East',
      ],
    ),
    VastuRoomGuideline(
      type: VastuRoomType.masterBedroom,
      title: 'Master Bedroom',
      emoji: '👑',
      idealDirection: 'South-West (Niruthi)',
      targetHeading: 225.0,
      plainPurpose: 'Leadership, authority, family stability & deep rest',
      description: 'The South-West represents the heavy Earth element.',
      reason: 'Grounded heavy energy provides stability to the head of the household.',
      dos: [
        'Bed should be placed with head towards South or East',
        'Heavy wooden wardrobes should be placed against South and West walls',
        'Use grounding earthy colors like beige, tan, cream, or warm brown',
      ],
      donts: [
        'Never sleep with head facing North (causes magnetic blood pressure strain)',
        'Never place a mirror facing directly towards the sleeping bed',
        'Do not install beams directly over the bed mattress',
      ],
    ),
    VastuRoomGuideline(
      type: VastuRoomType.cashSafe,
      title: 'Cash Safe / Treasury Locker',
      emoji: '💰',
      idealDirection: 'North (Kubera)',
      targetHeading: 0.0,
      plainPurpose: 'Liquid wealth preservation, savings & prosperity',
      description:
          'North is ruled by Lord Kubera, the celestial guardian of wealth.',
      reason:
          'Opening locker doors towards the North invites financial expansion.',
      dos: [
        'Place locker on South wall so its door swings open towards North',
        'Keep a green plant or Kubera Yantra near financial books',
        'Locker should rest on a solid even floor, raised slightly',
      ],
      donts: [
        'Never keep locker under a staircase or facing bathroom door',
        'Locker should not open towards South or West',
        'Do not store legal disputes or unpaid bills inside the cash safe',
      ],
    ),
    VastuRoomGuideline(
      type: VastuRoomType.sleepingHead,
      title: 'Optimal Sleeping Head Direction',
      emoji: '🛏️',
      idealDirection: 'South (Primary) or East (Secondary)',
      targetHeading: 180.0,
      plainPurpose: 'Deep REM sleep, cardiovascular balance & stress relief',
      description:
          'The human body has its own biomagnetic poles (Head is North).',
      reason: 'Sleeping with head to South aligns with Earth’s magnetic field.',
      dos: [
        'Sleep with head towards South for longevity and deep sleep',
        'Students and researchers should sleep with head towards East',
        'Ensure the bed is constructed from natural seasoned solid wood',
      ],
      donts: [
        'NEVER sleep with head pointing towards North (repulsive magnetic strain)',
        'Avoid metal beds which distort local electromagnetic field lines',
        'Do not keep electronic chargers under pillows or next to head',
      ],
    ),
    VastuRoomGuideline(
      type: VastuRoomType.mainDoor,
      title: 'Main Entrance Door',
      emoji: '🚪',
      idealDirection: 'East (090°) or North (000°)',
      targetHeading: 90.0,
      plainPurpose: 'Primary cosmic prana entry & family auspiciousness',
      description: 'The main door is the mouth of the house through which cosmic energy enters.',
      reason: 'East captures early morning beneficial solar spectrum.',
      dos: [
        'Ensure the entrance opens clockwise inward',
        'Place auspicious symbols like Swastika, Om, or Toran at the threshold',
        'Keep the entrance brightly illuminated day and night',
      ],
      donts: [
        'Avoid squeaking hinges or self-closing spring slams',
        'Do not place shoes or dustbins directly in front of main entrance',
        'Main door should not face a stark T-junction road directly',
      ],
    ),
    VastuRoomGuideline(
      type: VastuRoomType.livingRoom,
      title: 'Living Room / Drawing Hall',
      emoji: '🛋️',
      idealDirection: 'East (090°) or North-East (045°)',
      targetHeading: 90.0,
      plainPurpose: 'Family bonding, welcoming guests & harmony',
      description: 'The living room reflects the warmth and social energy of the family.',
      reason:
          'East orientation ensures abundant natural ventilation and light.',
      dos: [
        'Host should sit facing East or North while entertaining guests',
        'Heavy sofa sets should be positioned against South or West walls',
        'Television should be mounted in South-East or North-West wall',
      ],
      donts: [
        'Avoid cluttering the North-East corner of the living room',
        'Do not hang paintings of war, violence, or dry barren trees',
        'Avoid dark heavy curtains that permanently block morning sunlight',
      ],
    ),
    VastuRoomGuideline(
      type: VastuRoomType.childrenRoom,
      title: 'Children Bedroom & Study Room',
      emoji: '🎒',
      idealDirection: 'West (270°) or West-South-West (247.5°)',
      targetHeading: 270.0,
      plainPurpose: 'Academic retention, creative focus & peaceful rest',
      description:
          'The West sector governed by Varuna encourages disciplined learning.',
      reason:
          'Even afternoon light aids study focus without high hyperactivity.',
      dos: [
        'Study desk positioned so child faces East or North while reading',
        'Bookcase located on the North or East wall of the room',
        'Use uplifting colors like light green, pastel blue, or cream',
      ],
      donts: [
        'Do not place mirrors directly in front of the study desk',
        'Avoid bunk beds if possible to prevent oppressive ceiling pressure',
        'Never let study desk face a blank bare dark wall',
      ],
    ),
    VastuRoomGuideline(
      type: VastuRoomType.guestRoom,
      title: 'Guest Bedroom',
      emoji: '🧳',
      idealDirection: 'North-West (Vayu)',
      targetHeading: 315.0,
      plainPurpose: 'Comfortable temporary stay without imposing long stays',
      description:
          'North-West embodies wind energy (Vayu), promoting mobility.',
      reason: 'Guests enjoy their stay but depart harmoniously without overstaying.',
      dos: [
        'Bed positioned with head towards South or East',
        'Keep light pastel shades like off-white, light silver, or sky blue',
        'Provide wardrobe on the South or West wall of the guest room',
      ],
      donts: [
        'Never allocate South-West bedroom to guests (usurps family authority)',
        'Do not place attached toilet directly facing the bed',
        'Avoid heavy dark furniture in guest room',
      ],
    ),
    VastuRoomGuideline(
      type: VastuRoomType.toilets,
      title: 'Restroom & Waste Outlets',
      emoji: '🚽',
      idealDirection: 'South-South-West (202.5°) or West-North-West (292.5°)',
      targetHeading: 202.5,
      plainPurpose:
          'Proper bodily waste disposal without draining positive energy',
      description: 'The SSW and WNW zones naturally govern disposal and detox.',
      reason: 'Prevents contamination of sacred and prosperity sectors.',
      dos: [
        'Commode should face North or South',
        'Ensure proper ventilation window on outer exterior wall',
        'Keep bathroom doors closed at all times',
      ],
      donts: [
        'NEVER place toilet in North-East (destroys mental clarity & prosperity)',
        'Never locate toilet in South-West (destroys relationships & stability)',
        'Do not position toilet adjacent to kitchen or pooja room',
      ],
    ),
  ];

  // -------------------------------------------------------------
  // Calculator Methods
  // -------------------------------------------------------------

  /// 8-Direction Zone Lookup
  static VastuZoneInfo getZone(double headingDegrees) {
    final norm = (headingDegrees % 360.0 + 360.0) % 360.0;
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

  /// 16-Direction Sub-Zone Lookup (Shodasha Mandala)
  static Vastu16ZoneInfo get16Zone(double headingDegrees) {
    final norm = (headingDegrees % 360.0 + 360.0) % 360.0;
    if (norm >= 348.75 || norm < 11.25) {
      return sixteenZones[0]; // North
    }
    for (int i = 1; i < sixteenZones.length; i++) {
      if (norm >= sixteenZones[i].startDegrees &&
          norm < sixteenZones[i].endDegrees) {
        return sixteenZones[i];
      }
    }
    return sixteenZones[0];
  }

  /// 32-Devata Entrance Pada Lookup (Vastu Purusha Mandala)
  static Vastu32ZoneInfo get32Zone(double headingDegrees) {
    final norm = (headingDegrees % 360.0 + 360.0) % 360.0;
    if (norm >= 348.75 || norm < 0.0) {
      return thirtyTwoZones[0]; // E1 Shikhi
    }
    for (int i = 0; i < thirtyTwoZones.length; i++) {
      final z = thirtyTwoZones[i];
      if (z.startDegrees <= z.endDegrees) {
        if (norm >= z.startDegrees && norm < z.endDegrees) {
          return z;
        }
      } else {
        if (norm >= z.startDegrees || norm < z.endDegrees) {
          return z;
        }
      }
    }
    return thirtyTwoZones[0];
  }

  /// Returns domestic room guideline
  static VastuRoomGuideline getGuideline(VastuRoomType room) {
    return roomGuidelines.firstWhere(
      (g) => g.type == room,
      orElse: () => roomGuidelines.first,
    );
  }

  /// Returns commercial room guideline
  static CommercialGuideline getCommercialGuideline(CommercialRoomType room) {
    return commercialGuidelines.firstWhere(
      (g) => g.type == room,
      orElse: () => commercialGuidelines.first,
    );
  }

  /// Checks if current heading is aligned with target room heading within tolerance
  static bool isAlignedWithRoom(
    double heading,
    VastuRoomType room, {
    double tolerance = 15.0,
  }) {
    final guideline = getGuideline(room);
    double diff = (heading - guideline.targetHeading).abs() % 360.0;
    if (diff > 180.0) diff = 360.0 - diff;
    return diff <= tolerance;
  }
}
