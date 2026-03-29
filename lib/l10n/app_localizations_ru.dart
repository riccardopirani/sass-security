// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get app_title => 'CyberGuard';

  @override
  String get marketing_landing_headline => 'Кибербезопасность для команд SMB';

  @override
  String get marketing_landing_body =>
      'CyberGuard помогает малому и среднему бизнесу предотвращать фишинг, отслеживать оповещения в реальном времени и повышать кибербезопасность сотрудников.';

  @override
  String get marketing_landing_same_account =>
      'Один аккаунт работает в веб-версии и в мобильном приложении.';

  @override
  String get login => 'Вход';

  @override
  String get signup => 'Регистрация';

  @override
  String get email => 'Email';

  @override
  String get password => 'Пароль';

  @override
  String get name => 'Имя';

  @override
  String get company_name => 'Название компании';

  @override
  String get company_code => 'Код компании';

  @override
  String get role => 'Роль';

  @override
  String get admin => 'Админ';

  @override
  String get employee => 'Сотрудник';

  @override
  String get dashboard => 'Панель';

  @override
  String get risk_score => 'Оценка риска';

  @override
  String risk_score_fraction(int score) {
    return '$score/100';
  }

  @override
  String get company_risk_score => 'Риск компании';

  @override
  String get active_campaigns => 'Активные фишинг-кампании';

  @override
  String get alerts => 'Оповещения';

  @override
  String get open_alerts => 'Открытые оповещения';

  @override
  String get employees => 'Сотрудники';

  @override
  String get phishing => 'Фишинг';

  @override
  String get subscription => 'Подписка';

  @override
  String get settings => 'Настройки';

  @override
  String get logout => 'Выйти';

  @override
  String get save => 'Сохранить';

  @override
  String get cancel => 'Отмена';

  @override
  String get add_employee => 'Добавить сотрудника';

  @override
  String get edit_employee => 'Изменить сотрудника';

  @override
  String get delete_employee => 'Удалить сотрудника';

  @override
  String get no_employees => 'Сотрудников пока нет';

  @override
  String get loading => 'Загрузка...';

  @override
  String get high => 'Высокий';

  @override
  String get medium => 'Средний';

  @override
  String get low => 'Низкий';

  @override
  String get severity => 'Уровень';

  @override
  String get send_test => 'Отправить тест';

  @override
  String get campaign_name => 'Название кампании';

  @override
  String get campaign_template => 'Шаблон кампании';

  @override
  String get opened => 'Открыто';

  @override
  String get clicked => 'Нажато';

  @override
  String get sent => 'Отправлено';

  @override
  String get pricing => 'Тарифы';

  @override
  String get starter => 'Starter';

  @override
  String get pro => 'Pro';

  @override
  String get business => 'Business';

  @override
  String get per_month => 'месяц';

  @override
  String get current_plan => 'Текущий тариф';

  @override
  String get upgrade => 'Обновить тариф';

  @override
  String get manage_subscription => 'Управлять подпиской';

  @override
  String get language => 'Язык';

  @override
  String get choose_language => 'Выбрать язык';

  @override
  String get training_completion => 'Завершение обучения';

  @override
  String get employee_risk_ranking => 'Рейтинг риска сотрудников';

  @override
  String get create_account => 'Создать аккаунт';

  @override
  String get already_have_account => 'Уже есть аккаунт?';

  @override
  String get dont_have_account => 'Нет аккаунта?';

  @override
  String get sign_in => 'Войти';

  @override
  String get sign_up_success_check_email =>
      'Аккаунт создан. Подтвердите email.';

  @override
  String get signup_licensed_seats_label => 'Лицензируемые места';

  @override
  String get signup_licensed_seats_hint => 'Сколько пользователей (1–50 000)';

  @override
  String get sign_up_opening_checkout => 'Аккаунт создан. Открываем оплату…';

  @override
  String get sign_up_verify_email_then_pay =>
      'Аккаунт создан. Подтвердите email, войдите и завершите оплату в checkout.';

  @override
  String get error_generic => 'Что-то пошло не так';

  @override
  String get success => 'Успех';

  @override
  String get empty_alerts => 'Сейчас нет оповещений';

  @override
  String get no_campaigns => 'Фишинг-кампаний пока нет';

  @override
  String get refresh => 'Обновить';

  @override
  String get plan_starter_desc => 'Базовая защита для небольших команд';

  @override
  String get plan_pro_desc => 'Продвинутые симуляции и аналитика';

  @override
  String get plan_business_desc =>
      'Корпоративные процессы и приоритетная поддержка';

  @override
  String get billing => 'Биллинг';

  @override
  String get status => 'Статус';

  @override
  String get create_campaign => 'Создать кампанию';

  @override
  String get send => 'Отправить';

  @override
  String get subscription_updated => 'Подписка обновлена';

  @override
  String get mark_read => 'Отметить как прочитанное';

  @override
  String get unknown => 'Неизвестно';

  @override
  String get welcome_back => 'С возвращением';

  @override
  String get security_posture => 'Уровень безопасности';

  @override
  String get backend_not_configured => 'Бэкенд не настроен';

  @override
  String get setup_instructions =>
      'Укажите SUPABASE_URL и SUPABASE_ANON_KEY через --dart-define';

  @override
  String get nav_news => 'News';

  @override
  String get nav_companion => 'Companion';

  @override
  String get nav_security_ops => 'Security Ops';

  @override
  String get subscription_required_title => 'Требуется подписка';

  @override
  String get subscription_required_body =>
      '30-дневный бесплатный период окончен, подписка не активна или оплата продления не прошла. Откройте Подписку, выберите места и оплатите через Stripe, чтобы продолжить работу с CyberGuard.';

  @override
  String get go_to_plans => 'Открыть подписку';

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
  String get subscription_section_invoices => 'Счета';

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

  @override
  String get subscription_billing_monthly => 'Ежемесячно';

  @override
  String get subscription_billing_yearly => 'Ежегодно';

  @override
  String get subscription_billing_checkout_cadence =>
      'Период оплаты (оформление)';

  @override
  String subscription_billing_current(String interval) {
    return 'Текущая оплата: $interval';
  }

  @override
  String subscription_estimated_yearly(String amount) {
    return 'Ориентир: $amount/год';
  }

  @override
  String get subscription_switch_to_monthly =>
      'Перейти на месячное при продлении';

  @override
  String get subscription_switch_to_monthly_confirm_title =>
      'Перейти на месячную оплату?';

  @override
  String get subscription_switch_to_monthly_confirm_body =>
      'Годовой период действует до его окончания. После этого Stripe будет списывать месячную ставку за места. Автовозврат за неиспользованное время по годовому тарифу не предусмотрен.';

  @override
  String get subscription_switch_to_monthly_confirm_action =>
      'Запланировать месячное';

  @override
  String get subscription_switch_to_monthly_scheduled =>
      'Месячная оплата запланирована с следующего продления.';

  @override
  String get subscription_billing_activity => 'События по оплате';

  @override
  String subscription_event_switch_monthly(String date) {
    return 'Месячная оплата запланирована с $date';
  }

  @override
  String get subscription_no_billing_events => 'Пока нет изменений по оплате.';

  @override
  String get subscription_already_monthly =>
      'Подписка уже оплачивается ежемесячно.';

  @override
  String get subscription_pay_with_store => 'Оформить в App Store / Play';

  @override
  String get subscription_pay_with_card_browser => 'Оплатить картой (браузер)';

  @override
  String get subscription_store_disclaimer =>
      'Подписки в магазине используют фиксированные SKU; расчёт по местам — только при оплате картой.';

  @override
  String get subscription_store_unavailable =>
      'Товары магазина не найдены. Создайте подписки в консолях.';

  @override
  String get subscription_store_success => 'Подписка активирована.';

  @override
  String get subscription_billing_provider_appstore => 'App Store';

  @override
  String get subscription_billing_provider_play => 'Google Play';

  @override
  String get subscription_manage_in_store =>
      'Управляйте подпиской в настройках Apple ID или в Google Play.';
}
