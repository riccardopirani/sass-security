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
}
