import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleController extends ChangeNotifier {
  LocaleController(this._locale);

  static const _prefsKey = 'cyberguard.locale';

  static const supportedLocales = [
    Locale('en'),
    Locale('it'),
    Locale('de'),
    Locale('fr'),
    Locale('zh'),
    Locale('ru'),
  ];

  Locale _locale;
  Locale get locale => _locale;

  static Future<LocaleController> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefsKey);
    final locale = supportedLocales.firstWhere(
      (item) => item.languageCode == code,
      orElse: () => const Locale('en'),
    );
    return LocaleController(locale);
  }

  Future<void> setLocale(Locale locale) async {
    if (!supportedLocales.contains(locale)) {
      return;
    }
    _locale = locale;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, locale.languageCode);
  }
}
