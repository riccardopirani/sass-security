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
}
