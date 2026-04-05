import 'package:flutter/material.dart';
import '../../../../data/items/item_model.dart';
import '../../../../data/lists/list_model.dart';

class DetailInfoSection extends StatelessWidget {
  final ItemModel item;
  final ListModel? library;

  const DetailInfoSection({super.key, required this.item, this.library});

  bool get _supportsCompletion => library?.supportsCompletion ?? false;
  bool get _supportsWishlist => library?.supportsWishlist ?? false;
  bool get _supportsPrice => library?.supportsPrice ?? false;
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
                    _getStatusLabel(item.status),
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
                    item.wishlist ? 'En lista de deseos' : 'Adquirido',
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
                  item.wishlist ? 'PRECIO ESTIMADO' : 'COSTE',
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

  String _getStatusLabel(String? status) {
    switch (status) {
      case 'PENDING':
        return 'Pendiente';
      case 'IN_PROGRESS':
        return 'En Progreso';
      case 'COMPLETED':
        return 'Completado';
      default:
        return status ?? 'Desconocido';
    }
  }

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
