import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/phishing_campaign.dart';

class PhishingService {
  PhishingService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<void> sendTestCampaign({
    required String campaignName,
    required String template,
    String? templateB,
    bool useAi = false,
    bool abTestEnabled = true,
    String campaignMode = 'manual',
  }) async {
    await _client.functions.invoke(
      'send-phishing-test',
      body: {
        'name': campaignName,
        'template': template,
        if (templateB != null && templateB.trim().isNotEmpty)
          'templateB': templateB.trim(),
        'useAi': useAi,
        'abTestEnabled': abTestEnabled,
        'campaignMode': campaignMode,
      },
    );
  }

  Future<Map<String, dynamic>> generateTemplates({
    required String scenario,
    required String targetRole,
  }) async {
    final response = await _client.functions.invoke(
      'generate-phishing-template',
      body: {'scenario': scenario, 'targetRole': targetRole},
    );

    return (response.data as Map<String, dynamic>?) ?? <String, dynamic>{};
  }

  Future<List<Map<String, dynamic>>> listAttackLibrary(String companyId) async {
    final rows = await _client
        .from('security_cg_attack_library')
        .select('id,category,name,subject_line,body_template,company_id')
        .or('company_id.is.null,company_id.eq.$companyId')
        .order('name', ascending: true);

    return (rows as List).cast<Map<String, dynamic>>();
  }

  Future<List<PhishingCampaign>> listCampaigns(String companyId) async {
    final rows = await _client
        .from('security_cg_phishing_campaigns')
        .select(
          'id,name,status,sent_count,opened_count,clicked_count,credential_submitted_count,ab_test_enabled,campaign_mode,generated_by_ai,created_at',
        )
        .eq('company_id', companyId)
        .order('created_at', ascending: false)
        .limit(50);

    return (rows as List)
        .map((row) => PhishingCampaign.fromMap(row as Map<String, dynamic>))
        .toList();
  }
}
