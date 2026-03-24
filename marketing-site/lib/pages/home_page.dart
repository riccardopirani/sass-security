import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../i18n/generated/app_localizations.dart';
import '../services/deep_link_service.dart';
import '../theme/app_theme.dart';
import '../widgets/cta_button.dart';
import '../widgets/glass_card.dart';
import '../widgets/section_container.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.localeCode});

  final String localeCode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final featureCards = <({IconData icon, String title, String subtitle})>[
      (
        icon: Icons.email_outlined,
        title: l10n.homeFeaturePhishingTitle,
        subtitle: l10n.homeFeaturePhishingDesc,
      ),
      (
        icon: Icons.notifications_active_outlined,
        title: l10n.homeFeatureAlertsTitle,
        subtitle: l10n.homeFeatureAlertsDesc,
      ),
      (
        icon: Icons.query_stats_outlined,
        title: l10n.homeFeatureRiskTitle,
        subtitle: l10n.homeFeatureRiskDesc,
      ),
      (
        icon: Icons.school_outlined,
        title: l10n.homeFeatureTrainingTitle,
        subtitle: l10n.homeFeatureTrainingDesc,
      ),
    ];

    final steps = <({String title, String subtitle})>[
      (title: l10n.homeStep1Title, subtitle: l10n.homeStep1Desc),
      (title: l10n.homeStep2Title, subtitle: l10n.homeStep2Desc),
      (title: l10n.homeStep3Title, subtitle: l10n.homeStep3Desc),
    ];

    final testimonials = <({String quote, String name, String role})>[
      (
        quote: l10n.homeTestimonial1Quote,
        name: l10n.homeTestimonial1Name,
        role: l10n.homeTestimonial1Role,
      ),
      (
        quote: l10n.homeTestimonial2Quote,
        name: l10n.homeTestimonial2Name,
        role: l10n.homeTestimonial2Role,
      ),
      (
        quote: l10n.homeTestimonial3Quote,
        name: l10n.homeTestimonial3Name,
        role: l10n.homeTestimonial3Role,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionContainer(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 30),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 920;

              return Wrap(
                spacing: 24,
                runSpacing: 24,
                children: [
                  SizedBox(
                    width: compact
                        ? constraints.maxWidth
                        : constraints.maxWidth * 0.57,
                    child:
                        Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.homeHeroTitle,
                                  style: Theme.of(context)
                                      .textTheme
                                      .displaySmall
                                      ?.copyWith(fontSize: compact ? 36 : 50),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  l10n.homeHeroSubtitle,
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(color: AppColors.mutedText),
                                ),
                                const SizedBox(height: 22),
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  children: [
                                    CtaButton(
                                      label: l10n.commonStartFreeTrial,
                                      onPressed: () =>
                                          DeepLinkService.handleCta(
                                            context,
                                            CtaDeepLink.signup,
                                          ),
                                    ),
                                    CtaButton(
                                      label: l10n.commonSeeDemo,
                                      filled: false,
                                      onPressed: () => _showDemoModal(context),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  l10n.sameAccountText,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(color: AppColors.mutedText),
                                ),
                              ],
                            )
                            .animate()
                            .fadeIn(duration: 500.ms)
                            .slideY(begin: 0.1, end: 0),
                  ),
                  SizedBox(
                        width: compact
                            ? constraints.maxWidth
                            : constraints.maxWidth * 0.38,
                        child: GlassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.homeHeroPanelTitle,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 14),
                              _miniMetric(l10n.homeHeroPanelMetric1, '99.9%'),
                              _miniMetric(l10n.homeHeroPanelMetric2, '500+'),
                              _miniMetric(l10n.homeHeroPanelMetric3, '<90s'),
                            ],
                          ),
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 550.ms)
                      .slideY(begin: 0.08, end: 0),
                ],
              );
            },
          ),
        ),
        SectionContainer(
          padding: const EdgeInsets.fromLTRB(24, 10, 24, 20),
          child: GlassCard(
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              runSpacing: 10,
              spacing: 18,
              children: [
                _socialTile(context, l10n.socialSmbs),
                _socialTile(context, l10n.socialUptime),
                _socialTile(context, l10n.socialIncidents),
              ],
            ),
          ),
        ),
        SectionContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.homeMessagingTitle,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _messageGroup(
                    context,
                    l10n.homeMessagingHeadlinesTitle,
                    l10n.homeMessagingHeadlinesItems,
                  ),
                  _messageGroup(
                    context,
                    l10n.homeMessagingValueTitle,
                    l10n.homeMessagingValueItems,
                  ),
                  _messageGroup(
                    context,
                    l10n.homeMessagingProblemTitle,
                    l10n.homeMessagingProblemItems,
                  ),
                  _messageGroup(
                    context,
                    l10n.homeMessagingAiTitle,
                    l10n.homeMessagingAiItems,
                  ),
                  _messageGroup(
                    context,
                    l10n.homeMessagingRoiTitle,
                    l10n.homeMessagingRoiItems,
                  ),
                  _messageGroup(
                    context,
                    l10n.homeMessagingExecTitle,
                    l10n.homeMessagingExecItems,
                  ),
                  _messageGroup(
                    context,
                    l10n.homeMessagingUrgencyTitle,
                    l10n.homeMessagingUrgencyItems,
                  ),
                  _messageGroup(
                    context,
                    l10n.homeMessagingMobileTitle,
                    l10n.homeMessagingMobileItems,
                  ),
                ],
              ),
            ],
          ),
        ),
        SectionContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.homeFeatureSectionTitle,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: List.generate(featureCards.length, (index) {
                  final feature = featureCards[index];
                  return SizedBox(
                        width: MediaQuery.sizeOf(context).width < 760
                            ? double.infinity
                            : 270,
                        child: GlassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(feature.icon, color: AppColors.accent),
                              const SizedBox(height: 12),
                              Text(
                                feature.title,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                feature.subtitle,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: AppColors.mutedText),
                              ),
                            ],
                          ),
                        ),
                      )
                      .animate(delay: (index * 90).ms)
                      .fadeIn(duration: 500.ms)
                      .slideY(begin: 0.05, end: 0);
                }),
              ),
            ],
          ),
        ),
        SectionContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.homeHowItWorksTitle,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 14,
                runSpacing: 14,
                children: List.generate(steps.length, (index) {
                  final step = steps[index];
                  return SizedBox(
                    width: MediaQuery.sizeOf(context).width < 900
                        ? double.infinity
                        : 360,
                    child: GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '0${index + 1}',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(color: AppColors.accent),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            step.title,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            step.subtitle,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppColors.mutedText),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
        SectionContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.homeTestimonialsTitle,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: testimonials
                    .map(
                      (item) => SizedBox(
                        width: MediaQuery.sizeOf(context).width < 900
                            ? double.infinity
                            : 360,
                        child: GlassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '"${item.quote}"',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                item.name,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              Text(
                                item.role,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: AppColors.mutedText),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
        SectionContainer(
          padding: const EdgeInsets.fromLTRB(24, 30, 24, 30),
          child: GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.homeFinalCtaTitle,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 10),
                Text(
                  l10n.homeFinalCtaSubtitle,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: AppColors.mutedText),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    CtaButton(
                      label: l10n.commonStartFreeTrial,
                      onPressed: () => DeepLinkService.handleCta(
                        context,
                        CtaDeepLink.signup,
                      ),
                    ),
                    CtaButton(
                      label: l10n.commonSeeDemo,
                      filled: false,
                      onPressed: () =>
                          DeepLinkService.handleCta(context, CtaDeepLink.demo),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _miniMetric(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.accent,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _socialTile(BuildContext context, String label) {
    return Text(
      label,
      style: Theme.of(
        context,
      ).textTheme.bodyLarge?.copyWith(color: AppColors.mutedText),
    );
  }

  Widget _messageGroup(BuildContext context, String title, String items) {
    final lines = items.split('||').where((item) => item.trim().isNotEmpty);

    return SizedBox(
      width: MediaQuery.sizeOf(context).width < 900 ? double.infinity : 520,
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            ...lines.map(
              (line) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  '- ${line.trim()}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.mutedText),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDemoModal(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: GlassCard(
            child: SizedBox(
              width: 760,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.demoModalTitle,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.demoModalSubtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.mutedText,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Center(
                        child: Text(
                          l10n.demoModalPlaceholder,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: AppColors.mutedText),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      CtaButton(
                        label: l10n.commonOpenInApp,
                        onPressed: () => DeepLinkService.handleCta(
                          context,
                          CtaDeepLink.demo,
                        ),
                      ),
                      CtaButton(
                        label: l10n.commonClose,
                        filled: false,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
