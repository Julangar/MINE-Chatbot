import 'package:flutter/material.dart';

class LocaleProvider extends ChangeNotifier {
  Locale? _locale;

  Locale? get locale => _locale;

  void setLocale(Locale locale) {
    if (!L10n.all.contains(locale)) return;
    _locale = locale;
    notifyListeners();
  }

  void clearLocale() {
    _locale = null;
    notifyListeners();
  }
}

// Helper para los idiomas soportados
class L10n {
  static final all = [
    const Locale('en'),
    const Locale('es'),
    const Locale('es', '419'), // Español Latinoamérica
    const Locale('pt'),
    const Locale('pt', 'BR'),
    const Locale('fr'),
    const Locale('it'),
    const Locale('de'),
    const Locale('ar'),
    const Locale('ja'),
    const Locale('ko'),
    const Locale('ru'),
    const Locale('bg'),
    const Locale('nl'),
    const Locale('he'),
    const Locale('hi'),
    const Locale('el'),
    const Locale('hu'),
    const Locale('pl'),
    const Locale('tl'),
    const Locale('tr'),
    const Locale('vi'),
    const Locale('zh'),
  ];

  static String getLanguageName(String code, [String? countryCode]) {
    switch (code) {
      case 'en':
        return 'English';
      case 'es':
        if (countryCode == '419') return 'Español (Lat)';
        return 'Español';
      case 'pt':
        if (countryCode == 'BR') return 'Português (Br)';
        return 'Português';
      case 'fr':
        return 'Français';
      case 'it':
        return 'Italiano';
      case 'de':
        return 'Deutsch';
      case 'ar':
        return 'العربية';
      case 'ja':
        return '日本語';
      case 'ko':
        return '한국어';
      case 'ru':
        return 'Русский';
      case 'bg':
        return 'Български';
      case 'nl':
        return 'Nederlands';
      case 'he':
        return 'עברית';
      case 'hi':
        return 'हिन्दी';
      case 'el':
        return 'Ελληνικά';
      case 'hu':
        return 'Magyar';
      case 'pl':
        return 'Polski';
      case 'tl':
        return 'Tagalog';
      case 'tr':
        return 'Türkçe';
      case 'vi':
        return 'Tiếng Việt';
      case 'zh':
        return '中文';
      default:
        return code;
    }
  }
}
