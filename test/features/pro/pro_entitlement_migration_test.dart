import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:compass_app/core/theme/app_colors.dart';
import 'package:compass_app/features/pro/controllers/pro_controller.dart';
import 'package:compass_app/features/pro/services/billing_service.dart';

import 'fake_in_app_purchase.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    BillingService.customIapResolver = () => FakeNoopInAppPurchase();
  });

  group('Pro Entitlement Migration Tests (Phase 6B.1)', () {
    test(
      'Migrates legacy compass_is_pro = true to Free and deletes legacy key',
      () async {
        SharedPreferences.setMockInitialValues({
          ProController.keyLegacyIsPro: true,
          'compass_theme_mode': AppThemeMode.arcticCyan.index,
          'compass_saved_waypoints': 'Home:12.34,56.78',
        });

        final controller = ProController(billingService: BillingService());
        // Wait for asynchronous preferences load & migration
        await Future<void>.delayed(const Duration(milliseconds: 20));

        // State must be Free, NOT Pro
        expect(controller.state.isPro, isFalse);

        final prefs = await SharedPreferences.getInstance();
        // Legacy key must be deleted
        expect(prefs.getBool(ProController.keyLegacyIsPro), isNull);
        // New schema marker must be set to 2
        expect(
          prefs.getInt(ProController.keyEntitlementSchemaVersion),
          ProController.currentSchemaVersion,
        );
        // New entitlement cache must be false
        expect(prefs.getBool(ProController.keyProEntitlementCacheV2), isFalse);

        // Unrelated preferences must remain completely untouched
        expect(
          prefs.getInt('compass_theme_mode'),
          AppThemeMode.arcticCyan.index,
        );
        expect(prefs.getString('compass_saved_waypoints'), 'Home:12.34,56.78');

        controller.dispose();
      },
    );

    test('Migrates legacy compass_is_pro = false cleanly', () async {
      SharedPreferences.setMockInitialValues({
        ProController.keyLegacyIsPro: false,
      });

      final controller = ProController(billingService: BillingService());
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(controller.state.isPro, isFalse);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(ProController.keyLegacyIsPro), isNull);
      expect(
        prefs.getInt(ProController.keyEntitlementSchemaVersion),
        ProController.currentSchemaVersion,
      );
      expect(prefs.getBool(ProController.keyProEntitlementCacheV2), isFalse);

      controller.dispose();
    });

    test('Fresh install initializes schema v2 as Free', () async {
      SharedPreferences.setMockInitialValues({});

      final controller = ProController(billingService: BillingService());
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(controller.state.isPro, isFalse);

      final prefs = await SharedPreferences.getInstance();
      expect(
        prefs.getInt(ProController.keyEntitlementSchemaVersion),
        ProController.currentSchemaVersion,
      );
      expect(prefs.getBool(ProController.keyProEntitlementCacheV2), isFalse);

      controller.dispose();
    });

    test(
      'Subsequent launches do not reset genuinely confirmed Pro cache',
      () async {
        // User already has schema v2 and a genuinely confirmed Pro purchase in cache
        SharedPreferences.setMockInitialValues({
          ProController.keyEntitlementSchemaVersion: 2,
          ProController.keyProEntitlementCacheV2: true,
        });

        final controller = ProController(billingService: BillingService());
        await Future<void>.delayed(const Duration(milliseconds: 20));

        // Must load genuine Pro entitlement
        expect(controller.state.isPro, isTrue);

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getBool(ProController.keyProEntitlementCacheV2), isTrue);

        controller.dispose();
      },
    );

    test(
      'Debug Pro override is isolated from genuine persistent cache',
      () async {
        SharedPreferences.setMockInitialValues({
          ProController.keyEntitlementSchemaVersion: 2,
          ProController.keyProEntitlementCacheV2: false,
        });

        final controller = ProController(billingService: BillingService());
        await Future<void>.delayed(const Duration(milliseconds: 20));

        expect(controller.state.isPro, isFalse);

        // Trigger debug in-memory toggle
        controller.debugTogglePro();
        expect(controller.state.isPro, isTrue);

        // Verify persistent cache was NOT modified
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getBool(ProController.keyProEntitlementCacheV2), isFalse);

        // Disabling debug override restores actual entitlement
        controller.debugTogglePro();
        expect(controller.state.isPro, isFalse);

        controller.dispose();
      },
    );

    test('Genuine purchase confirmation persists to v2 cache', () async {
      SharedPreferences.setMockInitialValues({
        ProController.keyEntitlementSchemaVersion: 2,
        ProController.keyProEntitlementCacheV2: false,
      });

      final controller = ProController(billingService: BillingService());
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(controller.state.isPro, isFalse);

      // Simulate verified Google Play purchase callback
      await controller.setEntitledForTesting(true);

      expect(controller.state.isPro, isTrue);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(ProController.keyProEntitlementCacheV2), isTrue);

      controller.dispose();
    });

    test(
      'Existing cached Pro entitlement survives temporary store unavailability',
      () async {
        SharedPreferences.setMockInitialValues({
          ProController.keyEntitlementSchemaVersion: 2,
          ProController.keyProEntitlementCacheV2: true,
        });

        // Test with unavailable InAppPurchase instance
        final unavailableIap =
            FakeNoopInAppPurchase(); // isAvailable returns false
        final billingService = BillingService(iap: unavailableIap);

        final controller = ProController(billingService: billingService);
        await Future<void>.delayed(const Duration(milliseconds: 20));

        // Entitlement must remain Pro offline even when Google Play is unavailable
        expect(controller.state.isPro, isTrue);

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getBool(ProController.keyProEntitlementCacheV2), isTrue);

        controller.dispose();
        billingService.dispose();
        unavailableIap.dispose();
      },
    );
  });
}
