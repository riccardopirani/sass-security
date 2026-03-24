import 'package:flutter/material.dart';

import '../i18n/generated/app_localizations.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/section_container.dart';
import '../widgets/section_heading.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key, required this.localeCode});

  final String localeCode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionContainer(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 20),
          child: SectionHeading(
            title: l10n.contactTitle,
            subtitle: l10n.contactSubtitle,
          ),
        ),
        SectionContainer(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              SizedBox(
                width: MediaQuery.sizeOf(context).width < 960
                    ? double.infinity
                    : 760,
                child: GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _inputField(label: l10n.contactFormName),
                      const SizedBox(height: 12),
                      _inputField(label: l10n.contactFormEmail),
                      const SizedBox(height: 12),
                      _inputField(label: l10n.contactFormCompany),
                      const SizedBox(height: 12),
                      _inputField(label: l10n.contactFormMessage, lines: 6),
                      const SizedBox(height: 14),
                      Text(
                        l10n.contactFormDisclaimer,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.mutedText,
                        ),
                      ),
                      const SizedBox(height: 14),
                      FilledButton(
                        onPressed: () {},
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: AppColors.background,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 14,
                          ),
                        ),
                        child: Text(l10n.contactFormSend),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: MediaQuery.sizeOf(context).width < 960
                    ? double.infinity
                    : 380,
                child: GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.contactSidebarTitle,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      _infoTile(
                        context,
                        l10n.contactSidebarEmail,
                        l10n.contactSidebarEmailValue,
                      ),
                      _infoTile(
                        context,
                        l10n.contactSidebarResponse,
                        l10n.contactSidebarResponseValue,
                      ),
                      _infoTile(
                        context,
                        l10n.contactSidebarHours,
                        l10n.contactSidebarHoursValue,
                      ),
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

  Widget _inputField({required String label, int lines = 1}) {
    return TextField(
      maxLines: lines,
      style: const TextStyle(color: AppColors.text),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.mutedText),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accent),
        ),
      ),
    );
  }

  Widget _infoTile(BuildContext context, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.mutedText),
          ),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }
}
