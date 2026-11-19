import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

/// BillingService coordinates Google Play Billing for one-time lifetime Pro access.
///
/// Features:
/// - Product ID: [compass_pro_lifetime] (non-consumable, one-time purchase)
/// - Localized price retrieval directly from Google Play (e.g. ₹149.00 in India, $1.99 in US)
/// - Transaction lifecycle handling: pending, purchased, restored, error, canceled
/// - Purchase completion & acknowledgment per Google Play specifications
/// - Offline resilience and graceful degradation when Play Services are absent
/// - Token-based idempotency preventing duplicate entitlement processing
class BillingService {
  static const String proLifetimeProductId = 'compass_pro_lifetime';

  final InAppPurchase _iap;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  ProductDetails? _productDetails;
  Future<void>? _inFlightQuery;
  bool _hasRestoredOnStartup = false;
  final Set<String> _processedPurchaseTokens = <String>{};

  Function(bool isPro)? _onEntitlementChanged;
  Function(String? error)? _onError;
  Function(bool isPending)? _onPendingChanged;
  Function(String formattedPrice)? _onPriceLoaded;
  Function(bool isLoading)? _onLoadingChanged;
  Function(bool isUnavailable)? _onStoreUnavailable;
  Function(bool isNotFound)? _onProductNotFound;

  BillingService({InAppPurchase? iap}) : _iap = iap ?? _resolveDefaultIap();

  static InAppPurchase Function()? customIapResolver;

  static InAppPurchase _resolveDefaultIap() {
    if (customIapResolver != null) {
      return customIapResolver!();
    }
    return InAppPurchase.instance;
  }

  ProductDetails? get productDetails => _productDetails;
  bool get isQueryingProduct => _inFlightQuery != null;
  bool get hasRestoredOnStartup => _hasRestoredOnStartup;

  /// Initializes the billing service and subscribes to the purchase stream before any queries or restore calls.
  void initialize({
    required Function(bool isPro) onEntitlementChanged,
    Function(String? error)? onError,
    Function(bool isPending)? onPendingChanged,
    Function(String formattedPrice)? onPriceLoaded,
    Function(bool isLoading)? onLoadingChanged,
    Function(bool isUnavailable)? onStoreUnavailable,
    Function(bool isNotFound)? onProductNotFound,
  }) {
    _onEntitlementChanged = onEntitlementChanged;
    _onError = onError;
    _onPendingChanged = onPendingChanged;
    _onPriceLoaded = onPriceLoaded;
    _onLoadingChanged = onLoadingChanged;
    _onStoreUnavailable = onStoreUnavailable;
    _onProductNotFound = onProductNotFound;

    try {
      // 1. Register purchase-stream listener first to guarantee no events are missed
      _subscription?.cancel();
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

      // 2. Load localized product details
      loadProductDetails();

      // 3. Trigger automatic background restore once on startup
      _restorePurchasesOnStartup();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[BillingService] Platform channel not available: $e');
      }
    }
  }

  /// Automatically restores purchases once during application startup.
  /// Runs in background without presenting a payment pending spinner.
  Future<void> _restorePurchasesOnStartup() async {
    if (_hasRestoredOnStartup) return;
    _hasRestoredOnStartup = true;

    try {
      final bool available = await _iap.isAvailable();
      if (!available) {
        if (kDebugMode) {
          debugPrint(
            '[BillingService] Store unavailable during startup restore check.',
          );
        }
        return;
      }
      // Note: Do NOT set _onPendingChanged(true) on startup.
      // If the user previously purchased Pro, Google Play emits it to purchaseStream.
      // If the user has no purchase, this completes silently without an indefinite spinner.
      await _iap.restorePurchases();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[BillingService] Exception during startup restore: $e');
      }
    }
  }

  /// Queries Google Play Store for the product details of [compass_pro_lifetime].
  /// Returns existing in-flight future if a query is already executing.
  Future<void> loadProductDetails() {
    if (_inFlightQuery != null) {
      return _inFlightQuery!;
    }
    _inFlightQuery = _performLoadProductDetails().whenComplete(() {
      _inFlightQuery = null;
    });
    return _inFlightQuery!;
  }

  Future<void> _performLoadProductDetails() async {
    _onLoadingChanged?.call(true);

    try {
      final bool available = await _iap.isAvailable();
      if (!available) {
        if (kDebugMode) {
          debugPrint('[BillingService] Google Play Billing unavailable.');
        }
        _onStoreUnavailable?.call(true);
        _onLoadingChanged?.call(false);
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
        _onLoadingChanged?.call(false);
        return;
      }

      if (response.notFoundIDs.contains(proLifetimeProductId) ||
          response.productDetails.isEmpty) {
        if (kDebugMode) {
          debugPrint(
            '[BillingService] Product $proLifetimeProductId not found in store.',
          );
        }
        _onProductNotFound?.call(true);
        _onLoadingChanged?.call(false);
        return;
      }

      _productDetails = response.productDetails.first;
      if (kDebugMode) {
        debugPrint(
          '[BillingService] Loaded product: ${_productDetails!.id}, price: ${_productDetails!.price}',
        );
      }
      _onPriceLoaded?.call(_productDetails!.price);
      _onStoreUnavailable?.call(false);
      _onProductNotFound?.call(false);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[BillingService] Exception querying products: $e');
      }
      _onError?.call(e.toString());
    } finally {
      _onLoadingChanged?.call(false);
    }
  }

  /// Retries querying product details if previous query failed or timed out.
  Future<void> retryProductQuery() async {
    _inFlightQuery = null;
    await loadProductDetails();
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

      final bool success = await _iap.buyNonConsumable(
        purchaseParam: purchaseParam,
      );
      if (!success) {
        _onPendingChanged?.call(false);
      }
      return success;
    } catch (e) {
      _onPendingChanged?.call(false);
      _onError?.call(e.toString());
      return false;
    }
  }

  /// Manual restore action invoked by the user ("Restore Purchases").
  /// Ensures pending spinner clears cleanly even if no purchases exist in the account.
  Future<void> restorePurchases() async {
    try {
      final bool available = await _iap.isAvailable();
      if (!available) {
        _onStoreUnavailable?.call(true);
        _onError?.call(
          'Google Play Store is unavailable. Please check your connection.',
        );
        return;
      }
      _onPendingChanged?.call(true);
      await _iap.restorePurchases();
    } catch (e) {
      _onError?.call(e.toString());
    } finally {
      // Cleanly clear pending state so UI does not remain stuck when 0 purchases exist
      _onPendingChanged?.call(false);
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
          _onError?.call(null);

        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          _onPendingChanged?.call(false);

          // For Android Google Play, the purchase token resides in serverVerificationData.
          // purchaseID is not a purchase token and cannot be used as verification.
          final String purchaseToken = purchase
              .verificationData
              .serverVerificationData
              .trim();
          final bool hasValidToken = purchaseToken.isNotEmpty;
          final bool hasNoError = purchase.error == null;

          if (hasValidToken && hasNoError) {
            // Idempotency: Grant entitlement only once per unique purchase token
            final bool isNewToken = _processedPurchaseTokens.add(purchaseToken);
            if (isNewToken) {
              _onEntitlementChanged?.call(true);
            }

            // Always complete/acknowledge pending purchases with Google Play
            if (purchase.pendingCompletePurchase) {
              try {
                await _iap.completePurchase(purchase);
              } catch (e) {
                if (kDebugMode) {
                  debugPrint('[BillingService] Error completing purchase: $e');
                }
                _onError?.call(
                  'Failed to acknowledge purchase with Google Play. Please check your connection.',
                );
              }
            }
          } else {
            if (kDebugMode) {
              debugPrint(
                '[BillingService] Purchase verification failed or reported error: ${purchase.error}',
              );
            }
            _onError?.call(
              purchase.error?.message ??
                  'Invalid purchase verification: missing purchase token.',
            );
          }

        case PurchaseStatus.error:
          _onPendingChanged?.call(false);
          _onError?.call(purchase.error?.message ?? 'Purchase failed.');
          if (purchase.pendingCompletePurchase) {
            try {
              await _iap.completePurchase(purchase);
            } catch (_) {}
          }

        case PurchaseStatus.canceled:
          _onPendingChanged?.call(false);
      }
    }
  }

  @visibleForTesting
  void resetStartupRestoreForTesting() {
    _hasRestoredOnStartup = false;
    _processedPurchaseTokens.clear();
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}
