import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageNotifier with ChangeNotifier {
  Locale _locale = const Locale('es', 'MX');

  Locale get locale => _locale;

  Future<void> setLocale(String languageCode, String countryCode) async {
    _locale = Locale(languageCode, countryCode);
    notifyListeners();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', languageCode);
    await prefs.setString('countryCode', countryCode);
  }

  Future<void> loadLocale() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? languageCode = prefs.getString('languageCode');
    String? countryCode = prefs.getString('countryCode');

    if (languageCode != null && countryCode != null) {
      _locale = Locale(languageCode, countryCode);
      notifyListeners();
    }
  }
}
