import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:list_me/core/i18n/l10n_extension.dart';
import 'package:list_me/providers/friends/friends_provider.dart';
import 'package:list_me/widgets/shared/custom_gradient_app_bar.dart';
import 'package:list_me/widgets/shared/app_shell.dart';
import 'package:list_me/widgets/shared/responsive_centered_content.dart';
import 'package:list_me/widgets/social/friend_card.dart';
import 'package:list_me/screens/social/friend_requests_screen.dart';

/// Pantalla social que muestra la lista de amigos del usuario autenticado.
///
/// Ofrece acceso a las solicitudes de amistad pendientes (con badge de contador),
/// un botón de añadir amigo y tarjetas con las estadísticas de cada amigo confirmado.
class SocialScreen extends StatelessWidget {
  const SocialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final friends = context.watch<FriendsProvider>();

    if (friends.isLoading) {
      return AppShell(
        currentIndex: 3,
        appBar: CustomGradientAppBar(
          title: context.l10n.socialTitle,
          showBackButton: false,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return AppShell(
      currentIndex: 3,
      appBar: CustomGradientAppBar(
        title: context.l10n.socialTitle,
        showBackButton: false,
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.people_outline),
                tooltip: 'Solicitudes de amistad',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const FriendRequestsScreen(),
                  ),
                ).then((_) => friends.loadAll()),
              ),
              if (friends.pendingCount > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      friends.pendingCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.person_add_outlined),
            tooltip: 'Añadir amigo',
            onPressed: () => _showAddFriendDialog(context, friends),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: friends.loadAll,
        child: friends.friends.isEmpty
            ? _buildEmptyState(context, theme, friends)
            : _buildFriendsList(context, theme, friends),
      ),
    );
  }

  Widget _buildFriendsList(
    BuildContext context,
    ThemeData theme,
    FriendsProvider friends,
  ) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 12),
      children: [
        ResponsiveCenteredContent(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 12),
                child: Text(
                  'AMIGOS (${friends.friends.length})',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              ...friends.friends.map(
                (friend) => FriendCard(
                  friend: friend,
                  onRemove: () => _confirmRemoveFriend(context, friend.username, friends),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    ThemeData theme,
    FriendsProvider friends,
  ) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.people_outline,
                  size: 80,
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 20),
                Text(
                  'Aún no tienes amigos',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Añade amigos para ver sus listas e ítems',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => _showAddFriendDialog(context, friends),
                  icon: const Icon(Icons.person_add_outlined),
                  label: const Text('Añadir amigo'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Muestra un diálogo con un campo de texto para buscar un usuario por nombre
  /// y enviarle una solicitud de amistad.
  void _showAddFriendDialog(BuildContext context, FriendsProvider friends) {
    final controller = TextEditingController();
    bool sending = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Añadir amigo'),
          content: TextField(
            controller: controller,
            autofocus: true,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: 'Nombre de usuario',
              hintText: 'Escribe el username exacto',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: sending
                  ? null
                  : () async {
                      final username = controller.text.trim();
                      if (username.isEmpty) return;
                      setState(() => sending = true);
                      final success = await friends.sendRequest(username);
                      if (!ctx.mounted) return;
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            success
                                ? 'Solicitud enviada a $username'
                                : (friends.errorMessage ?? 'Error al enviar solicitud'),
                          ),
                        ),
                      );
                      if (success) friends.clearError();
                    },
              child: sending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Enviar'),
            ),
          ],
        ),
      ),
    );
  }

  /// Muestra un diálogo de confirmación antes de eliminar a [username] de la lista de amigos.
  void _confirmRemoveFriend(
    BuildContext context,
    String username,
    FriendsProvider friends,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar amigo'),
        content: Text('¿Seguro que quieres eliminar a $username de tu lista de amigos?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await friends.removeFriend(username);
              if (context.mounted && !success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(friends.errorMessage ?? 'Error al eliminar amigo'),
                  ),
                );
              }
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
