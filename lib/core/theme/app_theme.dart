import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'color_schemes.dart';
import 'widget_themes.dart';
import 'text_themes.dart';

/// Orquestador principal del sistema de temas.
class AppTheme {
  AppTheme._();

  /// Devuelve el [ThemeData] para el acento y brillo indicados.
  static ThemeData getTheme(String accent, Brightness brightness, double fontScale) {
    final isDark = brightness == Brightness.dark;
    final (scheme, surface) = _schemeAndSurface(accent, isDark);
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: surface,
      textTheme: TextThemes.scaledTextTheme(scheme, fontScale),
      appBarTheme: WidgetThemes.appBarTheme(scheme, isDark, _isTitanium(scheme)),
      cardTheme: WidgetThemes.cardTheme(scheme, isDark),
      inputDecorationTheme: WidgetThemes.inputDecorationTheme(scheme, isDark),
      elevatedButtonTheme: WidgetThemes.elevatedButtonTheme(scheme),
      chipTheme: WidgetThemes.chipTheme(scheme),
    );
  }

  /// Devuelve el color primario de un acento específico.
  static Color getPrimaryColor(String accent, Brightness brightness) {
    final (scheme, _) = _schemeAndSurface(accent, brightness == Brightness.dark);
    return scheme.primary;
  }

  /// Helper para gradientes de AppBar.
  static Widget appBarGradient(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isTitanium(scheme)) {
      // Titanium/Platino: gradiente metálico premium
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? const [Color(0xFF1D1B1E), Color(0xFFD0D0D8)]
                : const [Color(0xFFD0D0D8),Color(0xFF1D1B1E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
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
  static bool appBarUsesDarkText(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _isTitanium(scheme) && !isDark;
  }

  // --- Privados ---

  static (ColorScheme, Color) _schemeAndSurface(String accent, bool isDark) {
    return switch (accent) {
      'emerald'   => isDark ? (ColorSchemes.emeraldDark,   AppColors.emeraldSurfaceDark)
                            : (ColorSchemes.emeraldLight,  AppColors.emeraldSurfaceLight),
      'amethyst'  => isDark ? (ColorSchemes.amethystDark,  AppColors.amethystSurfaceDark)
                            : (ColorSchemes.amethystLight, AppColors.amethystSurfaceLight),
      'sapphire'  => isDark ? (ColorSchemes.sapphireDark,  AppColors.sapphireSurfaceDark)
                            : (ColorSchemes.sapphireLight, AppColors.sapphireSurfaceLight),
      'ruby'      => isDark ? (ColorSchemes.rubyDark,      AppColors.rubySurfaceDark)
                            : (ColorSchemes.rubyLight,     AppColors.rubySurfaceLight),
      'amber'     => isDark ? (ColorSchemes.amberDark,     AppColors.amberSurfaceDark)
                            : (ColorSchemes.amberLight,    AppColors.amberSurfaceLight),
      'cobalt'    => isDark ? (ColorSchemes.cobaltDark,    AppColors.cobaltSurfaceDark)
                            : (ColorSchemes.cobaltLight,   AppColors.cobaltSurfaceLight),
      'cyan'      => isDark ? (ColorSchemes.cyanDark,      AppColors.cyanSurfaceDark)
                            : (ColorSchemes.cyanLight,     AppColors.cyanSurfaceLight),
      'magenta'   => isDark ? (ColorSchemes.magentaDark,   AppColors.magentaSurfaceDark)
                            : (ColorSchemes.magentaLight,  AppColors.magentaSurfaceLight),
      _           => isDark ? (ColorSchemes.titaniumDark,  AppColors.titaniumSurfaceDark)
                            : (ColorSchemes.titaniumLight, AppColors.titaniumSurfaceLight),
    };
  }

  /// Detecta el tema Titanium comparando con sus colores primarios conocidos.
  /// NO se puede usar r==g==b porque titaniumPrimaryLight(0xFF1D1B1E) no tiene
  /// los canales iguales.
  static bool _isTitanium(ColorScheme scheme) {
    final p = scheme.primary.toARGB32();
    return p == AppColors.titaniumPrimaryLight.toARGB32() ||
           p == AppColors.titaniumPrimaryDark.toARGB32();
  }
}
