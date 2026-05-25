import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Definiciones de [ColorScheme] para cada acento visual.
///
/// Los temas Emerald y Amethyst usan esquemas completamente manuales con todos
/// los roles M3 especificados. El resto de temas (Sapphire, Ruby, Titanium,
/// Amber, Cobalt, Cyan, Magenta) se generan con [ColorScheme.fromSeed] para
/// que Flutter calcule automáticamente los roles derivados.
class ColorSchemes {
  ColorSchemes._();

  // ---------------------------------------------------------------------------
  // EMERALD
  // ---------------------------------------------------------------------------

  /// Esquema claro del tema Esmeralda (verde bosque), con todos los roles M3.
  static final ColorScheme emeraldLight = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.emeraldPrimaryLight,
    onPrimary: AppColors.emeraldOnPrimaryLight,
    primaryContainer: AppColors.emeraldPrimaryContainerLight,
    onPrimaryContainer: AppColors.emeraldOnPrimaryContainerLight,
    secondary: AppColors.emeraldSecondaryLight,
    onSecondary: AppColors.emeraldOnSecondaryLight,
    secondaryContainer: AppColors.emeraldSecondaryContainerLight,
    onSecondaryContainer: AppColors.emeraldOnSecondaryContainerLight,
    tertiary: AppColors.emeraldTertiaryLight,
    onTertiary: AppColors.emeraldOnTertiaryLight,
    tertiaryContainer: AppColors.emeraldTertiaryContainerLight,
    onTertiaryContainer: AppColors.emeraldOnTertiaryContainerLight,
    error: AppColors.emeraldErrorLight,
    onError: AppColors.emeraldOnErrorLight,
    errorContainer: AppColors.emeraldErrorContainerLight,
    onErrorContainer: AppColors.emeraldOnErrorContainerLight,
    surface: AppColors.emeraldSurfaceLight,
    onSurface: AppColors.emeraldOnSurfaceLight,
    surfaceContainerHighest: AppColors.emeraldSurfaceVariantLight,
    onSurfaceVariant: AppColors.emeraldOnSurfaceVariantLight,
    outline: AppColors.emeraldOutlineLight,
    outlineVariant: AppColors.emeraldOutlineVariantLight,
  );

  /// Esquema oscuro del tema Esmeralda (verde bosque), con todos los roles M3.
  static final ColorScheme emeraldDark = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.emeraldPrimaryDark,
    onPrimary: AppColors.emeraldOnPrimaryDark,
    primaryContainer: AppColors.emeraldPrimaryContainerDark,
    onPrimaryContainer: AppColors.emeraldOnPrimaryContainerDark,
    secondary: AppColors.emeraldSecondaryDark,
    onSecondary: AppColors.emeraldOnSecondaryDark,
    secondaryContainer: AppColors.emeraldSecondaryContainerDark,
    onSecondaryContainer: AppColors.emeraldOnSecondaryContainerDark,
    tertiary: AppColors.emeraldTertiaryDark,
    onTertiary: AppColors.emeraldOnTertiaryDark,
    tertiaryContainer: AppColors.emeraldTertiaryContainerDark,
    onTertiaryContainer: AppColors.emeraldOnTertiaryContainerDark,
    error: AppColors.emeraldErrorDark,
    onError: AppColors.emeraldOnErrorDark,
    errorContainer: AppColors.emeraldErrorContainerDark,
    onErrorContainer: AppColors.emeraldOnErrorContainerDark,
    surface: AppColors.emeraldSurfaceDark,
    onSurface: AppColors.emeraldOnSurfaceDark,
    surfaceContainerHighest: AppColors.emeraldSurfaceVariantDark,
    onSurfaceVariant: AppColors.emeraldOnSurfaceVariantDark,
    outline: AppColors.emeraldOutlineDark,
    outlineVariant: AppColors.emeraldOutlineVariantDark,
  );

  // ---------------------------------------------------------------------------
  // AMETHYST
  // ---------------------------------------------------------------------------

  /// Esquema claro del tema Amatista (púrpura), con todos los roles M3.
  static final ColorScheme amethystLight = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.amethystPrimaryLight,
    onPrimary: AppColors.amethystOnPrimaryLight,
    primaryContainer: AppColors.amethystPrimaryContainerLight,
    onPrimaryContainer: AppColors.amethystOnPrimaryContainerLight,
    secondary: AppColors.amethystSecondaryLight,
    onSecondary: AppColors.amethystOnSecondaryLight,
    secondaryContainer: AppColors.amethystSecondaryContainerLight,
    onSecondaryContainer: AppColors.amethystOnSecondaryContainerLight,
    tertiary: AppColors.amethystTertiaryLight,
    onTertiary: AppColors.amethystOnTertiaryLight,
    tertiaryContainer: AppColors.amethystTertiaryContainerLight,
    onTertiaryContainer: AppColors.amethystOnTertiaryContainerLight,
    error: AppColors.amethystErrorLight,
    onError: AppColors.amethystOnErrorLight,
    surface: AppColors.amethystSurfaceLight,
    onSurface: AppColors.amethystOnSurfaceLight,
    surfaceContainerHighest: AppColors.amethystSurfaceVariantLight,
    onSurfaceVariant: AppColors.amethystOnSurfaceVariantLight,
    outline: AppColors.amethystOutlineLight,
  );

  /// Esquema oscuro del tema Amatista (púrpura), con todos los roles M3.
  static final ColorScheme amethystDark = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.amethystPrimaryDark,
    onPrimary: AppColors.amethystOnPrimaryDark,
    primaryContainer: AppColors.amethystPrimaryContainerDark,
    onPrimaryContainer: AppColors.amethystOnPrimaryContainerDark,
    secondary: AppColors.amethystSecondaryDark,
    onSecondary: AppColors.amethystOnSecondaryDark,
    secondaryContainer: AppColors.amethystSecondaryContainerDark,
    onSecondaryContainer: AppColors.amethystOnSecondaryContainerDark,
    tertiary: AppColors.amethystTertiaryDark,
    onTertiary: AppColors.amethystOnTertiaryDark,
    tertiaryContainer: AppColors.amethystTertiaryContainerDark,
    onTertiaryContainer: AppColors.amethystOnTertiaryContainerDark,
    error: AppColors.amethystErrorDark,
    onError: AppColors.amethystOnErrorDark,
    surface: AppColors.amethystSurfaceDark,
    onSurface: AppColors.amethystOnSurfaceDark,
    surfaceContainerHighest: AppColors.amethystSurfaceVariantDark,
    onSurfaceVariant: AppColors.amethystOnSurfaceVariantDark,
    outline: AppColors.amethystOutlineDark,
  );

  // ---------------------------------------------------------------------------
  // SEED-BASED
  // ---------------------------------------------------------------------------

  /// Esquema claro del tema Zafiro (verde-azulado), generado por semilla.
  static final ColorScheme sapphireLight = ColorScheme.fromSeed(
    seedColor: AppColors.sapphirePrimaryLight,
    primary: AppColors.sapphirePrimaryLight,
    surface: AppColors.sapphireSurfaceLight,
    brightness: Brightness.light,
  );

  /// Esquema oscuro del tema Zafiro, generado por semilla.
  static final ColorScheme sapphireDark = ColorScheme.fromSeed(
    seedColor: AppColors.sapphirePrimaryDark,
    primary: AppColors.sapphirePrimaryDark,
    surface: AppColors.sapphireSurfaceDark,
    brightness: Brightness.dark,
  );

  /// Esquema claro del tema Rubí (rojo oscuro), generado por semilla.
  static final ColorScheme rubyLight = ColorScheme.fromSeed(
    seedColor: AppColors.rubyPrimaryLight,
    primary: AppColors.rubyPrimaryLight,
    surface: AppColors.rubySurfaceLight,
    brightness: Brightness.light,
  );

  /// Esquema oscuro del tema Rubí, generado por semilla.
  static final ColorScheme rubyDark = ColorScheme.fromSeed(
    seedColor: AppColors.rubyPrimaryDark,
    primary: AppColors.rubyPrimaryDark,
    surface: AppColors.rubySurfaceDark,
    brightness: Brightness.dark,
  );

  /// Esquema claro del tema Titanio (monocromático), definido manualmente para
  /// un look minimalista negro/blanco.
  static final ColorScheme titaniumLight = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.titaniumPrimaryLight,
    onPrimary: Colors.white,
    secondary: const Color(0xFF605D62),
    onSecondary: Colors.white,
    error: const Color(0xFFBA1A1A),
    onError: Colors.white,
    surface: AppColors.titaniumSurfaceLight,
    onSurface: const Color(0xFF1D1B1E),
    surfaceContainerHighest: const Color(0xFFE3E2E6),
    outline: const Color(0xFF7D747D),
  );

  /// Esquema oscuro del tema Titanio, definido manualmente.
  static final ColorScheme titaniumDark = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.titaniumPrimaryDark,
    onPrimary: Colors.black,
    secondary: const Color(0xFF938F99),
    onSecondary: Colors.black,
    error: const Color(0xFFFFB4AB),
    onError: const Color(0xFF690005),
    surface: AppColors.titaniumSurfaceDark,
    onSurface: const Color(0xFFE3E2E6),
    surfaceContainerHighest: const Color(0xFF4C444D),
    outline: const Color(0xFF978E97),
  );

  /// Esquema claro del tema Ámbar (naranja/dorado), generado por semilla.
  static final ColorScheme amberLight = ColorScheme.fromSeed(
    seedColor: AppColors.amberPrimaryLight,
    primary: AppColors.amberPrimaryLight,
    surface: AppColors.amberSurfaceLight,
    brightness: Brightness.light,
  );

  /// Esquema oscuro del tema Ámbar, generado por semilla.
  static final ColorScheme amberDark = ColorScheme.fromSeed(
    seedColor: AppColors.amberPrimaryDark,
    primary: AppColors.amberPrimaryDark,
    surface: AppColors.amberSurfaceDark,
    brightness: Brightness.dark,
  );

  /// Esquema claro del tema Cobalto (azul profundo), generado por semilla.
  static final ColorScheme cobaltLight = ColorScheme.fromSeed(
    seedColor: AppColors.cobaltPrimaryLight,
    primary: AppColors.cobaltPrimaryLight,
    surface: AppColors.cobaltSurfaceLight,
    brightness: Brightness.light,
  );

  /// Esquema oscuro del tema Cobalto, generado por semilla.
  static final ColorScheme cobaltDark = ColorScheme.fromSeed(
    seedColor: AppColors.cobaltPrimaryDark,
    primary: AppColors.cobaltPrimaryDark,
    surface: AppColors.cobaltSurfaceDark,
    brightness: Brightness.dark,
  );

  /// Esquema claro del tema Cian (azul claro), generado por semilla.
  static final ColorScheme cyanLight = ColorScheme.fromSeed(
    seedColor: AppColors.cyanPrimaryLight,
    primary: AppColors.cyanPrimaryLight,
    surface: AppColors.cyanSurfaceLight,
    brightness: Brightness.light,
  );

  /// Esquema oscuro del tema Cian, generado por semilla.
  static final ColorScheme cyanDark = ColorScheme.fromSeed(
    seedColor: AppColors.cyanPrimaryDark,
    primary: AppColors.cyanPrimaryDark,
    surface: AppColors.cyanSurfaceDark,
    brightness: Brightness.dark,
  );

  /// Esquema claro del tema Magenta (rosa/fucsia), generado por semilla.
  static final ColorScheme magentaLight = ColorScheme.fromSeed(
    seedColor: AppColors.magentaPrimaryLight,
    primary: AppColors.magentaPrimaryLight,
    surface: AppColors.magentaSurfaceLight,
    brightness: Brightness.light,
  );

  /// Esquema oscuro del tema Magenta, generado por semilla.
  static final ColorScheme magentaDark = ColorScheme.fromSeed(
    seedColor: AppColors.magentaPrimaryDark,
    primary: AppColors.magentaPrimaryDark,
    surface: AppColors.magentaSurfaceDark,
    brightness: Brightness.dark,
  );

  // ---------------------------------------------------------------------------
  // LIME
  // ---------------------------------------------------------------------------

  /// Esquema claro del tema Lima (verde lima / verdes claros), con todos los roles M3.
  static final ColorScheme limeLight = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.limePrimaryLight,
    onPrimary: AppColors.limeOnPrimaryLight,
    primaryContainer: AppColors.limePrimaryContainerLight,
    onPrimaryContainer: AppColors.limeOnPrimaryContainerLight,
    secondary: AppColors.limeSecondaryLight,
    onSecondary: AppColors.limeOnSecondaryLight,
    secondaryContainer: AppColors.limeSecondaryContainerLight,
    onSecondaryContainer: AppColors.limeOnSecondaryContainerLight,
    tertiary: AppColors.limeTertiaryLight,
    onTertiary: AppColors.limeOnTertiaryLight,
    tertiaryContainer: AppColors.limeTertiaryContainerLight,
    onTertiaryContainer: AppColors.limeOnTertiaryContainerLight,
    error: AppColors.limeErrorLight,
    onError: AppColors.limeOnErrorLight,
    errorContainer: AppColors.limeErrorContainerLight,
    onErrorContainer: AppColors.limeOnErrorContainerLight,
    surface: AppColors.limeSurfaceLight,
    onSurface: AppColors.limeOnSurfaceLight,
    surfaceContainerHighest: AppColors.limeSurfaceVariantLight,
    onSurfaceVariant: AppColors.limeOnSurfaceVariantLight,
    outline: AppColors.limeOutlineLight,
    outlineVariant: AppColors.limeOutlineVariantLight,
  );

  /// Esquema oscuro del tema Lima (verde lima / verdes claros), con todos los roles M3.
  static final ColorScheme limeDark = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.limePrimaryDark,
    onPrimary: AppColors.limeOnPrimaryDark,
    primaryContainer: AppColors.limePrimaryContainerDark,
    onPrimaryContainer: AppColors.limeOnPrimaryContainerDark,
    secondary: AppColors.limeSecondaryDark,
    onSecondary: AppColors.limeOnSecondaryDark,
    secondaryContainer: AppColors.limeSecondaryContainerDark,
    onSecondaryContainer: AppColors.limeOnSecondaryContainerDark,
    tertiary: AppColors.limeTertiaryDark,
    onTertiary: AppColors.limeOnTertiaryDark,
    tertiaryContainer: AppColors.limeTertiaryContainerDark,
    onTertiaryContainer: AppColors.limeOnTertiaryContainerDark,
    error: AppColors.limeErrorDark,
    onError: AppColors.limeOnErrorDark,
    errorContainer: AppColors.limeErrorContainerDark,
    onErrorContainer: AppColors.limeOnErrorContainerDark,
    surface: AppColors.limeSurfaceDark,
    onSurface: AppColors.limeOnSurfaceDark,
    surfaceContainerHighest: AppColors.limeSurfaceVariantDark,
    onSurfaceVariant: AppColors.limeOnSurfaceVariantDark,
    outline: AppColors.limeOutlineDark,
    outlineVariant: AppColors.limeOutlineVariantDark,
  );
}
