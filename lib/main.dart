import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cyberguard_marketing/app.dart' as marketing_site;
import 'package:cyberguard_marketing/services/deep_link_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/env.dart';
import 'core/localization/locale_controller.dart';
import 'features/auth/presentation/auth_gate.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final localeController = await LocaleController.load();
  String? backendError;
  var backendReady = false;

  if (Env.hasSupabaseConfig) {
    try {
      await Supabase.initialize(
        url: Env.supabaseUrl,
        anonKey: Env.supabaseAnonKey,
      );
      backendReady = true;
    } catch (error) {
      backendError = error.toString();
    }
  }

  DeepLinkService.ctaOverrideHandler = (context, target) async {
    if (target == CtaDeepLink.login || target == CtaDeepLink.signup) {
      if (!context.mounted) return;
      await Navigator.of(context).push(
        PageRouteBuilder<void>(
          pageBuilder: (_, __, ___) => AnimatedBuilder(
            animation: localeController,
            builder: (context, __) => Localizations(
              locale: localeController.locale,
              delegates: AppLocalizations.localizationsDelegates,
              child: AuthGate(
                localeController: localeController,
                backendReady: backendReady,
                backendError: backendError,
              ),
            ),
          ),
          transitionsBuilder: (_, animation, __, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            );
            return FadeTransition(opacity: curved, child: child);
          },
        ),
      );
      return;
    }

    await DeepLinkService.showDesktopFallback(context, deepLink: target.uri);
  };

  runApp(const ProviderScope(child: marketing_site.CyberGuardApp()));
}
