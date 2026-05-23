import 'package:flutter/material.dart';
import 'package:list_me/core/i18n/l10n_extension.dart';

/// Tile de solicitud de amistad pendiente con botones de aceptar y rechazar.
///
/// Muestra indicadores de carga individuales por botón mientras la operación
/// está en curso para evitar doble pulsación. Acepta cualquier objeto que exponga
/// los campos [senderPhotoUrl] y [senderUsername] vía duck-typing (dynamic).
class SocialFriendRequestTile extends StatefulWidget {
  final dynamic request;
  final Future<bool> Function() onAccept;
  final Future<bool> Function() onReject;

  const SocialFriendRequestTile({
    super.key,
    required this.request,
    required this.onAccept,
    required this.onReject,
  });

  @override
  State<SocialFriendRequestTile> createState() =>
      _SocialFriendRequestTileState();
}

class _SocialFriendRequestTileState extends State<SocialFriendRequestTile> {
  bool _accepting = false;
  bool _rejecting = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final photoUrl = widget.request.senderPhotoUrl as String?;
    final username = widget.request.senderUsername as String;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.15)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            _buildAvatar(photoUrl, username, scheme),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    username,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    context.l10n.socialWantsToBeYourFriend,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            _accepting
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : IconButton(
                    icon: const Icon(Icons.check_circle_outline),
                    color: Colors.green,
                    tooltip: context.l10n.commonAccept,
                    onPressed: _rejecting ? null : _handleAccept,
                  ),
            _rejecting
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : IconButton(
                    icon: const Icon(Icons.cancel_outlined),
                    color: scheme.error,
                    tooltip: context.l10n.socialReject,
                    onPressed: _accepting ? null : _handleReject,
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(String? photoUrl, String username, ColorScheme scheme) {
    if (photoUrl != null && photoUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 20,
        backgroundImage: NetworkImage(photoUrl),
        backgroundColor: scheme.primaryContainer,
      );
    }
    return CircleAvatar(
      radius: 20,
      backgroundColor: scheme.primaryContainer,
      child: Text(
        username[0].toUpperCase(),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: scheme.onPrimaryContainer,
        ),
      ),
    );
  }

  Future<void> _handleAccept() async {
    setState(() => _accepting = true);
    await widget.onAccept();
    if (mounted) setState(() => _accepting = false);
  }

  Future<void> _handleReject() async {
    setState(() => _rejecting = true);
    await widget.onReject();
    if (mounted) setState(() => _rejecting = false);
  }
}
