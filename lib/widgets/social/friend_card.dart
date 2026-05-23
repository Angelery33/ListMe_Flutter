import 'package:flutter/material.dart';
import 'package:list_me/data/friends/friend_model.dart';

/// Tarjeta visual que representa un amigo del usuario en la pantalla social.
///
/// Muestra el avatar del amigo (foto de perfil o inicial), su nombre de usuario
/// y sus estadísticas de uso: número de listas e ítems totales.
/// El botón de menú contextual expone la opción de eliminar la amistad.
class FriendCard extends StatelessWidget {
  /// El modelo del amigo cuyos datos se renderizan en la tarjeta.
  final FriendModel friend;

  /// Llamada de retorno para la acción de eliminar la amistad. Cuando es `null`,
  /// la opción de eliminar no se muestra.
  final VoidCallback? onRemove;

  const FriendCard({super.key, required this.friend, this.onRemove});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      elevation: isDark ? 4 : 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _buildAvatar(scheme),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    friend.username,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildStat(
                        context,
                        icon: Icons.list_alt_rounded,
                        value: friend.totalLibraries.toString(),
                        label: '',
                      ),
                      const SizedBox(width: 16),
                      _buildStat(
                        context,
                        icon: Icons.check_circle_outline,
                        value: friend.totalItems.toString(),
                        label: '',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (onRemove != null)
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: scheme.onSurfaceVariant),
                onSelected: (value) {
                  if (value == 'remove') onRemove!();
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'remove',
                    child: Row(
                      children: [
                        Icon(Icons.person_remove_outlined, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Eliminar amigo', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  /// Construye el avatar circular con la foto de perfil o la inicial del nombre de usuario.
  Widget _buildAvatar(ColorScheme scheme) {
    if (friend.photoUrl != null && friend.photoUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 28,
        backgroundImage: NetworkImage(friend.photoUrl!),
        backgroundColor: scheme.primaryContainer,
      );
    }
    return CircleAvatar(
      radius: 28,
      backgroundColor: scheme.primaryContainer,
      child: Text(
        friend.username[0].toUpperCase(),
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: scheme.onPrimaryContainer,
        ),
      ),
    );
  }

  /// Construye una pequeña estadística con icono, valor numérico y etiqueta descriptiva.
  Widget _buildStat(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
  }) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.primary),
        const SizedBox(width: 4),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 2),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
