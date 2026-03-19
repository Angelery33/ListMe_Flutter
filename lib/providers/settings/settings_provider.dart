import 'package:flutter/material.dart';

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

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void setFontScale(double scale) {
    _fontScale = scale;
    notifyListeners();
  }

  void setAccentColor(String accent) {
    _accentColor = accent;
    notifyListeners();
  }
}
