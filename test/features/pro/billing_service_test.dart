import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:compass_app/features/pro/services/billing_service.dart';

class FakePurchaseDetails extends PurchaseDetails {
  FakePurchaseDetails({
    required super.productID,
    required super.status,
    super.purchaseID,
    IAPError? error,
    bool pendingComplete = true,
    String localVerification = 'test_token',
    String serverVerification = 'test_token',
  }) : super(
         verificationData: PurchaseVerificationData(
           localVerificationData: localVerification,
           serverVerificationData: serverVerification,
           source: 'google_play',
         ),
         transactionDate: '2026-11-19',
       ) {
    this.error = error;
    pendingCompletePurchase = pendingComplete;
  }
}

class FakeInAppPurchase extends Fake implements InAppPurchase {
  final StreamController<List<PurchaseDetails>> _controller =
      StreamController<List<PurchaseDetails>>.broadcast();

  bool available = true;
  bool completePurchaseCalled = false;
  int restorePurchasesCount = 0;
  bool hasListenerWhenRestoring = false;
  bool buyNonConsumableCalled = false;
  bool buyNonConsumableResult = true;
  bool shouldThrowOnBuy = false;
  bool shouldFailCompletePurchase = false;
  bool emitOnRestore = false;
  ProductDetailsResponse? customProductResponse;

  @override
  Stream<List<PurchaseDetails>> get purchaseStream => _controller.stream;

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<ProductDetailsResponse> queryProductDetails(
    Set<String> identifiers,
  ) async {
    if (customProductResponse != null) {
      return customProductResponse!;
    }
    final products = identifiers.map((id) {
      return ProductDetails(
        id: id,
        title: 'Compass Pro Lifetime',
        description:
            'Unlimited waypoints, 32-zone Vastu, Night Vision & Bearing Lock',
        price: '₹149.00',
        rawPrice: 149.0,
        currencyCode: 'INR',
        currencySymbol: '₹',
      );
    }).toList();

    return ProductDetailsResponse(productDetails: products, notFoundIDs: []);
  }

  @override
  Future<void> completePurchase(PurchaseDetails purchase) async {
    if (shouldFailCompletePurchase) {
      throw Exception('Network timeout completing purchase');
    }
    completePurchaseCalled = true;
  }

  @override
  Future<void> restorePurchases({String? applicationUserName}) async {
    restorePurchasesCount++;
    hasListenerWhenRestoring = _controller.hasListener;
    if (emitOnRestore) {
      _controller.add([
        FakePurchaseDetails(
          productID: BillingService.proLifetimeProductId,
          status: PurchaseStatus.restored,
          serverVerification: 'restored_token_123',
        ),
      ]);
    }
  }

  @override
  Future<bool> buyNonConsumable({required PurchaseParam purchaseParam}) async {
    buyNonConsumableCalled = true;
    if (shouldThrowOnBuy) {
      throw Exception('Google Play service unavailable');
    }
    if (!buyNonConsumableResult) {
      return false;
    }
    _controller.add([
      FakePurchaseDetails(
        productID: purchaseParam.productDetails.id,
        status: PurchaseStatus.purchased,
        serverVerification: 'new_purchase_token_456',
      ),
    ]);
    return true;
  }

  void emitPurchase(PurchaseDetails details) {
    _controller.add([details]);
  }

  void dispose() {
    _controller.close();
  }
}

void main() {
  group('BillingService & Google Play Lifetime Pro Tests (Phase 6B.2)', () {
    late FakeInAppPurchase fakeIap;
    late BillingService billingService;

    setUp(() {
      fakeIap = FakeInAppPurchase();
      billingService = BillingService(iap: fakeIap);
    });

    tearDown(() {
      billingService.dispose();
      fakeIap.dispose();
    });

    test('Validates product ID is compass_pro_lifetime', () {
      expect(BillingService.proLifetimeProductId, 'compass_pro_lifetime');
    });

    test('1. Startup subscribes to purchase stream before restoring', () async {
      fakeIap.emitOnRestore = false;

      billingService.initialize(onEntitlementChanged: (_) {});

      // Wait microtask for startup initialization sequence
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(fakeIap.hasListenerWhenRestoring, isTrue);
      expect(fakeIap.restorePurchasesCount, 1);
    });

    test('2. Startup restore is triggered only once', () async {
      fakeIap.emitOnRestore = false;

      billingService.initialize(onEntitlementChanged: (_) {});
      await Future<void>.delayed(const Duration(milliseconds: 10));

      // Re-initialize or load details should not re-trigger startup restore
      await billingService.loadProductDetails();
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(fakeIap.restorePurchasesCount, 1);
      expect(billingService.hasRestoredOnStartup, isTrue);
    });

    test(
      'Startup restore with existing purchase grants Pro automatically',
      () async {
        fakeIap.emitOnRestore = true;
        bool? isProGranted;

        billingService.initialize(
          onEntitlementChanged: (pro) => isProGranted = pro,
        );
        await Future<void>.delayed(const Duration(milliseconds: 10));

        expect(isProGranted, isTrue);
      },
    );

    test(
      'Manual restore flow with existing purchase restores entitlement',
      () async {
        fakeIap.emitOnRestore = true;
        bool? isProRestored;

        billingService.initialize(
          onEntitlementChanged: (pro) => isProRestored = pro,
        );

        await billingService.restorePurchases();
        await Future<void>.delayed(const Duration(milliseconds: 10));

        expect(isProRestored, isTrue);
      },
    );

    test('4. Restore with no previous purchases finishes cleanly without indefinite pending state', () async {
      fakeIap.emitOnRestore =
          false; // Simulates Google Play returning 0 purchases
      bool? pendingState;

      billingService.initialize(
        onEntitlementChanged: (_) {},
        onPendingChanged: (p) => pendingState = p,
      );

      final restoreFuture = billingService.restorePurchases();
      // Should clear pending state upon completion
      await restoreFuture;
      expect(pendingState, isFalse);
    });

    test('5. Empty serverVerificationData with a non-empty purchaseID does not grant Pro', () async {
      bool? isProGranted;
      String? reportedError;

      billingService.initialize(
        onEntitlementChanged: (p) => isProGranted = p,
        onError: (err) => reportedError = err,
      );

      // Invalid: Has a purchaseID ('order_12345') but EMPTY serverVerificationData (token)
      fakeIap.emitPurchase(
        FakePurchaseDetails(
          productID: BillingService.proLifetimeProductId,
          status: PurchaseStatus.purchased,
          purchaseID: 'order_12345',
          serverVerification: '   ', // whitespace / empty token
          localVerification: '{"orderId":"order_12345"}',
        ),
      );

      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(isProGranted, isNull);
      expect(reportedError, contains('missing purchase token'));
    });

    test('6. Valid matching purchase with non-empty serverVerificationData grants Pro', () async {
      bool? isProGranted;
      billingService.initialize(
        onEntitlementChanged: (pro) => isProGranted = pro,
      );
      await billingService.loadProductDetails();

      final started = await billingService.buyProLifetime();
      expect(started, isTrue);
      expect(fakeIap.buyNonConsumableCalled, isTrue);

      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(isProGranted, isTrue);
      expect(fakeIap.completePurchaseCalled, isTrue);
    });

    test(
      '7. Duplicate delivery of the same token grants Pro only once',
      () async {
        int grantCount = 0;
        billingService.initialize(onEntitlementChanged: (_) => grantCount++);

        final purchase = FakePurchaseDetails(
          productID: BillingService.proLifetimeProductId,
          status: PurchaseStatus.purchased,
          serverVerification: 'unique_verified_token_999',
        );

        // First delivery: grants entitlement
        fakeIap.emitPurchase(purchase);
        await Future<void>.delayed(const Duration(milliseconds: 10));

        // Duplicate delivery: must NOT trigger grant again
        fakeIap.emitPurchase(purchase);
        await Future<void>.delayed(const Duration(milliseconds: 10));

        expect(grantCount, 1);
        expect(fakeIap.completePurchaseCalled, isTrue);
      },
    );

    test('8. Unrelated product IDs are ignored', () async {
      bool? isProGranted;
      billingService.initialize(onEntitlementChanged: (p) => isProGranted = p);

      fakeIap.emitPurchase(
        FakePurchaseDetails(
          productID: 'some_other_tier_or_consumable',
          status: PurchaseStatus.purchased,
          serverVerification: 'token_abc',
        ),
      );

      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(isProGranted, isNull);
    });

    test('9. Pending and canceled purchases do not grant Pro', () async {
      bool? isProGranted;
      bool? pendingState;

      billingService.initialize(
        onEntitlementChanged: (p) => isProGranted = p,
        onPendingChanged: (p) => pendingState = p,
      );

      // Pending event
      fakeIap.emitPurchase(
        FakePurchaseDetails(
          productID: BillingService.proLifetimeProductId,
          status: PurchaseStatus.pending,
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(isProGranted, isNull);
      expect(pendingState, isTrue);

      // Canceled event
      fakeIap.emitPurchase(
        FakePurchaseDetails(
          productID: BillingService.proLifetimeProductId,
          status: PurchaseStatus.canceled,
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(isProGranted, isNull);
      expect(pendingState, isFalse);
    });

    test('10. Purchase launch returning false clears pending', () async {
      fakeIap.buyNonConsumableResult = false;
      bool? pendingState;

      billingService.initialize(
        onEntitlementChanged: (_) {},
        onPendingChanged: (p) => pendingState = p,
      );
      await billingService.loadProductDetails();

      final result = await billingService.buyProLifetime();
      expect(result, isFalse);
      expect(pendingState, isFalse);
    });

    test(
      '11. Exception during purchase launch clears pending and reports error',
      () async {
        fakeIap.shouldThrowOnBuy = true;
        bool? pendingState;
        String? reportedError;

        billingService.initialize(
          onEntitlementChanged: (_) {},
          onPendingChanged: (p) => pendingState = p,
          onError: (err) => reportedError = err,
        );
        await billingService.loadProductDetails();

        final result = await billingService.buyProLifetime();
        expect(result, isFalse);
        expect(pendingState, isFalse);
        expect(reportedError, contains('service unavailable'));
      },
    );

    test('12. Purchase completion errors are reported without silently claiming acknowledgement', () async {
      fakeIap.shouldFailCompletePurchase = true;
      String? reportedError;
      billingService.initialize(
        onEntitlementChanged: (_) {},
        onError: (err) => reportedError = err,
      );

      fakeIap.emitPurchase(
        FakePurchaseDetails(
          productID: BillingService.proLifetimeProductId,
          status: PurchaseStatus.purchased,
          serverVerification: 'token_will_fail_complete',
        ),
      );

      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(
        reportedError,
        contains('Failed to acknowledge purchase with Google Play'),
      );
    });

    test(
      'Loads product details with localized INR pricing from store',
      () async {
        String? loadedPrice;
        billingService.initialize(
          onEntitlementChanged: (_) {},
          onPriceLoaded: (p) => loadedPrice = p,
        );

        await billingService.loadProductDetails();

        expect(billingService.productDetails, isNotNull);
        expect(billingService.productDetails!.id, 'compass_pro_lifetime');
        expect(billingService.productDetails!.price, '₹149.00');
        expect(loadedPrice, '₹149.00');
      },
    );

    test(
      'Loads foreign currency pricing formatted by store without hardcoded INR',
      () async {
        fakeIap.customProductResponse = ProductDetailsResponse(
          productDetails: [
            ProductDetails(
              id: 'compass_pro_lifetime',
              title: 'Compass Pro Lifetime',
              description: 'Lifetime access',
              price: '\$1.99',
              rawPrice: 1.99,
              currencyCode: 'USD',
              currencySymbol: '\$',
            ),
          ],
          notFoundIDs: [],
        );

        String? loadedPrice;
        billingService.initialize(
          onEntitlementChanged: (_) {},
          onPriceLoaded: (p) => loadedPrice = p,
        );

        await billingService.loadProductDetails();
        expect(loadedPrice, '\$1.99');
      },
    );

    test('Handles store unavailable gracefully', () async {
      fakeIap.available = false;
      bool? isStoreUnavailable;
      billingService.initialize(
        onEntitlementChanged: (_) {},
        onStoreUnavailable: (u) => isStoreUnavailable = u,
      );

      await billingService.loadProductDetails();
      expect(isStoreUnavailable, isTrue);
      expect(billingService.productDetails, isNull);
    });

    test('Handles product in notFoundIDs gracefully', () async {
      fakeIap.customProductResponse = ProductDetailsResponse(
        productDetails: [],
        notFoundIDs: ['compass_pro_lifetime'],
      );

      bool? isNotFound;
      billingService.initialize(
        onEntitlementChanged: (_) {},
        onProductNotFound: (nf) => isNotFound = nf,
      );

      await billingService.loadProductDetails();
      expect(isNotFound, isTrue);
      expect(billingService.productDetails, isNull);
    });

    test('Handles queryProductDetails error correctly', () async {
      fakeIap.customProductResponse = ProductDetailsResponse(
        productDetails: [],
        notFoundIDs: [],
        error: IAPError(
          source: 'google_play',
          code: 'BILLING_UNAVAILABLE',
          message: 'Billing API unavailable',
        ),
      );

      String? reportedError;
      billingService.initialize(
        onEntitlementChanged: (_) {},
        onError: (err) => reportedError = err,
      );

      await billingService.loadProductDetails();
      expect(reportedError, 'Billing API unavailable');
    });
  });
}
