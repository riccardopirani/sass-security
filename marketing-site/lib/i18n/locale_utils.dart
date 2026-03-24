import 'package:flutter/material.dart';

class LocaleUtils {
  static const supportedLocaleCodes = <String>[
    'en',
    'it',
    'de',
    'fr',
    'zh',
    'ru',
  ];

  static const supportedLocales = <Locale>[
    Locale('en'),
    Locale('it'),
    Locale('de'),
    Locale('fr'),
    Locale('zh'),
    Locale('ru'),
  ];

  static const localeLabels = <String, String>{
    'en': 'EN',
    'it': 'IT',
    'de': 'DE',
    'fr': 'FR',
    'zh': '中文',
    'ru': 'RU',
  };

  static bool isSupportedCode(String code) =>
      supportedLocaleCodes.contains(code.toLowerCase());

  static Locale fromCode(String? code) {
    final normalized = (code ?? 'en').toLowerCase();
    if (isSupportedCode(normalized)) {
      return Locale(normalized);
    }
    return const Locale('en');
  }

  static String normalizeCode(String? code) => fromCode(code).languageCode;

  static String withLocale(String localeCode, String suffix) {
    final clean = suffix.startsWith('/') ? suffix : '/$suffix';
    if (suffix.isEmpty || suffix == '/') {
      return '/$localeCode';
    }
    return '/$localeCode$clean';
  }

  static String switchLocaleInPath(String currentPath, String newLocaleCode) {
    final uri = Uri.parse(currentPath);
    final segments = List<String>.from(uri.pathSegments);

    if (segments.isEmpty) {
      return '/$newLocaleCode';
    }

    if (isSupportedCode(segments.first)) {
      segments[0] = newLocaleCode;
    } else {
      segments.insert(0, newLocaleCode);
    }

    final nextPath = '/${segments.join('/')}';
    if (uri.query.isEmpty) {
      return nextPath;
    }
    return '$nextPath?${uri.query}';
  }
}
