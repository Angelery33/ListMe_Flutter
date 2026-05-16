import 'package:flutter/material.dart';
import '../../../core/i18n/l10n_extension.dart';

/// Sección de configuración que expone un conjunto de indicadores de características activables para una biblioteca.
///
/// Cada indicador se asigna a una capacidad (seguimiento de finalización, puntuación, agrupación temática,
/// lista de deseos, seguimiento de fechas, seguimiento de precios, diseño compacto, seguimiento de progreso).
/// Al activar un interruptor se llama a la función de retorno correspondiente para que la pantalla principal pueda
/// actualizar su estado.
class ConfigFeaturesSection extends StatelessWidget {
  /// Indica si los elementos de esta biblioteca pueden marcarse como completados/pendientes/etc.
  final bool supportsCompletion;

  /// Se llama cuando el usuario activa el interruptor de "admite finalización".
  final ValueChanged<bool> onSupportsCompletionChanged;

  /// Indica si a los elementos se les puede asignar una puntuación/calificación numérica.
  final bool isGradeable;

  /// Se llama cuando el usuario activa el interruptor de "calificable".
  final ValueChanged<bool> onIsGradeableChanged;

  /// Indica si los elementos están organizados en secciones de género/categoría.
  final bool isThematic;

  /// Se llama cuando el usuario activa el interruptor de "temático".
  final ValueChanged<bool> onIsThematicChanged;

  /// Indica si la biblioteca admite una lista de deseos (elementos aún no adquiridos).
  final bool supportsWishlist;

  /// Se llama cuando el usuario activa el interruptor de "admite lista de deseos".
  final ValueChanged<bool> onSupportsWishlistChanged;

  /// Indica si los elementos rastrean fechas de inicio/finalización.
  final bool tracksDates;

  /// Se llama cuando el usuario activa el interruptor de "rastrea fechas".
  final ValueChanged<bool> onTracksDatesChanged;

  /// Indica si los elementos almacenan un precio de compra.
  final bool supportsPrice;

  /// Se llama cuando el usuario activa el interruptor de "admite precio".
  final ValueChanged<bool> onSupportsPriceChanged;

  /// Indica si la tarjeta de lista utiliza un diseño de elementos compacto (más denso).
  final bool isCompact;

  /// Se llama cuando el usuario activa el interruptor de "compacto".
  final ValueChanged<bool> onIsCompactChanged;

  /// Indica si los elementos rastrean un contador de progreso numérico (páginas, capítulos, niveles…).
  final bool supportsProgress;

  /// Se llama cuando el usuario activa el interruptor de "admite progreso".
  final ValueChanged<bool> onSupportsProgressChanged;

  const ConfigFeaturesSection({
    super.key,
    required this.supportsCompletion,
    required this.onSupportsCompletionChanged,
    required this.isGradeable,
    required this.onIsGradeableChanged,
    required this.isThematic,
    required this.onIsThematicChanged,
    required this.supportsWishlist,
    required this.onSupportsWishlistChanged,
    required this.tracksDates,
    required this.onTracksDatesChanged,
    required this.supportsPrice,
    required this.onSupportsPriceChanged,
    required this.isCompact,
    required this.onIsCompactChanged,
    required this.supportsProgress,
    required this.onSupportsProgressChanged,
  });

  /// Construye una única fila [SwitchListTile] para un interruptor de característica.
  ///
  /// [title] es la etiqueta principal, [subtitle] es el texto explicativo,
  /// [value] es el estado actual del interruptor, [onChanged] se activa cuando el usuario
  /// acciona el interruptor, e [icon] es el icono decorativo inicial.
  Widget _buildSwitch(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
    IconData icon,
  ) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      secondary: Icon(icon),
      value: value,
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            _buildSwitch(
              context.l10n.listConfigCompletion,
              context.l10n.listConfigCompletionSubtitle,
              supportsCompletion,
              onSupportsCompletionChanged,
              Icons.check_circle_outline,
            ),
            _buildSwitch(
              context.l10n.listConfigGradeable,
              context.l10n.listConfigGradeableSubtitle,
              isGradeable,
              onIsGradeableChanged,
              Icons.star_border,
            ),
            _buildSwitch(
              context.l10n.listConfigThematic,
              context.l10n.listConfigThematicSubtitle,
              isThematic,
              onIsThematicChanged,
              Icons.category_outlined,
            ),
            _buildSwitch(
              context.l10n.listConfigWishlist,
              context.l10n.listConfigWishlistSubtitle,
              supportsWishlist,
              onSupportsWishlistChanged,
              Icons.card_giftcard,
            ),
            _buildSwitch(
              context.l10n.listConfigTracksDates,
              context.l10n.listConfigTracksDatesSubtitle,
              tracksDates,
              onTracksDatesChanged,
              Icons.date_range,
            ),
            _buildSwitch(
              context.l10n.listConfigPrice,
              context.l10n.listConfigPriceSubtitle,
              supportsPrice,
              onSupportsPriceChanged,
              Icons.attach_money,
            ),
            _buildSwitch(
              context.l10n.listConfigCompact,
              context.l10n.listConfigCompactSubtitle,
              isCompact,
              onIsCompactChanged,
              Icons.view_comfy_alt_outlined,
            ),
            _buildSwitch(
              context.l10n.listConfigProgress,
              "Contabilizar páginas, capítulos, niveles...",
              supportsProgress,
              onSupportsProgressChanged,
              Icons.trending_up,
            ),
          ],
        ),
      ),
    );
  }
}
