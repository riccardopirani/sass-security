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

    final bullets = [
      l10n.pricingModelBullet1,
      l10n.pricingModelBullet2,
      l10n.pricingModelBullet3,
    ];

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionContainer(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 20),
          child: SectionHeading(
            title: l10n.pricingModelTitle,
            subtitle: l10n.pricingModelSubtitle,
          ),
        ),
        SectionContainer(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          child: GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.pricingModelFormula,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.92),
                        height: 1.45,
                      ),
                ),
                const SizedBox(height: 20),
                ...bullets.map(
                  (line) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          size: 18,
                          color: AppColors.accent,
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: Text(line)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                CtaButton(
                  label: l10n.pricingModelCta,
                  onPressed: () => DeepLinkService.handleCta(
                    context,
                    CtaDeepLink.signup,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 500.ms),
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
