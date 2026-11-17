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
  }) : super(
         verificationData: PurchaseVerificationData(
           localVerificationData: 'test_token',
           serverVerificationData: 'test_token',
           source: 'google_play',
         ),
         transactionDate: '2026-11-18',
       ) {
    this.error = error;
    pendingCompletePurchase = pendingComplete;
  }
}

class FakeInAppPurchase extends Fake implements InAppPurchase {
  final StreamController<List<PurchaseDetails>> _controller =
      StreamController<List<PurchaseDetails>>.broadcast();

  bool completePurchaseCalled = false;
  bool restorePurchasesCalled = false;
  bool buyNonConsumableCalled = false;

  @override
  Stream<List<PurchaseDetails>> get purchaseStream => _controller.stream;

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<ProductDetailsResponse> queryProductDetails(
    Set<String> identifiers,
  ) async {
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

        // Wait microtask for stream event
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

    test('Pending purchase status notifies UI correctly', () async {
      bool? pendingState;
      billingService.initialize(
        onEntitlementChanged: (_) {},
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
    });

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
  });
}
