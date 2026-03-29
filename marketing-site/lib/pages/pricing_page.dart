import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../i18n/generated/app_localizations.dart';
import '../pricing/subscription_price.dart';
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
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          child: _PricingSimulatorCard().animate().fadeIn(
                delay: 80.ms,
                duration: 500.ms,
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

class _PricingSimulatorCard extends StatefulWidget {
  const _PricingSimulatorCard();

  @override
  State<_PricingSimulatorCard> createState() => _PricingSimulatorCardState();
}

class _PricingSimulatorCardState extends State<_PricingSimulatorCard> {
  final _usersCtrl = TextEditingController(text: '50');
  double _risk = 35;

  @override
  void dispose() {
    _usersCtrl.dispose();
    super.dispose();
  }

  int _usersClamped() {
    final parsed = int.tryParse(_usersCtrl.text.trim());
    if (parsed == null) return 1;
    return parsed.clamp(1, 50000);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final users = _usersClamped();
    final risk = _risk.round().clamp(0, 100);
    final monthly =
        computeMonthlySubscriptionUsd(users: users, riskScore: risk);
    final currency = NumberFormat.currency(
      locale: Localizations.localeOf(context).toString(),
      symbol: r'$',
      decimalDigits: 2,
    );

    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.pricingSimulatorTitle,
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.pricingSimulatorSubtitle,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: AppColors.mutedText),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.pricingSimulatorSeatsLabel,
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _usersCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: theme.textTheme.bodyLarge,
              decoration: InputDecoration(
                hintText: l10n.pricingSimulatorSeatsHint,
                filled: true,
                fillColor: Colors.black.withValues(alpha: 0.25),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.pricingSimulatorRiskLabel,
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                Text(
                  '$risk',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppColors.accent,
                inactiveTrackColor: AppColors.accent.withValues(alpha: 0.22),
                thumbColor: AppColors.accent,
                overlayColor: AppColors.accent.withValues(alpha: 0.18),
              ),
              child: Slider(
                value: _risk.clamp(0, 100),
                min: 0,
                max: 100,
                divisions: 100,
                label: '$risk',
                onChanged: (v) => setState(() => _risk = v),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.accent.withValues(alpha: 0.35)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.pricingSimulatorEstimateLabel,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: AppColors.mutedText),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    currency.format(monthly),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              l10n.pricingSimulatorDisclaimer,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.mutedText,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
