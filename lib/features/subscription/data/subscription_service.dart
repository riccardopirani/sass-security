import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/subscription_record.dart';

class SubscriptionService {
  SubscriptionService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<SubscriptionRecord?> currentForCompany(String companyId) async {
    final row = await _client
        .from('subscriptions')
        .select('plan,status,current_period_end,created_at')
        .eq('company_id', companyId)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (row == null) {
      return null;
    }

    return SubscriptionRecord.fromMap(row);
  }

  Future<void> openCheckout(String plan) async {
    final response = await _client.functions.invoke(
      'stripe-checkout',
      body: {'plan': plan},
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

  Future<void> openBillingPortal() async {
    final response = await _client.functions.invoke('create-billing-portal');
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
