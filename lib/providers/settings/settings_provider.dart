import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Proveedor de estado para los ajustes de la aplicación.
///
/// Gestiona preferencias no sensibles del usuario (ej: modo noche, idioma).
/// Persistencia con shared_preferences (datos no sensibles).
class SettingsProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  double _fontScale = 1.0;
  String _accentColor = 'amethyst';
  String _omdbApiKey = '';
  String _tmdbApiKey = '';

  ThemeMode get themeMode => _themeMode;
  double get fontScale => _fontScale;
  String get accentColor => _accentColor;
  String get omdbApiKey => _omdbApiKey;
  String get tmdbApiKey => _tmdbApiKey;

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

    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', mode.index);
  }

  Future<void> setFontScale(double scale) async {
    if (_fontScale == scale) return;
    _fontScale = scale;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontScale', scale);
  }

  Future<void> setAccentColor(String accent) async {
    if (_accentColor == accent) return;
    _accentColor = accent;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accentColor', accent);
  }

  Future<void> setOmdbApiKey(String key) async {
    _omdbApiKey = key;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('omdbApiKey', key);
  }

  Future<void> setTmdbApiKey(String key) async {
    _tmdbApiKey = key;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tmdbApiKey', key);
  }
}
