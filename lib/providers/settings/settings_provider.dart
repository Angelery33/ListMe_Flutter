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

  ThemeMode get themeMode => _themeMode;
  double get fontScale => _fontScale;
  String get accentColor => _accentColor;

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
}

