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
      return Container(color: isDark ? const Color(0xFF121212) : Colors.white);
    }

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

  static bool _isTitanium(ColorScheme scheme) =>
      scheme.primary.r == scheme.primary.g &&
      scheme.primary.g == scheme.primary.b;
}
