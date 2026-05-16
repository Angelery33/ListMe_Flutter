import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/i18n/l10n_extension.dart';
import '../../../data/items/item_model.dart';
import '../../../core/providers/responsive_provider.dart';

/// Renderiza una fila horizontal de chips de etiquetas de colores compactos en el encabezado de
/// la pantalla de detalles, mostrando el estado del elemento, el estado de la lista de deseos, la marca de colección y el género.
///
/// Los tamaños de las etiquetas son impulsados por [ResponsiveProvider] para que se escalen correctamente en
/// diferentes densidades de pantalla y puntos de interrupción.
class DetailHeaderTags extends StatelessWidget {
  /// El elemento cuyos metadatos se utilizan para construir los chips de etiquetas.
  final ItemModel item;

  const DetailHeaderTags({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildCompactTag(
          context,
          _getStatusLabel(context, item.status ?? 'PENDING'),
          _getStatusColor(item.status),
          _getStatusIcon(item.status),
        ),
        if (item.wishlist)
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: _buildCompactTag(
              context,
              "En la Wishlist",
              Colors.orange,
              Icons.favorite_border,
            ),
          ),
        if (!item.wishlist && item.collection)
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: _buildCompactTag(
              context,
              "Coleccion",
              Theme.of(context).colorScheme.primary,
              Icons.collections_bookmark_outlined,
            ),
          ),
        if (item.genre != null && item.genre!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: _buildCompactTag(
              context,
              item.genre!,
              Theme.of(context).colorScheme.secondary,
              Icons.category_outlined,
            ),
          ),
      ],
    );
  }

  /// Construye un único chip de etiqueta en forma de píldora con [icon], [label] y [color].
  /// La opacidad del fondo se adapta al brillo actual para mayor legibilidad.
  Widget _buildCompactTag(
    BuildContext context,
    String label,
    Color color,
    IconData icon,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final responsive = context.read<ResponsiveProvider>();
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsive.tagFontSize,
        vertical: responsive.tagFontSize * 0.6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: responsive.tagIconSize, color: color),
          SizedBox(width: responsive.tagFontSize * 0.4),
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              fontSize: responsive.tagFontSize,
            ),
          ),
        ],
      ),
    );
  }

  /// Devuelve la etiqueta de visualización localizada para la clave de [status] dada.
  String _getStatusLabel(BuildContext context, String status) {
    final l = context.l10n;
    switch (status) {
      case 'PENDING':
        return l.statusPending;
      case 'IN_PROGRESS':
        return l.statusInProgress;
      case 'COMPLETED':
        return l.statusCompleted;
      case 'DROPPED':
        return l.statusDropped;
      case 'PAUSED':
        return l.statusPaused;
      default:
        return status;
    }
  }

  /// Devuelve el color de acento asociado con la clave de [status] dada para que cada
  /// estado sea visualmente distinguible de un vistazo.
  Color _getStatusColor(String? status) {
    switch (status) {
      case 'PENDING':
        return Colors.blue;
      case 'IN_PROGRESS':
        return Colors.green;
      case 'COMPLETED':
        return Colors.purple;
      case 'DROPPED':
        return Colors.red;
      case 'PAUSED':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  /// Devuelve el icono que representa la clave de [status] dada dentro del chip de etiqueta.
  IconData _getStatusIcon(String? status) {
    switch (status) {
      case 'PENDING':
        return Icons.schedule;
      case 'IN_PROGRESS':
        return Icons.play_circle_outline;
      case 'COMPLETED':
        return Icons.check_circle_outline;
      case 'DROPPED':
        return Icons.cancel_outlined;
      case 'PAUSED':
        return Icons.pause_circle_outline;
      default:
        return Icons.info_outline;
    }
  }
}
