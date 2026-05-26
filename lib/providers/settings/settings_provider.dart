import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SharedListsLayout { section, tab, bottom }

/// Proveedor de estado para los ajustes de la aplicación.
///
/// Gestiona preferencias no sensibles del usuario (ej: modo noche, idioma).
/// Persistencia con shared_preferences (datos no sensibles).
class SettingsProvider extends ChangeNotifier {
  /// Modo de tema actual (claro, oscuro o según el sistema).
  ThemeMode _themeMode = ThemeMode.system;

  /// Multiplicador aplicado a la escala de texto de la app (1.0 = valor por defecto).
  double _fontScale = 1.0;

  /// Clave que identifica la paleta de color de acento activa (p. ej. `'amethyst'`).
  String _accentColor = 'amethyst';

  /// Clave de API OMDb introducida por el usuario para importar películas/series.
  String _omdbApiKey = '';

  /// Clave de API TMDb introducida por el usuario para importar películas/series.
  String _tmdbApiKey = '';

  /// Clave de API Google Books introducida por el usuario para importar libros/manga.
  String _googleBooksApiKey = '';

  /// Código de idioma BCP-47 para el locale de la app (p. ej. `'es'`, `'en'`).
  String _locale = 'es';

  /// Código de moneda ISO 4217 usado para mostrar precios (p. ej. `'EUR'`).
  String _currency = 'EUR';

  /// Preferencia de disposición para las listas compartidas (no propias).
  SharedListsLayout _sharedListsLayout = SharedListsLayout.section;

  /// Instancia cacheada de [SharedPreferences] para evitar llamar a
  /// [SharedPreferences.getInstance] en cada setter.
  SharedPreferences? _prefs;

  /// El [ThemeMode] activo actualmente.
  ThemeMode get themeMode => _themeMode;

  /// El multiplicador de escala de fuente activo.
  double get fontScale => _fontScale;

  /// La clave del color de acento activo.
  String get accentColor => _accentColor;

  /// La clave de API OMDb almacenada por el usuario.
  String get omdbApiKey => _omdbApiKey;

  /// La clave de API TMDb almacenada por el usuario.
  String get tmdbApiKey => _tmdbApiKey;

  /// La clave de API Google Books almacenada por el usuario.
  String get googleBooksApiKey => _googleBooksApiKey;

  /// El código de locale BCP-47 actualmente en uso.
  String get locale => _locale;

  /// El código de moneda ISO 4217 actualmente en uso.
  String get currency => _currency;

  /// La preferencia de disposición para las listas compartidas (no propias).
  SharedListsLayout get sharedListsLayout => _sharedListsLayout;

  /// Carga los ajustes desde el almacenamiento local e inicializa la instancia
  /// cacheada de [SharedPreferences] para reutilizarla en los setters.
  Future<void> loadSettings() async {
    _prefs = await SharedPreferences.getInstance();

    // Modo de tema
    final modeIndex = _prefs!.getInt('themeMode') ?? 0; // 0 = sistema
    _themeMode = ThemeMode.values[modeIndex];

    // Escala de fuente
    _fontScale = _prefs!.getDouble('fontScale') ?? 1.0;

    // Color de acento
    _accentColor = _prefs!.getString('accentColor') ?? 'amethyst';

    // Claves de API del usuario (TMDb y Google Books son opcionales: el servidor las gestiona)
    _omdbApiKey = _prefs!.getString('omdbApiKey') ?? '';
    _tmdbApiKey = _prefs!.getString('tmdbApiKey') ?? '';
    _googleBooksApiKey = _prefs!.getString('googleBooksApiKey') ?? '';

    // Locale y moneda
    _locale = _prefs!.getString('locale') ?? 'es';
    _currency = _prefs!.getString('currency') ?? 'EUR';

    // Disposición de listas compartidas
    final layoutIndex = _prefs!.getInt('sharedListsLayout') ?? 0;
    _sharedListsLayout = SharedListsLayout.values[layoutIndex];

    notifyListeners();
  }

  /// Persiste [locale] en las preferencias compartidas y notifica a los listeners.
  ///
  /// No hace nada si [locale] coincide con el valor actual para evitar escrituras innecesarias.
  Future<void> setLocale(String locale) async {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setString('locale', locale);
  }

  /// Persiste [currency] en las preferencias compartidas y notifica a los listeners.
  ///
  /// No hace nada si [currency] coincide con el valor actual.
  Future<void> setCurrency(String currency) async {
    if (_currency == currency) return;
    _currency = currency;
    notifyListeners();
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setString('currency', currency);
  }

  /// Cambia el tema de la app a [mode] y persiste la elección.
  ///
  /// No hace nada si [mode] coincide con el [themeMode] actual.
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', mode.index);
  }

  /// Actualiza el multiplicador de escala de texto a [scale] y persiste el cambio.
  ///
  /// No hace nada si [scale] coincide con el [fontScale] actual.
  Future<void> setFontScale(double scale) async {
    if (_fontScale == scale) return;
    _fontScale = scale;
    notifyListeners();
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setDouble('fontScale', scale);
  }

  /// Cambia la paleta de color de acento a [accent] y persiste la elección.
  ///
  /// No hace nada si [accent] coincide con el [accentColor] actual.
  Future<void> setAccentColor(String accent) async {
    if (_accentColor == accent) return;
    _accentColor = accent;
    notifyListeners();
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setString('accentColor', accent);
  }

  /// Almacena la clave de API OMDb [key] del usuario para importar películas/series
  /// y la persiste en las preferencias compartidas.
  Future<void> setOmdbApiKey(String key) async {
    _omdbApiKey = key;
    notifyListeners();
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setString('omdbApiKey', key);
  }

  /// Almacena la clave de API TMDb [key] del usuario para importar películas/series
  /// y la persiste en las preferencias compartidas.
  Future<void> setTmdbApiKey(String key) async {
    _tmdbApiKey = key;
    notifyListeners();
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setString('tmdbApiKey', key);
  }

  /// Persiste [layout] en las preferencias compartidas y notifica a los listeners.
  Future<void> setSharedListsLayout(SharedListsLayout layout) async {
    if (_sharedListsLayout == layout) return;
    _sharedListsLayout = layout;
    notifyListeners();
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setInt('sharedListsLayout', layout.index);
  }

  /// Almacena la clave de API Google Books [key] del usuario para importar libros/manga
  /// y la persiste en las preferencias compartidas.
  Future<void> setGoogleBooksApiKey(String key) async {
    _googleBooksApiKey = key;
    notifyListeners();
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setString('googleBooksApiKey', key);
  }
}
