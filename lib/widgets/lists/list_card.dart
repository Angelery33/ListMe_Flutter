import 'package:flutter/material.dart';
import '../../core/i18n/l10n_extension.dart';
import '../../data/lists/list_model.dart';
import '../../core/theme/theme.dart';

/// Tarjeta visual que representa una única biblioteca de usuario.
///
/// Soporta dos variantes de layout mediante [webLayout]:
/// - **Móvil** (por defecto): icono + columna con nombre, recuento y descripción opcional.
/// - **Web** ([webLayout] = `true`): icono + fila con nombre a la izquierda y recuento a la
///   derecha + descripción en una segunda línea (siempre reserva el hueco aunque esté vacía).
class ListCard extends StatelessWidget {
  final ListModel list;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onShare;

  /// Cuando es `true` usa el layout compacto de web: nombre y recuento en la
  /// misma fila, descripción debajo en una sola línea con ellipsis.
  final bool webLayout;

  const ListCard({
    super.key,
    required this.list,
    required this.onTap,
    this.onEdit,
    this.onDelete,
    this.onShare,
    this.webLayout = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final scheme = theme.colorScheme;
    final accentColor = AppTheme.getPrimaryColor(list.color, theme.brightness);
    final isTitanium = AppTheme.isTitanium(scheme);

    final cardColor = isTitanium
        ? (isDark ? const Color(0xFF2C2C2E) : Colors.white)
        : (isDark ? scheme.surface.withValues(alpha: 0.8) : scheme.surface);

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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Icono ────────────────────────────────────────────────────
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
              // ── Contenido ────────────────────────────────────────────────
              Expanded(
                child: webLayout
                    ? _WebContent(list: list, theme: theme)
                    : _MobileContent(list: list, theme: theme),
              ),
              // ── Menú 3 puntos ─────────────────────────────────────────────
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert_rounded,
                  color: scheme.onSurfaceVariant,
                ),
                onSelected: (value) {
                  if (value == 'edit') onEdit?.call();
                  if (value == 'delete') onDelete?.call();
                  if (value == 'share') onShare?.call();
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Text(context.l10n.commonEdit,
                        style: theme.textTheme.bodyMedium),
                  ),
                  if (list.owner)
                    PopupMenuItem(
                      value: 'share',
                      child: Text(context.l10n.commonShare,
                          style: theme.textTheme.bodyMedium),
                    ),
                  if (list.owner)
                    PopupMenuItem(
                      value: 'delete',
                      child: Text(
                        context.l10n.commonDelete,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: scheme.error),
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
      case 'shopping_cart': return Icons.shopping_cart_rounded;
      case 'tv':            return Icons.tv_rounded;
      case 'book':          return Icons.book_rounded;
      case 'movie':         return Icons.movie_rounded;
      case 'games':         return Icons.sports_esports_rounded;
      case 'music':         return Icons.music_note_rounded;
      case 'restaurant':    return Icons.restaurant_rounded;
      case 'work':          return Icons.work_rounded;
      case 'fitness':       return Icons.fitness_center_rounded;
      case 'home':          return Icons.home_rounded;
      case 'favorite':      return Icons.favorite_rounded;
      default:              return Icons.list_rounded;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// VARIANTE WEB
// ─────────────────────────────────────────────────────────────────────────────

/// Layout web: nombre + recuento en la misma fila; descripción debajo (1 línea).
///
/// Las tarjetas sin descripción reservan igualmente el espacio de una línea para
/// que todas las cards de una fila tengan la misma altura.
class _WebContent extends StatelessWidget {
  final ListModel list;
  final ThemeData theme;

  const _WebContent({required this.list, required this.theme});

  @override
  Widget build(BuildContext context) {
    final onSurface = theme.colorScheme.onSurfaceVariant;
    final countLabel =
        '${list.itemCount} ${list.itemCount == 1 ? context.l10n.commonItem : context.l10n.commonItems}';

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Fila: nombre | [compartido] | recuento ─────────────────────
        Row(
          children: [
            Expanded(
              child: Text(
                list.name,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (list.isShared) ...[
              const SizedBox(width: 6),
              Icon(Icons.people_alt_rounded,
                  size: 16, color: onSurface.withValues(alpha: 0.6)),
            ],
            const SizedBox(width: 8),
            Text(
              countLabel,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: onSurface.withValues(alpha: 0.7)),
            ),
          ],
        ),
        const SizedBox(height: 2),
        // ── Fila: descripción | badge propietario ──────────────────────
        Row(
          children: [
            Expanded(
              child: Text(
                list.description ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: onSurface.withValues(alpha: 0.8)),
              ),
            ),
            if (!list.owner) ...[
              const SizedBox(width: 6),
              _OwnerBadge(theme: theme, ownerUsername: list.ownerUsername),
            ],
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// VARIANTE MÓVIL
// ─────────────────────────────────────────────────────────────────────────────

/// Layout móvil: nombre encima, recuento debajo, descripción opcional en 2 líneas.
class _MobileContent extends StatelessWidget {
  final ListModel list;
  final ThemeData theme;

  const _MobileContent({required this.list, required this.theme});

  @override
  Widget build(BuildContext context) {
    final onSurface = theme.colorScheme.onSurfaceVariant;

    return Column(
      mainAxisSize: MainAxisSize.min,
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
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${list.itemCount} ${list.itemCount == 1 ? context.l10n.commonItem : context.l10n.commonItems}',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: onSurface.withValues(alpha: 0.7)),
                  ),
                ],
              ),
            ),
            if (list.isShared) ...[
              const SizedBox(width: 8),
              Icon(Icons.people_alt_rounded,
                  size: 18, color: onSurface.withValues(alpha: 0.6)),
            ],
            if (!list.owner) ...[
              const SizedBox(width: 8),
              _OwnerBadge(theme: theme, ownerUsername: list.ownerUsername),
            ],
          ],
        ),
        if (list.description != null && list.description!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              list.description!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: onSurface),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BADGE PROPIETARIO
// ─────────────────────────────────────────────────────────────────────────────

/// Chip pequeño que muestra el nombre del propietario de una lista ajena.
class _OwnerBadge extends StatelessWidget {
  final String? ownerUsername;
  final ThemeData theme;

  const _OwnerBadge({required this.theme, this.ownerUsername});

  @override
  Widget build(BuildContext context) {
    final scheme = theme.colorScheme;
    final label = ownerUsername != null ? '@$ownerUsername' : context.l10n.listOwnerCollaborator;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: scheme.onSecondaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
