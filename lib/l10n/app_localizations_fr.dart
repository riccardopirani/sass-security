// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get app_title => 'CyberGuard';

  @override
  String get marketing_landing_headline =>
      'Plateforme de cybersécurité pour les PME';

  @override
  String get marketing_landing_body =>
      'CyberGuard aide les petites et moyennes entreprises à prévenir le phishing, à surveiller les alertes en temps réel et à améliorer la posture de sécurité des collaborateurs.';

  @override
  String get marketing_landing_same_account =>
      'Le même compte fonctionne sur le Web et l’application mobile.';

  @override
  String get login => 'Connexion';

  @override
  String get signup => 'Inscription';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Mot de passe';

  @override
  String get name => 'Nom';

  @override
  String get company_name => 'Nom de l\'entreprise';

  @override
  String get company_code => 'Code entreprise';

  @override
  String get role => 'Rôle';

  @override
  String get admin => 'Admin';

  @override
  String get employee => 'Employé';

  @override
  String get dashboard => 'Tableau de bord';

  @override
  String get risk_score => 'Score de risque';

  @override
  String risk_score_fraction(int score) {
    return '$score/100';
  }

  @override
  String get company_risk_score => 'Score de risque de l\'entreprise';

  @override
  String get active_campaigns => 'Campagnes phishing actives';

  @override
  String get alerts => 'Alertes';

  @override
  String get open_alerts => 'Alertes ouvertes';

  @override
  String get employees => 'Employés';

  @override
  String get phishing => 'Phishing';

  @override
  String get subscription => 'Abonnement';

  @override
  String get settings => 'Paramètres';

  @override
  String get logout => 'Se déconnecter';

  @override
  String get save => 'Enregistrer';

  @override
  String get cancel => 'Annuler';

  @override
  String get add_employee => 'Ajouter un employé';

  @override
  String get edit_employee => 'Modifier l\'employé';

  @override
  String get delete_employee => 'Supprimer l\'employé';

  @override
  String get no_employees => 'Aucun employé';

  @override
  String get loading => 'Chargement...';

  @override
  String get high => 'Élevé';

  @override
  String get medium => 'Moyen';

  @override
  String get low => 'Faible';

  @override
  String get severity => 'Sévérité';

  @override
  String get send_test => 'Envoyer un test';

  @override
  String get campaign_name => 'Nom de campagne';

  @override
  String get campaign_template => 'Modèle de campagne';

  @override
  String get opened => 'Ouvert';

  @override
  String get clicked => 'Cliqué';

  @override
  String get sent => 'Envoyé';

  @override
  String get pricing => 'Tarifs';

  @override
  String get starter => 'Starter';

  @override
  String get pro => 'Pro';

  @override
  String get business => 'Business';

  @override
  String get per_month => 'mois';

  @override
  String get current_plan => 'Plan actuel';

  @override
  String get upgrade => 'Mettre à niveau';

  @override
  String get manage_subscription => 'Gérer l\'abonnement';

  @override
  String get language => 'Langue';

  @override
  String get choose_language => 'Choisir la langue';

  @override
  String get training_completion => 'Achèvement de la formation';

  @override
  String get employee_risk_ranking => 'Classement des risques employés';

  @override
  String get create_account => 'Créer un compte';

  @override
  String get already_have_account => 'Vous avez déjà un compte ?';

  @override
  String get dont_have_account => 'Vous n\'avez pas de compte ?';

  @override
  String get sign_in => 'Se connecter';

  @override
  String get sign_up_success_check_email =>
      'Compte créé. Vérifiez votre e-mail pour confirmer.';

  @override
  String get signup_licensed_seats_label => 'Sièges sous licence';

  @override
  String get signup_licensed_seats_hint =>
      'Nombre d\'utilisateurs facturés (1–50 000)';

  @override
  String get sign_up_opening_checkout =>
      'Compte créé. Ouverture du paiement sécurisé…';

  @override
  String get sign_up_verify_email_then_pay =>
      'Compte créé. Confirmez l\'e-mail, puis connectez-vous pour payer.';

  @override
  String get error_generic => 'Une erreur est survenue';

  @override
  String get success => 'Succès';

  @override
  String get empty_alerts => 'Aucune alerte actuellement';

  @override
  String get no_campaigns => 'Aucune campagne phishing';

  @override
  String get refresh => 'Actualiser';

  @override
  String get plan_starter_desc => 'Protection essentielle pour petites équipes';

  @override
  String get plan_pro_desc => 'Simulations avancées et analyses';

  @override
  String get plan_business_desc =>
      'Workflows enterprise et support prioritaire';

  @override
  String get billing => 'Facturation';

  @override
  String get status => 'Statut';

  @override
  String get create_campaign => 'Créer une campagne';

  @override
  String get send => 'Envoyer';

  @override
  String get subscription_updated => 'Abonnement mis à jour';

  @override
  String get mark_read => 'Marquer comme lu';

  @override
  String get unknown => 'Inconnu';

  @override
  String get welcome_back => 'Bon retour';

  @override
  String get security_posture => 'Posture de sécurité';

  @override
  String get backend_not_configured => 'Backend non configuré';

  @override
  String get setup_instructions =>
      'Définissez SUPABASE_URL et SUPABASE_ANON_KEY via --dart-define';

  @override
  String get nav_news => 'News';

  @override
  String get nav_companion => 'Companion';

  @override
  String get nav_security_ops => 'Security Ops';

  @override
  String get subscription_required_title => 'Abonnement requis';

  @override
  String get subscription_required_body =>
      'Votre essai gratuit de 30 jours est terminé, l\'abonnement n\'est pas actif ou le renouvellement a échoué. Ouvrez Abonnement pour choisir les sièges et payer en toute sécurité via Stripe afin de continuer à utiliser CyberGuard.';

  @override
  String get go_to_plans => 'Ouvrir l\'abonnement';

  @override
  String get exit_app => 'Sign out';

  @override
  String get role_security_manager => 'Security Manager';

  @override
  String get role_auditor => 'Auditor';

  @override
  String get open_incidents => 'Open incidents';

  @override
  String get critical_incidents => 'Critical incidents';

  @override
  String get high_risk_employees_count => 'High risk employees';

  @override
  String get metric_benchmark => 'Benchmark';

  @override
  String benchmark_safer_than(int percent) {
    return 'Safer than $percent%';
  }

  @override
  String get security_posture_high_risk => 'High risk';

  @override
  String get security_posture_stable => 'Stable';

  @override
  String get top_risky_users_week => 'Top 10 risky users this week';

  @override
  String get no_risky_users_week => 'No risky users this week.';

  @override
  String get monthly_risk_trend => 'Monthly risk trend';

  @override
  String get no_trend_data => 'No trend data yet.';

  @override
  String get manager_access_required =>
      'Admin or Security Manager access required.';

  @override
  String get attack_sim_library => 'Attack simulation library';

  @override
  String get custom => 'Custom';

  @override
  String get template_primary => 'Template A (primary)';

  @override
  String get template_ab_test => 'Template B (A/B test)';

  @override
  String get use_ai => 'Use AI';

  @override
  String get ab_test => 'A/B test';

  @override
  String get manual_mode => 'Manual';

  @override
  String get automatic_mode => 'Automatic';

  @override
  String get generate_ai_ab => 'Generate AI A/B';

  @override
  String get ai_templates_generated => 'AI templates generated';

  @override
  String get credential_submitted_short => 'Cred';

  @override
  String get teams_departments_title => 'Teams & Departments';

  @override
  String get org_manager_required =>
      'Admin or Security Manager access required.';

  @override
  String get departments => 'Departments';

  @override
  String get new_department_name => 'New department name';

  @override
  String get add_department => 'Add department';

  @override
  String get unnamed => 'Unnamed';

  @override
  String get no_departments => 'No departments yet.';

  @override
  String get teams => 'Teams';

  @override
  String get department_optional => 'Department (optional)';

  @override
  String get no_department => 'No department';

  @override
  String get new_team_name => 'New team name';

  @override
  String get add_team => 'Add team';

  @override
  String get no_teams => 'No teams yet.';

  @override
  String get security_operations_title => 'Security Operations';

  @override
  String get ops_access_required => 'Manager or Auditor access required.';

  @override
  String get copilot_hint => 'Ask: \"Is this event dangerous?\"';

  @override
  String get ask_copilot => 'Ask Copilot';

  @override
  String get refresh_analytics => 'Refresh analytics';

  @override
  String get employee_id => 'Employee ID';

  @override
  String get suggest_actions => 'Suggest actions';

  @override
  String get execute_actions => 'Execute actions';

  @override
  String get sender_email => 'Sender email';

  @override
  String get subject_field => 'Subject';

  @override
  String get body_excerpt => 'Body excerpt';

  @override
  String get scan_email => 'Scan email';

  @override
  String get generate_compliance_pdf => 'Generate GDPR/Security PDF';

  @override
  String get copilot_no_answer => 'No answer.';

  @override
  String get no_benchmark_data => 'No benchmark data.';

  @override
  String get employee_id_required => 'Employee ID is required';

  @override
  String get email_fields_required => 'Sender, subject and body are required';

  @override
  String get action_applied => 'Action applied';

  @override
  String get training_marked_complete => 'Training marked as completed';

  @override
  String get invalid_news_link => 'Invalid link';

  @override
  String get cannot_open_news => 'Unable to open the article';

  @override
  String get no_news_for_filter => 'No news found for this filter';

  @override
  String get security_news_title => 'Security News';

  @override
  String get security_news_subtitle =>
      'Latest free articles from forums and cyber sources on viruses, hacking, and tools.';

  @override
  String get news_topic_all => 'All';

  @override
  String get news_topic_tools => 'Tools';

  @override
  String get news_badge_virus => 'VIRUS';

  @override
  String get news_badge_hacking => 'HACKING';

  @override
  String get news_badge_tools => 'TOOLS';

  @override
  String get read_more => 'Read more';

  @override
  String get report_incident_title => 'Report virus or hacking';

  @override
  String get incident_type => 'Incident type';

  @override
  String get incident_type_virus => 'Virus';

  @override
  String get incident_type_hacking => 'Hacking';

  @override
  String get severity_critical => 'Critical';

  @override
  String get incident_title => 'Title';

  @override
  String get incident_details => 'Incident details';

  @override
  String get send_alert => 'Send alert';

  @override
  String get incident_report_sent =>
      'Report sent and email forwarded to the company.';

  @override
  String get companion_title => 'Mobile Security Companion';

  @override
  String get companion_no_employee => 'No linked employee profile found.';

  @override
  String get companion_user => 'User';

  @override
  String get companion_risk_score => 'Risk score';

  @override
  String get companion_training => 'Training completion';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get mfa_enabled_label => 'MFA enabled';

  @override
  String get force_mfa_login => 'Force MFA on next login';

  @override
  String get suspicious_activity => 'Suspicious activity';

  @override
  String get no_open_suspicious => 'No open suspicious activity.';

  @override
  String get approve => 'Approve';

  @override
  String get block => 'Block';

  @override
  String get adaptive_learning => 'Adaptive micro-learning';

  @override
  String get no_training_assignments => 'No active training assignments.';

  @override
  String get training_label => 'Training';

  @override
  String get assignment_status => 'Status';

  @override
  String get complete => 'Complete';

  @override
  String get subscription_activation => 'Subscription activation';

  @override
  String get trial_30_days => 'Free 30 days';

  @override
  String get stripe_monthly_now => 'Stripe monthly now';

  @override
  String get trial_then_paywall => '30 days free, then subscription prompt';

  @override
  String get stripe_pay_immediately =>
      'Monthly subscription with Stripe immediately';

  @override
  String get plan_label => 'Plan';

  @override
  String get plan_price_starter => 'Starter - \$29/mo';

  @override
  String get plan_price_pro => 'Pro - \$79/mo';

  @override
  String get plan_price_business => 'Business - \$199/mo';

  @override
  String get password_behavior_risk => 'Password behavior risk (0-100)';

  @override
  String get incident_history_risk => 'Incident history risk (0-100)';

  @override
  String get device_compliance_risk => 'Device compliance risk (0-100)';

  @override
  String get behavior_risk => 'Behavior risk (0-100)';

  @override
  String get mfa_on => 'ON';

  @override
  String get mfa_off => 'OFF';

  @override
  String get employee_photo => 'Profile photo';

  @override
  String get change_photo => 'Change photo';

  @override
  String get remove_photo => 'Remove photo';

  @override
  String get photo_upload_failed => 'Could not upload photo';

  @override
  String get photo_invalid => 'Choose a valid image';

  @override
  String behavior_risk_profile_line(int score, int samples) {
    return 'Behavior risk profile: $score/100 (samples: $samples)';
  }

  @override
  String get ai_phishing_engine_title => 'AI Phishing Simulation Engine';

  @override
  String get ai_copilot_title => 'AI Security Copilot';

  @override
  String get behavior_benchmark_section => 'Behavior analytics & benchmark';

  @override
  String get auto_remediation_title => 'Auto-remediation';

  @override
  String get email_security_layer_title => 'Email security layer';

  @override
  String get audit_reports_title => 'Audit & compliance reports';

  @override
  String remediation_summary_line(int suggested, int executed, int risk) {
    return 'Suggested: $suggested | Executed: $executed | Risk: $risk';
  }

  @override
  String email_scan_summary_line(int score, String severity) {
    return 'Risk score: $score | Severity: $severity';
  }

  @override
  String report_generated_summary(String file, int chars) {
    return 'Generated: $file | PDF payload size: $chars characters';
  }

  @override
  String get subscription_plan_flex => 'Per-user pricing';

  @override
  String get subscription_seats_label => 'Number of users (seats)';

  @override
  String subscription_pricing_explainer(String base) {
    return 'Monthly price uses your company risk score (0–100) and seat count: base $base + (users × 0.22) + (users^1.1 × 0.02) + (risk × 0.05).';
  }

  @override
  String subscription_company_risk_value(int score) {
    return 'Company risk score: $score/100';
  }

  @override
  String subscription_estimated_monthly(String amount) {
    return 'Estimated: $amount/month';
  }

  @override
  String get subscription_continue_checkout => 'Continue to checkout';

  @override
  String get subscription_seats_invalid =>
      'Enter a valid number of users (1 or more).';

  @override
  String get subscription_purchase_history => 'Purchase history';

  @override
  String get subscription_no_invoices =>
      'No invoices yet. Completed payments will appear here.';

  @override
  String get subscription_history_admin_only =>
      'Only company admins can view billing history and cancel subscriptions.';

  @override
  String get subscription_invoice_on => 'Date';

  @override
  String get subscription_invoice_ref => 'Invoice';

  @override
  String get subscription_open_invoice => 'View';

  @override
  String get subscription_download_pdf => 'PDF';

  @override
  String get subscription_cancel_subscription => 'Cancel subscription';

  @override
  String get subscription_cancel_confirm_title => 'Cancel subscription?';

  @override
  String get subscription_cancel_confirm_body =>
      'Your access will continue until the end of the current billing period. You can resubscribe anytime.';

  @override
  String get subscription_cancel_confirm_action => 'Cancel at period end';

  @override
  String get subscription_cancel_scheduled =>
      'Cancellation scheduled at the end of the billing period.';

  @override
  String get subscription_invoice_status_paid => 'Paid';

  @override
  String get subscription_invoice_status_open => 'Open';

  @override
  String get subscription_invoice_status_draft => 'Draft';

  @override
  String get subscription_invoice_status_void => 'Void';

  @override
  String get subscription_invoice_status_uncollectible => 'Uncollectible';
}
