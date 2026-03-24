import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../i18n/generated/app_localizations.dart';
import '../services/deep_link_service.dart';
import '../state/faq_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/cta_button.dart';
import '../widgets/glass_card.dart';
import '../widgets/section_container.dart';
import '../widgets/section_heading.dart';

class PricingPage extends ConsumerWidget {
  const PricingPage({super.key, required this.localeCode});

  final String localeCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final openIndex = ref.watch(openFaqIndexProvider);

    final plans = [
      _PlanData(
        name: l10n.pricingStarter,
        price: l10n.pricingStarterPrice,
        features: [
          l10n.pricingStarterF1,
          l10n.pricingStarterF2,
          l10n.pricingStarterF3,
          l10n.pricingStarterF4,
        ],
      ),
      _PlanData(
        name: l10n.pricingPro,
        price: l10n.pricingProPrice,
        features: [
          l10n.pricingProF1,
          l10n.pricingProF2,
          l10n.pricingProF3,
          l10n.pricingProF4,
        ],
        highlighted: true,
      ),
      _PlanData(
        name: l10n.pricingBusiness,
        price: l10n.pricingBusinessPrice,
        features: [
          l10n.pricingBusinessF1,
          l10n.pricingBusinessF2,
          l10n.pricingBusinessF3,
          l10n.pricingBusinessF4,
        ],
      ),
    ];

    final faq = [
      (q: l10n.pricingFaq1Q, a: l10n.pricingFaq1A),
      (q: l10n.pricingFaq2Q, a: l10n.pricingFaq2A),
      (q: l10n.pricingFaq3Q, a: l10n.pricingFaq3A),
      (q: l10n.pricingFaq4Q, a: l10n.pricingFaq4A),
      (q: l10n.pricingFaq5Q, a: l10n.pricingFaq5A),
      (q: l10n.pricingFaq6Q, a: l10n.pricingFaq6A),
      (q: l10n.pricingFaq7Q, a: l10n.pricingFaq7A),
      (q: l10n.pricingFaq8Q, a: l10n.pricingFaq8A),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionContainer(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 20),
          child: SectionHeading(
            title: l10n.pricingTitle,
            subtitle: l10n.pricingSubtitle,
          ),
        ),
        SectionContainer(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          child: Wrap(
            spacing: 16,
            runSpacing: 16,
            children: List.generate(plans.length, (index) {
              final plan = plans[index];

              return SizedBox(
                width: MediaQuery.sizeOf(context).width < 960
                    ? double.infinity
                    : 370,
                child: GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            plan.name,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          if (plan.highlighted) ...[
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                l10n.pricingPopular,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: AppColors.accent),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${plan.price} ${l10n.pricingPerMonth}',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(color: AppColors.accent),
                      ),
                      const SizedBox(height: 16),
                      ...plan.features.map(
                        (feature) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle_outline,
                                size: 18,
                                color: AppColors.accent,
                              ),
                              const SizedBox(width: 8),
                              Expanded(child: Text(feature)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      CtaButton(
                        label: l10n.commonStartFreeTrial,
                        onPressed: () => DeepLinkService.handleCta(
                          context,
                          CtaDeepLink.signup,
                        ),
                      ),
                    ],
                  ),
                ).animate(delay: (index * 80).ms).fadeIn(duration: 500.ms),
              );
            }),
          ),
        ),
        SectionContainer(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.pricingFaqTitle,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              ...List.generate(faq.length, (index) {
                final item = faq[index];
                final expanded = openIndex == index;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GlassCard(
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () {
                            ref.read(openFaqIndexProvider.notifier).state =
                                expanded ? null : index;
                          },
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item.q,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ),
                              Icon(
                                expanded
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                              ),
                            ],
                          ),
                        ),
                        AnimatedCrossFade(
                          duration: const Duration(milliseconds: 180),
                          crossFadeState: expanded
                              ? CrossFadeState.showFirst
                              : CrossFadeState.showSecond,
                          firstChild: Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                              item.a,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AppColors.mutedText),
                            ),
                          ),
                          secondChild: const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
        SectionContainer(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.pricingComparisonTitle,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: GlassCard(
                  child: DataTable(
                    headingTextStyle: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(color: AppColors.text),
                    dataTextStyle: Theme.of(context).textTheme.bodyMedium,
                    columns: [
                      DataColumn(label: Text(l10n.pricingComparisonFeature)),
                      DataColumn(label: Text(l10n.pricingStarter)),
                      DataColumn(label: Text(l10n.pricingPro)),
                      DataColumn(label: Text(l10n.pricingBusiness)),
                    ],
                    rows: [
                      _comparisonRow(l10n.pricingComparisonPhishing, [
                        true,
                        true,
                        true,
                      ]),
                      _comparisonRow(l10n.pricingComparisonAlerts, [
                        true,
                        true,
                        true,
                      ]),
                      _comparisonRow(l10n.pricingComparisonTraining, [
                        false,
                        true,
                        true,
                      ]),
                      _comparisonRow(l10n.pricingComparisonSupabase, [
                        false,
                        false,
                        true,
                      ]),
                      _comparisonRow(l10n.pricingComparisonSso, [
                        false,
                        true,
                        true,
                      ]),
                      _comparisonRow(l10n.pricingComparisonSupport, [
                        false,
                        false,
                        true,
                      ]),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  DataRow _comparisonRow(String label, List<bool> values) {
    DataCell cell(bool enabled) {
      return DataCell(
        Icon(
          enabled ? Icons.check : Icons.close,
          color: enabled ? AppColors.accent : AppColors.mutedText,
          size: 18,
        ),
      );
    }

    return DataRow(cells: [DataCell(Text(label)), ...values.map(cell)]);
  }
}

class _PlanData {
  const _PlanData({
    required this.name,
    required this.price,
    required this.features,
    this.highlighted = false,
  });

  final String name;
  final String price;
  final List<String> features;
  final bool highlighted;
}
