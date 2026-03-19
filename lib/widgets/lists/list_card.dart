import 'package:flutter/material.dart';
import '../../data/lists/list_model.dart';
import '../../core/app_colors.dart';

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
    final accentColor = AppColors.getPrimary(list.color);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
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
                        Text(
                          list.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (list.isShared) ...[
                          const SizedBox(width: 8),
                          Icon(Icons.people_alt_rounded, size: 16, color: theme.hintColor),
                        ],
                      ],
                    ),
                    if (list.description != null)
                      Text(
                        list.description!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: theme.hintColor),
                      ),
                  ],
                ),
              ),
              // Menú de 3 puntos
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded),
                onSelected: (value) {
                  if (value == 'edit') onEdit?.call();
                  if (value == 'delete') onDelete?.call();
                  if (value == 'share') onShare?.call();
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Editar')),
                  const PopupMenuItem(value: 'share', child: Text('Compartir')),
                  const PopupMenuItem(
                    value: 'delete', 
                    child: Text('Eliminar', style: TextStyle(color: Colors.red)),
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
      case 'shopping_cart': return Icons.shopping_cart_rounded;
      case 'tv': return Icons.tv_rounded;
      case 'book': return Icons.book_rounded;
      default: return Icons.list_rounded;
    }
  }
}
