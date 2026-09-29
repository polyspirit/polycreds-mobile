import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/l10n.dart';

/// Non-secret app preferences.
class Settings extends ChangeNotifier {
  Settings(this._prefs);

  final SharedPreferences _prefs;

  static const autoLockOptions = <int>[0, 30, 60, 300, 900, -1];
  static const clipboardOptions = <int>[15, 30, 60, 120, -1];

  static Future<Settings> load() async => Settings(await SharedPreferences.getInstance());

  ThemeMode get themeMode => ThemeMode.values.byName(_prefs.getString('theme') ?? ThemeMode.system.name);

  set themeMode(ThemeMode v) {
    _prefs.setString('theme', v.name);
    notifyListeners();
  }

  /// Seconds in background before the app locks. 0 = immediately, -1 = never.
  int get autoLockSeconds => _prefs.getInt('auto_lock') ?? 60;

  set autoLockSeconds(int v) {
    _prefs.setInt('auto_lock', v);
    notifyListeners();
  }

  /// Seconds before copied secrets are wiped from the clipboard. -1 = never.
  int get clipboardClearSeconds => _prefs.getInt('clipboard_clear') ?? 30;

  set clipboardClearSeconds(int v) {
    _prefs.setInt('clipboard_clear', v);
    notifyListeners();
  }

  /// Last used login, prefilled on the login screen.
  String get lastEmail => _prefs.getString('last_email') ?? '';

  set lastEmail(String v) => _prefs.setString('last_email', v);

  /// Interface language: 'system', 'ru' or 'en'.
  String get language => _prefs.getString('language') ?? 'system';

  set language(String v) {
    _prefs.setString('language', v);
    notifyListeners();
  }

  /// Explicit locale, or null to follow the system.
  Locale? get locale => language == 'system' ? null : Locale(language);

  static String duration(int s) => s < 60 ? tr.durationSeconds(s) : tr.durationMinutes(s ~/ 60);

  static String autoLockLabel(int s) => switch (s) {
        0 => tr.immediately,
        -1 => tr.never,
        _ => tr.afterDuration(duration(s)),
      };

  static String clipboardLabel(int s) => s < 0 ? tr.never : tr.afterDuration(duration(s));
}
