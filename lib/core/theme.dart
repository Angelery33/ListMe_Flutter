import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Configuración del tema visual de la aplicación.
class AppTheme {
  AppTheme._();

  static ThemeData getTheme(String accent, Brightness brightness, double fontScale) {
    final primaryColor = AppColors.getPrimary(accent);
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: primaryColor,
      brightness: brightness,
      textTheme: _getScaledTextTheme(fontScale, isDark),
      // Configuración de AppBar por defecto
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
    );
  }

  static TextTheme _getScaledTextTheme(double scale, bool isDark) {
    final Color color = isDark ? Colors.white : Colors.black87;
    
    // Definimos explícitamente todos los estilos de Material 3 con sus tamaños base
    // multiplicados por la escala para GARANTIZAR que no existan nulls.
    return TextTheme(
      displayLarge: TextStyle(fontSize: 57 * scale, color: color),
      displayMedium: TextStyle(fontSize: 45 * scale, color: color),
      displaySmall: TextStyle(fontSize: 36 * scale, color: color),
      headlineLarge: TextStyle(fontSize: 32 * scale, color: color),
      headlineMedium: TextStyle(fontSize: 28 * scale, color: color),
      headlineSmall: TextStyle(fontSize: 24 * scale, color: color),
      titleLarge: TextStyle(fontSize: 22 * scale, color: color),
      titleMedium: TextStyle(fontSize: 16 * scale, color: color),
      titleSmall: TextStyle(fontSize: 14 * scale, color: color),
      bodyLarge: TextStyle(fontSize: 16 * scale, color: color),
      bodyMedium: TextStyle(fontSize: 14 * scale, color: color),
      bodySmall: TextStyle(fontSize: 12 * scale, color: color),
      labelLarge: TextStyle(fontSize: 14 * scale, color: color),
      labelMedium: TextStyle(fontSize: 12 * scale, color: color),
      labelSmall: TextStyle(fontSize: 11 * scale, color: color),
    );
  }
}
