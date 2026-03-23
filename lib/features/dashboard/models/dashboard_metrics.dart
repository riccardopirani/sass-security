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
    required this.riskRanking,
  });

  final int companyRiskScore;
  final int activeCampaigns;
  final int openAlerts;
  final List<RiskRankEntry> riskRanking;
}
