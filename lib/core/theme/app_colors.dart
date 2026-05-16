import 'package:flutter/material.dart';

/// Paleta de colores de todos los temas de la aplicación.
///
/// Cada tema (gema) define su color primario, contenedor, secundario, terciario,
/// error, surface y outline para modo claro y oscuro.
///
/// Los temas Emerald y Amethyst están completamente definidos con todos los
/// roles M3. Los demás temas (Sapphire, Ruby, Titanium, Amber, Cobalt, Cyan y
/// Magenta) sólo definen los colores primarios y de superficie, ya que el resto
/// se genera con [ColorScheme.fromSeed].
class AppColors {
  AppColors._();

  // ---------------------------------------------------------------------------
  // EMERALD / Bosque (Verde Esmeralda)
  // ---------------------------------------------------------------------------
  static const emeraldPrimaryLight            = Color(0xFF256A4A);
  static const emeraldOnPrimaryLight          = Color(0xFFFFFFFF);
  static const emeraldPrimaryContainerLight   = Color(0xFFABF2C9);
  static const emeraldOnPrimaryContainerLight = Color(0xFF005234);
  static const emeraldSecondaryLight          = Color(0xFF4D6356);
  static const emeraldOnSecondaryLight        = Color(0xFFFFFFFF);
  static const emeraldSecondaryContainerLight = Color(0xFFD0E8D7);
  static const emeraldOnSecondaryContainerLight = Color(0xFF364B3F);
  static const emeraldTertiaryLight           = Color(0xFF3C6472);
  static const emeraldOnTertiaryLight         = Color(0xFFFFFFFF);
  static const emeraldTertiaryContainerLight  = Color(0xFFC0E9FA);
  static const emeraldOnTertiaryContainerLight = Color(0xFF234C59);
  static const emeraldErrorLight              = Color(0xFFBA1A1A);
  static const emeraldOnErrorLight            = Color(0xFFFFFFFF);
  static const emeraldErrorContainerLight     = Color(0xFFFFDAD6);
  static const emeraldOnErrorContainerLight   = Color(0xFF93000A);
  static const emeraldSurfaceLight            = Color(0xFFF5FBF4);
  static const emeraldOnSurfaceLight          = Color(0xFF171D19);
  static const emeraldSurfaceVariantLight     = Color(0xFFDCE5DC);
  static const emeraldOnSurfaceVariantLight   = Color(0xFF404943);
  static const emeraldOutlineLight            = Color(0xFF707972);
  static const emeraldOutlineVariantLight     = Color(0xFFC0C9C1);

  static const emeraldPrimaryDark             = Color(0xFF90D5AE);
  static const emeraldOnPrimaryDark           = Color(0xFF003823);
  static const emeraldPrimaryContainerDark    = Color(0xFF005234);
  static const emeraldOnPrimaryContainerDark  = Color(0xFFABF2C9);
  static const emeraldSecondaryDark           = Color(0xFFB4CCBC);
  static const emeraldOnSecondaryDark         = Color(0xFF203529);
  static const emeraldSecondaryContainerDark  = Color(0xFF364B3F);
  static const emeraldOnSecondaryContainerDark = Color(0xFFD0E8D7);
  static const emeraldTertiaryDark            = Color(0xFFA4CDDD);
  static const emeraldOnTertiaryDark          = Color(0xFF053542);
  static const emeraldTertiaryContainerDark   = Color(0xFF234C59);
  static const emeraldOnTertiaryContainerDark = Color(0xFFC0E9FA);
  static const emeraldErrorDark               = Color(0xFFFFB4AB);
  static const emeraldOnErrorDark             = Color(0xFF690005);
  static const emeraldErrorContainerDark      = Color(0xFF93000A);
  static const emeraldOnErrorContainerDark    = Color(0xFFFFDAD6);
  static const emeraldSurfaceDark             = Color(0xFF0F1511);
  static const emeraldOnSurfaceDark           = Color(0xFFDEE4DE);
  static const emeraldSurfaceVariantDark      = Color(0xFF404943);
  static const emeraldOnSurfaceVariantDark    = Color(0xFFC0C9C1);
  static const emeraldOutlineDark             = Color(0xFF8A938C);
  static const emeraldOutlineVariantDark      = Color(0xFF404943);

  // ---------------------------------------------------------------------------
  // AMETHYST / Púrpura
  // ---------------------------------------------------------------------------
  static const amethystPrimaryLight            = Color(0xFF7D4E7E);
  static const amethystOnPrimaryLight          = Color(0xFFFFFFFF);
  static const amethystPrimaryContainerLight   = Color(0xFFFFD7F1);
  static const amethystOnPrimaryContainerLight = Color(0xFF330B37);
  static const amethystSecondaryLight          = Color(0xFF6D5869);
  static const amethystOnSecondaryLight        = Color(0xFFFFFFFF);
  static const amethystSecondaryContainerLight = Color(0xFFF6DBEF);
  static const amethystOnSecondaryContainerLight = Color(0xFF261625);
  static const amethystTertiaryLight           = Color(0xFF82524A);
  static const amethystOnTertiaryLight         = Color(0xFFFFFFFF);
  static const amethystTertiaryContainerLight  = Color(0xFFFFDAD4);
  static const amethystOnTertiaryContainerLight = Color(0xFF33110C);
  static const amethystErrorLight              = Color(0xFFBA1A1A);
  static const amethystOnErrorLight            = Color(0xFFFFFFFF);
  static const amethystSurfaceLight            = Color(0xFFFFFBFF);
  static const amethystOnSurfaceLight          = Color(0xFF1E1A1D);
  static const amethystSurfaceVariantLight     = Color(0xFFEBDCE9);
  static const amethystOnSurfaceVariantLight   = Color(0xFF4C444D);
  static const amethystOutlineLight            = Color(0xFF7D747D);

  static const amethystPrimaryDark             = Color(0xFFEDB8EE);
  static const amethystOnPrimaryDark           = Color(0xFF4A204D);
  static const amethystPrimaryContainerDark    = Color(0xFF643765);
  static const amethystOnPrimaryContainerDark  = Color(0xFFFFD7F1);
  static const amethystSecondaryDark           = Color(0xFFD9BFD3);
  static const amethystOnSecondaryDark         = Color(0xFF3C2B3A);
  static const amethystSecondaryContainerDark  = Color(0xFF544151);
  static const amethystOnSecondaryContainerDark = Color(0xFFF6DBEF);
  static const amethystTertiaryDark            = Color(0xFFF6B8AD);
  static const amethystOnTertiaryDark          = Color(0xFF4C251F);
  static const amethystTertiaryContainerDark   = Color(0xFF663B34);
  static const amethystOnTertiaryContainerDark = Color(0xFFFFDAD4);
  static const amethystErrorDark               = Color(0xFFFFB4AB);
  static const amethystOnErrorDark             = Color(0xFF690005);
  static const amethystSurfaceDark             = Color(0xFF1E1A1D);
  static const amethystOnSurfaceDark           = Color(0xFFE9E0E5);
  static const amethystSurfaceVariantDark      = Color(0xFF4C444D);
  static const amethystOnSurfaceVariantDark    = Color(0xFFCEC3CD);
  static const amethystOutlineDark             = Color(0xFF978E97);

  // ---------------------------------------------------------------------------
  // Otros Temas (Sapphire, Ruby, Titanium, Amber, Cobalt, Cyan, Magenta)
  // ---------------------------------------------------------------------------

  /// Color primario para el tema Sapphire (verde azulado) en modo claro.
  static const sapphirePrimaryLight   = Color(0xFF00796B);
  /// Superficie de fondo para el tema Sapphire en modo claro.
  static const sapphireSurfaceLight   = Color(0xFFE0F2F1);
  /// Color primario para el tema Sapphire en modo oscuro.
  static const sapphirePrimaryDark    = Color(0xFF80CBC4);
  /// Superficie de fondo para el tema Sapphire en modo oscuro.
  static const sapphireSurfaceDark    = Color(0xFF161F1E);

  /// Color primario para el tema Ruby (rojo profundo) en modo claro.
  static const rubyPrimaryLight       = Color(0xFF800020);
  /// Superficie de fondo para el tema Ruby en modo claro.
  static const rubySurfaceLight       = Color(0xFFFFF5F5);
  /// Color primario para el tema Ruby en modo oscuro.
  static const rubyPrimaryDark        = Color(0xFFB71C1C);
  /// Superficie de fondo para el tema Ruby en modo oscuro.
  static const rubySurfaceDark        = Color(0xFF241616);

  /// Color primario para el tema Titanium (casi negro/blanco) en modo claro.
  static const titaniumPrimaryLight   = Color.fromARGB(255, 38, 36, 39);
  /// Superficie de fondo para el tema Titanium en modo claro.
  static const titaniumSurfaceLight   = Color.fromARGB(255, 240, 240, 240);
  /// Color primario para el tema Titanium en modo oscuro.
  static const titaniumPrimaryDark    = Color(0xFFE3E2E6);
  /// Superficie de fondo para el tema Titanium en modo oscuro.
  static const titaniumSurfaceDark    = Color.fromARGB(255, 27, 27, 27);

  /// Color primario para el tema Amber (naranja/oro) en modo claro.
  static const amberPrimaryLight      = Color(0xFFA66800);
  /// Superficie de fondo para el tema Amber en modo claro.
  static const amberSurfaceLight      = Color(0xFFFFF8F0);
  /// Color primario para el tema Amber en modo oscuro.
  static const amberPrimaryDark       = Color(0xFFFFB77C);
  /// Superficie de fondo para el tema Amber en modo oscuro.
  static const amberSurfaceDark       = Color(0xFF2E1C0A);

  /// Color primario para el tema Cobalt (azul profundo) en modo claro.
  static const cobaltPrimaryLight     = Color(0xFF2F48A8);
  /// Superficie de fondo para el tema Cobalt en modo claro.
  static const cobaltSurfaceLight     = Color(0xFFEEF0FA);
  /// Color primario para el tema Cobalt en modo oscuro.
  static const cobaltPrimaryDark      = Color(0xFFBCC4FF);
  /// Superficie de fondo para el tema Cobalt en modo oscuro.
  static const cobaltSurfaceDark      = Color(0xFF0F1530);

  /// Color primario para el tema Cyan (azul claro) en modo claro.
  static const cyanPrimaryLight       = Color(0xFF00ACC1);
  /// Superficie de fondo para el tema Cyan en modo claro.
  static const cyanSurfaceLight       = Color(0xFFE0F7FA);
  /// Color primario para el tema Cyan en modo oscuro.
  static const cyanPrimaryDark        = Color(0xFF4DD0E1);
  /// Superficie de fondo para el tema Cyan en modo oscuro.
  static const cyanSurfaceDark        = Color(0xFF001F24);

  /// Color primario para el tema Magenta (rosa) en modo claro.
  static const magentaPrimaryLight    = Color(0xFFC2185B);
  /// Superficie de fondo para el tema Magenta en modo claro.
  static const magentaSurfaceLight    = Color(0xFFFCE4EC);
  /// Color primario para el tema Magenta en modo oscuro.
  static const magentaPrimaryDark     = Color(0xFFF48FB1);
  /// Superficie de fondo para el tema Magenta en modo oscuro.
  static const magentaSurfaceDark     = Color(0xFF300516);
}
