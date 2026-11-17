import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

/// BillingService coordinates Google Play Billing for one-time lifetime Pro access.
///
/// Features:
/// - Product ID: [compass_pro_lifetime] (non-consumable, one-time purchase)
/// - Localized price retrieval (e.g. INR ₹149 in India, USD $1.99 in US)
/// - Transaction lifecycle handling: pending, purchased, restored, error, canceled
/// - Purchase completion & acknowledgment per Google Play specifications
/// - Offline resilience and graceful degradation when Play Services are absent
class BillingService {
  static const String proLifetimeProductId = 'compass_pro_lifetime';

  final InAppPurchase _iap;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  ProductDetails? _productDetails;
  Function(bool isPro)? _onEntitlementChanged;
  Function(String? error)? _onError;
  Function(bool isPending)? _onPendingChanged;
  Function(String formattedPrice)? _onPriceLoaded;

  BillingService({InAppPurchase? iap}) : _iap = iap ?? InAppPurchase.instance;

  ProductDetails? get productDetails => _productDetails;

  /// Initializes the billing service and subscribes to the purchase stream.
  void initialize({
    required Function(bool isPro) onEntitlementChanged,
    Function(String? error)? onError,
    Function(bool isPending)? onPendingChanged,
    Function(String formattedPrice)? onPriceLoaded,
  }) {
    _onEntitlementChanged = onEntitlementChanged;
    _onError = onError;
    _onPendingChanged = onPendingChanged;
    _onPriceLoaded = onPriceLoaded;

    try {
      _subscription = _iap.purchaseStream.listen(
        _handlePurchaseUpdates,
        onDone: () => _subscription?.cancel(),
        onError: (error) {
          if (kDebugMode) {
            debugPrint('[BillingService] Stream error: $error');
          }
          _onError?.call(error.toString());
        },
      );

      loadProductDetails();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[BillingService] Platform channel not available: $e');
      }
    }
  }

  /// Queries Google Play Store for the product details of [compass_pro_lifetime].
  Future<void> loadProductDetails() async {
    try {
      final bool available = await _iap.isAvailable();
      if (!available) {
        if (kDebugMode) {
          debugPrint('[BillingService] Google Play Billing unavailable.');
        }
        return;
      }

      final ProductDetailsResponse response = await _iap.queryProductDetails({
        proLifetimeProductId,
      });

      if (response.error != null) {
        if (kDebugMode) {
          debugPrint(
            '[BillingService] Product query error: ${response.error!.message}',
          );
        }
        _onError?.call(response.error!.message);
        return;
      }

      if (response.productDetails.isNotEmpty) {
        _productDetails = response.productDetails.first;
        if (kDebugMode) {
          debugPrint(
            '[BillingService] Loaded product: ${_productDetails!.id}, price: ${_productDetails!.price}',
          );
        }
        _onPriceLoaded?.call(_productDetails!.price);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[BillingService] Exception querying products: $e');
      }
    }
  }

  /// Initiates the Google Play purchase flow for the lifetime Pro license.
  Future<bool> buyProLifetime() async {
    try {
      if (_productDetails == null) {
        await loadProductDetails();
      }

      if (_productDetails == null) {
        _onError?.call(
          'Unable to load product from Google Play. Please check your connection.',
        );
        return false;
      }

      _onPendingChanged?.call(true);
      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: _productDetails!,
      );

      final success = await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      return success;
    } catch (e) {
      _onPendingChanged?.call(false);
      _onError?.call(e.toString());
      return false;
    }
  }

  /// Restores previous purchases across devices and reinstallations.
  Future<void> restorePurchases() async {
    try {
      _onPendingChanged?.call(true);
      await _iap.restorePurchases();
    } catch (e) {
      _onPendingChanged?.call(false);
      _onError?.call(e.toString());
    }
  }

  /// Handles incoming purchase events from the purchase stream.
  Future<void> _handlePurchaseUpdates(
    List<PurchaseDetails> purchaseDetailsList,
  ) async {
    for (final purchase in purchaseDetailsList) {
      if (purchase.productID != proLifetimeProductId) {
        continue;
      }

      switch (purchase.status) {
        case PurchaseStatus.pending:
          _onPendingChanged?.call(true);
          break;

        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          _onPendingChanged?.call(false);
          // Grant entitlement
          _onEntitlementChanged?.call(true);

          // Acknowledge/complete the transaction with Google Play
          if (purchase.pendingCompletePurchase) {
            try {
              await _iap.completePurchase(purchase);
            } catch (e) {
              if (kDebugMode) {
                debugPrint('[BillingService] Error completing purchase: $e');
              }
            }
          }
          break;

        case PurchaseStatus.error:
          _onPendingChanged?.call(false);
          _onError?.call(purchase.error?.message ?? 'Purchase failed.');
          if (purchase.pendingCompletePurchase) {
            try {
              await _iap.completePurchase(purchase);
            } catch (_) {}
          }
          break;

        case PurchaseStatus.canceled:
          _onPendingChanged?.call(false);
          break;
      }
    }
  }

  void dispose() {
    _subscription?.cancel();
  }
}
