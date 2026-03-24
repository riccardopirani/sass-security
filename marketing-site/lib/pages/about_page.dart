import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../i18n/generated/app_localizations.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/section_container.dart';
import '../widgets/section_heading.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key, required this.localeCode});

  final String localeCode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final values = [
      (title: l10n.aboutValue1Title, desc: l10n.aboutValue1Desc),
      (title: l10n.aboutValue2Title, desc: l10n.aboutValue2Desc),
      (title: l10n.aboutValue3Title, desc: l10n.aboutValue3Desc),
      (title: l10n.aboutValue4Title, desc: l10n.aboutValue4Desc),
    ];

    final team = [
      (name: l10n.aboutTeam1Name, role: l10n.aboutTeam1Role),
      (name: l10n.aboutTeam2Name, role: l10n.aboutTeam2Role),
      (name: l10n.aboutTeam3Name, role: l10n.aboutTeam3Role),
      (name: l10n.aboutTeam4Name, role: l10n.aboutTeam4Role),
    ];

    final timeline = [
      l10n.aboutTimeline1,
      l10n.aboutTimeline2,
      l10n.aboutTimeline3,
      l10n.aboutTimeline4,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionContainer(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 20),
          child: SectionHeading(
            title: l10n.aboutTitle,
            subtitle: l10n.aboutSubtitle,
          ),
        ),
        SectionContainer(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
          child: Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              SizedBox(
                width: MediaQuery.sizeOf(context).width < 980
                    ? double.infinity
                    : 570,
                child: GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.aboutMissionTitle,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.aboutMissionBody,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.mutedText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: MediaQuery.sizeOf(context).width < 980
                    ? double.infinity
                    : 570,
                child: GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.aboutWhyTitle,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.aboutWhyBody,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.mutedText,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          l10n.aboutCrossPlatformNote,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.accent),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        SectionContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.aboutValuesTitle,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: List.generate(values.length, (index) {
                  final value = values[index];
                  return SizedBox(
                    width: MediaQuery.sizeOf(context).width < 900
                        ? double.infinity
                        : 270,
                    child:
                        GlassCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    value.title,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    value.desc,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(color: AppColors.mutedText),
                                  ),
                                ],
                              ),
                            )
                            .animate(delay: (index * 80).ms)
                            .fadeIn(duration: 450.ms)
                            .slideY(begin: 0.04, end: 0),
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
                l10n.aboutTeamTitle,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: team
                    .map(
                      (member) => SizedBox(
                        width: MediaQuery.sizeOf(context).width < 900
                            ? double.infinity
                            : 270,
                        child: GlassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: AppColors.accent.withValues(
                                  alpha: 0.18,
                                ),
                                child: const Icon(
                                  Icons.person,
                                  color: AppColors.accent,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                member.name,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              Text(
                                member.role,
                                style: Theme.of(context).textTheme.bodyMedium
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
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.aboutTimelineTitle,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 14),
                ...timeline.map(
                  (step) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 6),
                          child: Icon(
                            Icons.bolt,
                            size: 14,
                            color: AppColors.accent,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            step,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppColors.mutedText),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
