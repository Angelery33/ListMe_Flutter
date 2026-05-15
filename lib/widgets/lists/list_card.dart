import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/i18n/l10n_extension.dart';
import '../../data/lists/list_model.dart';
import '../../core/theme/theme.dart';
import '../../providers/invitations/invitations_provider.dart';

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
      
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      elevation: isDark ? 4 : 1,
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: (list.description?.isNotEmpty == true)
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.center,
            children: [
              // Icono con color personalizado
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getIconData(list.icon),
                  color: accentColor,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              // Información de la lista
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                list.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${list.itemCount} ${list.itemCount == 1 ? context.l10n.commonItem : context.l10n.commonItems}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (list.isShared) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.people_alt_rounded,
                            size: 18,
                            color: theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.6),
                          ),
                        ],
                      ],
                    ),
                    if (list.description != null &&
                        list.description!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          list.description!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
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
                    child: Text(context.l10n.commonEdit, style: theme.textTheme.bodyMedium),
                  ),
                  PopupMenuItem(
                    value: 'share',
                    child: Text(context.l10n.commonShare, style: theme.textTheme.bodyMedium),
                  ),
                  if (list.owner)
                    PopupMenuItem(
                      value: 'delete',
                      child: Text(
                        context.l10n.commonDelete,
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
