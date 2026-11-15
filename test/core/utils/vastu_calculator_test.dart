import 'package:flutter_test/flutter_test.dart';
import 'package:compass_app/core/utils/vastu_calculator.dart';

void main() {
  group('VastuCalculator Tests', () {
    test('computes correct Vastu zone across all cardinal and intercardinal angles', () {
      expect(VastuCalculator.getZone(0.0).direction, 'N');
      expect(VastuCalculator.getZone(359.0).direction, 'N');
      expect(VastuCalculator.getZone(10.0).direction, 'N');

      expect(VastuCalculator.getZone(45.0).direction, 'NE');
      expect(VastuCalculator.getZone(45.0).sanskritName, contains('Ishan'));

      expect(VastuCalculator.getZone(90.0).direction, 'E');
      expect(VastuCalculator.getZone(135.0).direction, 'SE');
      expect(VastuCalculator.getZone(180.0).direction, 'S');
      expect(VastuCalculator.getZone(225.0).direction, 'SW');
      expect(VastuCalculator.getZone(270.0).direction, 'W');
      expect(VastuCalculator.getZone(315.0).direction, 'NW');
    });

    test('room guidelines provide accurate target headings and alignment', () {
      final pooja = VastuCalculator.getGuideline(VastuRoomType.poojaRoom);
      expect(pooja.targetHeading, 45.0);
      expect(VastuCalculator.isAlignedWithRoom(46.0, VastuRoomType.poojaRoom), isTrue);
      expect(VastuCalculator.isAlignedWithRoom(180.0, VastuRoomType.poojaRoom), isFalse);

      final kitchen = VastuCalculator.getGuideline(VastuRoomType.kitchen);
      expect(kitchen.targetHeading, 135.0);

      final master = VastuCalculator.getGuideline(VastuRoomType.masterBedroom);
      expect(master.targetHeading, 225.0);
    });
  });
}
