import 'dart:async';
import 'dart:convert';

import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:sass_security/core/billing/store_product_ids.dart';
import 'package:sass_security/core/platform/app_platform.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void _noopIapSync(String? error) {}

/// App Store / Play Store subscription purchase + server verification via Supabase.
class StoreIapService {
  StoreIapService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;
  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  void Function(String? error) _onSync = _noopIapSync;

  Future<bool> get isAvailable async {
    if (!isMobileNativeApp) return false;
    return _iap.isAvailable();
  }

  /// Call once when opening subscription UI. [onStoreSync] is called with null on success.
  void attachListener(void Function(String? error) onStoreSync) {
    _onSync = onStoreSync;
    _subscription?.cancel();
    _subscription = _iap.purchaseStream.listen(_onPurchasesUpdated, onError: (Object e) {
      _onSync(e.toString());
    });
  }

  Future<void> detachListener() async {
    await _subscription?.cancel();
    _subscription = null;
    _onSync = _noopIapSync;
  }

  Future<void> restore() async {
    if (!isMobileNativeApp) return;
    await _iap.restorePurchases();
  }

  Future<Set<String>> queryStoreProductIds(bool yearly) async {
    final id = yearly ? kIapProductYearly : kIapProductMonthly;
    final r = await _iap.queryProductDetails({id});
    if (r.error != null) {
      return {};
    }
    return r.productDetails.map((e) => e.id).toSet();
  }

  Future<bool> buySubscription(bool yearly) async {
    final id = yearly ? kIapProductYearly : kIapProductMonthly;
    final r = await _iap.queryProductDetails({id});
    if (r.productDetails.isEmpty) {
      return false;
    }
    final param = PurchaseParam(productDetails: r.productDetails.first);
    return _iap.buyNonConsumable(purchaseParam: param);
  }

  Future<void> _onPurchasesUpdated(List<PurchaseDetails> purchases) async {
    for (final p in purchases) {
      if (p.status == PurchaseStatus.pending) {
        continue;
      }
      if (p.status == PurchaseStatus.error) {
        _onSync(p.error?.message ?? 'Purchase error');
        continue;
      }
      if (p.status == PurchaseStatus.canceled) {
        continue;
      }
      if (p.status == PurchaseStatus.purchased || p.status == PurchaseStatus.restored) {
        await _syncWithBackend(p);
      }
    }
  }

  Future<void> _syncWithBackend(PurchaseDetails p) async {
    try {
      if (isIOSApp) {
        final receipt = _iosReceiptData(p);
        if (receipt.isEmpty) {
          _onSync('Missing App Store receipt');
          return;
        }
        final res = await _client.functions.invoke(
          'iap-verify-and-sync',
          body: {
            'platform': 'ios',
            'receipt_data': receipt,
          },
        );
        if (!_responseOk(res)) {
          _onSync(_errorMessage(res));
          return;
        }
      } else if (isAndroidApp) {
        final token = _androidPurchaseToken(p);
        if (token.isEmpty) {
          _onSync('Missing Play purchase token');
          return;
        }
        final res = await _client.functions.invoke(
          'iap-verify-and-sync',
          body: {
            'platform': 'android',
            'product_id': p.productID,
            'purchase_token': token,
          },
        );
        if (!_responseOk(res)) {
          _onSync(_errorMessage(res));
          return;
        }
      }

      if (p.pendingCompletePurchase) {
        await _iap.completePurchase(p);
      }
      _onSync(null);
    } catch (e) {
      _onSync(e.toString());
    }
  }

  static bool _responseOk(dynamic res) {
    if (res == null) return false;
    final data = res.data;
    if (data is Map<String, dynamic> && data['error'] != null) {
      return false;
    }
    return res.status == 200;
  }

  static String _errorMessage(dynamic res) {
    final data = res.data;
    if (data is Map<String, dynamic>) {
      return data['error']?.toString() ?? 'Verification failed';
    }
    return 'Verification failed';
  }

  static String _iosReceiptData(PurchaseDetails p) {
    final local = p.verificationData.localVerificationData.trim();
    if (local.isNotEmpty) {
      return local;
    }
    return p.verificationData.serverVerificationData.trim();
  }

  static String _androidPurchaseToken(PurchaseDetails p) {
    final local = p.verificationData.localVerificationData.trim();
    try {
      final map = jsonDecode(local) as Map<String, dynamic>;
      final t = map['purchaseToken'] as String?;
      if (t != null && t.isNotEmpty) {
        return t;
      }
    } catch (_) {}
    final server = p.verificationData.serverVerificationData.trim();
    if (server.isNotEmpty) {
      try {
        final map = jsonDecode(server) as Map<String, dynamic>;
        final t = map['purchaseToken'] as String?;
        if (t != null && t.isNotEmpty) {
          return t;
        }
      } catch (_) {
        return server;
      }
    }
    return local;
  }
}
