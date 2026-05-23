import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/i18n/l10n_extension.dart';
import '../../../data/friends/friend_model.dart';
import '../../../data/lists/collaborator_model.dart';
import '../../../providers/friends/friends_provider.dart';
import '../../../providers/invitations/invitations_provider.dart';
import '../../../providers/lists/lists_provider.dart';

/// Sección de la pantalla de configuración que permite al propietario invitar
/// colaboradores eligiendo entre sus amigos, y ver/eliminar los ya existentes.
///
/// Solo se renderiza cuando el usuario es propietario y la biblioteca ya tiene [libraryId].
/// En lugar de escribir un nombre de usuario, se muestra la lista de amigos filtrando
/// los que ya son colaboradores de esta biblioteca.
class ConfigCollaborationSection extends StatefulWidget {
  /// ID del servidor de la biblioteca. `null` oculta la sección (lista no guardada aún).
  final int? libraryId;

  /// `true` cuando el usuario actual es el propietario de la biblioteca.
  final bool isOwner;

  const ConfigCollaborationSection({
    super.key,
    required this.libraryId,
    required this.isOwner,
  });

  @override
  State<ConfigCollaborationSection> createState() =>
      _ConfigCollaborationSectionState();
}

class _ConfigCollaborationSectionState
    extends State<ConfigCollaborationSection> {
  /// Si el colaborador invitado tendrá solo lectura. Valor por defecto seguro.
  bool _isReadOnly = true;

  /// Amigo seleccionado para invitar, o `null` si aún no se ha elegido ninguno.
  FriendModel? _selectedFriend;

  /// Lista de colaboradores activos cargada desde el servidor.
  List<CollaboratorModel> _collaborators = [];

  /// Indica si la lista de colaboradores se está cargando.
  bool _loadingCollaborators = false;

  @override
  void initState() {
    super.initState();
    if (widget.isOwner && widget.libraryId != null) {
      _loadCollaborators();
    }
  }

  /// Obtiene los colaboradores actuales de la biblioteca desde el servidor.
  Future<void> _loadCollaborators() async {
    setState(() => _loadingCollaborators = true);
    try {
      final list = await context
          .read<ListsProvider>()
          .getCollaborators(widget.libraryId!);
      if (mounted) setState(() => _collaborators = list);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loadingCollaborators = false);
    }
  }

  /// Envía la invitación al amigo seleccionado con el permiso configurado.
  Future<void> _sendInvitation() async {
    if (_selectedFriend == null || widget.libraryId == null) return;

    final provider = context.read<InvitationsProvider>();
    final success = await provider.sendInvitation(
      widget.libraryId!,
      _selectedFriend!.username,
      _isReadOnly,
    );

    if (mounted) {
      if (success) {
        setState(() => _selectedFriend = null);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.listsInviteSent)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${context.l10n.commonError}: ${provider.error ?? context.l10n.collaborationSendErrorGeneric}'),
          ),
        );
      }
    }
  }

  /// Muestra un diálogo de confirmación y elimina al [collaborator] de la biblioteca.
  Future<void> _confirmRemove(CollaboratorModel collaborator) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ctx.l10n.collaborationRemoveTitle),
        content: Text(ctx.l10n.collaborationRemoveConfirm(collaborator.username)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(ctx.l10n.commonCancel.toUpperCase()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              ctx.l10n.commonDelete.toUpperCase(),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final ok = await context
        .read<ListsProvider>()
        .removeCollaborator(widget.libraryId!, collaborator.userId);

    if (mounted) {
      if (ok) {
        setState(() =>
            _collaborators.removeWhere((c) => c.userId == collaborator.userId));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.collaborationRemoveSuccess(collaborator.username)),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.collaborationRemoveError)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isOwner || widget.libraryId == null) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final allFriends = context.watch<FriendsProvider>().friends;

    // Filtra los amigos que ya son colaboradores de esta lista.
    final collaboratorUsernames =
        _collaborators.map((c) => c.username).toSet();
    final invitableFriends = allFriends
        .where((f) => !collaboratorUsernames.contains(f.username))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            context.l10n.collaborationTitle,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Colaboradores actuales ─────────────────────────────────
                if (_loadingCollaborators)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_collaborators.isNotEmpty) ...[
                  Text(
                    context.l10n.collaborationCurrentCollaborators,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._collaborators.map(
                    (c) => ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: _FriendAvatar(
                        username: c.username,
                        photoUrl: null,
                        radius: 16,
                      ),
                      title: Text(c.username,
                          style: theme.textTheme.bodyMedium),
                      subtitle: Text(
                        c.isEditor ? context.l10n.collaborationRoleEditor : context.l10n.collaborationRoleReadOnly,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.person_remove_outlined,
                            color: Colors.red, size: 20),
                        tooltip: context.l10n.collaborationRemoveTooltip,
                        onPressed: () => _confirmRemove(c),
                      ),
                    ),
                  ),
                  const Divider(height: 24),
                ],

                // ── Selector de amigos para invitar ───────────────────────
                Text(
                  context.l10n.collaborationInviteFriend,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),

                if (allFriends.isEmpty)
                  // Sin amigos aún
                  _EmptyFriendsHint()
                else if (invitableFriends.isEmpty)
                  // Todos los amigos ya son colaboradores
                  _AllFriendsAdded()
                else ...[
                  // Lista de amigos seleccionables
                  SizedBox(
                    height: invitableFriends.length > 3 ? 220 : null,
                    child: _FriendPickerList(
                      friends: invitableFriends,
                      selected: _selectedFriend,
                      onSelect: (f) => setState(() => _selectedFriend = f),
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Permiso
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          context.l10n.collaborationReadOnlyPermission,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      Switch(
                        value: _isReadOnly,
                        onChanged: (val) => setState(() => _isReadOnly = val),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Botón enviar
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _selectedFriend != null
                          ? _sendInvitation
                          : null,
                      icon: const Icon(Icons.send_rounded),
                      label: Text(
                        _selectedFriend != null
                            ? context.l10n.shareInviteAction(_selectedFriend!.username)
                            : context.l10n.shareSelectFriend,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 8),
                Text(
                  context.l10n.collaborationInfoNote,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WIDGETS INTERNOS
// ─────────────────────────────────────────────────────────────────────────────

/// Lista scrollable de amigos seleccionables para invitar a la biblioteca.
///
/// Cada tile muestra el avatar del amigo y su username. El seleccionado
/// se resalta con el color primario y un icono de check.
class _FriendPickerList extends StatelessWidget {
  final List<FriendModel> friends;
  final FriendModel? selected;
  final ValueChanged<FriendModel> onSelect;

  const _FriendPickerList({
    required this.friends,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return ListView.builder(
      shrinkWrap: true,
      physics: friends.length > 3
          ? const ClampingScrollPhysics()
          : const NeverScrollableScrollPhysics(),
      itemCount: friends.length,
      itemBuilder: (_, i) {
        final friend = friends[i];
        final isSelected = selected?.id == friend.id;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.only(bottom: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? scheme.primaryContainer.withValues(alpha: 0.5)
                : scheme.surfaceContainerHighest.withValues(alpha: 0.3),
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
            leading: _FriendAvatar(
              username: friend.username,
              photoUrl: friend.photoUrl,
              radius: 18,
            ),
            title: Text(
              friend.username,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? scheme.primary : null,
              ),
            ),
            trailing: isSelected
                ? Icon(Icons.check_circle_rounded,
                    color: scheme.primary, size: 20)
                : null,
            onTap: () => onSelect(friend),
          ),
        );
      },
    );
  }
}

/// Avatar circular con foto de perfil o inicial del username.
class _FriendAvatar extends StatelessWidget {
  final String username;
  final String? photoUrl;
  final double radius;

  const _FriendAvatar({
    required this.username,
    required this.photoUrl,
    this.radius = 20,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (photoUrl != null && photoUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(photoUrl!),
        backgroundColor: scheme.primaryContainer,
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: scheme.primaryContainer,
      child: Text(
        username[0].toUpperCase(),
        style: TextStyle(
          fontSize: radius * 0.8,
          fontWeight: FontWeight.bold,
          color: scheme.onPrimaryContainer,
        ),
      ),
    );
  }
}

/// Hint que se muestra cuando el usuario no tiene amigos aún.
class _EmptyFriendsHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(Icons.people_outline,
              size: 20, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              context.l10n.collaborationNoFriendsHint,
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

/// Mensaje que se muestra cuando todos los amigos ya son colaboradores.
class _AllFriendsAdded extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline,
              size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              context.l10n.collaborationAllAdded,
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
