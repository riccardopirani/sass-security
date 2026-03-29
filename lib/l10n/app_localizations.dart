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

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
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

  /// No description provided for @marketing_landing_headline.
  ///
  /// In en, this message translates to:
  /// **'Cybersecurity platform for SMB teams'**
  String get marketing_landing_headline;

  /// No description provided for @marketing_landing_body.
  ///
  /// In en, this message translates to:
  /// **'CyberGuard helps small and medium businesses prevent phishing, monitor alerts in real time, and improve employee security posture.'**
  String get marketing_landing_body;

  /// No description provided for @marketing_landing_same_account.
  ///
  /// In en, this message translates to:
  /// **'Same account works across Web and Mobile App.'**
  String get marketing_landing_same_account;

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

  /// No description provided for @risk_score_fraction.
  ///
  /// In en, this message translates to:
  /// **'{score}/100'**
  String risk_score_fraction(int score);

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

  /// No description provided for @signup_licensed_seats_label.
  ///
  /// In en, this message translates to:
  /// **'Licensed seats'**
  String get signup_licensed_seats_label;

  /// No description provided for @signup_licensed_seats_hint.
  ///
  /// In en, this message translates to:
  /// **'How many users to bill (1–50,000)'**
  String get signup_licensed_seats_hint;

  /// No description provided for @sign_up_opening_checkout.
  ///
  /// In en, this message translates to:
  /// **'Account created. Opening secure checkout…'**
  String get sign_up_opening_checkout;

  /// No description provided for @sign_up_verify_email_then_pay.
  ///
  /// In en, this message translates to:
  /// **'Account created. Confirm your email, then sign in to open checkout and pay.'**
  String get sign_up_verify_email_then_pay;

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

  /// No description provided for @nav_news.
  ///
  /// In en, this message translates to:
  /// **'News'**
  String get nav_news;

  /// No description provided for @nav_companion.
  ///
  /// In en, this message translates to:
  /// **'Companion'**
  String get nav_companion;

  /// No description provided for @nav_security_ops.
  ///
  /// In en, this message translates to:
  /// **'Security Ops'**
  String get nav_security_ops;

  /// No description provided for @subscription_required_title.
  ///
  /// In en, this message translates to:
  /// **'Subscription required'**
  String get subscription_required_title;

  /// No description provided for @subscription_required_body.
  ///
  /// In en, this message translates to:
  /// **'Your 30-day free trial has ended, your subscription is not active, or renewal payment failed. Open Subscription to choose your seats and pay securely with Stripe to continue using CyberGuard.'**
  String get subscription_required_body;

  /// No description provided for @go_to_plans.
  ///
  /// In en, this message translates to:
  /// **'Open subscription'**
  String get go_to_plans;

  /// No description provided for @exit_app.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get exit_app;

  /// No description provided for @role_security_manager.
  ///
  /// In en, this message translates to:
  /// **'Security Manager'**
  String get role_security_manager;

  /// No description provided for @role_auditor.
  ///
  /// In en, this message translates to:
  /// **'Auditor'**
  String get role_auditor;

  /// No description provided for @open_incidents.
  ///
  /// In en, this message translates to:
  /// **'Open incidents'**
  String get open_incidents;

  /// No description provided for @critical_incidents.
  ///
  /// In en, this message translates to:
  /// **'Critical incidents'**
  String get critical_incidents;

  /// No description provided for @high_risk_employees_count.
  ///
  /// In en, this message translates to:
  /// **'High risk employees'**
  String get high_risk_employees_count;

  /// No description provided for @metric_benchmark.
  ///
  /// In en, this message translates to:
  /// **'Benchmark'**
  String get metric_benchmark;

  /// No description provided for @benchmark_safer_than.
  ///
  /// In en, this message translates to:
  /// **'Safer than {percent}%'**
  String benchmark_safer_than(int percent);

  /// No description provided for @security_posture_high_risk.
  ///
  /// In en, this message translates to:
  /// **'High risk'**
  String get security_posture_high_risk;

  /// No description provided for @security_posture_stable.
  ///
  /// In en, this message translates to:
  /// **'Stable'**
  String get security_posture_stable;

  /// No description provided for @top_risky_users_week.
  ///
  /// In en, this message translates to:
  /// **'Top 10 risky users this week'**
  String get top_risky_users_week;

  /// No description provided for @no_risky_users_week.
  ///
  /// In en, this message translates to:
  /// **'No risky users this week.'**
  String get no_risky_users_week;

  /// No description provided for @monthly_risk_trend.
  ///
  /// In en, this message translates to:
  /// **'Monthly risk trend'**
  String get monthly_risk_trend;

  /// No description provided for @no_trend_data.
  ///
  /// In en, this message translates to:
  /// **'No trend data yet.'**
  String get no_trend_data;

  /// No description provided for @manager_access_required.
  ///
  /// In en, this message translates to:
  /// **'Admin or Security Manager access required.'**
  String get manager_access_required;

  /// No description provided for @attack_sim_library.
  ///
  /// In en, this message translates to:
  /// **'Attack simulation library'**
  String get attack_sim_library;

  /// No description provided for @custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

  /// No description provided for @template_primary.
  ///
  /// In en, this message translates to:
  /// **'Template A (primary)'**
  String get template_primary;

  /// No description provided for @template_ab_test.
  ///
  /// In en, this message translates to:
  /// **'Template B (A/B test)'**
  String get template_ab_test;

  /// No description provided for @use_ai.
  ///
  /// In en, this message translates to:
  /// **'Use AI'**
  String get use_ai;

  /// No description provided for @ab_test.
  ///
  /// In en, this message translates to:
  /// **'A/B test'**
  String get ab_test;

  /// No description provided for @manual_mode.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get manual_mode;

  /// No description provided for @automatic_mode.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get automatic_mode;

  /// No description provided for @generate_ai_ab.
  ///
  /// In en, this message translates to:
  /// **'Generate AI A/B'**
  String get generate_ai_ab;

  /// No description provided for @ai_templates_generated.
  ///
  /// In en, this message translates to:
  /// **'AI templates generated'**
  String get ai_templates_generated;

  /// No description provided for @credential_submitted_short.
  ///
  /// In en, this message translates to:
  /// **'Cred'**
  String get credential_submitted_short;

  /// No description provided for @teams_departments_title.
  ///
  /// In en, this message translates to:
  /// **'Teams & Departments'**
  String get teams_departments_title;

  /// No description provided for @org_manager_required.
  ///
  /// In en, this message translates to:
  /// **'Admin or Security Manager access required.'**
  String get org_manager_required;

  /// No description provided for @departments.
  ///
  /// In en, this message translates to:
  /// **'Departments'**
  String get departments;

  /// No description provided for @new_department_name.
  ///
  /// In en, this message translates to:
  /// **'New department name'**
  String get new_department_name;

  /// No description provided for @add_department.
  ///
  /// In en, this message translates to:
  /// **'Add department'**
  String get add_department;

  /// No description provided for @unnamed.
  ///
  /// In en, this message translates to:
  /// **'Unnamed'**
  String get unnamed;

  /// No description provided for @no_departments.
  ///
  /// In en, this message translates to:
  /// **'No departments yet.'**
  String get no_departments;

  /// No description provided for @teams.
  ///
  /// In en, this message translates to:
  /// **'Teams'**
  String get teams;

  /// No description provided for @department_optional.
  ///
  /// In en, this message translates to:
  /// **'Department (optional)'**
  String get department_optional;

  /// No description provided for @no_department.
  ///
  /// In en, this message translates to:
  /// **'No department'**
  String get no_department;

  /// No description provided for @new_team_name.
  ///
  /// In en, this message translates to:
  /// **'New team name'**
  String get new_team_name;

  /// No description provided for @add_team.
  ///
  /// In en, this message translates to:
  /// **'Add team'**
  String get add_team;

  /// No description provided for @no_teams.
  ///
  /// In en, this message translates to:
  /// **'No teams yet.'**
  String get no_teams;

  /// No description provided for @security_operations_title.
  ///
  /// In en, this message translates to:
  /// **'Security Operations'**
  String get security_operations_title;

  /// No description provided for @ops_access_required.
  ///
  /// In en, this message translates to:
  /// **'Manager or Auditor access required.'**
  String get ops_access_required;

  /// No description provided for @copilot_hint.
  ///
  /// In en, this message translates to:
  /// **'Ask: \"Is this event dangerous?\"'**
  String get copilot_hint;

  /// No description provided for @ask_copilot.
  ///
  /// In en, this message translates to:
  /// **'Ask Copilot'**
  String get ask_copilot;

  /// No description provided for @refresh_analytics.
  ///
  /// In en, this message translates to:
  /// **'Refresh analytics'**
  String get refresh_analytics;

  /// No description provided for @employee_id.
  ///
  /// In en, this message translates to:
  /// **'Employee ID'**
  String get employee_id;

  /// No description provided for @suggest_actions.
  ///
  /// In en, this message translates to:
  /// **'Suggest actions'**
  String get suggest_actions;

  /// No description provided for @execute_actions.
  ///
  /// In en, this message translates to:
  /// **'Execute actions'**
  String get execute_actions;

  /// No description provided for @sender_email.
  ///
  /// In en, this message translates to:
  /// **'Sender email'**
  String get sender_email;

  /// No description provided for @subject_field.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get subject_field;

  /// No description provided for @body_excerpt.
  ///
  /// In en, this message translates to:
  /// **'Body excerpt'**
  String get body_excerpt;

  /// No description provided for @scan_email.
  ///
  /// In en, this message translates to:
  /// **'Scan email'**
  String get scan_email;

  /// No description provided for @generate_compliance_pdf.
  ///
  /// In en, this message translates to:
  /// **'Generate GDPR/Security PDF'**
  String get generate_compliance_pdf;

  /// No description provided for @copilot_no_answer.
  ///
  /// In en, this message translates to:
  /// **'No answer.'**
  String get copilot_no_answer;

  /// No description provided for @no_benchmark_data.
  ///
  /// In en, this message translates to:
  /// **'No benchmark data.'**
  String get no_benchmark_data;

  /// No description provided for @employee_id_required.
  ///
  /// In en, this message translates to:
  /// **'Employee ID is required'**
  String get employee_id_required;

  /// No description provided for @email_fields_required.
  ///
  /// In en, this message translates to:
  /// **'Sender, subject and body are required'**
  String get email_fields_required;

  /// No description provided for @action_applied.
  ///
  /// In en, this message translates to:
  /// **'Action applied'**
  String get action_applied;

  /// No description provided for @training_marked_complete.
  ///
  /// In en, this message translates to:
  /// **'Training marked as completed'**
  String get training_marked_complete;

  /// No description provided for @invalid_news_link.
  ///
  /// In en, this message translates to:
  /// **'Invalid link'**
  String get invalid_news_link;

  /// No description provided for @cannot_open_news.
  ///
  /// In en, this message translates to:
  /// **'Unable to open the article'**
  String get cannot_open_news;

  /// No description provided for @no_news_for_filter.
  ///
  /// In en, this message translates to:
  /// **'No news found for this filter'**
  String get no_news_for_filter;

  /// No description provided for @security_news_title.
  ///
  /// In en, this message translates to:
  /// **'Security News'**
  String get security_news_title;

  /// No description provided for @security_news_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Latest free articles from forums and cyber sources on viruses, hacking, and tools.'**
  String get security_news_subtitle;

  /// No description provided for @news_topic_all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get news_topic_all;

  /// No description provided for @news_topic_tools.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get news_topic_tools;

  /// No description provided for @news_badge_virus.
  ///
  /// In en, this message translates to:
  /// **'VIRUS'**
  String get news_badge_virus;

  /// No description provided for @news_badge_hacking.
  ///
  /// In en, this message translates to:
  /// **'HACKING'**
  String get news_badge_hacking;

  /// No description provided for @news_badge_tools.
  ///
  /// In en, this message translates to:
  /// **'TOOLS'**
  String get news_badge_tools;

  /// No description provided for @read_more.
  ///
  /// In en, this message translates to:
  /// **'Read more'**
  String get read_more;

  /// No description provided for @report_incident_title.
  ///
  /// In en, this message translates to:
  /// **'Report virus or hacking'**
  String get report_incident_title;

  /// No description provided for @incident_type.
  ///
  /// In en, this message translates to:
  /// **'Incident type'**
  String get incident_type;

  /// No description provided for @incident_type_virus.
  ///
  /// In en, this message translates to:
  /// **'Virus'**
  String get incident_type_virus;

  /// No description provided for @incident_type_hacking.
  ///
  /// In en, this message translates to:
  /// **'Hacking'**
  String get incident_type_hacking;

  /// No description provided for @severity_critical.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get severity_critical;

  /// No description provided for @incident_title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get incident_title;

  /// No description provided for @incident_details.
  ///
  /// In en, this message translates to:
  /// **'Incident details'**
  String get incident_details;

  /// No description provided for @send_alert.
  ///
  /// In en, this message translates to:
  /// **'Send alert'**
  String get send_alert;

  /// No description provided for @incident_report_sent.
  ///
  /// In en, this message translates to:
  /// **'Report sent and email forwarded to the company.'**
  String get incident_report_sent;

  /// No description provided for @companion_title.
  ///
  /// In en, this message translates to:
  /// **'Mobile Security Companion'**
  String get companion_title;

  /// No description provided for @companion_no_employee.
  ///
  /// In en, this message translates to:
  /// **'No linked employee profile found.'**
  String get companion_no_employee;

  /// No description provided for @companion_user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get companion_user;

  /// No description provided for @companion_risk_score.
  ///
  /// In en, this message translates to:
  /// **'Risk score'**
  String get companion_risk_score;

  /// No description provided for @companion_training.
  ///
  /// In en, this message translates to:
  /// **'Training completion'**
  String get companion_training;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @mfa_enabled_label.
  ///
  /// In en, this message translates to:
  /// **'MFA enabled'**
  String get mfa_enabled_label;

  /// No description provided for @force_mfa_login.
  ///
  /// In en, this message translates to:
  /// **'Force MFA on next login'**
  String get force_mfa_login;

  /// No description provided for @suspicious_activity.
  ///
  /// In en, this message translates to:
  /// **'Suspicious activity'**
  String get suspicious_activity;

  /// No description provided for @no_open_suspicious.
  ///
  /// In en, this message translates to:
  /// **'No open suspicious activity.'**
  String get no_open_suspicious;

  /// No description provided for @approve.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approve;

  /// No description provided for @block.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get block;

  /// No description provided for @adaptive_learning.
  ///
  /// In en, this message translates to:
  /// **'Adaptive micro-learning'**
  String get adaptive_learning;

  /// No description provided for @no_training_assignments.
  ///
  /// In en, this message translates to:
  /// **'No active training assignments.'**
  String get no_training_assignments;

  /// No description provided for @training_label.
  ///
  /// In en, this message translates to:
  /// **'Training'**
  String get training_label;

  /// No description provided for @assignment_status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get assignment_status;

  /// No description provided for @complete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;

  /// No description provided for @subscription_activation.
  ///
  /// In en, this message translates to:
  /// **'Subscription activation'**
  String get subscription_activation;

  /// No description provided for @trial_30_days.
  ///
  /// In en, this message translates to:
  /// **'Free 30 days'**
  String get trial_30_days;

  /// No description provided for @stripe_monthly_now.
  ///
  /// In en, this message translates to:
  /// **'Stripe monthly now'**
  String get stripe_monthly_now;

  /// No description provided for @trial_then_paywall.
  ///
  /// In en, this message translates to:
  /// **'30 days free, then subscription prompt'**
  String get trial_then_paywall;

  /// No description provided for @stripe_pay_immediately.
  ///
  /// In en, this message translates to:
  /// **'Monthly subscription with Stripe immediately'**
  String get stripe_pay_immediately;

  /// No description provided for @plan_label.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get plan_label;

  /// No description provided for @plan_price_starter.
  ///
  /// In en, this message translates to:
  /// **'Starter - \$29/mo'**
  String get plan_price_starter;

  /// No description provided for @plan_price_pro.
  ///
  /// In en, this message translates to:
  /// **'Pro - \$79/mo'**
  String get plan_price_pro;

  /// No description provided for @plan_price_business.
  ///
  /// In en, this message translates to:
  /// **'Business - \$199/mo'**
  String get plan_price_business;

  /// No description provided for @password_behavior_risk.
  ///
  /// In en, this message translates to:
  /// **'Password behavior risk (0-100)'**
  String get password_behavior_risk;

  /// No description provided for @incident_history_risk.
  ///
  /// In en, this message translates to:
  /// **'Incident history risk (0-100)'**
  String get incident_history_risk;

  /// No description provided for @device_compliance_risk.
  ///
  /// In en, this message translates to:
  /// **'Device compliance risk (0-100)'**
  String get device_compliance_risk;

  /// No description provided for @behavior_risk.
  ///
  /// In en, this message translates to:
  /// **'Behavior risk (0-100)'**
  String get behavior_risk;

  /// No description provided for @mfa_on.
  ///
  /// In en, this message translates to:
  /// **'ON'**
  String get mfa_on;

  /// No description provided for @mfa_off.
  ///
  /// In en, this message translates to:
  /// **'OFF'**
  String get mfa_off;

  /// No description provided for @employee_photo.
  ///
  /// In en, this message translates to:
  /// **'Profile photo'**
  String get employee_photo;

  /// No description provided for @change_photo.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get change_photo;

  /// No description provided for @remove_photo.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get remove_photo;

  /// No description provided for @photo_upload_failed.
  ///
  /// In en, this message translates to:
  /// **'Could not upload photo'**
  String get photo_upload_failed;

  /// No description provided for @photo_invalid.
  ///
  /// In en, this message translates to:
  /// **'Choose a valid image'**
  String get photo_invalid;

  /// No description provided for @behavior_risk_profile_line.
  ///
  /// In en, this message translates to:
  /// **'Behavior risk profile: {score}/100 (samples: {samples})'**
  String behavior_risk_profile_line(int score, int samples);

  /// No description provided for @ai_phishing_engine_title.
  ///
  /// In en, this message translates to:
  /// **'AI Phishing Simulation Engine'**
  String get ai_phishing_engine_title;

  /// No description provided for @ai_copilot_title.
  ///
  /// In en, this message translates to:
  /// **'AI Security Copilot'**
  String get ai_copilot_title;

  /// No description provided for @behavior_benchmark_section.
  ///
  /// In en, this message translates to:
  /// **'Behavior analytics & benchmark'**
  String get behavior_benchmark_section;

  /// No description provided for @auto_remediation_title.
  ///
  /// In en, this message translates to:
  /// **'Auto-remediation'**
  String get auto_remediation_title;

  /// No description provided for @email_security_layer_title.
  ///
  /// In en, this message translates to:
  /// **'Email security layer'**
  String get email_security_layer_title;

  /// No description provided for @audit_reports_title.
  ///
  /// In en, this message translates to:
  /// **'Audit & compliance reports'**
  String get audit_reports_title;

  /// No description provided for @remediation_summary_line.
  ///
  /// In en, this message translates to:
  /// **'Suggested: {suggested} | Executed: {executed} | Risk: {risk}'**
  String remediation_summary_line(int suggested, int executed, int risk);

  /// No description provided for @email_scan_summary_line.
  ///
  /// In en, this message translates to:
  /// **'Risk score: {score} | Severity: {severity}'**
  String email_scan_summary_line(int score, String severity);

  /// No description provided for @report_generated_summary.
  ///
  /// In en, this message translates to:
  /// **'Generated: {file} | PDF payload size: {chars} characters'**
  String report_generated_summary(String file, int chars);

  /// No description provided for @subscription_plan_flex.
  ///
  /// In en, this message translates to:
  /// **'Per-user pricing'**
  String get subscription_plan_flex;

  /// No description provided for @subscription_seats_label.
  ///
  /// In en, this message translates to:
  /// **'Number of users (seats)'**
  String get subscription_seats_label;

  /// No description provided for @subscription_pricing_explainer.
  ///
  /// In en, this message translates to:
  /// **'Monthly price uses your company risk score (0–100) and seat count: base {base} + (users × 0.22) + (users^1.1 × 0.02) + (risk × 0.05).'**
  String subscription_pricing_explainer(String base);

  /// No description provided for @subscription_company_risk_value.
  ///
  /// In en, this message translates to:
  /// **'Company risk score: {score}/100'**
  String subscription_company_risk_value(int score);

  /// No description provided for @subscription_estimated_monthly.
  ///
  /// In en, this message translates to:
  /// **'Estimated: {amount}/month'**
  String subscription_estimated_monthly(String amount);

  /// No description provided for @subscription_continue_checkout.
  ///
  /// In en, this message translates to:
  /// **'Continue to checkout'**
  String get subscription_continue_checkout;

  /// No description provided for @subscription_seats_invalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number of users (1 or more).'**
  String get subscription_seats_invalid;

  /// No description provided for @subscription_purchase_history.
  ///
  /// In en, this message translates to:
  /// **'Purchase history'**
  String get subscription_purchase_history;

  /// No description provided for @subscription_no_invoices.
  ///
  /// In en, this message translates to:
  /// **'No invoices yet. Completed payments will appear here.'**
  String get subscription_no_invoices;

  /// No description provided for @subscription_history_admin_only.
  ///
  /// In en, this message translates to:
  /// **'Only company admins can view billing history and cancel subscriptions.'**
  String get subscription_history_admin_only;

  /// No description provided for @subscription_invoice_on.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get subscription_invoice_on;

  /// No description provided for @subscription_invoice_ref.
  ///
  /// In en, this message translates to:
  /// **'Invoice'**
  String get subscription_invoice_ref;

  /// No description provided for @subscription_open_invoice.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get subscription_open_invoice;

  /// No description provided for @subscription_download_pdf.
  ///
  /// In en, this message translates to:
  /// **'PDF'**
  String get subscription_download_pdf;

  /// No description provided for @subscription_cancel_subscription.
  ///
  /// In en, this message translates to:
  /// **'Cancel subscription'**
  String get subscription_cancel_subscription;

  /// No description provided for @subscription_cancel_confirm_title.
  ///
  /// In en, this message translates to:
  /// **'Cancel subscription?'**
  String get subscription_cancel_confirm_title;

  /// No description provided for @subscription_cancel_confirm_body.
  ///
  /// In en, this message translates to:
  /// **'Your access will continue until the end of the current billing period. You can resubscribe anytime.'**
  String get subscription_cancel_confirm_body;

  /// No description provided for @subscription_cancel_confirm_action.
  ///
  /// In en, this message translates to:
  /// **'Cancel at period end'**
  String get subscription_cancel_confirm_action;

  /// No description provided for @subscription_cancel_scheduled.
  ///
  /// In en, this message translates to:
  /// **'Cancellation scheduled at the end of the billing period.'**
  String get subscription_cancel_scheduled;

  /// No description provided for @subscription_invoice_status_paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get subscription_invoice_status_paid;

  /// No description provided for @subscription_invoice_status_open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get subscription_invoice_status_open;

  /// No description provided for @subscription_invoice_status_draft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get subscription_invoice_status_draft;

  /// No description provided for @subscription_invoice_status_void.
  ///
  /// In en, this message translates to:
  /// **'Void'**
  String get subscription_invoice_status_void;

  /// No description provided for @subscription_invoice_status_uncollectible.
  ///
  /// In en, this message translates to:
  /// **'Uncollectible'**
  String get subscription_invoice_status_uncollectible;
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
