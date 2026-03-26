import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../i18n/generated/app_localizations.dart';
import '../theme/app_theme.dart';
import '../widgets/dashboard_mock.dart';
import '../widgets/glass_card.dart';
import '../widgets/section_container.dart';
import '../widgets/section_heading.dart';

class FeaturesPage extends StatelessWidget {
  const FeaturesPage({super.key, required this.localeCode});

  final String localeCode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final sections =
        <({IconData icon, String title, String subtitle, Widget? trailing})>[
          (
            icon: Icons.monitor_heart_outlined,
            title: l10n.featuresDashboardTitle,
            subtitle: l10n.featuresDashboardDesc,
            trailing: null,
          ),
          (
            icon: Icons.email_outlined,
            title: l10n.featuresPhishingTitle,
            subtitle: l10n.featuresPhishingDesc,
            trailing: null,
          ),
          (
            icon: Icons.warning_amber_outlined,
            title: l10n.featuresAlertsTitle,
            subtitle: l10n.featuresAlertsDesc,
            trailing: _SeverityRow(
              labels: [
                l10n.featuresSeverityLow,
                l10n.featuresSeverityMedium,
                l10n.featuresSeverityHigh,
              ],
            ),
          ),
          (
            icon: Icons.groups_outlined,
            title: l10n.featuresEmployeeMgmtTitle,
            subtitle: l10n.featuresEmployeeMgmtDesc,
            trailing: _CrudPills(
              add: l10n.featuresCrudAdd,
              edit: l10n.featuresCrudEdit,
              delete: l10n.featuresCrudDelete,
            ),
          ),
          (
            icon: Icons.speed_outlined,
            title: l10n.featuresScoreEngineTitle,
            subtitle: l10n.featuresScoreEngineDesc,
            trailing: null,
          ),
          (
            icon: Icons.apartment_outlined,
            title: l10n.featuresMultiTenancyTitle,
            subtitle: l10n.featuresMultiTenancyDesc,
            trailing: null,
          ),
          (
            icon: Icons.verified_user_outlined,
            title: l10n.featuresRbacTitle,
            subtitle: l10n.featuresRbacDesc,
            trailing: null,
          ),
        ];

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionContainer(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 20),
          child: SectionHeading(
            title: l10n.featuresTitle,
            subtitle: l10n.featuresSubtitle,
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.5),
                ),
              ),
              child: Text(
                l10n.featuresWorksBadge,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        SectionContainer(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
          child: DashboardMock(
            title: l10n.dashboardMockTitle,
            riskLabel: l10n.dashboardMockRisk,
            alertLabel: l10n.dashboardMockAlerts,
            trainingLabel: l10n.dashboardMockTraining,
            coverageLabel: l10n.dashboardMockCoverage,
          ).animate().fadeIn(duration: 500.ms),
        ),
        SectionContainer(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 30),
          child: Wrap(
            spacing: 16,
            runSpacing: 16,
            children: List.generate(sections.length, (index) {
              final section = sections[index];
              return SizedBox(
                width: MediaQuery.sizeOf(context).width < 920
                    ? double.infinity
                    : 380,
                child:
                    GlassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(section.icon, color: AppColors.accent),
                              const SizedBox(height: 12),
                              Text(
                                section.title,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                section.subtitle,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: AppColors.mutedText),
                              ),
                              if (section.trailing != null) ...[
                                const SizedBox(height: 12),
                                section.trailing!,
                              ],
                            ],
                          ),
                        )
                        .animate(delay: (index * 70).ms)
                        .fadeIn(duration: 420.ms)
                        .slideY(begin: 0.04, end: 0),
              );
            }),
          ),
        ),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.hasBoundedHeight) {
          return SingleChildScrollView(child: content);
        }
        return content;
      },
    );
  }
}

class _SeverityRow extends StatelessWidget {
  const _SeverityRow({required this.labels});

  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final colors = [
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFFEF4444),
    ];

    return Wrap(
      spacing: 8,
      children: List.generate(labels.length, (index) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: colors[index].withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            labels[index],
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colors[index],
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }),
    );
  }
}

class _CrudPills extends StatelessWidget {
  const _CrudPills({
    required this.add,
    required this.edit,
    required this.delete,
  });

  final String add;
  final String edit;
  final String delete;

  @override
  Widget build(BuildContext context) {
    final labels = [add, edit, delete];

    return Wrap(
      spacing: 8,
      children: labels
          .map(
            (label) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(label, style: Theme.of(context).textTheme.bodySmall),
            ),
          )
          .toList(),
    );
  }
}
