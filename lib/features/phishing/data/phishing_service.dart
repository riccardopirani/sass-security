import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/phishing_campaign.dart';

class PhishingService {
  PhishingService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<void> sendTestCampaign({
    required String campaignName,
    required String template,
  }) async {
    await _client.functions.invoke(
      'send-phishing-test',
      body: {'name': campaignName, 'template': template},
    );
  }

  Future<List<PhishingCampaign>> listCampaigns(String companyId) async {
    final rows = await _client
        .from('cg_phishing_campaigns')
        .select(
          'id,name,status,sent_count,opened_count,clicked_count,created_at',
        )
        .eq('company_id', companyId)
        .order('created_at', ascending: false)
        .limit(50);

    return (rows as List)
        .map((row) => PhishingCampaign.fromMap(row as Map<String, dynamic>))
        .toList();
  }
}
