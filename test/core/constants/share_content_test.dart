import 'package:flutter_test/flutter_test.dart';
import 'package:compass_app/core/constants/compass_constants.dart';

void main() {
  group('App Sharing & Distribution Constants Tests', () {
    test('App identity and Package ID match Google Play requirements', () {
      expect(CompassConstants.appName, 'Compass');
      expect(CompassConstants.appPackageId, 'com.chittaranjan.compass');
      expect(
        CompassConstants.playStoreUrl,
        'https://play.google.com/store/apps/details?id=com.chittaranjan.compass',
      );
    });

    test('Share message contains app name, description, and store link', () {
      const msg = CompassConstants.shareMessage;
      expect(msg, contains('Compass'));
      expect(msg, contains('offline-first'));
      expect(msg, contains('True North'));
      expect(msg, contains('Qibla'));
      expect(msg, contains('Vastu'));
      expect(
        msg,
        contains(
          'https://play.google.com/store/apps/details?id=com.chittaranjan.compass',
        ),
      );
    });

    test(
      'Share message contains zero user location or personal identifiers',
      () {
        const msg = CompassConstants.shareMessage;
        // Guarantee privacy: no latitude, longitude, altitude, bearing, or device ID in share text
        expect(msg, isNot(contains('lat')));
        expect(msg, isNot(contains('lng')));
        expect(msg, isNot(contains('coord')));
        expect(msg, isNot(contains('bearing')));
        expect(msg, isNot(contains('altitude')));
        expect(msg, isNot(contains('user')));
        expect(msg, isNot(contains('device')));
      },
    );
  });
}
