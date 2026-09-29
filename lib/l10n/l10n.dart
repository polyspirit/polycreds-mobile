import 'package:flutter/widgets.dart';

import 'app_localizations.dart';

export 'app_localizations.dart';

extension L10nContext on BuildContext {
  L10n get l => L10n.of(this);
}

/// Strings for code without a BuildContext (API errors, formatting).
/// The app updates it whenever the resolved locale changes.
L10n tr = lookupL10n(const Locale('ru'));

/// Language code of [tr], for date formatting and the Accept-Language header.
String localeTag = 'ru';

void setCurrentLocale(Locale locale) {
  if (locale.languageCode == localeTag) return;
  tr = lookupL10n(locale);
  localeTag = locale.languageCode;
}

/// Device languages that get the Russian UI; everything else gets English.
const _russianSpeaking = {'ru', 'uk', 'be', 'kk'};

Locale resolveSystemLocale(List<Locale>? device) {
  for (final l in device ?? const <Locale>[]) {
    if (_russianSpeaking.contains(l.languageCode)) return const Locale('ru');
    if (l.languageCode == 'en') return const Locale('en');
  }
  return const Locale('en');
}
