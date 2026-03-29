import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/billing_history_event.dart';
import '../models/invoice_history_item.dart';
import '../models/subscription_record.dart';

class BillingSnapshot {
  const BillingSnapshot({
    required this.invoices,
    required this.billingEvents,
  });

  final List<InvoiceHistoryItem> invoices;
  final List<BillingHistoryEvent> billingEvents;
}

class SubscriptionService {
  SubscriptionService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<SubscriptionRecord?> currentForCompany(String companyId) async {
    final row = await _client
        .from('security_cg_subscriptions')
        .select(
          'plan,status,current_period_end,licensed_seats,stripe_subscription_id,billing_interval,billing_provider,created_at',
        )
        .eq('company_id', companyId)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (row == null) {
      return null;
    }

    return SubscriptionRecord.fromMap(row);
  }

  Future<int> fetchCompanyRiskScore(String companyId) async {
    final row = await _client
        .from('security_cg_companies')
        .select('risk_score')
        .eq('id', companyId)
        .maybeSingle();
    if (row == null) return 0;
    final v = row['risk_score'];
    if (v is num) return v.round().clamp(0, 100);
    return int.tryParse('$v')?.clamp(0, 100) ?? 0;
  }

  Future<void> openCheckout({
    required int users,
    String? stripeLocale,
    required String billingInterval,
  }) async {
    final body = <String, dynamic>{
      'users': users,
      'billing_interval': billingInterval,
      if (stripeLocale != null && stripeLocale.isNotEmpty) 'locale': stripeLocale,
    };
    final response = await _client.functions.invoke(
      'stripe-checkout',
      body: body,
    );
    final data = response.data as Map<String, dynamic>?;
    final url = data?['url'] as String?;

    if (url == null || url.isEmpty) {
      throw const PostgrestException(
        message: 'Stripe checkout URL not available.',
      );
    }

    await _openUrl(url);
  }

  Future<BillingSnapshot> fetchBillingSnapshot() async {
    final response = await _client.functions.invoke('stripe-list-invoices');
    final data = response.data as Map<String, dynamic>?;
    final raw = data?['invoices'];
    final invList = raw is List
        ? raw
            .map((e) => InvoiceHistoryItem.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList()
        : const <InvoiceHistoryItem>[];
    final evRaw = data?['billing_events'];
    final evList = evRaw is List
        ? evRaw
            .map((e) => BillingHistoryEvent.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList()
        : const <BillingHistoryEvent>[];
    return BillingSnapshot(invoices: invList, billingEvents: evList);
  }

  Future<void> scheduleMonthlyAtRenewal() async {
    final response = await _client.functions.invoke('stripe-schedule-monthly');
    final map = response.data;
    if (map is Map<String, dynamic> && map['error'] != null) {
      final code = map['error'];
      if (code == 'already_monthly') {
        throw SubscriptionBillingException('already_monthly');
      }
      throw SubscriptionBillingException(
        (map['message'] ?? code)?.toString() ?? 'Request failed',
      );
    }
    if (response.status != 200) {
      throw SubscriptionBillingException('Request failed');
    }
  }

  Future<void> cancelSubscriptionAtPeriodEnd() async {
    await _client.functions.invoke('stripe-cancel-subscription');
  }

  Future<void> openBillingPortal({String? stripeLocale}) async {
    final body = <String, dynamic>{
      if (stripeLocale != null && stripeLocale.isNotEmpty) 'locale': stripeLocale,
    };
    final response = await _client.functions.invoke(
      'create-billing-portal',
      body: body,
    );
    final data = response.data as Map<String, dynamic>?;
    final url = data?['url'] as String?;

    if (url == null || url.isEmpty) {
      throw const PostgrestException(
        message: 'Billing portal URL not available.',
      );
    }

    await _openUrl(url);
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched) {
      throw const PostgrestException(message: 'Unable to open Stripe URL.');
    }
  }
}

class SubscriptionBillingException implements Exception {
  SubscriptionBillingException(this.message);
  final String message;

  @override
  String toString() => message;
}
