// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get app_title => 'CyberGuard';

  @override
  String get marketing_landing_headline => '面向 SMB 团队的网络安全平台';

  @override
  String get marketing_landing_body => 'CyberGuard 帮助中小企业防范钓鱼、实时监控告警并提升员工安全态势。';

  @override
  String get marketing_landing_same_account => '同一账号适用于网页端与移动应用。';

  @override
  String get login => '登录';

  @override
  String get signup => '注册';

  @override
  String get email => '邮箱';

  @override
  String get password => '密码';

  @override
  String get name => '姓名';

  @override
  String get company_name => '公司名称';

  @override
  String get company_code => '公司代码';

  @override
  String get role => '角色';

  @override
  String get admin => '管理员';

  @override
  String get employee => '员工';

  @override
  String get dashboard => '仪表盘';

  @override
  String get risk_score => '风险评分';

  @override
  String risk_score_fraction(int score) {
    return '$score/100';
  }

  @override
  String get company_risk_score => '公司风险评分';

  @override
  String get active_campaigns => '进行中的钓鱼活动';

  @override
  String get alerts => '告警';

  @override
  String get open_alerts => '未处理告警';

  @override
  String get employees => '员工';

  @override
  String get phishing => '钓鱼模拟';

  @override
  String get subscription => '订阅';

  @override
  String get settings => '设置';

  @override
  String get logout => '退出登录';

  @override
  String get save => '保存';

  @override
  String get cancel => '取消';

  @override
  String get add_employee => '添加员工';

  @override
  String get edit_employee => '编辑员工';

  @override
  String get delete_employee => '删除员工';

  @override
  String get no_employees => '暂无员工';

  @override
  String get loading => '加载中...';

  @override
  String get high => '高';

  @override
  String get medium => '中';

  @override
  String get low => '低';

  @override
  String get severity => '严重级别';

  @override
  String get send_test => '发送测试';

  @override
  String get campaign_name => '活动名称';

  @override
  String get campaign_template => '活动模板';

  @override
  String get opened => '已打开';

  @override
  String get clicked => '已点击';

  @override
  String get sent => '已发送';

  @override
  String get pricing => '价格';

  @override
  String get starter => '入门版';

  @override
  String get pro => '专业版';

  @override
  String get business => '企业版';

  @override
  String get per_month => '月';

  @override
  String get current_plan => '当前套餐';

  @override
  String get upgrade => '升级套餐';

  @override
  String get manage_subscription => '管理订阅';

  @override
  String get language => '语言';

  @override
  String get choose_language => '选择语言';

  @override
  String get training_completion => '培训完成度';

  @override
  String get employee_risk_ranking => '员工风险排名';

  @override
  String get create_account => '创建账户';

  @override
  String get already_have_account => '已有账户？';

  @override
  String get dont_have_account => '还没有账户？';

  @override
  String get sign_in => '登录';

  @override
  String get sign_up_success_check_email => '账户已创建，请检查邮箱完成验证。';

  @override
  String get signup_licensed_seats_label => '授权座位数';

  @override
  String get signup_licensed_seats_hint => '计费用户数（1–50,000）';

  @override
  String get sign_up_opening_checkout => '账号已创建，正在打开安全结账…';

  @override
  String get sign_up_verify_email_then_pay => '账号已创建。请验证邮箱后登录以完成支付。';

  @override
  String get error_generic => '出现错误';

  @override
  String get success => '成功';

  @override
  String get empty_alerts => '当前没有告警';

  @override
  String get no_campaigns => '暂无钓鱼活动';

  @override
  String get refresh => '刷新';

  @override
  String get plan_starter_desc => '适合小团队的基础防护';

  @override
  String get plan_pro_desc => '高级模拟与分析';

  @override
  String get plan_business_desc => '企业级流程与优先支持';

  @override
  String get billing => '账单';

  @override
  String get status => '状态';

  @override
  String get create_campaign => '创建活动';

  @override
  String get send => '发送';

  @override
  String get subscription_updated => '订阅已更新';

  @override
  String get mark_read => '标记为已读';

  @override
  String get unknown => '未知';

  @override
  String get welcome_back => '欢迎回来';

  @override
  String get security_posture => '安全态势';

  @override
  String get backend_not_configured => '后端未配置';

  @override
  String get setup_instructions =>
      '请通过 --dart-define 设置 SUPABASE_URL 和 SUPABASE_ANON_KEY';

  @override
  String get nav_news => 'News';

  @override
  String get nav_companion => 'Companion';

  @override
  String get nav_security_ops => 'Security Ops';

  @override
  String get subscription_required_title => '需要订阅';

  @override
  String get subscription_required_body =>
      '30天免费试用已结束，订阅未激活或续费支付失败。请打开订阅页选择座位并通过 Stripe 安全付费以继续使用 CyberGuard。';

  @override
  String get go_to_plans => '打开订阅';

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
  String get subscription_section_invoices => '发票';

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
  String get subscription_billing_monthly => '按月';

  @override
  String get subscription_billing_yearly => '按年';

  @override
  String get subscription_billing_checkout_cadence => '结账计费周期';

  @override
  String subscription_billing_current(String interval) {
    return '当前计费：$interval';
  }

  @override
  String subscription_estimated_yearly(String amount) {
    return '预计：$amount/年';
  }

  @override
  String get subscription_switch_to_monthly => '在续订时改为按月';

  @override
  String get subscription_switch_to_monthly_confirm_title => '改为按月计费？';

  @override
  String get subscription_switch_to_monthly_confirm_body =>
      '当前年度周期将保持到期满。之后 Stripe 将按席位收取月费。年度计划中未使用的时间不会自动退款。';

  @override
  String get subscription_switch_to_monthly_confirm_action => '预约按月';

  @override
  String get subscription_switch_to_monthly_scheduled => '已预约在下一次续订时改为按月计费。';

  @override
  String get subscription_billing_activity => '计费活动';

  @override
  String subscription_event_switch_monthly(String date) {
    return '自 $date 起预约按月计费';
  }

  @override
  String get subscription_no_billing_events => '暂无计费变更。';

  @override
  String get subscription_already_monthly => '订阅已是按月计费。';

  @override
  String get subscription_pay_with_store => '通过 App Store / Play 订阅';

  @override
  String get subscription_pay_with_card_browser => '银行卡支付（浏览器）';

  @override
  String get subscription_store_disclaimer => '应用商店订阅使用固定 SKU；按席位计价仅适用于银行卡结账。';

  @override
  String get subscription_store_unavailable => '未找到商店商品。请在开发者控制台创建匹配的商品。';

  @override
  String get subscription_store_success => '订阅已激活。';

  @override
  String get subscription_billing_provider_appstore => 'App Store';

  @override
  String get subscription_billing_provider_play => 'Google Play';

  @override
  String get subscription_manage_in_store => '请在 iOS 设置或 Google Play 中管理订阅。';
}
