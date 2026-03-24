import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../i18n/generated/app_localizations.dart';
import '../theme/app_theme.dart';

enum CtaDeepLink {
  signup('myapp://signup'),
  login('myapp://login'),
  demo('myapp://demo');

  const CtaDeepLink(this.uri);
  final String uri;
}

class DeepLinkService {
  static final Uri _iosStoreUri = Uri.parse('https://apps.apple.com');
  static final Uri _androidStoreUri = Uri.parse(
    'https://play.google.com/store',
  );
  static Future<void> Function(BuildContext context, CtaDeepLink target)?
  ctaOverrideHandler;

  static Future<void> handleCta(
    BuildContext context,
    CtaDeepLink target,
  ) async {
    final override = ctaOverrideHandler;
    if (override != null) {
      await override(context, target);
      return;
    }

    final isDesktop = MediaQuery.sizeOf(context).width >= 1000;

    if (isDesktop) {
      if (!context.mounted) return;
      await showDesktopFallback(context, deepLink: target.uri);
      return;
    }

    final deepLinkUri = Uri.parse(target.uri);
    final launched = await launchUrl(
      deepLinkUri,
      mode: LaunchMode.externalApplication,
    );

    if (!launched && context.mounted) {
      await showDesktopFallback(context, deepLink: target.uri);
    }
  }

  static Future<void> showDesktopFallback(
    BuildContext context, {
    required String deepLink,
  }) {
    final l10n = AppLocalizations.of(context);

    return showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 460),
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.88),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.deepLinkDesktopTitle,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.deepLinkDesktopSubtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.mutedText,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        color: const Color(0xFF040812),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'QR\n$deepLink',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.deepLinkScanLabel,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        OutlinedButton(
                          onPressed: () => launchUrl(_iosStoreUri),
                          child: Text(l10n.deepLinkStoreIos),
                        ),
                        OutlinedButton(
                          onPressed: () => launchUrl(_androidStoreUri),
                          child: Text(l10n.deepLinkStoreAndroid),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(l10n.commonClose),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
