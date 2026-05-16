import 'package:flutter/widgets.dart';
import '../../l10n/generated/app_localizations.dart';

/// Acceso ergonómico a cadenas localizadas: `context.l10n.settingsTitle`.
extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// Catálogo de locales compatibles. Se mantiene aquí (no generado automáticamente) para un acceso
/// ergonómico desde la IU de ajustes (desplegable de etiquetas).
class AppLocaleInfo {
  /// Código de idioma BCP-47 (ej. `'es'`, `'en'`).
  final String code;

  /// Nombre legible por humanos del locale en su propio idioma.
  final String label;

  const AppLocaleInfo(this.code, this.label);
}

/// Lista completa de locales que admite la aplicación.
///
/// Cada entrada empareja un [AppLocaleInfo.code] BCP-47 con una [AppLocaleInfo.label] en su escritura
/// nativa para que el menú desplegable de ajustes sea legible independientemente del
/// locale actualmente seleccionado.
const List<AppLocaleInfo> kSupportedAppLocales = [
  AppLocaleInfo('es', 'Español'),
  AppLocaleInfo('ca', 'Català / Valencià'),
  AppLocaleInfo('en', 'English'),
  AppLocaleInfo('fr', 'Français'),
  AppLocaleInfo('it', 'Italiano'),
  AppLocaleInfo('de', 'Deutsch'),
  AppLocaleInfo('pt', 'Português'),
];
