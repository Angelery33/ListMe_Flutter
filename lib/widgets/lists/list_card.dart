import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/i18n/l10n_extension.dart';
import '../../data/lists/list_model.dart';
import '../../core/theme/theme.dart';
import '../../providers/invitations/invitations_provider.dart';

/// Tarjeta visual que representa una lista del usuario en el listado principal.
class ListCard extends StatefulWidget {
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
  State<ListCard> createState() => _ListCardState();
}

class _ListCardState extends State<ListCard> {
  void _showShareDialog() {
    final usernameController = TextEditingController();
    bool readOnly = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(ctx.l10n.listsShareTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${ctx.l10n.listsShareMessage} "${widget.list.name}"'),
              const SizedBox(height: 16),
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: ctx.l10n.listsShareEmail,
                  hintText: "Nombre de usuario",
                ),
              ),
              const SizedBox(height: 12),
              CheckboxListTile(
                title: const Text("Solo lectura"),
                value: readOnly,
                onChanged: (v) => setState(() => readOnly = v ?? true),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(ctx.l10n.commonCancel.toUpperCase()),
            ),
            TextButton(
              onPressed: () async {
                final username = usernameController.text.trim();
                if (username.isNotEmpty) {
                  Navigator.pop(ctx);
                  final success = await context.read<InvitationsProvider>().sendInvitation(
                    widget.list.id!,
                    username,
                    readOnly,
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(success 
                          ? context.l10n.listsInviteSent 
                          : "Error al enviar invitación"),
                      ),
                    );
                  }
                }
              },
              child: Text(ctx.l10n.commonSend.toUpperCase()),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final scheme = theme.colorScheme;
    final accentColor = AppTheme.getPrimaryColor(widget.list.color, theme.brightness);
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
        onTap: widget.onTap,
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
                  _getIconData(widget.list.icon),
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
                                widget.list.name,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${widget.list.itemCount} ${widget.list.itemCount == 1 ? context.l10n.commonItem : context.l10n.commonItems}',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.7),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (widget.list.isShared) ...[
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
                    if (widget.list.description != null &&
                        widget.list.description!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          widget.list.description!,
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
                  if (value == 'edit') widget.onEdit?.call();
                  if (value == 'delete') widget.onDelete?.call();
                  if (value == 'share') widget.onShare?.call();
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
                  if (widget.list.owner)
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
