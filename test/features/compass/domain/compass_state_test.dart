import 'package:flutter_test/flutter_test.dart';
import 'package:compass_app/features/compass/domain/compass_state.dart';
import 'package:compass_app/features/compass/domain/heading_type.dart';
import 'package:compass_app/core/constants/compass_constants.dart';

void main() {
  group('CompassState & Constants Tests', () {
    test('CompassConstants.getDirectionLabel resolves 16-point compass rose', () {
      expect(CompassConstants.getDirectionLabel(0.0), 'N');
      expect(CompassConstants.getDirectionLabel(355.0), 'N');
      expect(CompassConstants.getDirectionLabel(5.0), 'N');
      expect(CompassConstants.getDirectionLabel(45.0), 'NE');
      expect(CompassConstants.getDirectionLabel(90.0), 'E');
      expect(CompassConstants.getDirectionLabel(135.0), 'SE');
      expect(CompassConstants.getDirectionLabel(180.0), 'S');
      expect(CompassConstants.getDirectionLabel(225.0), 'SW');
      expect(CompassConstants.getDirectionLabel(270.0), 'W');
      expect(CompassConstants.getDirectionLabel(315.0), 'NW');
    });

    test('CompassState copyWith updates immutably', () {
      const state = CompassState(
        heading: 180.0,
        unwrappedHeading: 180.0,
        headingType: HeadingType.magnetic,
        accuracy: SensorAccuracyLevel.medium,
        pitch: 2.0,
        roll: 1.0,
        isLevel: false,
        hasLocationPermission: false,
      );

      final updated = state.copyWith(
        heading: 0.0,
        unwrappedHeading: 360.0,
        isLevel: true,
        accuracy: SensorAccuracyLevel.high,
      );

      expect(updated.heading, 0.0);
      expect(updated.unwrappedHeading, 360.0);
      expect(updated.isLevel, isTrue);
      expect(updated.accuracy, SensorAccuracyLevel.high);
      expect(updated.headingType, HeadingType.magnetic);
    });
  });
}
