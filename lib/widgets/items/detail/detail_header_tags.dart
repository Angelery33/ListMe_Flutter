import 'package:flutter/material.dart';
import '../../../../data/items/item_model.dart';


class DetailHeaderTags extends StatelessWidget {
  final ItemModel item;

  const DetailHeaderTags({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildCompactTag(
          context,
          _getStatusLabel(item.status ?? 'PENDING'),
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

  Widget _buildCompactTag(BuildContext context, String label, Color color, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  fontSize: 10,
                ),
          ),
        ],
      ),
    );
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'PENDING': return 'Pendiente';
      case 'IN_PROGRESS': return 'En Curso';
      case 'COMPLETED': return 'Completado';
      case 'DROPPED': return 'Abandonado';
      default: return status;
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'PENDING': return Colors.blue;
      case 'IN_PROGRESS': return Colors.green;
      case 'COMPLETED': return Colors.purple;
      case 'DROPPED': return Colors.red;
      default: return Colors.grey;
    }
  }

  IconData _getStatusIcon(String? status) {
    switch (status) {
      case 'PENDING': return Icons.schedule;
      case 'IN_PROGRESS': return Icons.play_circle_outline;
      case 'COMPLETED': return Icons.check_circle_outline;
      case 'DROPPED': return Icons.cancel_outlined;
      default: return Icons.info_outline;
    }
  }
}
