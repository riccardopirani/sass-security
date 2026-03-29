import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'i18n/generated/app_localizations.dart';
import 'i18n/locale_utils.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class CyberGuardApp extends ConsumerWidget {
  const CyberGuardApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appBrand,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: router,
      supportedLocales: LocaleUtils.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
    );
  }
}
