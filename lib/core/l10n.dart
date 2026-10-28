import 'package:flutter/widgets.dart';

import '../l10n/generated/app_localizations.dart';

export '../l10n/generated/app_localizations.dart';

extension L10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// Languages the interface itself is available in.
const appLanguages = <String, String>{
  'en': 'English',
  'ar': 'العربية',
  'fr': 'Français',
  'es': 'Español',
  'ur': 'اردو',
  'id': 'Bahasa Indonesia',
  'tr': 'Türkçe',
};
