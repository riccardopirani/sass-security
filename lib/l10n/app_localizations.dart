import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('fr'),
    Locale('it'),
    Locale('ru'),
    Locale('zh'),
  ];

  /// No description provided for @app_title.
  ///
  /// In en, this message translates to:
  /// **'CyberGuard'**
  String get app_title;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @signup.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signup;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @company_name.
  ///
  /// In en, this message translates to:
  /// **'Company name'**
  String get company_name;

  /// No description provided for @company_code.
  ///
  /// In en, this message translates to:
  /// **'Company code'**
  String get company_code;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @admin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get admin;

  /// No description provided for @employee.
  ///
  /// In en, this message translates to:
  /// **'Employee'**
  String get employee;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @risk_score.
  ///
  /// In en, this message translates to:
  /// **'Risk Score'**
  String get risk_score;

  /// No description provided for @company_risk_score.
  ///
  /// In en, this message translates to:
  /// **'Company risk score'**
  String get company_risk_score;

  /// No description provided for @active_campaigns.
  ///
  /// In en, this message translates to:
  /// **'Active phishing campaigns'**
  String get active_campaigns;

  /// No description provided for @alerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get alerts;

  /// No description provided for @open_alerts.
  ///
  /// In en, this message translates to:
  /// **'Open alerts'**
  String get open_alerts;

  /// No description provided for @employees.
  ///
  /// In en, this message translates to:
  /// **'Employees'**
  String get employees;

  /// No description provided for @phishing.
  ///
  /// In en, this message translates to:
  /// **'Phishing'**
  String get phishing;

  /// No description provided for @subscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get subscription;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @add_employee.
  ///
  /// In en, this message translates to:
  /// **'Add employee'**
  String get add_employee;

  /// No description provided for @edit_employee.
  ///
  /// In en, this message translates to:
  /// **'Edit employee'**
  String get edit_employee;

  /// No description provided for @delete_employee.
  ///
  /// In en, this message translates to:
  /// **'Delete employee'**
  String get delete_employee;

  /// No description provided for @no_employees.
  ///
  /// In en, this message translates to:
  /// **'No employees yet'**
  String get no_employees;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @high.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get high;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get low;

  /// No description provided for @severity.
  ///
  /// In en, this message translates to:
  /// **'Severity'**
  String get severity;

  /// No description provided for @send_test.
  ///
  /// In en, this message translates to:
  /// **'Send test'**
  String get send_test;

  /// No description provided for @campaign_name.
  ///
  /// In en, this message translates to:
  /// **'Campaign name'**
  String get campaign_name;

  /// No description provided for @campaign_template.
  ///
  /// In en, this message translates to:
  /// **'Campaign template'**
  String get campaign_template;

  /// No description provided for @opened.
  ///
  /// In en, this message translates to:
  /// **'Opened'**
  String get opened;

  /// No description provided for @clicked.
  ///
  /// In en, this message translates to:
  /// **'Clicked'**
  String get clicked;

  /// No description provided for @sent.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get sent;

  /// No description provided for @pricing.
  ///
  /// In en, this message translates to:
  /// **'Pricing'**
  String get pricing;

  /// No description provided for @starter.
  ///
  /// In en, this message translates to:
  /// **'Starter'**
  String get starter;

  /// No description provided for @pro.
  ///
  /// In en, this message translates to:
  /// **'Pro'**
  String get pro;

  /// No description provided for @business.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get business;

  /// No description provided for @per_month.
  ///
  /// In en, this message translates to:
  /// **'month'**
  String get per_month;

  /// No description provided for @current_plan.
  ///
  /// In en, this message translates to:
  /// **'Current plan'**
  String get current_plan;

  /// No description provided for @upgrade.
  ///
  /// In en, this message translates to:
  /// **'Upgrade Plan'**
  String get upgrade;

  /// No description provided for @manage_subscription.
  ///
  /// In en, this message translates to:
  /// **'Manage subscription'**
  String get manage_subscription;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @choose_language.
  ///
  /// In en, this message translates to:
  /// **'Choose language'**
  String get choose_language;

  /// No description provided for @training_completion.
  ///
  /// In en, this message translates to:
  /// **'Training completion'**
  String get training_completion;

  /// No description provided for @employee_risk_ranking.
  ///
  /// In en, this message translates to:
  /// **'Employee risk ranking'**
  String get employee_risk_ranking;

  /// No description provided for @create_account.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get create_account;

  /// No description provided for @already_have_account.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get already_have_account;

  /// No description provided for @dont_have_account.
  ///
  /// In en, this message translates to:
  /// **'Don’t have an account?'**
  String get dont_have_account;

  /// No description provided for @sign_in.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get sign_in;

  /// No description provided for @sign_up_success_check_email.
  ///
  /// In en, this message translates to:
  /// **'Account created. Check your email to confirm.'**
  String get sign_up_success_check_email;

  /// No description provided for @error_generic.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get error_generic;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @empty_alerts.
  ///
  /// In en, this message translates to:
  /// **'No alerts right now'**
  String get empty_alerts;

  /// No description provided for @no_campaigns.
  ///
  /// In en, this message translates to:
  /// **'No phishing campaigns yet'**
  String get no_campaigns;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @plan_starter_desc.
  ///
  /// In en, this message translates to:
  /// **'Essential protection for small teams'**
  String get plan_starter_desc;

  /// No description provided for @plan_pro_desc.
  ///
  /// In en, this message translates to:
  /// **'Advanced simulations and analytics'**
  String get plan_pro_desc;

  /// No description provided for @plan_business_desc.
  ///
  /// In en, this message translates to:
  /// **'Enterprise workflows and priority support'**
  String get plan_business_desc;

  /// No description provided for @billing.
  ///
  /// In en, this message translates to:
  /// **'Billing'**
  String get billing;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @create_campaign.
  ///
  /// In en, this message translates to:
  /// **'Create campaign'**
  String get create_campaign;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @subscription_updated.
  ///
  /// In en, this message translates to:
  /// **'Subscription updated'**
  String get subscription_updated;

  /// No description provided for @mark_read.
  ///
  /// In en, this message translates to:
  /// **'Mark as read'**
  String get mark_read;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @welcome_back.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcome_back;

  /// No description provided for @security_posture.
  ///
  /// In en, this message translates to:
  /// **'Security posture'**
  String get security_posture;

  /// No description provided for @backend_not_configured.
  ///
  /// In en, this message translates to:
  /// **'Backend not configured'**
  String get backend_not_configured;

  /// No description provided for @setup_instructions.
  ///
  /// In en, this message translates to:
  /// **'Set SUPABASE_URL and SUPABASE_ANON_KEY via --dart-define'**
  String get setup_instructions;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'fr',
    'it',
    'ru',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'ru':
      return AppLocalizationsRu();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
