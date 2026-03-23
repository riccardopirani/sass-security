import 'package:flutter/material.dart';
import 'package:sass_security/l10n/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/localization/locale_controller.dart';
import '../../../core/widgets/loading_skeleton.dart';
import '../data/auth_service.dart';
import '../models/app_profile.dart';
import 'login_signup_page.dart';
import '../../shell/presentation/home_shell.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({
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
    final l10n = AppLocalizations.of(context);

    if (!backendReady) {
      return _BackendNotReadyView(error: backendError, l10n: l10n);
    }

    final authService = AuthService();
    final supabase = Supabase.instance.client;

    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      initialData: AuthState(
        AuthChangeEvent.initialSession,
        supabase.auth.currentSession,
      ),
      builder: (context, snapshot) {
        final session = snapshot.data?.session;
        if (session == null) {
          return LoginSignupPage(authService: authService);
        }

        return FutureBuilder<AppProfile>(
          future: authService.fetchMyProfile(),
          builder: (context, profileSnapshot) {
            if (profileSnapshot.connectionState != ConnectionState.done) {
              return const _AuthLoadingView();
            }

            if (profileSnapshot.hasError || profileSnapshot.data == null) {
              return Scaffold(
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          profileSnapshot.error?.toString() ??
                              l10n.error_generic,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: authService.signOut,
                          child: Text(l10n.logout),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            return HomeShell(
              profile: profileSnapshot.data!,
              localeController: localeController,
              authService: authService,
            );
          },
        );
      },
    );
  }
}

class _AuthLoadingView extends StatelessWidget {
  const _AuthLoadingView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: SizedBox(
          width: 280,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LoadingSkeleton(height: 20),
              SizedBox(height: 12),
              LoadingSkeleton(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _BackendNotReadyView extends StatelessWidget {
  const _BackendNotReadyView({required this.error, required this.l10n});

  final String? error;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.backend_not_configured,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  Text(l10n.setup_instructions, textAlign: TextAlign.center),
                  if (error != null) ...[
                    const SizedBox(height: 12),
                    Text(error!, textAlign: TextAlign.center),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
