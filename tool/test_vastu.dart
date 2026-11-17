import '../lib/core/utils/vastu_calculator.dart';

void main() {
  print('Testing VastuCalculator...');

  // Test North wrap-around
  final n0 = VastuCalculator.getZone(0.0);
  assert(n0.direction == 'N', '0° should be North, got ${n0.direction}');
  final n355 = VastuCalculator.getZone(355.0);
  assert(n355.direction == 'N', '355° should be North, got ${n355.direction}');
  final n15 = VastuCalculator.getZone(15.0);
  assert(n15.direction == 'N', '15° should be North, got ${n15.direction}');

  // Test NE (Ishan)
  final ne45 = VastuCalculator.getZone(45.0);
  assert(ne45.direction == 'NE', '45° should be NE, got ${ne45.direction}');
  assert(ne45.sanskritName.contains('Ishan'), 'NE should be Ishan');
  assert(
    ne45.bestFor.any((b) => b.contains('Pooja')),
    'NE should include Pooja Room',
  );

  // Test E (Indra)
  final e90 = VastuCalculator.getZone(90.0);
  assert(e90.direction == 'E', '90° should be East');

  // Test SE (Agneya)
  final se135 = VastuCalculator.getZone(135.0);
  assert(se135.direction == 'SE', '135° should be SE');
  assert(
    se135.bestFor.any((b) => b.contains('Kitchen')),
    'SE should include Kitchen',
  );

  // Test S (Yama)
  final s180 = VastuCalculator.getZone(180.0);
  assert(s180.direction == 'S', '180° should be South');

  // Test SW (Nairutya)
  final sw225 = VastuCalculator.getZone(225.0);
  assert(sw225.direction == 'SW', '225° should be SW');
  assert(
    sw225.bestFor.any((b) => b.contains('Master Bedroom')),
    'SW should include Master Bedroom',
  );

  // Test W (Varuna)
  final w270 = VastuCalculator.getZone(270.0);
  assert(w270.direction == 'W', '270° should be West');

  // Test NW (Vayavya)
  final nw315 = VastuCalculator.getZone(315.0);
  assert(nw315.direction == 'NW', '315° should be NW');

  // Test Room Guidelines and Alignments
  final kitchenGuide = VastuCalculator.getGuideline(VastuRoomType.kitchen);
  assert(kitchenGuide.targetHeading == 135.0, 'Kitchen target should be 135°');
  assert(
    VastuCalculator.isAlignedWithRoom(134.0, VastuRoomType.kitchen),
    '134° should align with kitchen',
  );
  assert(
    !VastuCalculator.isAlignedWithRoom(45.0, VastuRoomType.kitchen),
    '45° should not align with kitchen',
  );

  final poojaGuide = VastuCalculator.getGuideline(VastuRoomType.poojaRoom);
  assert(poojaGuide.targetHeading == 45.0, 'Pooja room target should be 45°');

  print('VastuCalculator tests passed successfully!');
}
