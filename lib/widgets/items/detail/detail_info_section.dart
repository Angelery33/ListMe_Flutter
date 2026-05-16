import 'package:flutter/material.dart';
import '../../../core/i18n/l10n_extension.dart';
import '../../../../data/items/item_model.dart';
import '../../../../data/lists/list_model.dart';

/// Muestra chips de estado clave y una tarjeta de precio opcional para un elemento en la
/// pantalla de detalles.
///
/// Los chips que se muestran dependen de las capacidades de la biblioteca: estado
/// (finalización), lista de deseos/adquirido, género y precio. Las etiquetas y sus colores
/// reflejan el estado actual del elemento.
class DetailInfoSection extends StatelessWidget {
  /// El elemento cuyos campos de estado, lista de deseos, género y precio se renderizan.
  final ItemModel item;

  /// La biblioteca propietaria; controla qué bloques de información son visibles a través de indicadores de
  /// capacidad como [ListModel.supportsCompletion] y [ListModel.supportsPrice].
  final ListModel? library;

  const DetailInfoSection({super.key, required this.item, this.library});

  /// Indica si la biblioteca rastrea el estado de finalización de sus elementos.
  bool get _supportsCompletion => library?.supportsCompletion ?? false;

  /// Indica si la biblioteca tiene un interruptor de lista de deseos/adquirido.
  bool get _supportsWishlist => library?.supportsWishlist ?? false;

  /// Indica si la biblioteca rastrea los precios de los elementos.
  bool get _supportsPrice => library?.supportsPrice ?? false;

  /// Indica si la biblioteca organiza los elementos por género/tema.
  bool get _isThematic => library?.thematic ?? false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            if (_supportsCompletion)
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildModernTag(
                    context,
                    _getStatusLabel(context, item.status),
                    _getStatusColor(item.status, context),
                    _getStatusIcon(item.status),
                  ),
                ),
              ),
            if (_supportsWishlist)
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildModernTag(
                    context,
                    item.wishlist ? context.l10n.infoWishlist : context.l10n.infoAcquired,
                    item.wishlist
                        ? Colors.orange
                        : Theme.of(context).colorScheme.primary,
                    item.wishlist
                        ? Icons.favorite_border
                        : Icons.shopping_bag_outlined,
                  ),
                ),
              ),
            if (_isThematic && item.genre != null && item.genre!.isNotEmpty)
              Flexible(
                child: _buildModernTag(
                  context,
                  item.genre!,
                  Theme.of(context).colorScheme.secondary,
                  Icons.category_outlined,
                ),
              ),
          ],
        ),
        if (_supportsPrice && item.price != null) ...[
          const SizedBox(height: 16),
          _buildPriceCard(context),
        ],
      ],
    );
  }

  /// Construye un chip de tipo píldora redondeado con [icon], [label] y [color].
  /// La opacidad del fondo se reduce a la mitad en el modo oscuro para el equilibrio visual.
  Widget _buildModernTag(
    BuildContext context,
    String label,
    Color color,
    IconData icon,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label.toUpperCase(),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  fontSize: 10,
                ),
                overflow: TextOverflow.visible,
                maxLines: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Renderiza el precio del elemento (o precio estimado si está en la lista de deseos) dentro de
  /// una tarjeta temática utilizando el esquema de colores terciarios.
  Widget _buildPriceCard(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.2),
        ),
      ),
      color: Theme.of(
        context,
      ).colorScheme.tertiaryContainer.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.tertiary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.payments_outlined,
                color: Theme.of(context).colorScheme.tertiary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.wishlist ? context.l10n.infoPriceEstimated : context.l10n.infoPriceCost,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.tertiary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
                Text(
                  '${item.price!.toStringAsFixed(2)} €',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onTertiaryContainer,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Devuelve el icono que mejor representa la clave de [status] dada.
  IconData _getStatusIcon(String? status) {
    switch (status) {
      case 'PENDING':
        return Icons.hourglass_empty;
      case 'IN_PROGRESS':
        return Icons.play_circle_outline;
      case 'COMPLETED':
        return Icons.check_circle_outline;
      default:
        return Icons.info_outline;
    }
  }

  /// Devuelve la cadena de visualización localizada para la clave de [status] dada.
  String _getStatusLabel(BuildContext context, String? status) {
    final l = context.l10n;
    switch (status) {
      case 'PENDING':
        return l.statusPending;
      case 'IN_PROGRESS':
        return l.statusInProgress;
      case 'COMPLETED':
        return l.statusCompleted;
      default:
        return status ?? l.commonUnknown;
    }
  }

  /// Devuelve el color asociado con la clave de [status] dada para el chip de etiqueta.
  Color _getStatusColor(String? status, BuildContext context) {
    switch (status) {
      case 'PENDING':
        return Colors.grey;
      case 'IN_PROGRESS':
        return Colors.blue;
      case 'COMPLETED':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
