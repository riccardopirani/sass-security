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
/// import 'generated/app_localizations.dart';
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

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navFeatures.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get navFeatures;

  /// No description provided for @navPricing.
  ///
  /// In en, this message translates to:
  /// **'Pricing'**
  String get navPricing;

  /// No description provided for @navAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get navAbout;

  /// No description provided for @navContact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get navContact;

  /// No description provided for @navLogin.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get navLogin;

  /// No description provided for @footerTagline.
  ///
  /// In en, this message translates to:
  /// **'CyberGuard protects SMB teams with practical, measurable security.'**
  String get footerTagline;

  /// No description provided for @footerPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get footerPrivacy;

  /// No description provided for @footerTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms'**
  String get footerTerms;

  /// No description provided for @footerCopyright.
  ///
  /// In en, this message translates to:
  /// **'© 2026 CyberGuard. All rights reserved.'**
  String get footerCopyright;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonStartFreeTrial.
  ///
  /// In en, this message translates to:
  /// **'Start Free Trial'**
  String get commonStartFreeTrial;

  /// No description provided for @commonSeeDemo.
  ///
  /// In en, this message translates to:
  /// **'See Demo'**
  String get commonSeeDemo;

  /// No description provided for @commonOpenInApp.
  ///
  /// In en, this message translates to:
  /// **'Open in App'**
  String get commonOpenInApp;

  /// No description provided for @sameAccountText.
  ///
  /// In en, this message translates to:
  /// **'Same account works across Web and Mobile App.'**
  String get sameAccountText;

  /// No description provided for @deepLinkDesktopTitle.
  ///
  /// In en, this message translates to:
  /// **'Continue on mobile'**
  String get deepLinkDesktopTitle;

  /// No description provided for @deepLinkDesktopSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Open CyberGuard on your phone using the app deep link.'**
  String get deepLinkDesktopSubtitle;

  /// No description provided for @deepLinkScanLabel.
  ///
  /// In en, this message translates to:
  /// **'Scan the QR placeholder or use store links.'**
  String get deepLinkScanLabel;

  /// No description provided for @deepLinkStoreIos.
  ///
  /// In en, this message translates to:
  /// **'App Store'**
  String get deepLinkStoreIos;

  /// No description provided for @deepLinkStoreAndroid.
  ///
  /// In en, this message translates to:
  /// **'Google Play'**
  String get deepLinkStoreAndroid;

  /// No description provided for @demoModalTitle.
  ///
  /// In en, this message translates to:
  /// **'Live product demo'**
  String get demoModalTitle;

  /// No description provided for @demoModalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Interactive demo placeholder. Use the mobile app for full flow.'**
  String get demoModalSubtitle;

  /// No description provided for @demoModalPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Video placeholder'**
  String get demoModalPlaceholder;

  /// No description provided for @homeHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Cyber resilience made practical for SMB teams.'**
  String get homeHeroTitle;

  /// No description provided for @homeHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'CyberGuard combines phishing simulation, real-time alerts, and employee training so teams can detect, respond, and improve without enterprise overhead.'**
  String get homeHeroSubtitle;

  /// No description provided for @homeHeroPanelTitle.
  ///
  /// In en, this message translates to:
  /// **'Security pulse'**
  String get homeHeroPanelTitle;

  /// No description provided for @homeHeroPanelMetric1.
  ///
  /// In en, this message translates to:
  /// **'Platform uptime'**
  String get homeHeroPanelMetric1;

  /// No description provided for @homeHeroPanelMetric2.
  ///
  /// In en, this message translates to:
  /// **'Protected SMBs'**
  String get homeHeroPanelMetric2;

  /// No description provided for @homeHeroPanelMetric3.
  ///
  /// In en, this message translates to:
  /// **'Avg. critical alert response'**
  String get homeHeroPanelMetric3;

  /// No description provided for @socialSmbs.
  ///
  /// In en, this message translates to:
  /// **'Trusted by 500+ SMBs'**
  String get socialSmbs;

  /// No description provided for @socialUptime.
  ///
  /// In en, this message translates to:
  /// **'99.9% uptime'**
  String get socialUptime;

  /// No description provided for @socialIncidents.
  ///
  /// In en, this message translates to:
  /// **'24/7 monitored threat pipeline'**
  String get socialIncidents;

  /// No description provided for @homeFeatureSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Core capabilities'**
  String get homeFeatureSectionTitle;

  /// No description provided for @homeFeaturePhishingTitle.
  ///
  /// In en, this message translates to:
  /// **'Phishing Simulation'**
  String get homeFeaturePhishingTitle;

  /// No description provided for @homeFeaturePhishingDesc.
  ///
  /// In en, this message translates to:
  /// **'Run safe phishing campaigns to uncover risky behavior and coach teams quickly.'**
  String get homeFeaturePhishingDesc;

  /// No description provided for @homeFeatureAlertsTitle.
  ///
  /// In en, this message translates to:
  /// **'Real-time Alerts'**
  String get homeFeatureAlertsTitle;

  /// No description provided for @homeFeatureAlertsDesc.
  ///
  /// In en, this message translates to:
  /// **'Get immediate risk notifications with actionable context and ownership.'**
  String get homeFeatureAlertsDesc;

  /// No description provided for @homeFeatureRiskTitle.
  ///
  /// In en, this message translates to:
  /// **'Risk Scoring'**
  String get homeFeatureRiskTitle;

  /// No description provided for @homeFeatureRiskDesc.
  ///
  /// In en, this message translates to:
  /// **'Track company and user-level security posture on a transparent 0-100 scale.'**
  String get homeFeatureRiskDesc;

  /// No description provided for @homeFeatureTrainingTitle.
  ///
  /// In en, this message translates to:
  /// **'Employee Training'**
  String get homeFeatureTrainingTitle;

  /// No description provided for @homeFeatureTrainingDesc.
  ///
  /// In en, this message translates to:
  /// **'Deliver bite-sized training modules that close the loop after every incident.'**
  String get homeFeatureTrainingDesc;

  /// No description provided for @homeHowItWorksTitle.
  ///
  /// In en, this message translates to:
  /// **'How it works'**
  String get homeHowItWorksTitle;

  /// No description provided for @homeStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Connect your workspace'**
  String get homeStep1Title;

  /// No description provided for @homeStep1Desc.
  ///
  /// In en, this message translates to:
  /// **'Set up your tenants, users, and security baseline in minutes.'**
  String get homeStep1Desc;

  /// No description provided for @homeStep2Title.
  ///
  /// In en, this message translates to:
  /// **'Simulate and monitor'**
  String get homeStep2Title;

  /// No description provided for @homeStep2Desc.
  ///
  /// In en, this message translates to:
  /// **'Launch phishing tests and monitor live alert streams by severity.'**
  String get homeStep2Desc;

  /// No description provided for @homeStep3Title.
  ///
  /// In en, this message translates to:
  /// **'Train and improve'**
  String get homeStep3Title;

  /// No description provided for @homeStep3Desc.
  ///
  /// In en, this message translates to:
  /// **'Assign targeted learning and watch your security score increase over time.'**
  String get homeStep3Desc;

  /// No description provided for @homeTestimonialsTitle.
  ///
  /// In en, this message translates to:
  /// **'What customers say'**
  String get homeTestimonialsTitle;

  /// No description provided for @homeTestimonial1Quote.
  ///
  /// In en, this message translates to:
  /// **'CyberGuard gave us enterprise-level visibility without a heavy SOC budget.'**
  String get homeTestimonial1Quote;

  /// No description provided for @homeTestimonial1Name.
  ///
  /// In en, this message translates to:
  /// **'Elena Rossi'**
  String get homeTestimonial1Name;

  /// No description provided for @homeTestimonial1Role.
  ///
  /// In en, this message translates to:
  /// **'COO, Northlane Retail'**
  String get homeTestimonial1Role;

  /// No description provided for @homeTestimonial2Quote.
  ///
  /// In en, this message translates to:
  /// **'Our staff clicked fewer phishing emails after just one month of simulations.'**
  String get homeTestimonial2Quote;

  /// No description provided for @homeTestimonial2Name.
  ///
  /// In en, this message translates to:
  /// **'Marc Dubois'**
  String get homeTestimonial2Name;

  /// No description provided for @homeTestimonial2Role.
  ///
  /// In en, this message translates to:
  /// **'IT Lead, Atelier 19'**
  String get homeTestimonial2Role;

  /// No description provided for @homeTestimonial3Quote.
  ///
  /// In en, this message translates to:
  /// **'The risk score helped leadership align security decisions with real metrics.'**
  String get homeTestimonial3Quote;

  /// No description provided for @homeTestimonial3Name.
  ///
  /// In en, this message translates to:
  /// **'Jonas Weber'**
  String get homeTestimonial3Name;

  /// No description provided for @homeTestimonial3Role.
  ///
  /// In en, this message translates to:
  /// **'CFO, BrightForge'**
  String get homeTestimonial3Role;

  /// No description provided for @homeFinalCtaTitle.
  ///
  /// In en, this message translates to:
  /// **'Ready to harden your business?'**
  String get homeFinalCtaTitle;

  /// No description provided for @homeFinalCtaSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start your free trial and secure your entire team from day one.'**
  String get homeFinalCtaSubtitle;

  /// No description provided for @featuresTitle.
  ///
  /// In en, this message translates to:
  /// **'Platform features'**
  String get featuresTitle;

  /// No description provided for @featuresSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Everything SMBs need to prevent, detect, and respond to cyber risk.'**
  String get featuresSubtitle;

  /// No description provided for @featuresWorksBadge.
  ///
  /// In en, this message translates to:
  /// **'Works on Web + Mobile Flutter App'**
  String get featuresWorksBadge;

  /// No description provided for @dashboardMockTitle.
  ///
  /// In en, this message translates to:
  /// **'Risk command dashboard'**
  String get dashboardMockTitle;

  /// No description provided for @dashboardMockRisk.
  ///
  /// In en, this message translates to:
  /// **'Risk score (0-100)'**
  String get dashboardMockRisk;

  /// No description provided for @dashboardMockAlerts.
  ///
  /// In en, this message translates to:
  /// **'Open alerts'**
  String get dashboardMockAlerts;

  /// No description provided for @dashboardMockTraining.
  ///
  /// In en, this message translates to:
  /// **'Training completion'**
  String get dashboardMockTraining;

  /// No description provided for @dashboardMockCoverage.
  ///
  /// In en, this message translates to:
  /// **'Policy coverage'**
  String get dashboardMockCoverage;

  /// No description provided for @featuresDashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Unified Dashboard'**
  String get featuresDashboardTitle;

  /// No description provided for @featuresDashboardDesc.
  ///
  /// In en, this message translates to:
  /// **'Real-time risk scoring from 0 to 100 with contextual drill-down per team.'**
  String get featuresDashboardDesc;

  /// No description provided for @featuresPhishingTitle.
  ///
  /// In en, this message translates to:
  /// **'Phishing Simulation'**
  String get featuresPhishingTitle;

  /// No description provided for @featuresPhishingDesc.
  ///
  /// In en, this message translates to:
  /// **'Scenario-based campaigns with automated remediation paths and outcomes.'**
  String get featuresPhishingDesc;

  /// No description provided for @featuresAlertsTitle.
  ///
  /// In en, this message translates to:
  /// **'Real-time Alerts'**
  String get featuresAlertsTitle;

  /// No description provided for @featuresAlertsDesc.
  ///
  /// In en, this message translates to:
  /// **'Live incident stream with low, medium, and high severity triage.'**
  String get featuresAlertsDesc;

  /// No description provided for @featuresSeverityLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get featuresSeverityLow;

  /// No description provided for @featuresSeverityMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get featuresSeverityMedium;

  /// No description provided for @featuresSeverityHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get featuresSeverityHigh;

  /// No description provided for @featuresEmployeeMgmtTitle.
  ///
  /// In en, this message translates to:
  /// **'Employee Management'**
  String get featuresEmployeeMgmtTitle;

  /// No description provided for @featuresEmployeeMgmtDesc.
  ///
  /// In en, this message translates to:
  /// **'Invite, segment, and govern users with CRUD workflows and access controls.'**
  String get featuresEmployeeMgmtDesc;

  /// No description provided for @featuresCrudAdd.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get featuresCrudAdd;

  /// No description provided for @featuresCrudEdit.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get featuresCrudEdit;

  /// No description provided for @featuresCrudDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get featuresCrudDelete;

  /// No description provided for @featuresScoreEngineTitle.
  ///
  /// In en, this message translates to:
  /// **'Security Score Engine'**
  String get featuresScoreEngineTitle;

  /// No description provided for @featuresScoreEngineDesc.
  ///
  /// In en, this message translates to:
  /// **'Adaptive scoring logic that combines behavior signals and control maturity.'**
  String get featuresScoreEngineDesc;

  /// No description provided for @featuresMultiTenancyTitle.
  ///
  /// In en, this message translates to:
  /// **'Multi-tenancy'**
  String get featuresMultiTenancyTitle;

  /// No description provided for @featuresMultiTenancyDesc.
  ///
  /// In en, this message translates to:
  /// **'Supabase-based tenant isolation for secure SMB account boundaries.'**
  String get featuresMultiTenancyDesc;

  /// No description provided for @featuresRbacTitle.
  ///
  /// In en, this message translates to:
  /// **'Role-based Access'**
  String get featuresRbacTitle;

  /// No description provided for @featuresRbacDesc.
  ///
  /// In en, this message translates to:
  /// **'Admin, manager, and analyst roles with auditable permission boundaries.'**
  String get featuresRbacDesc;

  /// No description provided for @pricingTitle.
  ///
  /// In en, this message translates to:
  /// **'Simple pricing'**
  String get pricingTitle;

  /// No description provided for @pricingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Scale security by stage, not by complexity.'**
  String get pricingSubtitle;

  /// No description provided for @pricingStarter.
  ///
  /// In en, this message translates to:
  /// **'Starter'**
  String get pricingStarter;

  /// No description provided for @pricingPro.
  ///
  /// In en, this message translates to:
  /// **'Pro'**
  String get pricingPro;

  /// No description provided for @pricingBusiness.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get pricingBusiness;

  /// No description provided for @pricingStarterPrice.
  ///
  /// In en, this message translates to:
  /// **'\$29'**
  String get pricingStarterPrice;

  /// No description provided for @pricingProPrice.
  ///
  /// In en, this message translates to:
  /// **'\$79'**
  String get pricingProPrice;

  /// No description provided for @pricingBusinessPrice.
  ///
  /// In en, this message translates to:
  /// **'\$149'**
  String get pricingBusinessPrice;

  /// No description provided for @pricingPerMonth.
  ///
  /// In en, this message translates to:
  /// **'/month'**
  String get pricingPerMonth;

  /// No description provided for @pricingPopular.
  ///
  /// In en, this message translates to:
  /// **'Most popular'**
  String get pricingPopular;

  /// No description provided for @pricingStarterF1.
  ///
  /// In en, this message translates to:
  /// **'Risk dashboard'**
  String get pricingStarterF1;

  /// No description provided for @pricingStarterF2.
  ///
  /// In en, this message translates to:
  /// **'Basic phishing simulations'**
  String get pricingStarterF2;

  /// No description provided for @pricingStarterF3.
  ///
  /// In en, this message translates to:
  /// **'Email alerts'**
  String get pricingStarterF3;

  /// No description provided for @pricingStarterF4.
  ///
  /// In en, this message translates to:
  /// **'Up to 25 users'**
  String get pricingStarterF4;

  /// No description provided for @pricingProF1.
  ///
  /// In en, this message translates to:
  /// **'Advanced simulations'**
  String get pricingProF1;

  /// No description provided for @pricingProF2.
  ///
  /// In en, this message translates to:
  /// **'Real-time severity alerts'**
  String get pricingProF2;

  /// No description provided for @pricingProF3.
  ///
  /// In en, this message translates to:
  /// **'Training automation'**
  String get pricingProF3;

  /// No description provided for @pricingProF4.
  ///
  /// In en, this message translates to:
  /// **'Up to 150 users'**
  String get pricingProF4;

  /// No description provided for @pricingBusinessF1.
  ///
  /// In en, this message translates to:
  /// **'Unlimited users'**
  String get pricingBusinessF1;

  /// No description provided for @pricingBusinessF2.
  ///
  /// In en, this message translates to:
  /// **'Multi-tenant controls'**
  String get pricingBusinessF2;

  /// No description provided for @pricingBusinessF3.
  ///
  /// In en, this message translates to:
  /// **'Priority support'**
  String get pricingBusinessF3;

  /// No description provided for @pricingBusinessF4.
  ///
  /// In en, this message translates to:
  /// **'Security score API'**
  String get pricingBusinessF4;

  /// No description provided for @pricingFaqTitle.
  ///
  /// In en, this message translates to:
  /// **'Frequently asked questions'**
  String get pricingFaqTitle;

  /// No description provided for @pricingFaq1Q.
  ///
  /// In en, this message translates to:
  /// **'Can I change plans later?'**
  String get pricingFaq1Q;

  /// No description provided for @pricingFaq1A.
  ///
  /// In en, this message translates to:
  /// **'Yes. Upgrades and downgrades are handled from billing settings with prorated adjustments.'**
  String get pricingFaq1A;

  /// No description provided for @pricingFaq2Q.
  ///
  /// In en, this message translates to:
  /// **'Is there a free trial?'**
  String get pricingFaq2Q;

  /// No description provided for @pricingFaq2A.
  ///
  /// In en, this message translates to:
  /// **'Every plan starts with a free trial period and no setup fee.'**
  String get pricingFaq2A;

  /// No description provided for @pricingFaq3Q.
  ///
  /// In en, this message translates to:
  /// **'Do you support Stripe billing?'**
  String get pricingFaq3Q;

  /// No description provided for @pricingFaq3A.
  ///
  /// In en, this message translates to:
  /// **'Yes. CyberGuard uses Stripe for secure subscriptions and invoices.'**
  String get pricingFaq3A;

  /// No description provided for @pricingFaq4Q.
  ///
  /// In en, this message translates to:
  /// **'Does CyberGuard support multiple companies?'**
  String get pricingFaq4Q;

  /// No description provided for @pricingFaq4A.
  ///
  /// In en, this message translates to:
  /// **'The Business plan includes multi-tenant management for agencies and groups.'**
  String get pricingFaq4A;

  /// No description provided for @pricingFaq5Q.
  ///
  /// In en, this message translates to:
  /// **'Can we use SSO?'**
  String get pricingFaq5Q;

  /// No description provided for @pricingFaq5A.
  ///
  /// In en, this message translates to:
  /// **'SSO is available on Pro and Business with policy controls.'**
  String get pricingFaq5A;

  /// No description provided for @pricingFaq6Q.
  ///
  /// In en, this message translates to:
  /// **'Is mobile included?'**
  String get pricingFaq6Q;

  /// No description provided for @pricingFaq6A.
  ///
  /// In en, this message translates to:
  /// **'Yes. The same account works on Flutter Web and Flutter Mobile App.'**
  String get pricingFaq6A;

  /// No description provided for @pricingFaq7Q.
  ///
  /// In en, this message translates to:
  /// **'How long does onboarding take?'**
  String get pricingFaq7Q;

  /// No description provided for @pricingFaq7A.
  ///
  /// In en, this message translates to:
  /// **'Most SMBs complete setup in less than one day.'**
  String get pricingFaq7A;

  /// No description provided for @pricingFaq8Q.
  ///
  /// In en, this message translates to:
  /// **'Do you offer annual billing?'**
  String get pricingFaq8Q;

  /// No description provided for @pricingFaq8A.
  ///
  /// In en, this message translates to:
  /// **'Yes. Annual billing with discount is available from the billing portal.'**
  String get pricingFaq8A;

  /// No description provided for @pricingComparisonTitle.
  ///
  /// In en, this message translates to:
  /// **'Plan comparison'**
  String get pricingComparisonTitle;

  /// No description provided for @pricingComparisonFeature.
  ///
  /// In en, this message translates to:
  /// **'Feature'**
  String get pricingComparisonFeature;

  /// No description provided for @pricingComparisonPhishing.
  ///
  /// In en, this message translates to:
  /// **'Phishing simulation'**
  String get pricingComparisonPhishing;

  /// No description provided for @pricingComparisonAlerts.
  ///
  /// In en, this message translates to:
  /// **'Real-time alerts'**
  String get pricingComparisonAlerts;

  /// No description provided for @pricingComparisonTraining.
  ///
  /// In en, this message translates to:
  /// **'Employee training'**
  String get pricingComparisonTraining;

  /// No description provided for @pricingComparisonSupabase.
  ///
  /// In en, this message translates to:
  /// **'Multi-tenant isolation'**
  String get pricingComparisonSupabase;

  /// No description provided for @pricingComparisonSso.
  ///
  /// In en, this message translates to:
  /// **'SSO + RBAC'**
  String get pricingComparisonSso;

  /// No description provided for @pricingComparisonSupport.
  ///
  /// In en, this message translates to:
  /// **'Priority support'**
  String get pricingComparisonSupport;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About CyberGuard'**
  String get aboutTitle;

  /// No description provided for @aboutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Built to give SMBs practical security without enterprise complexity.'**
  String get aboutSubtitle;

  /// No description provided for @aboutMissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Mission'**
  String get aboutMissionTitle;

  /// No description provided for @aboutMissionBody.
  ///
  /// In en, this message translates to:
  /// **'We help growing companies reduce cyber risk with measurable controls and clear guidance.'**
  String get aboutMissionBody;

  /// No description provided for @aboutWhyTitle.
  ///
  /// In en, this message translates to:
  /// **'Why CyberGuard exists'**
  String get aboutWhyTitle;

  /// No description provided for @aboutWhyBody.
  ///
  /// In en, this message translates to:
  /// **'Most SMB teams are targeted but under-resourced. CyberGuard closes that gap with automation, visibility, and fast response workflows.'**
  String get aboutWhyBody;

  /// No description provided for @aboutCrossPlatformNote.
  ///
  /// In en, this message translates to:
  /// **'CyberGuard is a cross-platform system: Flutter Web + Flutter Mobile App'**
  String get aboutCrossPlatformNote;

  /// No description provided for @aboutValuesTitle.
  ///
  /// In en, this message translates to:
  /// **'Core values'**
  String get aboutValuesTitle;

  /// No description provided for @aboutValue1Title.
  ///
  /// In en, this message translates to:
  /// **'Practical security'**
  String get aboutValue1Title;

  /// No description provided for @aboutValue1Desc.
  ///
  /// In en, this message translates to:
  /// **'Prioritize actions teams can execute today.'**
  String get aboutValue1Desc;

  /// No description provided for @aboutValue2Title.
  ///
  /// In en, this message translates to:
  /// **'Clarity over noise'**
  String get aboutValue2Title;

  /// No description provided for @aboutValue2Desc.
  ///
  /// In en, this message translates to:
  /// **'Every alert should provide context, ownership, and next steps.'**
  String get aboutValue2Desc;

  /// No description provided for @aboutValue3Title.
  ///
  /// In en, this message translates to:
  /// **'Secure by design'**
  String get aboutValue3Title;

  /// No description provided for @aboutValue3Desc.
  ///
  /// In en, this message translates to:
  /// **'Multi-tenant isolation and role boundaries are built in by default.'**
  String get aboutValue3Desc;

  /// No description provided for @aboutValue4Title.
  ///
  /// In en, this message translates to:
  /// **'Continuous improvement'**
  String get aboutValue4Title;

  /// No description provided for @aboutValue4Desc.
  ///
  /// In en, this message translates to:
  /// **'Simulation and training are looped into one measurable system.'**
  String get aboutValue4Desc;

  /// No description provided for @aboutTeamTitle.
  ///
  /// In en, this message translates to:
  /// **'Team'**
  String get aboutTeamTitle;

  /// No description provided for @aboutTeam1Name.
  ///
  /// In en, this message translates to:
  /// **'A. Kim'**
  String get aboutTeam1Name;

  /// No description provided for @aboutTeam1Role.
  ///
  /// In en, this message translates to:
  /// **'CEO & Co-founder'**
  String get aboutTeam1Role;

  /// No description provided for @aboutTeam2Name.
  ///
  /// In en, this message translates to:
  /// **'L. Bianchi'**
  String get aboutTeam2Name;

  /// No description provided for @aboutTeam2Role.
  ///
  /// In en, this message translates to:
  /// **'Head of Security'**
  String get aboutTeam2Role;

  /// No description provided for @aboutTeam3Name.
  ///
  /// In en, this message translates to:
  /// **'M. Chen'**
  String get aboutTeam3Name;

  /// No description provided for @aboutTeam3Role.
  ///
  /// In en, this message translates to:
  /// **'Product Lead'**
  String get aboutTeam3Role;

  /// No description provided for @aboutTeam4Name.
  ///
  /// In en, this message translates to:
  /// **'R. Ivanov'**
  String get aboutTeam4Name;

  /// No description provided for @aboutTeam4Role.
  ///
  /// In en, this message translates to:
  /// **'Engineering Lead'**
  String get aboutTeam4Role;

  /// No description provided for @aboutTimelineTitle.
  ///
  /// In en, this message translates to:
  /// **'Journey'**
  String get aboutTimelineTitle;

  /// No description provided for @aboutTimeline1.
  ///
  /// In en, this message translates to:
  /// **'2023: CyberGuard founded to serve SMB cyber defense needs.'**
  String get aboutTimeline1;

  /// No description provided for @aboutTimeline2.
  ///
  /// In en, this message translates to:
  /// **'2024: First multi-tenant release built on Supabase.'**
  String get aboutTimeline2;

  /// No description provided for @aboutTimeline3.
  ///
  /// In en, this message translates to:
  /// **'2025: Mobile Flutter app launched for field-ready workflows.'**
  String get aboutTimeline3;

  /// No description provided for @aboutTimeline4.
  ///
  /// In en, this message translates to:
  /// **'2026: Cross-platform experience unified under one account.'**
  String get aboutTimeline4;

  /// No description provided for @contactTitle.
  ///
  /// In en, this message translates to:
  /// **'Talk with CyberGuard'**
  String get contactTitle;

  /// No description provided for @contactSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Send us your security goals and we will map the right rollout.'**
  String get contactSubtitle;

  /// No description provided for @contactFormName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get contactFormName;

  /// No description provided for @contactFormEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get contactFormEmail;

  /// No description provided for @contactFormCompany.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get contactFormCompany;

  /// No description provided for @contactFormMessage.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get contactFormMessage;

  /// No description provided for @contactFormSend.
  ///
  /// In en, this message translates to:
  /// **'Send Message'**
  String get contactFormSend;

  /// No description provided for @contactFormDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'UI placeholder form. Submission backend can be connected to Supabase or CRM.'**
  String get contactFormDisclaimer;

  /// No description provided for @contactSidebarTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact info'**
  String get contactSidebarTitle;

  /// No description provided for @contactSidebarEmail.
  ///
  /// In en, this message translates to:
  /// **'Support email'**
  String get contactSidebarEmail;

  /// No description provided for @contactSidebarEmailValue.
  ///
  /// In en, this message translates to:
  /// **'support@cyberguard.io'**
  String get contactSidebarEmailValue;

  /// No description provided for @contactSidebarResponse.
  ///
  /// In en, this message translates to:
  /// **'Response time'**
  String get contactSidebarResponse;

  /// No description provided for @contactSidebarResponseValue.
  ///
  /// In en, this message translates to:
  /// **'Within 24 business hours'**
  String get contactSidebarResponseValue;

  /// No description provided for @contactSidebarHours.
  ///
  /// In en, this message translates to:
  /// **'Working hours'**
  String get contactSidebarHours;

  /// No description provided for @contactSidebarHoursValue.
  ///
  /// In en, this message translates to:
  /// **'Mon-Fri, 09:00-18:00 CET'**
  String get contactSidebarHoursValue;

  /// No description provided for @privacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyTitle;

  /// No description provided for @privacyUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated: March 23, 2026'**
  String get privacyUpdated;

  /// No description provided for @privacyIntro.
  ///
  /// In en, this message translates to:
  /// **'This placeholder privacy policy describes how CyberGuard processes account, usage, and security telemetry data.'**
  String get privacyIntro;

  /// No description provided for @privacySection1Title.
  ///
  /// In en, this message translates to:
  /// **'Data we collect'**
  String get privacySection1Title;

  /// No description provided for @privacySection1Body.
  ///
  /// In en, this message translates to:
  /// **'We process account identity data, tenant configuration, and event telemetry required to operate the service.'**
  String get privacySection1Body;

  /// No description provided for @privacySection2Title.
  ///
  /// In en, this message translates to:
  /// **'How we use data'**
  String get privacySection2Title;

  /// No description provided for @privacySection2Body.
  ///
  /// In en, this message translates to:
  /// **'Data is used to provide cybersecurity monitoring, risk scoring, support, and service improvement.'**
  String get privacySection2Body;

  /// No description provided for @privacySection3Title.
  ///
  /// In en, this message translates to:
  /// **'Data sharing'**
  String get privacySection3Title;

  /// No description provided for @privacySection3Body.
  ///
  /// In en, this message translates to:
  /// **'We do not sell personal data. Limited subprocessors (for hosting, billing, and analytics) may process data on our behalf.'**
  String get privacySection3Body;

  /// No description provided for @privacySection4Title.
  ///
  /// In en, this message translates to:
  /// **'Retention and rights'**
  String get privacySection4Title;

  /// No description provided for @privacySection4Body.
  ///
  /// In en, this message translates to:
  /// **'Customers can request export or deletion according to contract and applicable law.'**
  String get privacySection4Body;

  /// No description provided for @termsTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsTitle;

  /// No description provided for @termsUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated: March 23, 2026'**
  String get termsUpdated;

  /// No description provided for @termsIntro.
  ///
  /// In en, this message translates to:
  /// **'This placeholder terms document defines platform usage rules, billing obligations, and acceptable use boundaries.'**
  String get termsIntro;

  /// No description provided for @termsSection1Title.
  ///
  /// In en, this message translates to:
  /// **'Service scope'**
  String get termsSection1Title;

  /// No description provided for @termsSection1Body.
  ///
  /// In en, this message translates to:
  /// **'CyberGuard provides cloud software for SMB cybersecurity operations and training workflows.'**
  String get termsSection1Body;

  /// No description provided for @termsSection2Title.
  ///
  /// In en, this message translates to:
  /// **'Billing'**
  String get termsSection2Title;

  /// No description provided for @termsSection2Body.
  ///
  /// In en, this message translates to:
  /// **'Paid subscriptions are billed through Stripe, with renewal, upgrade, and cancellation terms in the billing portal.'**
  String get termsSection2Body;

  /// No description provided for @termsSection3Title.
  ///
  /// In en, this message translates to:
  /// **'Customer responsibilities'**
  String get termsSection3Title;

  /// No description provided for @termsSection3Body.
  ///
  /// In en, this message translates to:
  /// **'Customers are responsible for secure credential handling and lawful use of simulation campaigns.'**
  String get termsSection3Body;

  /// No description provided for @termsSection4Title.
  ///
  /// In en, this message translates to:
  /// **'Liability and support'**
  String get termsSection4Title;

  /// No description provided for @termsSection4Body.
  ///
  /// In en, this message translates to:
  /// **'Support levels vary by plan. Liability limits and warranties are governed by the master agreement.'**
  String get termsSection4Body;

  /// No description provided for @homeMessagingTitle.
  ///
  /// In en, this message translates to:
  /// **'High-impact messaging'**
  String get homeMessagingTitle;

  /// No description provided for @homeMessagingHeadlinesTitle.
  ///
  /// In en, this message translates to:
  /// **'Headlines'**
  String get homeMessagingHeadlinesTitle;

  /// No description provided for @homeMessagingHeadlinesItems.
  ///
  /// In en, this message translates to:
  /// **'90% of cyberattacks start with human error. We prevent it.||Turn your employees into your first line of defense.||Discover who in your company is the highest risk, before a hacker does.||Cybersecurity is not only a technical problem. It is a human problem.||Reduce phishing risk by up to 70% without changing infrastructure.'**
  String get homeMessagingHeadlinesItems;

  /// No description provided for @homeMessagingValueTitle.
  ///
  /// In en, this message translates to:
  /// **'Value proposition'**
  String get homeMessagingValueTitle;

  /// No description provided for @homeMessagingValueItems.
  ///
  /// In en, this message translates to:
  /// **'We identify, measure, and reduce human risk in your company in real time.||An AI system that protects your company from employee mistakes.||We assign a risk score to every employee to prevent attacks before they happen.||Your company is secure until one employee clicks the wrong email.'**
  String get homeMessagingValueItems;

  /// No description provided for @homeMessagingProblemTitle.
  ///
  /// In en, this message translates to:
  /// **'Problem-aware hooks'**
  String get homeMessagingProblemTitle;

  /// No description provided for @homeMessagingProblemItems.
  ///
  /// In en, this message translates to:
  /// **'Do you know who in your company would click a phishing email today?||A single click can compromise your entire infrastructure.||Firewalls are not the problem. People are.||Every company is secure until the first human error.||Your security stack cannot see the biggest risk: your employees.'**
  String get homeMessagingProblemItems;

  /// No description provided for @homeMessagingAiTitle.
  ///
  /// In en, this message translates to:
  /// **'AI + innovation'**
  String get homeMessagingAiTitle;

  /// No description provided for @homeMessagingAiItems.
  ///
  /// In en, this message translates to:
  /// **'An AI system that analyzes human behavior and prevents attacks before they happen.||From monitoring to automatic prevention of human risk.||The first AI system that measures cyber risk of people, not only systems.||Security intelligence working in real time on human behavior.'**
  String get homeMessagingAiItems;

  /// No description provided for @homeMessagingRoiTitle.
  ///
  /// In en, this message translates to:
  /// **'ROI / business'**
  String get homeMessagingRoiTitle;

  /// No description provided for @homeMessagingRoiItems.
  ///
  /// In en, this message translates to:
  /// **'Reduce incident response costs by up to 60%.||Prevent costly breaches before they happen.||A single phishing attack can cost millions. We stop it before the click.||Immediate ROI: fewer incidents, less damage, less downtime.'**
  String get homeMessagingRoiItems;

  /// No description provided for @homeMessagingExecTitle.
  ///
  /// In en, this message translates to:
  /// **'Executive focus'**
  String get homeMessagingExecTitle;

  /// No description provided for @homeMessagingExecItems.
  ///
  /// In en, this message translates to:
  /// **'A simple dashboard to understand your company\'s real risk.||View your cyber risk level in under 60 seconds.||Make decisions with data, not assumptions.||Complete control of human risk in one view.'**
  String get homeMessagingExecItems;

  /// No description provided for @homeMessagingUrgencyTitle.
  ///
  /// In en, this message translates to:
  /// **'Urgency'**
  String get homeMessagingUrgencyTitle;

  /// No description provided for @homeMessagingUrgencyItems.
  ///
  /// In en, this message translates to:
  /// **'Every day without control over human risk is active risk.||Attacks do not wait until you are ready. They strike when an employee makes a mistake.||Not knowing who is vulnerable is already a vulnerability.||Your next breach could already be underway, without you knowing it.'**
  String get homeMessagingUrgencyItems;

  /// No description provided for @homeMessagingMobileTitle.
  ///
  /// In en, this message translates to:
  /// **'Mobile / modern'**
  String get homeMessagingMobileTitle;

  /// No description provided for @homeMessagingMobileItems.
  ///
  /// In en, this message translates to:
  /// **'Receive real-time alerts about employee risk.||Manage company security directly from your phone.||Cybersecurity that follows you everywhere, not only in the office.'**
  String get homeMessagingMobileItems;
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
