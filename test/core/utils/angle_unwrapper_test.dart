import 'package:flutter_test/flutter_test.dart';
import 'package:compass_app/core/utils/angle_unwrapper.dart';

void main() {
  group('AngleUnwrapper Tests', () {
    test('Initializes with first target angle', () {
      final unwrapper = AngleUnwrapper();
      expect(unwrapper.isInitialized, isFalse);

      final unwrapped = unwrapper.unwrap(45.0);
      expect(unwrapped, 45.0);
      expect(unwrapper.isInitialized, isTrue);
    });

    test('Small clockwise change within same revolution', () {
      final unwrapper = AngleUnwrapper(10.0);
      unwrapper.unwrap(10.0); // initialize
      final next = unwrapper.unwrap(15.0);
      expect(next, 15.0);
    });

    test('Small counter-clockwise change within same revolution', () {
      final unwrapper = AngleUnwrapper(15.0);
      unwrapper.unwrap(15.0);
      final next = unwrapper.unwrap(10.0);
      expect(next, 10.0);
    });

    test('Clockwise wrap-around from 359° to 1° steps +2°, not -358°', () {
      final unwrapper = AngleUnwrapper(359.0);
      unwrapper.unwrap(359.0);
      final next = unwrapper.unwrap(1.0);
      expect(next, 361.0); // 359 + 2
    });

    test('Counter-clockwise wrap-around from 1° to 359° steps -2°, not +358°', () {
      final unwrapper = AngleUnwrapper(1.0);
      unwrapper.unwrap(1.0);
      final next = unwrapper.unwrap(359.0);
      expect(next, -1.0); // 1 - 2
    });

    test('Multiple complete clockwise revolutions unwrap continuously', () {
      final unwrapper = AngleUnwrapper(350.0);
      unwrapper.unwrap(350.0);

      // Turn past north into revolution 1
      var angle = unwrapper.unwrap(10.0);
      expect(angle, 370.0);

      angle = unwrapper.unwrap(180.0);
      expect(angle, 540.0);

      // Continue clockwise: 180° -> 270° -> 350° -> 10°
      angle = unwrapper.unwrap(270.0);
      expect(angle, 630.0);

      angle = unwrapper.unwrap(350.0);
      expect(angle, 710.0);

      // Turn past north into revolution 2
      angle = unwrapper.unwrap(10.0);
      expect(angle, 730.0);
    });

    test('Reset correctly re-centers angle unwrapper', () {
      final unwrapper = AngleUnwrapper(730.0);
      unwrapper.unwrap(730.0);

      unwrapper.reset(45.0);
      expect(unwrapper.currentAngle, 45.0);

      final next = unwrapper.unwrap(50.0);
      expect(next, 50.0);
    });
  });
}
