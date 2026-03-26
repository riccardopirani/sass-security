import 'dart:math' show min;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../i18n/generated/app_localizations.dart';
import '../services/deep_link_service.dart';
import '../theme/app_theme.dart';
import '../widgets/cta_button.dart';
import '../widgets/cyber_threat_globe.dart';
import '../widgets/glass_card.dart';
import '../widgets/section_container.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.localeCode});

  final String localeCode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final compact = MediaQuery.sizeOf(context).width < 900;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── HERO ──────────────────────────────────────────────
        SectionContainer(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 30),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final narrow = constraints.maxWidth < 920;
              return Wrap(
                spacing: 24,
                runSpacing: 24,
                children: [
                  SizedBox(
                    width: narrow
                        ? constraints.maxWidth
                        : constraints.maxWidth * 0.57,
                    child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.homeHeroTitle,
                              style: theme.textTheme.displaySmall
                                  ?.copyWith(fontSize: narrow ? 36 : 50),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              l10n.homeHeroSubtitle,
                              style: theme.textTheme.bodyLarge
                                  ?.copyWith(color: AppColors.mutedText),
                            ),
                            const SizedBox(height: 22),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                CtaButton(
                                  label: l10n.homeHeroCtaTrial,
                                  onPressed: () =>
                                      DeepLinkService.handleCta(
                                        context,
                                        CtaDeepLink.signup,
                                      ),
                                ),
                                CtaButton(
                                  label: l10n.homeHeroCtaDemo,
                                  filled: false,
                                  onPressed: () => _showDemoModal(context),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            _proofBadges(context, l10n),
                          ],
                        )
                        .animate()
                        .fadeIn(duration: 500.ms)
                        .slideY(begin: 0.1, end: 0),
                  ),
                  SizedBox(
                        width: narrow
                            ? constraints.maxWidth
                            : constraints.maxWidth * 0.38,
                        child: GlassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l10n.homeGlobeTitle,
                                  style: theme.textTheme.titleLarge),
                              const SizedBox(height: 6),
                              Text(
                                l10n.homeGlobeSubtitle,
                                style: theme.textTheme.bodySmall
                                    ?.copyWith(color: AppColors.mutedText),
                              ),
                              const SizedBox(height: 14),
                              Center(
                                child: LayoutBuilder(
                                  builder: (context, c) {
                                    final side = min(320.0, c.maxWidth)
                                        .clamp(200.0, 320.0);
                                    return CyberThreatGlobe(size: side);
                                  },
                                ),
                              ),
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

        // ── PROBLEMA ──────────────────────────────────────────
        _contentSection(
          context,
          icon: Icons.warning_amber_rounded,
          iconColor: Colors.orangeAccent,
          title: l10n.homeProblemTitle,
          body: l10n.homeProblemBody,
          bullets: l10n.homeProblemBullets,
          tagline: l10n.homeProblemTagline,
        ),

        // ── SOLUZIONE ─────────────────────────────────────────
        _contentSection(
          context,
          icon: Icons.shield_outlined,
          iconColor: AppColors.accent,
          title: l10n.homeSolutionTitle,
          body: l10n.homeSolutionBody,
          bullets: l10n.homeSolutionBullets,
          tagline: l10n.homeSolutionTagline,
        ),

        // ── DASHBOARD ─────────────────────────────────────────
        _contentSection(
          context,
          icon: Icons.dashboard_outlined,
          iconColor: AppColors.accent,
          title: l10n.homeDashboardSectionTitle,
          body: l10n.homeDashboardSectionBody,
          bullets: l10n.homeDashboardSectionBullets,
          tagline: l10n.homeDashboardSectionTagline,
        ),

        // ── BENEFICI ──────────────────────────────────────────
        _contentSection(
          context,
          icon: Icons.trending_up_rounded,
          iconColor: Colors.greenAccent,
          title: l10n.homeBenefitsTitle,
          bullets: l10n.homeBenefitsBullets,
        ),

        // ── PHISHING SIMULATION ───────────────────────────────
        _contentSection(
          context,
          icon: Icons.phishing_outlined,
          iconColor: AppColors.accent,
          title: l10n.homePhishingSectionTitle,
          body: l10n.homePhishingSectionBody,
          bullets: l10n.homePhishingSectionBullets,
          tagline: l10n.homePhishingSectionTagline,
        ),

        // ── ALERT E INCIDENTI ─────────────────────────────────
        _contentSection(
          context,
          icon: Icons.notifications_active_outlined,
          iconColor: Colors.redAccent,
          title: l10n.homeAlertSectionTitle,
          body: l10n.homeAlertSectionBody,
          bullets: l10n.homeAlertSectionBullets,
          tagline: l10n.homeAlertSectionTagline,
        ),

        // ── GESTIONE TEAM ─────────────────────────────────────
        _contentSection(
          context,
          icon: Icons.people_outline_rounded,
          iconColor: AppColors.accent,
          title: l10n.homeTeamSectionTitle,
          body: l10n.homeTeamSectionBody,
          bullets: l10n.homeTeamSectionBullets,
          tagline: l10n.homeTeamSectionTagline,
        ),

        // ── PRIMA / DOPO ──────────────────────────────────────
        SectionContainer(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final availableWidth = constraints.maxWidth.clamp(
                0.0,
                double.infinity,
              );
              final singleColumn = compact || availableWidth < 760;
              final half =
                  singleColumn ? availableWidth : (availableWidth - 16) / 2;
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: half,
                    child: GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            const Icon(Icons.close, color: Colors.redAccent,
                                size: 20),
                            const SizedBox(width: 8),
                            Text(l10n.homeBeforeTitle,
                                style: theme.textTheme.titleLarge),
                          ]),
                          const SizedBox(height: 10),
                          _bulletList(context, l10n.homeBeforeBullets),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: half,
                    child: GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            const Icon(Icons.check_circle_outline,
                                color: Colors.greenAccent, size: 20),
                            const SizedBox(width: 8),
                            Text(l10n.homeAfterTitle,
                                style: theme.textTheme.titleLarge),
                          ]),
                          const SizedBox(height: 10),
                          _bulletList(context, l10n.homeAfterBullets),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),

        // ── MULTILINGUA ───────────────────────────────────────
        _contentSection(
          context,
          icon: Icons.language_rounded,
          iconColor: AppColors.accent,
          title: l10n.homeMultiLangTitle,
          body: l10n.homeMultiLangBody,
          tagline: l10n.homeMultiLangTagline,
        ),

        // ── PREZZI (sommario) ─────────────────────────────────
        SectionContainer(
          child: GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Icon(Icons.payments_outlined,
                      color: AppColors.accent),
                  const SizedBox(width: 10),
                  Text(l10n.homePricingSectionTitle,
                      style: theme.textTheme.headlineSmall),
                ]),
                const SizedBox(height: 10),
                Text(l10n.homePricingSectionBody,
                    style: theme.textTheme.bodyLarge
                        ?.copyWith(color: AppColors.mutedText)),
                const SizedBox(height: 10),
                _bulletList(context, l10n.homePricingSectionBullets),
                const SizedBox(height: 8),
                _tagline(context, l10n.homePricingSectionTagline),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    CtaButton(
                      label: l10n.homePricingSectionCtaFree,
                      onPressed: () => DeepLinkService.handleCta(
                          context, CtaDeepLink.signup),
                    ),
                    CtaButton(
                      label: l10n.homePricingSectionCtaPlans,
                      filled: false,
                      onPressed: () => DeepLinkService.handleCta(
                          context, CtaDeepLink.signup),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // ── TRUST / SICUREZZA ─────────────────────────────────
        _contentSection(
          context,
          icon: Icons.lock_outline_rounded,
          iconColor: AppColors.accent,
          title: l10n.homeTrustTitle,
          bullets: l10n.homeTrustBullets,
          tagline: l10n.homeTrustTagline,
        ),

        // ── TESTIMONIALS ──────────────────────────────────────
        _testimonialsSection(context, l10n),

        // ── CTA FINALE ────────────────────────────────────────
        SectionContainer(
          padding: const EdgeInsets.fromLTRB(24, 30, 24, 30),
          child: GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.homeFinalCtaTitle,
                    style: theme.textTheme.headlineSmall),
                const SizedBox(height: 10),
                Text(
                  l10n.homeFinalCtaSubtitle,
                  style: theme.textTheme.bodyLarge
                      ?.copyWith(color: AppColors.mutedText),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    CtaButton(
                      label: l10n.homeHeroCtaTrial,
                      onPressed: () => DeepLinkService.handleCta(
                          context, CtaDeepLink.signup),
                    ),
                    CtaButton(
                      label: l10n.homeHeroCtaDemo,
                      filled: false,
                      onPressed: () => DeepLinkService.handleCta(
                          context, CtaDeepLink.demo),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.hasBoundedHeight) {
          return SingleChildScrollView(
            child: content,
          );
        }
        return content;
      },
    );
  }

  // ── Helpers ───────────────────────────────────────────────────

  Widget _proofBadges(BuildContext context, AppLocalizations l10n) {
    final items = [
      l10n.homeHeroProof1,
      l10n.homeHeroProof2,
      l10n.homeHeroProof3,
    ];
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: items
          .map((text) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle,
                      color: AppColors.accent, size: 16),
                  const SizedBox(width: 6),
                  Text(text,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.mutedText)),
                ],
              ))
          .toList(),
    );
  }

  Widget _contentSection(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    String? body,
    String? bullets,
    String? tagline,
  }) {
    final theme = Theme.of(context);
    return SectionContainer(
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, color: iconColor),
              const SizedBox(width: 10),
              Expanded(
                child:
                    Text(title, style: theme.textTheme.headlineSmall),
              ),
            ]),
            if (body != null) ...[
              const SizedBox(height: 10),
              Text(body,
                  style: theme.textTheme.bodyLarge
                      ?.copyWith(color: AppColors.mutedText)),
            ],
            if (bullets != null) ...[
              const SizedBox(height: 10),
              _bulletList(context, bullets),
            ],
            if (tagline != null) ...[
              const SizedBox(height: 12),
              _tagline(context, tagline),
            ],
          ],
        ),
      ),
    );
  }

  Widget _bulletList(BuildContext context, String raw) {
    final lines =
        raw.split('||').where((s) => s.trim().isNotEmpty).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines
          .map((line) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Icon(Icons.circle,
                          size: 6, color: AppColors.accent),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(line.trim(),
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: AppColors.mutedText)),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }

  Widget _tagline(BuildContext context, String text) {
    return Row(
      children: [
        const Icon(Icons.arrow_forward_rounded,
            size: 16, color: AppColors.accent),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }

  Widget _testimonialsSection(
      BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final compact = MediaQuery.sizeOf(context).width < 900;
    final items = <({String quote, String name, String role})>[
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

    return SectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.homeTestimonialsTitle,
              style: theme.textTheme.headlineMedium),
          const SizedBox(height: 18),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: items
                .map((item) => SizedBox(
                      width: compact ? double.infinity : 360,
                      child: GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('"${item.quote}"',
                                style: theme.textTheme.bodyLarge),
                            const SizedBox(height: 12),
                            Text(item.name,
                                style: theme.textTheme.titleLarge),
                            Text(item.role,
                                style: theme.textTheme.bodySmall
                                    ?.copyWith(
                                        color: AppColors.mutedText)),
                          ],
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
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
                  Text(l10n.demoModalTitle,
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text(
                    l10n.demoModalSubtitle,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppColors.mutedText),
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
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
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
                            context, CtaDeepLink.demo),
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
