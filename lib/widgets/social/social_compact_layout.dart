import 'package:flutter/material.dart';
import 'package:list_me/core/i18n/l10n_extension.dart';
import 'package:list_me/core/theme/theme.dart';
import 'package:list_me/providers/friends/friends_provider.dart';
import 'package:list_me/providers/invitations/invitations_provider.dart';
import 'package:list_me/widgets/shared/app_shell.dart';
import 'package:list_me/widgets/shared/custom_gradient_app_bar.dart';
import 'package:list_me/widgets/social/friend_card.dart';
import 'package:list_me/widgets/social/social_dialogs.dart';
import 'package:list_me/widgets/social/social_invitation_tile.dart';
import 'package:list_me/widgets/social/social_request_tile.dart';
import 'package:list_me/widgets/social/social_shared_widgets.dart';

/// Layout con [TabBar] para móvil y tablet (< 840 dp).
///
/// Tres pestañas: Amigos, Solicitudes e Invitaciones.
/// Los badges de las pestañas 2 y 3 muestran el contador de elementos pendientes.
class SocialCompactLayout extends StatelessWidget {
  final FriendsProvider friends;
  final InvitationsProvider invitations;

  const SocialCompactLayout({
    super.key,
    required this.friends,
    required this.invitations,
  });

  @override
  Widget build(BuildContext context) {
    final fgColor = AppTheme.appBarUsesDarkText(context) ? Colors.black : Colors.white;

    return DefaultTabController(
      length: 3,
      child: AppShell(
        currentIndex: 3,
        appBar: CustomGradientAppBar(
          title: context.l10n.socialTitle,
          showBackButton: false,
          bottom: TabBar(
            labelColor: fgColor,
            unselectedLabelColor: fgColor.withValues(alpha: 0.6),
            indicatorColor: fgColor,
            tabs: [
              Tab(
                text: context.l10n.socialFriendsTab,
                icon: const Icon(Icons.people_outline),
              ),
              Tab(
                text: context.l10n.socialRequestsTab,
                icon: SocialTabIconWithBadge(
                  icon: Icons.person_add_outlined,
                  count: friends.pendingCount,
                ),
              ),
              Tab(
                text: context.l10n.socialInvitationsTab,
                icon: SocialTabIconWithBadge(
                  icon: Icons.mail_outline_rounded,
                  count: invitations.pendingCount,
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _MobileFriendsTab(friends: friends),
            _MobileFriendRequestsTab(friends: friends),
            _MobileInvitationsTab(invitations: invitations),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TABS MÓVIL
// ─────────────────────────────────────────────────────────────────────────────

/// Tab de amigos con pull-to-refresh y FAB para añadir nuevos.
class _MobileFriendsTab extends StatelessWidget {
  final FriendsProvider friends;

  const _MobileFriendsTab({required this.friends});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: friends.loadAll,
      child: friends.isLoading
          ? const Center(child: CircularProgressIndicator())
          : friends.friends.isEmpty
              ? _buildEmpty(context, theme)
              : _buildList(context),
    );
  }

  Widget _buildEmpty(BuildContext context, ThemeData theme) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.55,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.people_outline,
                  size: 72,
                  color: theme.colorScheme.onSurfaceVariant
                      .withValues(alpha: 0.25),
                ),
                const SizedBox(height: 16),
                Text(
                  context.l10n.socialNoFriendsTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: () => showAddFriendDialog(context, friends),
                  icon: const Icon(Icons.person_add_outlined),
                  label: Text(context.l10n.socialAddFriend),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildList(BuildContext context) {
    return Stack(
      children: [
        ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
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
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton.extended(
            onPressed: () => showAddFriendDialog(context, friends),
            icon: const Icon(Icons.person_add_outlined),
            label: Text(context.l10n.socialAddShort),
          ),
        ),
      ],
    );
  }
}

/// Tab de solicitudes de amistad pendientes.
class _MobileFriendRequestsTab extends StatelessWidget {
  final FriendsProvider friends;

  const _MobileFriendRequestsTab({required this.friends});

  @override
  Widget build(BuildContext context) {
    if (friends.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (friends.pendingRequests.isEmpty) {
      return SocialSectionEmpty(
        icon: Icons.people_outline,
        message: context.l10n.socialNoPendingRequests,
        large: true,
      );
    }
    return RefreshIndicator(
      onRefresh: friends.loadAll,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: friends.pendingRequests.length,
        itemBuilder: (_, i) {
          final r = friends.pendingRequests[i];
          return SocialFriendRequestTile(
            request: r,
            onAccept: () => friends.acceptRequest(r.id),
            onReject: () => friends.rejectRequest(r.id),
          );
        },
      ),
    );
  }
}

/// Tab de invitaciones a listas de colaboración pendientes.
class _MobileInvitationsTab extends StatelessWidget {
  final InvitationsProvider invitations;

  const _MobileInvitationsTab({required this.invitations});

  @override
  Widget build(BuildContext context) {
    if (invitations.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (invitations.pendingInvitations.isEmpty) {
      return SocialSectionEmpty(
        icon: Icons.inbox_outlined,
        message: context.l10n.socialNoPendingInvitations,
        large: true,
      );
    }
    return RefreshIndicator(
      onRefresh: invitations.loadPendingInvitations,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: invitations.pendingInvitations.length,
        itemBuilder: (_, i) => SocialInvitationTile(
          invitation: invitations.pendingInvitations[i],
        ),
      ),
    );
  }
}
