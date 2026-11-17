import '../lib/core/utils/vastu_calculator.dart';

void main() {
  print(
    '=== TESTING EXPANDED VASTU ENGINE (8, 16, 32 ZONES & COMMERCIAL) ===\n',
  );

  // 1. Verify 8-zone lookup
  assert(VastuCalculator.getZone(0.0).direction == 'N', '0° must be North');
  assert(
    VastuCalculator.getZone(45.0).direction == 'NE',
    '45° must be North-East',
  );
  assert(
    VastuCalculator.getZone(135.0).direction == 'SE',
    '135° must be South-East',
  );
  print('  [PASS] 8-Zone lookup verified!');

  // 2. Verify 16-zone lookup
  assert(VastuCalculator.sixteenZones.length == 16, 'Must contain 16 zones');
  assert(VastuCalculator.get16Zone(0.0).code == 'N', '0° must be N in 16-zone');
  assert(VastuCalculator.get16Zone(22.5).code == 'NNE', '22.5° must be NNE');
  assert(VastuCalculator.get16Zone(45.0).code == 'NE', '45° must be NE');
  assert(VastuCalculator.get16Zone(67.5).code == 'ENE', '67.5° must be ENE');
  assert(VastuCalculator.get16Zone(90.0).code == 'E', '90° must be E');
  assert(VastuCalculator.get16Zone(157.5).code == 'SSE', '157.5° must be SSE');
  assert(VastuCalculator.get16Zone(202.5).code == 'SSW', '202.5° must be SSW');
  assert(VastuCalculator.get16Zone(247.5).code == 'WSW', '247.5° must be WSW');
  assert(VastuCalculator.get16Zone(292.5).code == 'WNW', '292.5° must be WNW');
  assert(VastuCalculator.get16Zone(337.5).code == 'NNW', '337.5° must be NNW');
  print('  [PASS] 16-Zone Shodasha Mandala lookup verified!');

  // 3. Verify 32-zone entrance pada lookup
  assert(VastuCalculator.thirtyTwoZones.length == 32, 'Must contain 32 padas');
  final jayanta = VastuCalculator.thirtyTwoZones.firstWhere(
    (p) => p.padaCode == 'E3',
  );
  assert(jayanta.deityName.contains('Jayanta'), 'E3 must be Jayanta');
  assert(
    jayanta.suitability == EntranceSuitability.auspicious,
    'E3 must be auspicious',
  );

  final mukhya = VastuCalculator.thirtyTwoZones.firstWhere(
    (p) => p.padaCode == 'N3',
  );
  assert(mukhya.deityName.contains('Mukhya'), 'N3 must be Mukhya');
  assert(
    mukhya.suitability == EntranceSuitability.auspicious,
    'N3 must be auspicious',
  );

  final yama = VastuCalculator.thirtyTwoZones.firstWhere(
    (p) => p.padaCode == 'S5',
  );
  assert(yama.deityName.contains('Yama'), 'S5 must be Yama');
  assert(
    yama.suitability == EntranceSuitability.inauspicious,
    'S5 must be inauspicious',
  );
  print('  [PASS] 32-Zone Vastu Purusha Mandala entrance pada verified!');

  // 4. Verify Commercial guidelines
  assert(
    VastuCalculator.commercialGuidelines.length >= 8,
    'Must have at least 8 commercial directives',
  );
  final md = VastuCalculator.getCommercialGuideline(
    CommercialRoomType.managingDirector,
  );
  assert(md.idealDirection.contains('South-West'), 'MD must be in South-West');
  final cash = VastuCalculator.getCommercialGuideline(
    CommercialRoomType.cashierAccounts,
  );
  assert(
    cash.idealDirection.contains('North'),
    'Cash counter must be in North',
  );
  print('  [PASS] Commercial Vastu guidelines verified!');

  print('\n=== ALL VASTU ENGINE TESTS PASSED (100%) ===');
}
