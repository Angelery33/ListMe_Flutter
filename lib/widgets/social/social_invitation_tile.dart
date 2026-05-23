import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:list_me/core/i18n/l10n_extension.dart';
import 'package:list_me/data/invitations/invitation_model.dart';
import 'package:list_me/providers/invitations/invitations_provider.dart';
import 'package:list_me/providers/lists/lists_provider.dart';

/// Tile de invitación a lista de colaboración con botones de aceptar y rechazar.
///
/// Al aceptar refresca [ListsProvider] para que la nueva biblioteca aparezca
/// inmediatamente en el drawer. Muestra spinners individuales para cada botón
/// y los desactiva mutuamente mientras una operación está en curso.
class SocialInvitationTile extends StatefulWidget {
  final InvitationModel invitation;

  const SocialInvitationTile({super.key, required this.invitation});

  @override
  State<SocialInvitationTile> createState() => _SocialInvitationTileState();
}

class _SocialInvitationTileState extends State<SocialInvitationTile> {
  bool _accepting = false;
  bool _rejecting = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final inv = widget.invitation;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.15)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Remitente ──────────────────────────────────────────────────
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: scheme.secondaryContainer,
                  child: Text(
                    inv.senderUsername[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: scheme.onSecondaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        inv.senderUsername,
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        context.l10n.socialInvitesYouToCollaborate,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // ── Nombre de la biblioteca + rol ──────────────────────────────
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.list_alt_rounded,
                      size: 14, color: scheme.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      inv.libraryName,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: inv.readOnly
                          ? scheme.tertiaryContainer
                          : scheme.primaryContainer,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      inv.readOnly
                          ? context.l10n.socialRoleReader
                          : context.l10n.socialRoleEditor,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: inv.readOnly
                            ? scheme.onTertiaryContainer
                            : scheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // ── Acciones ───────────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _rejecting
                      ? const _Spinner()
                      : OutlinedButton(
                          onPressed: _accepting ? null : _handleReject,
                          style: OutlinedButton.styleFrom(
                            padding:
                                const EdgeInsets.symmetric(vertical: 8),
                          ),
                          child: Text(context.l10n.socialReject),
                        ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _accepting
                      ? const _Spinner()
                      : FilledButton(
                          onPressed: _rejecting ? null : _handleAccept,
                          style: FilledButton.styleFrom(
                            padding:
                                const EdgeInsets.symmetric(vertical: 8),
                          ),
                          child: Text(context.l10n.commonAccept),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleAccept() async {
    setState(() => _accepting = true);
    final provider = context.read<InvitationsProvider>();
    final success = await provider.acceptInvitation(widget.invitation.id);
    if (success && context.mounted) {
      context.read<ListsProvider>().fetchLists();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.socialInvitationAccepted)),
      );
    }
    if (mounted) setState(() => _accepting = false);
  }

  Future<void> _handleReject() async {
    setState(() => _rejecting = true);
    await context
        .read<InvitationsProvider>()
        .rejectInvitation(widget.invitation.id);
    if (mounted) setState(() => _rejecting = false);
  }
}

class _Spinner extends StatelessWidget {
  const _Spinner();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}
