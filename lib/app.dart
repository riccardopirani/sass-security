import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sass_security/l10n/app_localizations.dart';

import 'core/localization/locale_controller.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/auth_gate.dart';
import 'features/marketing/presentation/marketing_landing_page.dart';

class CyberGuardApp extends StatelessWidget {
  const CyberGuardApp({
    required this.localeController,
    required this.backendReady,
    this.backendError,
    super.key,
  });

  final LocaleController localeController;
  final bool backendReady;
  final String? backendError;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: localeController,
      builder: (context, _) {
        return MaterialApp(
          onGenerateTitle: (context) =>
              AppLocalizations.of(context).app_title,
          debugShowCheckedModeBanner: false,
          builder: (context, child) {
            final mq = MediaQuery.of(context);
            final scaled = mq.textScaler.clamp(
              minScaleFactor: 0.88,
              maxScaleFactor: 1.2,
            );
            return MediaQuery(
              data: mq.copyWith(textScaler: scaled),
              child: child ?? const SizedBox.shrink(),
            );
          },
          locale: localeController.locale,
          supportedLocales: LocaleController.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: AppTheme.darkTheme,
          themeMode: ThemeMode.dark,
          home: MarketingLandingPage(
            onLoginPressed: (context) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AnimatedBuilder(
                    animation: localeController,
                    builder: (context, _) => Localizations(
                      locale: localeController.locale,
                      delegates: const [
                        AppLocalizations.delegate,
                        GlobalMaterialLocalizations.delegate,
                        GlobalWidgetsLocalizations.delegate,
                        GlobalCupertinoLocalizations.delegate,
                      ],
                      child: AuthGate(
                        localeController: localeController,
                        backendReady: backendReady,
                        backendError: backendError,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
