import 'package:flutter/material.dart';

/// Define todas las paletas de colores para los diferentes temas de gema.
class AppColors {
  AppColors._();

  // --- AMETHYST (Púrpura) ---
  static const amethystPrimaryLight = Color(0xFF9C27B0);
  static const amethystPrimaryDark = Color(0xFFBA68C8);
  static const amethystAccent = Color(0xFFE1BEE7);

  // --- SAPPHIRE (Azul) ---
  static const sapphirePrimaryLight = Color(0xFF2196F3);
  static const sapphirePrimaryDark = Color(0xFF64B5F6);
  static const sapphireAccent = Color(0xFFBBDEFB);

  // --- RUBY (Rojo) ---
  static const rubyPrimaryLight = Color(0xFFE91E63);
  static const rubyPrimaryDark = Color(0xFFF06292);
  static const rubyAccent = Color(0xFFF8BBD0);

  // --- EMERALD (Verde) ---
  static const emeraldPrimaryLight = Color(0xFF4CAF50);
  static const emeraldPrimaryDark = Color(0xFF81C784);
  static const emeraldAccent = Color(0xFFC8E6C9);

  // --- AMBER (Ámbar) ---
  static const amberPrimaryLight = Color(0xFFFFC107);
  static const amberPrimaryDark = Color(0xFFFFD54F);
  static const amberAccent = Color(0xFFFFECB3);

  // --- COBALT (Azul Oscuro) ---
  static const cobaltPrimaryLight = Color(0xFF3F51B5);
  static const cobaltPrimaryDark = Color(0xFF7986CB);
  static const cobaltAccent = Color(0xFFC5CAE9);

  // --- CYAN (Cian) ---
  static const cyanPrimaryLight = Color(0xFF00BCD4);
  static const cyanPrimaryDark = Color(0xFF4DD0E1);
  static const cyanAccent = Color(0xFFB2EBF2);

  // --- MAGENTA (Rosa Fuerte) ---
  static const magentaPrimaryLight = Color(0xFFE91E63);
  static const magentaPrimaryDark = Color(0xFFF06292);
  static const magentaAccent = Color(0xFFF8BBD0);

  // --- TITANIUM (Gris/Por defecto) ---
  static const titaniumPrimaryLight = Color(0xFF607D8B);
  static const titaniumPrimaryDark = Color(0xFF90A4AE);
  static const titaniumAccent = Color(0xFFCFD8DC);

  /// Obtiene el color primario según el nombre del acento.
  static Color getPrimary(String accent) {
    switch (accent.toLowerCase()) {
      case 'amethyst': return amethystPrimaryLight;
      case 'sapphire': return sapphirePrimaryLight;
      case 'ruby': return rubyPrimaryLight;
      case 'emerald': return emeraldPrimaryLight;
      case 'amber': return amberPrimaryLight;
      case 'cobalt': return cobaltPrimaryLight;
      case 'cyan': return cyanPrimaryLight;
      case 'magenta': return magentaPrimaryLight;
      case 'titanium':
      default:
        return titaniumPrimaryLight;
    }
  }

  /// Genera el fondo del AppBar dinámicamente según el ColorScheme y el tema elegido.
  static Widget getAppBarGradient(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Detectar tema Titanium (monocromo)
    final isTitanium =
        (scheme.primary.r == scheme.primary.g &&
        scheme.primary.g == scheme.primary.b);

    // Temas que usan el gradiente Primary -> Tertiary
    final isAmethyst =
        scheme.primary.toARGB32() == amethystPrimaryLight.toARGB32() ||
        scheme.primary.toARGB32() == amethystPrimaryDark.toARGB32();
    final isEmerald =
        scheme.primary.toARGB32() == emeraldPrimaryLight.toARGB32() ||
        scheme.primary.toARGB32() == emeraldPrimaryDark.toARGB32();
    final isRuby =
        scheme.primary.toARGB32() == rubyPrimaryLight.toARGB32() ||
        scheme.primary.toARGB32() == rubyPrimaryDark.toARGB32();
    final isAmber =
        scheme.primary.toARGB32() == amberPrimaryLight.toARGB32() ||
        scheme.primary.toARGB32() == amberPrimaryDark.toARGB32();
    final isCobalt =
        scheme.primary.toARGB32() == cobaltPrimaryLight.toARGB32() ||
        scheme.primary.toARGB32() == cobaltPrimaryDark.toARGB32();
    final isCyan =
        scheme.primary.toARGB32() == cyanPrimaryLight.toARGB32() ||
        scheme.primary.toARGB32() == cyanPrimaryDark.toARGB32();
    final isMagenta =
        scheme.primary.toARGB32() == magentaPrimaryLight.toARGB32() ||
        scheme.primary.toARGB32() == magentaPrimaryDark.toARGB32();

    if (isTitanium) {
      return Container(color: isDark ? const Color(0xFF121212) : Colors.white);
    }

    if (isAmethyst ||
        isEmerald ||
        isRuby ||
        isAmber ||
        isCobalt ||
        isCyan ||
        isMagenta) {
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

    // Para otros temas: modo claro -> gradiente oscuro, modo oscuro -> gradiente claro
    if (isDark) {
      final Color lighterPrimary = HSLColor.fromColor(
        scheme.primary,
      ).withLightness(0.75).toColor();
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [scheme.primary, lighterPrimary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      );
    }

    final Color darkerPrimary = HSLColor.fromColor(
      scheme.primary,
    ).withLightness(0.3).toColor();
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [scheme.primary, darkerPrimary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}
