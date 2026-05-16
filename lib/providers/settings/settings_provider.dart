import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Proveedor de estado para los ajustes de la aplicación.
///
/// Gestiona preferencias no sensibles del usuario (ej: modo noche, idioma).
/// Persistencia con shared_preferences (datos no sensibles).
class SettingsProvider extends ChangeNotifier {
  /// The current theme mode (light, dark, or system).
  ThemeMode _themeMode = ThemeMode.system;

  /// Multiplier applied to the app's text scale factor (1.0 = default).
  double _fontScale = 1.0;

  /// Key identifying the active accent colour palette (e.g. `'amethyst'`).
  String _accentColor = 'amethyst';

  /// User-supplied OMDb API key for movie/series search import.
  String _omdbApiKey = '';

  /// User-supplied TMDb API key for movie/series search import.
  String _tmdbApiKey = '';

  /// BCP-47 language code for the app locale (e.g. `'es'`, `'en'`).
  String _locale = 'es';

  /// ISO 4217 currency code used for price display (e.g. `'EUR'`).
  String _currency = 'EUR';

  /// The currently active [ThemeMode].
  ThemeMode get themeMode => _themeMode;

  /// The active font scale multiplier.
  double get fontScale => _fontScale;

  /// The key of the active accent colour.
  String get accentColor => _accentColor;

  /// The OMDb API key stored by the user.
  String get omdbApiKey => _omdbApiKey;

  /// The TMDb API key stored by the user.
  String get tmdbApiKey => _tmdbApiKey;

  /// The BCP-47 locale code currently in use.
  String get locale => _locale;

  /// The ISO 4217 currency code currently in use.
  String get currency => _currency;

  /// Carga los ajustes desde el almacenamiento local.
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    // Theme Mode
    final modeIndex = prefs.getInt('themeMode') ?? 0; // 0 = system
    _themeMode = ThemeMode.values[modeIndex];

    // Font Scale
    _fontScale = prefs.getDouble('fontScale') ?? 1.0;

    // Accent Color
    _accentColor = prefs.getString('accentColor') ?? 'amethyst';

    // API Keys - Keys por defecto de proyectos anteriores
    _omdbApiKey = prefs.getString('omdbApiKey') ?? '';
    _tmdbApiKey =
        prefs.getString('tmdbApiKey') ?? 'a4294c7b69c82d96850476e2439c2da6';

    // Locale & Currency
    _locale = prefs.getString('locale') ?? 'es';
    _currency = prefs.getString('currency') ?? 'EUR';

    notifyListeners();
  }

  /// Persists [locale] to shared preferences and notifies listeners.
  ///
  /// No-op when [locale] equals the current value to avoid unnecessary writes.
  Future<void> setLocale(String locale) async {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', locale);
  }

  /// Persists [currency] to shared preferences and notifies listeners.
  ///
  /// No-op when [currency] equals the current value.
  Future<void> setCurrency(String currency) async {
    if (_currency == currency) return;
    _currency = currency;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency', currency);
  }

  /// Switches the app's theme to [mode] and persists the choice.
  ///
  /// No-op when [mode] equals the current [themeMode].
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', mode.index);
  }

  /// Updates the text scale multiplier to [scale] and persists the change.
  ///
  /// No-op when [scale] equals the current [fontScale].
  Future<void> setFontScale(double scale) async {
    if (_fontScale == scale) return;
    _fontScale = scale;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontScale', scale);
  }

  /// Switches the accent colour palette to [accent] and persists the choice.
  ///
  /// No-op when [accent] equals the current [accentColor].
  Future<void> setAccentColor(String accent) async {
    if (_accentColor == accent) return;
    _accentColor = accent;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accentColor', accent);
  }

  /// Stores the user's OMDb API [key] for movie/series search import and
  /// persists it to shared preferences.
  Future<void> setOmdbApiKey(String key) async {
    _omdbApiKey = key;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('omdbApiKey', key);
  }

  /// Stores the user's TMDb API [key] for movie/series search import and
  /// persists it to shared preferences.
  Future<void> setTmdbApiKey(String key) async {
    _tmdbApiKey = key;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tmdbApiKey', key);
  }
}
