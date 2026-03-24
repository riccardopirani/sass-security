import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/dashboard_metrics.dart';

class DashboardRepository {
  DashboardRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<DashboardMetrics> fetchMetrics(String companyId) async {
    final companyRow = await _client
        .from('cg_companies')
        .select('risk_score,benchmark_percentile')
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

    final incidents = await _client
        .from('cg_incidents')
        .select('id,severity')
        .eq('company_id', companyId)
        .eq('status', 'open');

    final rankingRows = await _client
        .from('cg_employees')
        .select('id,name,risk_score')
        .eq('company_id', companyId)
        .order('risk_score', ascending: false)
        .limit(50);

    final snapshots = await _client
        .from('cg_company_score_snapshots')
        .select('snapshot_date,risk_score')
        .eq('company_id', companyId)
        .order('snapshot_date', ascending: false)
        .limit(30);

    final startOfWeek = DateTime.now()
        .subtract(Duration(days: DateTime.now().weekday - 1))
        .toIso8601String();
    final weeklyEvents = await _client
        .from('cg_phishing_events')
        .select('employee_id,event_type')
        .eq('company_id', companyId)
        .gte('created_at', startOfWeek);

    final riskRanking = (rankingRows as List)
        .take(5)
        .map(
          (row) => RiskRankEntry(
            name: (row['name'] as String?) ?? 'Unknown',
            riskScore: (row['risk_score'] as num?)?.toInt() ?? 0,
          ),
        )
        .toList();

    final weeklyScoreBoost = <String, int>{};
    for (final row in (weeklyEvents as List)) {
      final employeeId = row['employee_id'] as String?;
      if (employeeId == null) {
        continue;
      }
      final eventType = (row['event_type'] as String?) ?? '';
      final delta = switch (eventType) {
        'credential_submitted' => 30,
        'clicked' => 15,
        'opened' => 3,
        _ => 0,
      };
      weeklyScoreBoost[employeeId] =
          (weeklyScoreBoost[employeeId] ?? 0) + delta;
    }

    final riskyWeek = (rankingRows as List).map((row) {
      final id = row['id'] as String?;
      final baseScore = (row['risk_score'] as num?)?.toInt() ?? 0;
      return RiskRankEntry(
        name: (row['name'] as String?) ?? 'Unknown',
        riskScore: baseScore + (id == null ? 0 : (weeklyScoreBoost[id] ?? 0)),
      );
    }).toList()..sort((a, b) => b.riskScore.compareTo(a.riskScore));

    final trend =
        (snapshots as List)
            .map(
              (row) => RiskTrendEntry(
                date:
                    DateTime.tryParse(
                      (row['snapshot_date'] as String?) ?? '',
                    ) ??
                    DateTime.fromMillisecondsSinceEpoch(0),
                riskScore: (row['risk_score'] as num?)?.toInt() ?? 0,
              ),
            )
            .toList()
          ..sort((a, b) => a.date.compareTo(b.date));

    final openIncidentRows = (incidents as List);
    final highRiskEmployees = (rankingRows as List)
        .where((row) => ((row['risk_score'] as num?)?.toInt() ?? 0) >= 70)
        .length;

    return DashboardMetrics(
      companyRiskScore: (companyRow?['risk_score'] as num?)?.toInt() ?? 0,
      benchmarkPercentile:
          (companyRow?['benchmark_percentile'] as num?)?.toInt() ?? 0,
      activeCampaigns: (campaigns as List).length,
      openAlerts: (alerts as List).length,
      openIncidents: openIncidentRows.length,
      criticalIncidents: openIncidentRows
          .where((item) => item['severity'] == 'critical')
          .length,
      highRiskEmployees: highRiskEmployees,
      riskRanking: riskRanking,
      topRiskyWeek: riskyWeek.take(10).toList(),
      riskTrend: trend,
    );
  }
}
