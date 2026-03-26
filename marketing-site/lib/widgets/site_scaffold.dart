import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../i18n/generated/app_localizations.dart';
import '../i18n/locale_utils.dart';
import '../services/deep_link_service.dart';
import '../theme/app_theme.dart';
import 'cta_button.dart';
import 'cyber_background.dart';
import 'section_container.dart';

class SiteScaffold extends StatelessWidget {
  const SiteScaffold({
    super.key,
    required this.localeCode,
    required this.child,
    this.animateBackground = false,
  });

  final String localeCode;
  final Widget child;

  /// When true, [CyberBackground] animates (intended for home only).
  final bool animateBackground;

  @override
  Widget build(BuildContext context) {
    final locale = LocaleUtils.fromCode(localeCode);

    return Localizations.override(
      context: context,
      locale: locale,
      child: Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context);

          return Scaffold(
            body: Stack(
              children: [
                Positioned.fill(
                  child: CyberBackground(animated: animateBackground),
                ),
                SingleChildScrollView(
                  child: Column(
                    children: [
                      _TopNav(localeCode: localeCode, l10n: l10n),
                      child,
                      SectionContainer(
                        padding: const EdgeInsets.fromLTRB(24, 40, 24, 50),
                        child: _Footer(localeCode: localeCode, l10n: l10n),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TopNav extends StatelessWidget {
  const _TopNav({required this.localeCode, required this.l10n});

  final String localeCode;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.sizeOf(context).width < 980;

    final navItems = <({String label, String path})>[
      (label: l10n.navHome, path: '/$localeCode'),
      (label: l10n.navFeatures, path: '/$localeCode/features'),
      (label: l10n.navPricing, path: '/$localeCode/pricing'),
      (label: l10n.navAbout, path: '/$localeCode/about'),
      (label: l10n.navContact, path: '/$localeCode/contact'),
    ];

    return SectionContainer(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.52),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          runAlignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: 12,
          spacing: 16,
          children: [
            InkWell(
              onTap: () => context.go('/$localeCode'),
              child: Text(
                'CyberGuard',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (isCompact)
              SizedBox(
                width: MediaQuery.sizeOf(context).width - 90,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ...navItems.map(
                        (item) => _NavLink(item: item, l10n: l10n),
                      ),
                      const SizedBox(width: 10),
                      _LocalePicker(localeCode: localeCode),
                      const SizedBox(width: 10),
                      CtaButton(
                        label: l10n.navLogin,
                        filled: false,
                        onPressed: () => DeepLinkService.handleCta(
                          context,
                          CtaDeepLink.login,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...navItems.map((item) => _NavLink(item: item, l10n: l10n)),
                  const SizedBox(width: 10),
                  _LocalePicker(localeCode: localeCode),
                  const SizedBox(width: 10),
                  CtaButton(
                    label: l10n.navLogin,
                    filled: false,
                    onPressed: () =>
                        DeepLinkService.handleCta(context, CtaDeepLink.login),
                  ),
                ],
              ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.08, end: 0);
  }
}

class _NavLink extends StatelessWidget {
  const _NavLink({required this.item, required this.l10n});

  final ({String label, String path}) item;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.path;
    final active = currentPath == item.path;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: () => context.go(item.path),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: active ? AppColors.accent.withValues(alpha: 0.14) : null,
          ),
          child: Text(
            item.label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: active ? AppColors.accent : AppColors.text,
            ),
          ),
        ),
      ),
    );
  }
}

class _LocalePicker extends StatelessWidget {
  const _LocalePicker({required this.localeCode});

  final String localeCode;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
        color: Colors.black.withValues(alpha: 0.18),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          dropdownColor: AppColors.surface,
          value: localeCode,
          iconEnabledColor: AppColors.text,
          onChanged: (nextCode) {
            if (nextCode == null) return;
            final currentPath = GoRouterState.of(context).uri.toString();
            final nextPath = LocaleUtils.switchLocaleInPath(
              currentPath,
              nextCode,
            );
            context.go(nextPath);
          },
          items: LocaleUtils.supportedLocaleCodes
              .map(
                (code) => DropdownMenuItem<String>(
                  value: code,
                  child: Text(
                    LocaleUtils.localeLabels[code] ?? code.toUpperCase(),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.localeCode, required this.l10n});

  final String localeCode;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: AppColors.border.withValues(alpha: 0.7)),
        const SizedBox(height: 18),
        Wrap(
          spacing: 18,
          runSpacing: 10,
          alignment: WrapAlignment.spaceBetween,
          children: [
            Text(
              l10n.footerTagline,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.mutedText),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () => context.go('/$localeCode/legal/privacy'),
                  child: Text(l10n.footerPrivacy),
                ),
                TextButton(
                  onPressed: () => context.go('/$localeCode/legal/terms'),
                  child: Text(l10n.footerTerms),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          l10n.footerCopyright,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.mutedText),
        ),
      ],
    );
  }
}
