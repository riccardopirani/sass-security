import 'package:flutter/material.dart';
import 'package:sass_security/l10n/app_localizations.dart';

import '../../../core/widgets/employee_avatar.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/loading_skeleton.dart';
import '../../auth/models/app_profile.dart';
import '../data/dashboard_repository.dart';
import '../models/dashboard_metrics.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({required this.profile, super.key});

  final AppProfile profile;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late Future<DashboardMetrics> _future;
  final _repo = DashboardRepository();

  @override
  void initState() {
    super.initState();
    _future = _repo.fetchMetrics(widget.profile.companyId);
  }

  Future<void> _reload() async {
    setState(() {
      _future = _repo.fetchMetrics(widget.profile.companyId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return RefreshIndicator(
      onRefresh: _reload,
      child: FutureBuilder<DashboardMetrics>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return ListView(
              padding: const EdgeInsets.all(20),
              children: const [
                LoadingSkeleton(height: 130),
                SizedBox(height: 12),
                LoadingSkeleton(height: 130),
                SizedBox(height: 12),
                LoadingSkeleton(height: 200),
              ],
            );
          }

          if (snapshot.hasError || snapshot.data == null) {
            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(snapshot.error?.toString() ?? l10n.error_generic),
                const SizedBox(height: 12),
                ElevatedButton(onPressed: _reload, child: Text(l10n.refresh)),
              ],
            );
          }

          final data = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                l10n.welcome_back,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(
                widget.profile.companyName ?? l10n.unknown,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth > 800;
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _MetricCard(
                        title: l10n.company_risk_score,
                        value: '${data.companyRiskScore}/100',
                        width: wide
                            ? (constraints.maxWidth - 12) / 2
                            : constraints.maxWidth,
                      ),
                      _MetricCard(
                        title: l10n.active_campaigns,
                        value: '${data.activeCampaigns}',
                        width: wide
                            ? (constraints.maxWidth - 12) / 2
                            : constraints.maxWidth,
                      ),
                      _MetricCard(
                        title: l10n.open_alerts,
                        value: '${data.openAlerts}',
                        width: wide
                            ? (constraints.maxWidth - 12) / 2
                            : constraints.maxWidth,
                      ),
                      _MetricCard(
                        title: l10n.open_incidents,
                        value: '${data.openIncidents}',
                        width: wide
                            ? (constraints.maxWidth - 12) / 2
                            : constraints.maxWidth,
                      ),
                      _MetricCard(
                        title: l10n.critical_incidents,
                        value: '${data.criticalIncidents}',
                        width: wide
                            ? (constraints.maxWidth - 12) / 2
                            : constraints.maxWidth,
                      ),
                      _MetricCard(
                        title: l10n.high_risk_employees_count,
                        value: '${data.highRiskEmployees}',
                        width: wide
                            ? (constraints.maxWidth - 12) / 2
                            : constraints.maxWidth,
                      ),
                      _MetricCard(
                        title: l10n.metric_benchmark,
                        value: l10n.benchmark_safer_than(data.benchmarkPercentile),
                        width: wide
                            ? (constraints.maxWidth - 12) / 2
                            : constraints.maxWidth,
                      ),
                      _MetricCard(
                        title: l10n.security_posture,
                        value: data.companyRiskScore >= 70
                            ? l10n.security_posture_high_risk
                            : l10n.security_posture_stable,
                        width: wide
                            ? (constraints.maxWidth - 12) / 2
                            : constraints.maxWidth,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.top_risky_users_week,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    ...data.topRiskyWeek.asMap().entries.map(
                      (entry) => ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 28,
                              child: Text(
                                '${entry.key + 1}',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                            ),
                            EmployeeAvatar(
                              name: entry.value.name,
                              imageUrl: entry.value.avatarUrl,
                              radius: 18,
                              backgroundColor: const Color(0xFF7C3AED),
                            ),
                          ],
                        ),
                        title: Text(entry.value.name),
                        trailing: Text('${entry.value.riskScore}/100'),
                      ),
                    ),
                    if (data.topRiskyWeek.isEmpty)
                      Text(
                        l10n.no_risky_users_week,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.monthly_risk_trend,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    if (data.riskTrend.isEmpty)
                      Text(
                        l10n.no_trend_data,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: data.riskTrend
                            .map(
                              (point) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0x3322C55E),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Text(
                                  '${point.date.day.toString().padLeft(2, '0')}/${point.date.month.toString().padLeft(2, '0')}: ${point.riskScore}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.employee_risk_ranking,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    ...data.riskRanking.map(
                      (entry) => ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: EmployeeAvatar(
                          name: entry.name,
                          imageUrl: entry.avatarUrl,
                          radius: 20,
                          backgroundColor: const Color(0xFF1D4ED8),
                        ),
                        title: Text(entry.name),
                        trailing: Text('${entry.riskScore}/100'),
                      ),
                    ),
                    if (data.riskRanking.isEmpty)
                      Text(
                        l10n.no_employees,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.width,
  });

  final String title;
  final String value;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.headlineSmall),
          ],
        ),
      ),
    );
  }
}
