class RiskRankEntry {
  const RiskRankEntry({required this.name, required this.riskScore});

  final String name;
  final int riskScore;
}

class DashboardMetrics {
  const DashboardMetrics({
    required this.companyRiskScore,
    required this.activeCampaigns,
    required this.openAlerts,
    required this.openIncidents,
    required this.criticalIncidents,
    required this.highRiskEmployees,
    required this.benchmarkPercentile,
    required this.riskRanking,
    required this.topRiskyWeek,
    required this.riskTrend,
  });

  final int companyRiskScore;
  final int activeCampaigns;
  final int openAlerts;
  final int openIncidents;
  final int criticalIncidents;
  final int highRiskEmployees;
  final int benchmarkPercentile;
  final List<RiskRankEntry> riskRanking;
  final List<RiskRankEntry> topRiskyWeek;
  final List<RiskTrendEntry> riskTrend;
}

class RiskTrendEntry {
  const RiskTrendEntry({required this.date, required this.riskScore});

  final DateTime date;
  final int riskScore;
}
