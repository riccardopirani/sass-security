import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../i18n/locale_utils.dart';
import '../pages/about_page.dart';
import '../pages/contact_page.dart';
import '../pages/features_page.dart';
import '../pages/home_page.dart';
import '../pages/legal/privacy_page.dart';
import '../pages/legal/terms_page.dart';
import '../pages/pricing_page.dart';
import '../theme/app_theme.dart';
import '../widgets/site_scaffold.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/en',
    redirect: (context, state) {
      final segments = state.uri.pathSegments;
      if (segments.isEmpty) {
        return '/en';
      }

      final first = segments.first.toLowerCase();
      if (LocaleUtils.isSupportedCode(first)) {
        return null;
      }

      final isLocaleLike = first.length == 2;
      final remaining = isLocaleLike ? segments.skip(1).toList() : segments;
      final path = remaining.isEmpty ? '/en' : '/en/${remaining.join('/')}';
      if (state.uri.query.isEmpty) {
        return path;
      }
      return '$path?${state.uri.query}';
    },
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          final localeCode = LocaleUtils.normalizeCode(
            state.pathParameters['locale'],
          );
          final segments =
              state.uri.pathSegments.where((s) => s.isNotEmpty).toList();
          final isHome = segments.length == 1 &&
              LocaleUtils.isSupportedCode(segments.first);
          return SiteScaffold(
            localeCode: localeCode,
            animateBackground: isHome,
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/:locale',
            builder: (context, state) => HomePage(
              localeCode: LocaleUtils.normalizeCode(
                state.pathParameters['locale'],
              ),
            ),
            routes: [
              GoRoute(
                path: 'features',
                builder: (context, state) => FeaturesPage(
                  localeCode: LocaleUtils.normalizeCode(
                    state.pathParameters['locale'],
                  ),
                ),
              ),
              GoRoute(
                path: 'pricing',
                builder: (context, state) => PricingPage(
                  localeCode: LocaleUtils.normalizeCode(
                    state.pathParameters['locale'],
                  ),
                ),
              ),
              GoRoute(
                path: 'about',
                builder: (context, state) => AboutPage(
                  localeCode: LocaleUtils.normalizeCode(
                    state.pathParameters['locale'],
                  ),
                ),
              ),
              GoRoute(
                path: 'contact',
                builder: (context, state) => ContactPage(
                  localeCode: LocaleUtils.normalizeCode(
                    state.pathParameters['locale'],
                  ),
                ),
              ),
              GoRoute(
                path: 'legal/privacy',
                builder: (context, state) => PrivacyPage(
                  localeCode: LocaleUtils.normalizeCode(
                    state.pathParameters['locale'],
                  ),
                ),
              ),
              GoRoute(
                path: 'legal/terms',
                builder: (context, state) => TermsPage(
                  localeCode: LocaleUtils.normalizeCode(
                    state.pathParameters['locale'],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) {
      return Scaffold(
        body: Center(
          child: Text(
            '404 - ${state.error ?? 'Page not found'}',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: AppColors.text),
          ),
        ),
      );
    },
  );
});
