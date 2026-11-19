import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:compass_app/features/pro/services/billing_service.dart';

class FakePurchaseDetails extends PurchaseDetails {
  FakePurchaseDetails({
    required super.productID,
    required super.status,
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
  bool restorePurchasesCalled = false;
  bool buyNonConsumableCalled = false;
  bool shouldFailCompletePurchase = false;
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
    restorePurchasesCalled = true;
    _controller.add([
      FakePurchaseDetails(
        productID: BillingService.proLifetimeProductId,
        status: PurchaseStatus.restored,
      ),
    ]);
  }

  @override
  Future<bool> buyNonConsumable({required PurchaseParam purchaseParam}) async {
    buyNonConsumableCalled = true;
    _controller.add([
      FakePurchaseDetails(
        productID: purchaseParam.productDetails.id,
        status: PurchaseStatus.purchased,
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
  group('BillingService & Google Play Lifetime Pro Tests', () {
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

    test('Loads product details with localized INR pricing', () async {
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
    });

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

    test('Handles empty productDetails result gracefully', () async {
      fakeIap.customProductResponse = ProductDetailsResponse(
        productDetails: [],
        notFoundIDs: [],
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

    test(
      'Purchase flow triggers entitlement and completes transaction',
      () async {
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
      },
    );

    test('Restore purchases flow restores entitlement', () async {
      bool? isProRestored;
      billingService.initialize(
        onEntitlementChanged: (pro) => isProRestored = pro,
      );

      await billingService.restorePurchases();
      expect(fakeIap.restorePurchasesCalled, isTrue);

      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(isProRestored, isTrue);
    });

    test(
      'Pending purchase status notifies UI and does not grant Pro',
      () async {
        bool? pendingState;
        bool? isProGranted;
        billingService.initialize(
          onEntitlementChanged: (pro) => isProGranted = pro,
          onPendingChanged: (p) => pendingState = p,
        );

        fakeIap.emitPurchase(
          FakePurchaseDetails(
            productID: BillingService.proLifetimeProductId,
            status: PurchaseStatus.pending,
          ),
        );

        await Future<void>.delayed(const Duration(milliseconds: 10));
        expect(pendingState, isTrue);
        expect(isProGranted, isNull);
      },
    );

    test(
      'Canceled purchase clears pending state and does not report error',
      () async {
        bool? pendingState;
        String? errorReported;
        billingService.initialize(
          onEntitlementChanged: (_) {},
          onPendingChanged: (p) => pendingState = p,
          onError: (err) => errorReported = err,
        );

        fakeIap.emitPurchase(
          FakePurchaseDetails(
            productID: BillingService.proLifetimeProductId,
            status: PurchaseStatus.canceled,
          ),
        );

        await Future<void>.delayed(const Duration(milliseconds: 10));
        expect(pendingState, isFalse);
        expect(errorReported, isNull);
      },
    );

    test('Error during purchase reports message to error callback', () async {
      String? reportedError;
      billingService.initialize(
        onEntitlementChanged: (_) {},
        onError: (e) => reportedError = e,
      );

      fakeIap.emitPurchase(
        FakePurchaseDetails(
          productID: BillingService.proLifetimeProductId,
          status: PurchaseStatus.error,
          error: IAPError(
            source: 'google_play',
            code: 'ITEM_ALREADY_OWNED',
            message: 'User already owns this item.',
          ),
        ),
      );

      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(reportedError, contains('already owns'));
    });

    test('Ignores purchase events for unrelated product IDs', () async {
      bool? isProGranted;
      billingService.initialize(onEntitlementChanged: (p) => isProGranted = p);

      fakeIap.emitPurchase(
        FakePurchaseDetails(
          productID: 'some_other_subscription',
          status: PurchaseStatus.purchased,
        ),
      );

      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(isProGranted, isNull);
    });

    test('Invalid or empty verification data does not grant Pro', () async {
      bool? isProGranted;
      String? reportedError;
      billingService.initialize(
        onEntitlementChanged: (p) => isProGranted = p,
        onError: (e) => reportedError = e,
      );

      fakeIap.emitPurchase(
        FakePurchaseDetails(
          productID: BillingService.proLifetimeProductId,
          status: PurchaseStatus.purchased,
          localVerification: '',
          serverVerification: '',
        ),
      );

      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(isProGranted, isNull);
      expect(reportedError, contains('verification'));
    });

    test('Duplicate purchase stream events are idempotent', () async {
      int grantCount = 0;
      billingService.initialize(onEntitlementChanged: (_) => grantCount++);

      final purchase = FakePurchaseDetails(
        productID: BillingService.proLifetimeProductId,
        status: PurchaseStatus.purchased,
      );

      fakeIap.emitPurchase(purchase);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      fakeIap.emitPurchase(purchase);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(grantCount, 2); // Idempotent notifications to state controller
    });

    test('Failure in completePurchase reports error to UI', () async {
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
        ),
      );

      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(reportedError, contains('Failed to acknowledge purchase'));
    });
  });
}
