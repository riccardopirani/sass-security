import 'package:flutter/material.dart';
import 'package:sass_security/l10n/app_localizations.dart';

import '../../../core/localization/locale_controller.dart';
import '../../../core/utils/app_snack.dart';
import '../../../core/widgets/glass_card.dart';
import '../../auth/data/auth_service.dart';
import '../../auth/models/app_profile.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({
    required this.profile,
    required this.localeController,
    required this.authService,
    super.key,
  });

  final AppProfile profile;
  final LocaleController localeController;
  final AuthService authService;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.settings,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              Text('${l10n.name}: ${profile.name}'),
              Text('${l10n.email}: ${profile.email}'),
              Text(
                '${l10n.role}: ${profile.isAdmin ? l10n.admin : l10n.employee}',
              ),
              Text(
                '${l10n.company_name}: ${profile.companyName ?? l10n.unknown}',
              ),
              Text(
                '${l10n.company_code}: ${profile.companyCode ?? l10n.unknown}',
              ),
              const SizedBox(height: 18),
              DropdownButtonFormField<Locale>(
                initialValue: localeController.locale,
                decoration: InputDecoration(labelText: l10n.choose_language),
                items: LocaleController.supportedLocales
                    .map(
                      (locale) => DropdownMenuItem(
                        value: locale,
                        child: Text(_labelForLocale(locale)),
                      ),
                    )
                    .toList(),
                onChanged: (locale) {
                  if (locale == null) {
                    return;
                  }
                  localeController.setLocale(locale);
                },
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: () async {
                  try {
                    await authService.signOut();
                  } catch (error) {
                    if (context.mounted) {
                      AppSnack.error(context, error.toString());
                    }
                  }
                },
                icon: const Icon(Icons.logout),
                label: Text(l10n.logout),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _labelForLocale(Locale locale) {
    switch (locale.languageCode) {
      case 'it':
        return 'Italiano';
      case 'de':
        return 'Deutsch';
      case 'fr':
        return 'Français';
      case 'zh':
        return '简体中文';
      case 'ru':
        return 'Русский';
      case 'en':
      default:
        return 'English';
    }
  }
}
