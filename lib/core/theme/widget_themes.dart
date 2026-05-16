import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Centraliza la construcción de temas de widgets específicos (Cards, Botones, Inputs, Chips).
///
/// Cada método estático devuelve el objeto de tema correspondiente listo para
/// ser inyectado en [ThemeData]. El tema Titanium recibe tratamiento especial
/// en la mayoría de los widgets para mantener su apariencia monocromática.
class WidgetThemes {
  WidgetThemes._();

  /// Construye un [AppBarTheme] transparente con texto blanco para la mayoría
  /// de los temas, o texto oscuro/claro dependiendo del modo Titanium.
  ///
  /// [scheme] El [ColorScheme] activo.
  /// [isDark] Si el modo oscuro está activado.
  /// [isTitanium] Si el tema Titanio está seleccionado, lo que requiere
  /// color de primer plano diferente para mantener legibilidad.
  static AppBarTheme appBarTheme(
    ColorScheme scheme,
    bool isDark,
    bool isTitanium,
  ) {
    return AppBarTheme(
      centerTitle: true,
      backgroundColor: Colors.transparent,
      foregroundColor: isTitanium
          ? (isDark ? Colors.white : Colors.black)
          : Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      toolbarHeight: 48,
    );
  }

  /// Detecta el tema Titanium por sus colores primarios conocidos.
  static bool isTitaniumScheme(ColorScheme scheme) {
    final p = scheme.primary.toARGB32();
    return p == AppColors.titaniumPrimaryLight.toARGB32() ||
        p == AppColors.titaniumPrimaryDark.toARGB32();
  }

  /// Construye un [CardThemeData] con bordes redondeados y elevación adaptada
  /// al tema activo.
  ///
  /// El tema Titanio usa fondo blanco en modo claro para un aspecto limpio y
  /// plano. Los demás temas usan `surfaceContainerHigh` del esquema.
  ///
  /// [scheme] El [ColorScheme] activo.
  /// [isDark] Si el modo oscuro está activado.
  static CardThemeData cardTheme(ColorScheme scheme, bool isDark) {
    final isTitanium = isTitaniumScheme(scheme);

    return CardThemeData(
      elevation: isTitanium ? (isDark ? 8 : 1) : (isDark ? 6 : 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDark
          ? scheme.surface
          : (isTitanium ? Colors.white : scheme.surfaceContainerHigh),
      clipBehavior: Clip.antiAlias,
      surfaceTintColor: isDark ? Colors.white10 : Colors.black12,
    );
  }

  /// Construye un [InputDecorationTheme] con fondo relleno y bordes redondeados.
  ///
  /// El tema Titanio usa fondos específicos (negro profundo / blanco puro) para
  /// diferenciarse del resto de temas que usan el color `surface` del esquema.
  ///
  /// [scheme] El [ColorScheme] activo.
  /// [isDark] Si el modo oscuro está activado.
  static InputDecorationTheme inputDecorationTheme(
    ColorScheme scheme,
    bool isDark,
  ) {
    final isTitanium = isTitaniumScheme(scheme);

    return InputDecorationTheme(
      filled: true,
      fillColor: isTitanium
          ? (isDark ? const Color(0xFF1E1E1E) : Colors.white)
          : scheme.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: isTitanium
            ? BorderSide(color: isDark ? Colors.white10 : Colors.black12)
            : BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.black12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.primary, width: 2),
      ),
      labelStyle: TextStyle(color: scheme.onSurfaceVariant),
    );
  }

  /// Construye un [ElevatedButtonThemeData] usando el color primario del esquema
  /// como fondo y el color `onPrimary` como texto/icono.
  ///
  /// [scheme] El [ColorScheme] activo.
  static ElevatedButtonThemeData elevatedButtonTheme(ColorScheme scheme) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    );
  }

  /// Construye un [ChipThemeData] con bordes redondeados y sin línea de borde
  /// visible, usando `surfaceContainerHighest` como fondo.
  ///
  /// [scheme] El [ColorScheme] activo.
  static ChipThemeData chipTheme(ColorScheme scheme) {
    return ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      side: BorderSide.none,
      backgroundColor: scheme.surfaceContainerHighest,
    );
  }
}
