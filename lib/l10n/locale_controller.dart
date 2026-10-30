import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds the user's chosen app language. A null value follows the device language.
class LocaleController {
  LocaleController._();

  static const _prefsKey = 'app_locale';

  static final ValueNotifier<Locale?> locale = ValueNotifier<Locale?>(null);

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefsKey);
    locale.value = code == null ? null : Locale(code);
  }

  static Future<void> select(Locale? value) async {
    locale.value = value;
    final prefs = await SharedPreferences.getInstance();
    if (value == null) {
      await prefs.remove(_prefsKey);
    } else {
      await prefs.setString(_prefsKey, value.languageCode);
    }
  }
}
