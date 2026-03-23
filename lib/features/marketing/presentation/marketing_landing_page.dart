import 'package:flutter/material.dart';
import 'package:sass_security/l10n/app_localizations.dart';

class MarketingLandingPage extends StatelessWidget {
  const MarketingLandingPage({required this.onLoginPressed, super.key});

  final VoidCallback onLoginPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF030712),
                  Color(0xFF0F172A),
                  Color(0xFF052E2B),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                  child: Row(
                    children: [
                      Text(
                        l10n.app_title,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const Spacer(),
                      FilledButton(
                        onPressed: onLoginPressed,
                        child: Text(l10n.login),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 900),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Cybersecurity platform for SMB teams',
                              style: Theme.of(context).textTheme.displaySmall,
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'CyberGuard helps small and medium businesses prevent phishing, monitor alerts in real time, and improve employee security posture.',
                              style: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.copyWith(color: Colors.white70),
                            ),
                            const SizedBox(height: 22),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                FilledButton(
                                  onPressed: onLoginPressed,
                                  child: Text(l10n.sign_in),
                                ),
                                OutlinedButton(
                                  onPressed: onLoginPressed,
                                  child: Text(l10n.create_account),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Same account works across Web and Mobile App.',
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(color: Colors.white60),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
