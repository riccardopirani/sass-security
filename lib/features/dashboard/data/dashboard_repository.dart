import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/dashboard_metrics.dart';

class DashboardRepository {
  DashboardRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<DashboardMetrics> fetchMetrics(String companyId) async {
    final companyRow = await _client
        .from('cg_companies')
        .select('risk_score')
        .eq('id', companyId)
        .maybeSingle();

    final campaigns = await _client
        .from('cg_phishing_campaigns')
        .select('id')
        .eq('company_id', companyId)
        .inFilter('status', ['scheduled', 'sent']);

    final alerts = await _client
        .from('cg_alerts')
        .select('id')
        .eq('company_id', companyId)
        .eq('is_read', false);

    final rankingRows = await _client
        .from('cg_employees')
        .select('name,risk_score')
        .eq('company_id', companyId)
        .order('risk_score', ascending: false)
        .limit(5);

    final riskRanking = (rankingRows as List)
        .map(
          (row) => RiskRankEntry(
            name: (row['name'] as String?) ?? 'Unknown',
            riskScore: (row['risk_score'] as num?)?.toInt() ?? 0,
          ),
        )
        .toList();

    return DashboardMetrics(
      companyRiskScore: (companyRow?['risk_score'] as num?)?.toInt() ?? 0,
      activeCampaigns: (campaigns as List).length,
      openAlerts: (alerts as List).length,
      riskRanking: riskRanking,
    );
  }
}
