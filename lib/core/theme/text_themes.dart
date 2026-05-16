import 'package:flutter/material.dart';

/// Centraliza la generación de [TextTheme] escalable.
///
/// Todos los tamaños de fuente siguen la escala tipográfica de Material 3 y se
/// multiplican por [fontScale] para respetar la preferencia de tamaño de letra
/// del usuario configurada en los ajustes de la aplicación.
class TextThemes {
  TextThemes._();

  /// Construye un [TextTheme] con tamaños M3 explícitos escalados por [fontScale].
  ///
  /// [scheme] El [ColorScheme] activo, del que se extrae el color `onSurface`
  /// aplicado uniformemente a todos los estilos de texto.
  /// [fontScale] Factor multiplicador (1.0 = tamaño estándar M3).
  static TextTheme scaledTextTheme(ColorScheme scheme, double fontScale) {
    final color = scheme.onSurface;
    return TextTheme(
      displayLarge:   TextStyle(fontSize: 57 * fontScale, color: color),
      displayMedium:  TextStyle(fontSize: 45 * fontScale, color: color),
      displaySmall:   TextStyle(fontSize: 36 * fontScale, color: color),
      headlineLarge:  TextStyle(fontSize: 32 * fontScale, color: color),
      headlineMedium: TextStyle(fontSize: 28 * fontScale, color: color),
      headlineSmall:  TextStyle(fontSize: 24 * fontScale, color: color),
      titleLarge:     TextStyle(fontSize: 22 * fontScale, color: color),
      titleMedium:    TextStyle(fontSize: 16 * fontScale, color: color),
      titleSmall:     TextStyle(fontSize: 14 * fontScale, color: color),
      bodyLarge:      TextStyle(fontSize: 16 * fontScale, color: color),
      bodyMedium:     TextStyle(fontSize: 14 * fontScale, color: color),
      bodySmall:      TextStyle(fontSize: 12 * fontScale, color: color),
      labelLarge:     TextStyle(fontSize: 14 * fontScale, color: color),
      labelMedium:    TextStyle(fontSize: 12 * fontScale, color: color),
      labelSmall:     TextStyle(fontSize: 11 * fontScale, color: color),
    );
  }
}
