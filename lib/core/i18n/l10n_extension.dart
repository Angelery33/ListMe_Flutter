import 'package:flutter/widgets.dart';
import '../../l10n/generated/app_localizations.dart';

/// Ergonomic access to localized strings: `context.l10n.settingsTitle`.
extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// Supported locales catalog. Kept here (not auto-generated) for ergonomic
/// access from the settings UI (label dropdown).
class AppLocaleInfo {
  final String code;
  final String label;
  const AppLocaleInfo(this.code, this.label);
}

const List<AppLocaleInfo> kSupportedAppLocales = [
  AppLocaleInfo('es', 'Español'),
  AppLocaleInfo('ca', 'Català / Valencià'),
  AppLocaleInfo('en', 'English'),
  AppLocaleInfo('fr', 'Français'),
  AppLocaleInfo('it', 'Italiano'),
  AppLocaleInfo('de', 'Deutsch'),
  AppLocaleInfo('pt', 'Português'),
];
