import 'package:flutter_test/flutter_test.dart';
import 'package:compass_app/core/utils/vastu_calculator.dart';

void main() {
  group('VastuCalculator Tests', () {
    test('computes correct 8-direction Vastu zone across all angles', () {
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

    test('computes correct 16-zone Shodasha Mandala sub-zones', () {
      expect(VastuCalculator.sixteenZones.length, 16);
      expect(VastuCalculator.get16Zone(0.0).code, 'N');
      expect(VastuCalculator.get16Zone(22.5).code, 'NNE');
      expect(VastuCalculator.get16Zone(45.0).code, 'NE');
      expect(VastuCalculator.get16Zone(67.5).code, 'ENE');
      expect(VastuCalculator.get16Zone(90.0).code, 'E');
      expect(VastuCalculator.get16Zone(112.5).code, 'ESE');
      expect(VastuCalculator.get16Zone(135.0).code, 'SE');
      expect(VastuCalculator.get16Zone(157.5).code, 'SSE');
      expect(VastuCalculator.get16Zone(180.0).code, 'S');
      expect(VastuCalculator.get16Zone(202.5).code, 'SSW');
      expect(VastuCalculator.get16Zone(225.0).code, 'SW');
      expect(VastuCalculator.get16Zone(247.5).code, 'WSW');
      expect(VastuCalculator.get16Zone(270.0).code, 'W');
      expect(VastuCalculator.get16Zone(292.5).code, 'WNW');
      expect(VastuCalculator.get16Zone(315.0).code, 'NW');
      expect(VastuCalculator.get16Zone(337.5).code, 'NNW');
    });

    test('computes 32-zone entrance pada fields and auspiciousness', () {
      expect(VastuCalculator.thirtyTwoZones.length, 32);
      final jayanta = VastuCalculator.thirtyTwoZones.firstWhere((p) => p.padaCode == 'E3');
      expect(jayanta.deityName, contains('Jayanta'));
      expect(jayanta.suitability, EntranceSuitability.auspicious);

      final mukhya = VastuCalculator.thirtyTwoZones.firstWhere((p) => p.padaCode == 'N3');
      expect(mukhya.deityName, contains('Mukhya'));
      expect(mukhya.suitability, EntranceSuitability.auspicious);

      final yama = VastuCalculator.thirtyTwoZones.firstWhere((p) => p.padaCode == 'S5');
      expect(yama.suitability, EntranceSuitability.inauspicious);
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

    test('commercial guidelines provide accurate executive placements', () {
      final md = VastuCalculator.getCommercialGuideline(CommercialRoomType.managingDirector);
      expect(md.targetHeading, 225.0);
      expect(md.idealDirection, contains('South-West'));

      final cashier = VastuCalculator.getCommercialGuideline(CommercialRoomType.cashierAccounts);
      expect(cashier.targetHeading, 0.0);
      expect(cashier.idealDirection, contains('North'));
    });
  });
}
