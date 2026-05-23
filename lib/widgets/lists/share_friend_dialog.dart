import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/i18n/l10n_extension.dart';
import '../../data/friends/friend_model.dart';
import '../../providers/invitations/invitations_provider.dart';
import '../../providers/lists/lists_provider.dart';

/// Diálogo reutilizable que muestra la lista de amigos del usuario para invitarles
/// a colaborar en una biblioteca concreta.
///
/// Carga los colaboradores actuales al abrirse y filtra de la lista de amigos
/// a los que ya tienen acceso. El selector resalta al amigo elegido y el botón
/// de enviar permanece deshabilitado hasta que haya una selección válida.
///
/// Uso:
/// ```dart
/// showDialog(
///   context: context,
///   builder: (_) => ShareFriendDialog(
///     listId: list.id!,
///     listName: list.name,
///     friends: context.read<FriendsProvider>().friends,
///   ),
/// );
/// ```
class ShareFriendDialog extends StatefulWidget {
  /// ID de la biblioteca a compartir.
  final int listId;

  /// Nombre de la biblioteca, mostrado en el subtítulo del diálogo.
  final String listName;

  /// Lista completa de amigos confirmados del usuario autenticado.
  final List<FriendModel> friends;

  const ShareFriendDialog({
    super.key,
    required this.listId,
    required this.listName,
    required this.friends,
  });

  @override
  State<ShareFriendDialog> createState() => _ShareFriendDialogState();
}

class _ShareFriendDialogState extends State<ShareFriendDialog> {
  FriendModel? _selected;
  bool _readOnly = true;
  bool _sending = false;

  /// Nombres de usuario de los colaboradores actuales de la lista.
  /// Se carga de forma asíncrona en [initState].
  Set<String> _collaboratorNames = {};
  bool _loadingCollaborators = true;

  @override
  void initState() {
    super.initState();
    _fetchCollaborators();
  }

  /// Obtiene los colaboradores actuales para excluirlos de la lista de amigos seleccionables.
  Future<void> _fetchCollaborators() async {
    try {
      final list = await context
          .read<ListsProvider>()
          .getCollaborators(widget.listId);
      if (mounted) {
        setState(() {
          _collaboratorNames = list.map((c) => c.username).toSet();
          _loadingCollaborators = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingCollaborators = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final invitable = widget.friends
        .where((f) => !_collaboratorNames.contains(f.username))
        .toList();

    return AlertDialog(
      title: Text(context.l10n.shareInviteFriendTitle),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lista: "${widget.listName}"',
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 14),
            if (_loadingCollaborators)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (widget.friends.isEmpty)
              _HintRow(
                icon: Icons.people_outline,
                text: context.l10n.shareNoFriendsHint,
              )
            else if (invitable.isEmpty)
              _HintRow(
                icon: Icons.check_circle_outline,
                text: context.l10n.shareAllFriendsCollaborating,
              )
            else ...[
              Text(
                context.l10n.shareSelectFriend,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 240),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: invitable.length,
                  itemBuilder: (_, i) {
                    final f = invitable[i];
                    final isSelected = _selected?.id == f.id;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      margin: const EdgeInsets.only(bottom: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? scheme.primaryContainer.withValues(alpha: 0.5)
                            : scheme.surfaceContainerHighest
                                .withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? scheme.primary
                              : scheme.outlineVariant.withValues(alpha: 0.4),
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: ListTile(
                        dense: true,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        leading: _FriendAvatar(f: f, scheme: scheme),
                        title: Text(
                          f.username,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected ? scheme.primary : null,
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(Icons.check_circle_rounded,
                                color: scheme.primary, size: 20)
                            : null,
                        onTap: () => setState(() => _selected = f),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      context.l10n.shareReadOnlyLabel,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  Switch(
                    value: _readOnly,
                    onChanged: (v) => setState(() => _readOnly = v),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.commonCancel),
        ),
        if (!_loadingCollaborators && invitable.isNotEmpty)
          FilledButton(
            onPressed: (_selected == null || _sending) ? null : _send,
            child: _sending
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    _selected != null
                        ? context.l10n.shareInviteAction(_selected!.username)
                        : context.l10n.shareSelectOne,
                  ),
          ),
      ],
    );
  }

  Future<void> _send() async {
    if (_selected == null) return;
    setState(() => _sending = true);
    final success = await context.read<InvitationsProvider>().sendInvitation(
          widget.listId,
          _selected!.username,
          _readOnly,
        );
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? context.l10n.shareInviteSentTo(_selected!.username)
              : context.l10n.shareInviteError,
        ),
      ),
    );
  }
}

/// Avatar circular con foto de perfil o inicial del username.
class _FriendAvatar extends StatelessWidget {
  final FriendModel f;
  final ColorScheme scheme;

  const _FriendAvatar({required this.f, required this.scheme});

  @override
  Widget build(BuildContext context) {
    if (f.photoUrl != null && f.photoUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 18,
        backgroundImage: NetworkImage(f.photoUrl!),
        backgroundColor: scheme.primaryContainer,
      );
    }
    return CircleAvatar(
      radius: 18,
      backgroundColor: scheme.primaryContainer,
      child: Text(
        f.username[0].toUpperCase(),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: scheme.onPrimaryContainer,
        ),
      ),
    );
  }
}

/// Fila de aviso con icono y texto descriptivo para estados vacíos o informativos.
class _HintRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _HintRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
