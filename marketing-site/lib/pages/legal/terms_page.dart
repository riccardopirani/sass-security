import 'package:flutter/material.dart';

import '../../i18n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/section_container.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({super.key, required this.localeCode});

  final String localeCode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final sections = [
      (title: l10n.termsSection1Title, body: l10n.termsSection1Body),
      (title: l10n.termsSection2Title, body: l10n.termsSection2Body),
      (title: l10n.termsSection3Title, body: l10n.termsSection3Body),
      (title: l10n.termsSection4Title, body: l10n.termsSection4Body),
    ];

    return SectionContainer(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.termsTitle,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.termsUpdated,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.mutedText),
            ),
            const SizedBox(height: 14),
            Text(
              l10n.termsIntro,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.mutedText),
            ),
            const SizedBox(height: 20),
            ...sections.map(
              (section) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      section.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      section.body,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.mutedText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
