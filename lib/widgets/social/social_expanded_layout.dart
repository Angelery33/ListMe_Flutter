import 'package:flutter/material.dart';
import 'package:list_me/core/i18n/l10n_extension.dart';
import 'package:list_me/providers/friends/friends_provider.dart';
import 'package:list_me/providers/invitations/invitations_provider.dart';
import 'package:list_me/widgets/shared/app_shell.dart';
import 'package:list_me/widgets/shared/custom_gradient_app_bar.dart';
import 'package:list_me/widgets/social/friend_card.dart';
import 'package:list_me/widgets/social/social_dialogs.dart';
import 'package:list_me/widgets/social/social_invitation_tile.dart';
import 'package:list_me/widgets/social/social_request_tile.dart';
import 'package:list_me/widgets/social/social_shared_widgets.dart';

/// Layout web de tres columnas para la pantalla social (≥ 840 dp).
///
/// - **Izquierda** (280 dp): lista de amigos confirmados dentro de una card.
/// - **Centro** (flexible): feed de actividad (próximamente).
/// - **Derecha** (300 dp): solicitudes de amistad e invitaciones a listas.
///
/// El padding lateral de 24 dp separa las columnas extremas del borde de la
/// ventana; el padding superior de 20 dp aleja el contenido del AppBar.
class SocialExpandedLayout extends StatelessWidget {
  final FriendsProvider friends;
  final InvitationsProvider invitations;

  const SocialExpandedLayout({
    super.key,
    required this.friends,
    required this.invitations,
  });

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentIndex: 3,
      appBar: CustomGradientAppBar(
        title: context.l10n.socialTitle,
        showBackButton: false,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(64, 50, 64, 30),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Columna izquierda: amigos (20 %) ──────────────────────────
            Expanded(
              flex: 25,
              child: _FriendsPanel(friends: friends),
            ),
            const SizedBox(width: 16),
            // ── Columna central: feed (50 %) ───────────────────────────────
            const Expanded(
              flex: 50,
              child: _FeedPanel(),
            ),
            const SizedBox(width: 16),
            // ── Columna derecha: solicitudes e invitaciones (25 %) ────────
            Expanded(
              flex: 25,
              child: _RightSidePanel(
                friends: friends,
                invitations: invitations,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// COLUMNA IZQUIERDA
// ─────────────────────────────────────────────────────────────────────────────

/// Card con la lista de amigos confirmados y botón para añadir nuevos.
class _FriendsPanel extends StatelessWidget {
  final FriendsProvider friends;

  const _FriendsPanel({required this.friends});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Encabezado ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    '${context.l10n.socialFriendsTab.toUpperCase()} (${friends.friends.length})',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: () => showAddFriendDialog(context, friends),
                  icon: const Icon(Icons.person_add_outlined, size: 18),
                  tooltip: context.l10n.socialAddFriend,
                  style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.secondaryContainer,
                    foregroundColor: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
              ],
            ),
          ),
          // ── Lista ──────────────────────────────────────────────────────
          Expanded(
            child: RefreshIndicator(
              onRefresh: friends.loadAll,
              child: friends.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : friends.friends.isEmpty
                      ? _buildEmpty(context, theme)
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding:
                              const EdgeInsets.fromLTRB(8, 8, 8, 24),
                          itemCount: friends.friends.length,
                          itemBuilder: (_, i) => FriendCard(
                            friend: friends.friends[i],
                            onRemove: () => confirmRemoveFriend(
                              context,
                              friends.friends[i].username,
                              friends,
                            ),
                          ),
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(BuildContext context, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.people_outline,
            size: 72,
            color:
                theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.25),
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.socialNoFriendsTitle,
            style: theme.textTheme.titleMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.shareNoFriendsHint,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant
                  .withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// COLUMNA CENTRAL
// ─────────────────────────────────────────────────────────────────────────────

/// Placeholder del feed de actividad de amigos (funcionalidad futura).
class _FeedPanel extends StatelessWidget {
  const _FeedPanel();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.dynamic_feed_outlined,
              size: 64,
              color:
                  theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.25),
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.socialFeedComingSoon,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant
                    .withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// COLUMNA DERECHA
// ─────────────────────────────────────────────────────────────────────────────

/// Columna derecha con dos [SocialFloatingCard]: solicitudes de amistad e
/// invitaciones a listas. Tiene scroll propio para no bloquear el resto del layout.
class _RightSidePanel extends StatelessWidget {
  final FriendsProvider friends;
  final InvitationsProvider invitations;

  const _RightSidePanel({
    required this.friends,
    required this.invitations,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        children: [
          // ── Solicitudes de amistad ─────────────────────────────────────
          SocialFloatingCard(
            header: SocialSectionHeader(
              icon: Icons.person_add_outlined,
              title: context.l10n.socialRequestsTab,
              badge: friends.pendingCount,
            ),
            child: friends.isLoading
                ? const SocialSectionLoading()
                : friends.pendingRequests.isEmpty
                    ? SocialSectionEmpty(
                        icon: Icons.people_outline,
                        message: context.l10n.socialNoPendingRequests,
                      )
                    : Column(
                        children: friends.pendingRequests
                            .map((r) => SocialFriendRequestTile(
                                  request: r,
                                  onAccept: () => friends.acceptRequest(r.id),
                                  onReject: () => friends.rejectRequest(r.id),
                                ))
                            .toList(),
                      ),
          ),
          const SizedBox(height: 16),
          // ── Invitaciones a listas ──────────────────────────────────────
          SocialFloatingCard(
            header: SocialSectionHeader(
              icon: Icons.mail_outline_rounded,
              title: context.l10n.socialInvitationsTab,
              badge: invitations.pendingCount,
            ),
            child: invitations.isLoading
                ? const SocialSectionLoading()
                : invitations.pendingInvitations.isEmpty
                    ? SocialSectionEmpty(
                        icon: Icons.inbox_outlined,
                        message: context.l10n.socialNoPendingInvitations,
                      )
                    : Column(
                        children: invitations.pendingInvitations
                            .map((inv) =>
                                SocialInvitationTile(invitation: inv))
                            .toList(),
                      ),
          ),
        ],
      ),
    );
  }
}
