import 'package:flutter/material.dart';
import '../../data/lists/list_model.dart';
import '../../core/theme.dart';

/// Tarjeta visual que representa una lista del usuario en el listado principal.
class ListCard extends StatelessWidget {
  final ListModel list;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onShare;

  const ListCard({
    super.key,
    required this.list,
    required this.onTap,
    this.onEdit,
    this.onDelete,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final scheme = theme.colorScheme;
    final accentColor = AppTheme.getPrimaryColor(list.color, theme.brightness);
    final isTitanium = AppTheme.isTitanium(scheme);

    Color cardColor;
    if (isTitanium) {
      cardColor = isDark ? const Color(0xFF2C2C2E) : Colors.white;
    } else {
      cardColor = isDark
          ? scheme.surface.withValues(alpha: 0.8)
          : scheme.surface;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      elevation: isDark ? 4 : 1,
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Icono con color personalizado
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getIconData(list.icon),
                  color: accentColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              // Información de la lista
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                list.name,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${list.itemCount} elementos',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.7),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (list.isShared) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.people_alt_rounded,
                            size: 16,
                            color: theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.6),
                          ),
                        ],
                      ],
                    ),
                    if (list.description != null &&
                        list.description!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          list.description!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Menú de 3 puntos
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert_rounded,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                onSelected: (value) {
                  if (value == 'edit') onEdit?.call();
                  if (value == 'delete') onDelete?.call();
                  if (value == 'share') onShare?.call();
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Text('Editar', style: theme.textTheme.bodyMedium),
                  ),
                  PopupMenuItem(
                    value: 'share',
                    child: Text('Compartir', style: theme.textTheme.bodyMedium),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text(
                      'Eliminar',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'shopping_cart':
        return Icons.shopping_cart_rounded;
      case 'tv':
        return Icons.tv_rounded;
      case 'book':
        return Icons.book_rounded;
      case 'movie':
        return Icons.movie_rounded;
      case 'games':
        return Icons.sports_esports_rounded;
      case 'music':
        return Icons.music_note_rounded;
      case 'restaurant':
        return Icons.restaurant_rounded;
      case 'work':
        return Icons.work_rounded;
      case 'fitness':
        return Icons.fitness_center_rounded;
      case 'home':
        return Icons.home_rounded;
      case 'favorite':
        return Icons.favorite_rounded;
      default:
        return Icons.list_rounded;
    }
  }
}
