import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:list_me/data/friends/friendship_request_model.dart';
import 'package:list_me/providers/friends/friends_provider.dart';

/// Pantalla que muestra las solicitudes de amistad pendientes recibidas por el usuario.
///
/// Cada solicitud ofrece botones para aceptarla o rechazarla directamente. Al aceptar,
/// el remitente pasa a formar parte de la lista de amigos del usuario autenticado.
class FriendRequestsScreen extends StatelessWidget {
  const FriendRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final friends = context.watch<FriendsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitudes de amistad'),
        centerTitle: true,
      ),
      body: friends.isLoading
          ? const Center(child: CircularProgressIndicator())
          : friends.pendingRequests.isEmpty
              ? _buildEmpty(theme)
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: friends.pendingRequests.length,
                  itemBuilder: (context, index) {
                    final request = friends.pendingRequests[index];
                    return _FriendRequestTile(request: request);
                  },
                ),
    );
  }

  Widget _buildEmpty(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'No tienes solicitudes pendientes',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Tile individual para una solicitud de amistad pendiente.
///
/// Muestra el avatar del remitente (foto o inicial), su nombre de usuario y la
/// fecha de envío, junto con botones de aceptar y rechazar con indicadores de carga.
class _FriendRequestTile extends StatefulWidget {
  final FriendshipRequestModel request;

  const _FriendRequestTile({required this.request});

  @override
  State<_FriendRequestTile> createState() => _FriendRequestTileState();
}

class _FriendRequestTileState extends State<_FriendRequestTile> {
  bool _accepting = false;
  bool _rejecting = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            _buildAvatar(scheme),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.request.senderUsername,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDate(widget.request.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _accepting
                    ? const SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : IconButton(
                        icon: const Icon(Icons.check_circle_outline),
                        color: Colors.green,
                        tooltip: 'Aceptar',
                        onPressed: _rejecting ? null : () => _accept(context),
                      ),
                _rejecting
                    ? const SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : IconButton(
                        icon: const Icon(Icons.cancel_outlined),
                        color: scheme.error,
                        tooltip: 'Rechazar',
                        onPressed: _accepting ? null : () => _reject(context),
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(ColorScheme scheme) {
    final photoUrl = widget.request.senderPhotoUrl;
    if (photoUrl != null && photoUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 24,
        backgroundImage: NetworkImage(photoUrl),
        backgroundColor: scheme.primaryContainer,
      );
    }
    return CircleAvatar(
      radius: 24,
      backgroundColor: scheme.primaryContainer,
      child: Text(
        widget.request.senderUsername[0].toUpperCase(),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: scheme.onPrimaryContainer,
        ),
      ),
    );
  }

  Future<void> _accept(BuildContext context) async {
    setState(() => _accepting = true);
    final provider = context.read<FriendsProvider>();
    final success = await provider.acceptRequest(widget.request.id);
    if (!mounted) return;
    setState(() => _accepting = false);
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage ?? 'Error al aceptar solicitud')),
      );
    }
  }

  Future<void> _reject(BuildContext context) async {
    setState(() => _rejecting = true);
    final provider = context.read<FriendsProvider>();
    final success = await provider.rejectRequest(widget.request.id);
    if (!mounted) return;
    setState(() => _rejecting = false);
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage ?? 'Error al rechazar solicitud')),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
