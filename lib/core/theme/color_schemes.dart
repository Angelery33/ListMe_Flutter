import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Definiciones de [ColorScheme] para cada acento visual.
class ColorSchemes {
  ColorSchemes._();

  // ---------------------------------------------------------------------------
  // EMERALD
  // ---------------------------------------------------------------------------
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

  static final ColorScheme sapphireLight = ColorScheme.fromSeed(
    seedColor: AppColors.sapphirePrimaryLight,
    primary: AppColors.sapphirePrimaryLight,
    surface: AppColors.sapphireSurfaceLight,
    brightness: Brightness.light,
  );
  static final ColorScheme sapphireDark = ColorScheme.fromSeed(
    seedColor: AppColors.sapphirePrimaryDark,
    primary: AppColors.sapphirePrimaryDark,
    surface: AppColors.sapphireSurfaceDark,
    brightness: Brightness.dark,
  );

  static final ColorScheme rubyLight = ColorScheme.fromSeed(
    seedColor: AppColors.rubyPrimaryLight,
    primary: AppColors.rubyPrimaryLight,
    surface: AppColors.rubySurfaceLight,
    brightness: Brightness.light,
  );
  static final ColorScheme rubyDark = ColorScheme.fromSeed(
    seedColor: AppColors.rubyPrimaryDark,
    primary: AppColors.rubyPrimaryDark,
    surface: AppColors.rubySurfaceDark,
    brightness: Brightness.dark,
  );

  static final ColorScheme titaniumLight = ColorScheme.fromSeed(
    seedColor: AppColors.titaniumPrimaryLight,
    primary: AppColors.titaniumPrimaryLight,
    onPrimary: Colors.white,
    secondary: const Color(0xFF605D62),
    surface: AppColors.titaniumSurfaceLight,
    onSurface: const Color(0xFF1D1B1E),
    brightness: Brightness.light,
  );
  static final ColorScheme titaniumDark = ColorScheme.fromSeed(
    seedColor: AppColors.titaniumPrimaryDark,
    primary: AppColors.titaniumPrimaryDark,
    onPrimary: Colors.black,
    secondary: const Color(0xFF938F99),
    surface: AppColors.titaniumSurfaceDark,
    onSurface: const Color(0xFFE3E2E6),
    brightness: Brightness.dark,
  );

  static final ColorScheme amberLight = ColorScheme.fromSeed(
    seedColor: AppColors.amberPrimaryLight,
    primary: AppColors.amberPrimaryLight,
    surface: AppColors.amberSurfaceLight,
    brightness: Brightness.light,
  );
  static final ColorScheme amberDark = ColorScheme.fromSeed(
    seedColor: AppColors.amberPrimaryDark,
    primary: AppColors.amberPrimaryDark,
    surface: AppColors.amberSurfaceDark,
    brightness: Brightness.dark,
  );

  static final ColorScheme cobaltLight = ColorScheme.fromSeed(
    seedColor: AppColors.cobaltPrimaryLight,
    primary: AppColors.cobaltPrimaryLight,
    surface: AppColors.cobaltSurfaceLight,
    brightness: Brightness.light,
  );
  static final ColorScheme cobaltDark = ColorScheme.fromSeed(
    seedColor: AppColors.cobaltPrimaryDark,
    primary: AppColors.cobaltPrimaryDark,
    surface: AppColors.cobaltSurfaceDark,
    brightness: Brightness.dark,
  );

  static final ColorScheme cyanLight = ColorScheme.fromSeed(
    seedColor: AppColors.cyanPrimaryLight,
    primary: AppColors.cyanPrimaryLight,
    surface: AppColors.cyanSurfaceLight,
    brightness: Brightness.light,
  );
  static final ColorScheme cyanDark = ColorScheme.fromSeed(
    seedColor: AppColors.cyanPrimaryDark,
    primary: AppColors.cyanPrimaryDark,
    surface: AppColors.cyanSurfaceDark,
    brightness: Brightness.dark,
  );

  static final ColorScheme magentaLight = ColorScheme.fromSeed(
    seedColor: AppColors.magentaPrimaryLight,
    primary: AppColors.magentaPrimaryLight,
    surface: AppColors.magentaSurfaceLight,
    brightness: Brightness.light,
  );
  static final ColorScheme magentaDark = ColorScheme.fromSeed(
    seedColor: AppColors.magentaPrimaryDark,
    primary: AppColors.magentaPrimaryDark,
    surface: AppColors.magentaSurfaceDark,
    brightness: Brightness.dark,
  );
}
