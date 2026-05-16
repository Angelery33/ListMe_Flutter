import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'color_schemes.dart';
import 'widget_themes.dart';
import 'text_themes.dart';

/// Orquestador principal del sistema de temas.
///
/// Centraliza la construcción de [ThemeData] a partir de un nombre de acento
/// (p. ej. `'emerald'`) y un [Brightness], delegando los sub-temas a
/// [ColorSchemes], [WidgetThemes] y [TextThemes].
class AppTheme {
  AppTheme._();

  /// Devuelve el [ThemeData] para el acento y brillo indicados.
  ///
  /// [accent] Nombre del acento visual (p. ej. `'emerald'`, `'amethyst'`).
  /// [brightness] Modo claro u oscuro.
  /// [fontScale] Factor multiplicador aplicado a todos los tamaños de fuente M3.
  static ThemeData getTheme(
    String accent,
    Brightness brightness,
    double fontScale,
  ) {
    final isDark = brightness == Brightness.dark;
    final (scheme, surface) = _schemeAndSurface(accent, isDark);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: surface,
      textTheme: TextThemes.scaledTextTheme(scheme, fontScale),
      appBarTheme: WidgetThemes.appBarTheme(scheme, isDark, isTitanium(scheme)),
      cardTheme: WidgetThemes.cardTheme(scheme, isDark),
      inputDecorationTheme: WidgetThemes.inputDecorationTheme(scheme, isDark),
      elevatedButtonTheme: WidgetThemes.elevatedButtonTheme(scheme),
      chipTheme: WidgetThemes.chipTheme(scheme),
    );
  }

  /// Devuelve el color primario de un acento específico.
  ///
  /// [accent] Nombre del acento cuyo color primario se quiere obtener.
  /// [brightness] Determina si se usa la variante clara u oscura del color.
  static Color getPrimaryColor(String accent, Brightness brightness) {
    final (scheme, _) = _schemeAndSurface(
      accent,
      brightness == Brightness.dark,
    );
    return scheme.primary;
  }

  /// Helper para gradientes de AppBar.
  ///
  /// Devuelve un [Container] decorado con un gradiente lineal que va del color
  /// primario al terciario del esquema actual. Para el tema Titanium usa una
  /// escala de grises específica para mantener la apariencia monocromática.
  static Widget appBarGradient(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isTitanium(scheme)) {
      final Color lighterGray = !isDark
          ? const Color(0xFF3C3C3E)
          : const Color(0xFFE5E5EA);
      final Color darkerGray = !isDark
          ? const Color(0xFF1C1C1E)
          : const Color.fromARGB(255, 107, 107, 109);
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [darkerGray, lighterGray]
                : [darkerGray, lighterGray],
            begin: Alignment.topLeft,
            end: const Alignment(0.8, 0.8),
          ),
        ),
      );
    }

    // Todos los demás temas: gradiente Primary -> Tertiary
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [scheme.primary, scheme.tertiary],
          begin: Alignment.topLeft,
          end: const Alignment(0.6, 0.6),
        ),
      ),
    );
  }

  /// Devuelve si el texto del AppBar debe ser oscuro (Titanium claro).
  ///
  /// Cuando es `true` los íconos y el título del AppBar deben usar un color
  /// oscuro para contraste con el fondo gris claro del tema Titanium.
  static bool appBarUsesDarkText(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isTitanium(scheme) && !isDark;
  }

  // --- Privados ---

  static (ColorScheme, Color) _schemeAndSurface(String accent, bool isDark) {
    return switch (accent) {
      'emerald' =>
        isDark
            ? (ColorSchemes.emeraldDark, AppColors.emeraldSurfaceDark)
            : (ColorSchemes.emeraldLight, AppColors.emeraldSurfaceLight),
      'amethyst' =>
        isDark
            ? (ColorSchemes.amethystDark, AppColors.amethystSurfaceDark)
            : (ColorSchemes.amethystLight, AppColors.amethystSurfaceLight),
      'sapphire' =>
        isDark
            ? (ColorSchemes.sapphireDark, AppColors.sapphireSurfaceDark)
            : (ColorSchemes.sapphireLight, AppColors.sapphireSurfaceLight),
      'ruby' =>
        isDark
            ? (ColorSchemes.rubyDark, AppColors.rubySurfaceDark)
            : (ColorSchemes.rubyLight, AppColors.rubySurfaceLight),
      'amber' =>
        isDark
            ? (ColorSchemes.amberDark, AppColors.amberSurfaceDark)
            : (ColorSchemes.amberLight, AppColors.amberSurfaceLight),
      'cobalt' =>
        isDark
            ? (ColorSchemes.cobaltDark, AppColors.cobaltSurfaceDark)
            : (ColorSchemes.cobaltLight, AppColors.cobaltSurfaceLight),
      'cyan' =>
        isDark
            ? (ColorSchemes.cyanDark, AppColors.cyanSurfaceDark)
            : (ColorSchemes.cyanLight, AppColors.cyanSurfaceLight),
      'magenta' =>
        isDark
            ? (ColorSchemes.magentaDark, AppColors.magentaSurfaceDark)
            : (ColorSchemes.magentaLight, AppColors.magentaSurfaceLight),
      _ =>
        isDark
            ? (ColorSchemes.titaniumDark, AppColors.titaniumSurfaceDark)
            : (ColorSchemes.titaniumLight, AppColors.titaniumSurfaceLight),
    };
  }

  /// Detecta el tema Titanium comparando con sus colores primarios conocidos.
  /// NO se puede usar r==g==b porque titaniumPrimaryLight(0xFF1D1B1E) no tiene
  /// los canales iguales.
  static bool isTitanium(ColorScheme scheme) {
    final p = scheme.primary.toARGB32();
    return p == AppColors.titaniumPrimaryLight.toARGB32() ||
        p == AppColors.titaniumPrimaryDark.toARGB32();
  }
}
