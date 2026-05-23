import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:list_me/core/i18n/l10n_extension.dart';
import 'package:list_me/core/providers/responsive_provider.dart';
import 'package:list_me/providers/friends/friends_provider.dart';
import 'package:list_me/providers/invitations/invitations_provider.dart';
import 'package:list_me/providers/lists/lists_provider.dart';
import 'package:list_me/data/invitations/invitation_model.dart';
import 'package:list_me/widgets/shared/custom_gradient_app_bar.dart';
import 'package:list_me/widgets/shared/app_shell.dart';
import 'package:list_me/widgets/social/friend_card.dart';

/// Pantalla social principal de la aplicación.
///
/// En pantallas anchas (≥ 840 dp) muestra un layout de dos columnas:
/// - **Columna izquierda** (350 dp fija): Solicitudes de amistad pendientes y
///   invitaciones a listas de colaboración.
/// - **Columna derecha** (flexible): Lista de amigos confirmados con estadísticas.
///
/// En móvil (< 840 dp) usa un [TabBar] con tres pestañas:
/// Amigos, Solicitudes y Invitaciones.
class SocialScreen extends StatefulWidget {
  const SocialScreen({super.key});

  @override
  State<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final inv = context.read<InvitationsProvider>();
      if (inv.isStale && !inv.isLoading) inv.loadPendingInvitations();
      final fr = context.read<FriendsProvider>();
      if (!fr.isLoading) fr.loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.watch<ResponsiveProvider>();
    final friends = context.watch<FriendsProvider>();
    final invitations = context.watch<InvitationsProvider>();

    if (responsive.isExpanded) {
      return _ExpandedLayout(friends: friends, invitations: invitations);
    }
    return _CompactLayout(friends: friends, invitations: invitations);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LAYOUT WEB / EXPANDED (≥ 840 dp)
// ─────────────────────────────────────────────────────────────────────────────

/// Layout web con amigos centrados (ancho limitado) y panel derecho flotante.
///
/// - **Centro**: lista de amigos con `maxWidth` de 700 dp, centrada en el espacio
///   que queda entre el NavigationRail y el panel lateral.
/// - **Derecha**: columna de 300 dp con dos cards independientes (solicitudes de
///   amistad e invitaciones a listas), cada una con scroll propio.
class _ExpandedLayout extends StatelessWidget {
  final FriendsProvider friends;
  final InvitationsProvider invitations;

  const _ExpandedLayout({required this.friends, required this.invitations});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentIndex: 3,
      appBar: CustomGradientAppBar(
        title: context.l10n.socialTitle,
        showBackButton: false,
      ),
      body: Stack(
        children: [
          // ── Lista de amigos (ocupa todo el espacio) ────────────────────────
          _FriendsPanel(friends: friends),
          // ── Cards flotantes ancladas arriba-derecha ────────────────────────
          Positioned(
            top: 16,
            right: 16,
            width: 300,
            child: _RightSidePanel(friends: friends, invitations: invitations),
          ),
        ],
      ),
    );
  }
}

/// Panel derecho con dos cards flotantes: solicitudes e invitaciones.
///
/// Cada card tiene su propio scroll interno para no bloquear la página entera.
class _RightSidePanel extends StatelessWidget {
  final FriendsProvider friends;
  final InvitationsProvider invitations;

  const _RightSidePanel({required this.friends, required this.invitations});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(0, 20, 16, 24),
      child: Column(
        children: [
          // ── Card: Solicitudes de amistad ───────────────────────────────────
          _FloatingCard(
            header: _SectionHeader(
              icon: Icons.person_add_outlined,
              title: 'Solicitudes',
              badge: friends.pendingCount,
            ),
            child: friends.isLoading
                ? const _SectionLoading()
                : friends.pendingRequests.isEmpty
                    ? const _SectionEmpty(
                        icon: Icons.people_outline,
                        message: 'Sin solicitudes pendientes',
                      )
                    : Column(
                        children: friends.pendingRequests
                            .map(
                              (r) => _FriendRequestTile(
                                request: r,
                                onAccept: () => friends.acceptRequest(r.id),
                                onReject: () => friends.rejectRequest(r.id),
                              ),
                            )
                            .toList(),
                      ),
          ),
          const SizedBox(height: 16),
          // ── Card: Invitaciones a listas ────────────────────────────────────
          _FloatingCard(
            header: _SectionHeader(
              icon: Icons.mail_outline_rounded,
              title: 'Invitaciones',
              badge: invitations.pendingCount,
            ),
            child: invitations.isLoading
                ? const _SectionLoading()
                : invitations.pendingInvitations.isEmpty
                    ? const _SectionEmpty(
                        icon: Icons.inbox_outlined,
                        message: 'Sin invitaciones pendientes',
                      )
                    : Column(
                        children: invitations.pendingInvitations
                            .map((inv) => _InvitationTile(invitation: inv))
                            .toList(),
                      ),
          ),
        ],
      ),
    );
  }
}

/// Card flotante con borde suave usada en el panel lateral derecho.
class _FloatingCard extends StatelessWidget {
  final Widget header;
  final Widget child;

  const _FloatingCard({required this.header, required this.child});

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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            header,
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

/// Panel central del layout web con la lista de amigos centrada y con ancho limitado.
class _FriendsPanel extends StatelessWidget {
  final FriendsProvider friends;

  const _FriendsPanel({required this.friends});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Encabezado ───────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 4),
          child: Row(
            children: [
              Text(
                'AMIGOS (${friends.friends.length})',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              FilledButton.tonalIcon(
                onPressed: () => _showAddFriendDialog(context, friends),
                icon: const Icon(Icons.person_add_outlined, size: 18),
                label: const Text('Añadir amigo'),
              ),
            ],
          ),
        ),
        // ── Lista ────────────────────────────────────────────────────────────
        Expanded(
          child: RefreshIndicator(
            onRefresh: friends.loadAll,
            child: friends.isLoading
                ? const Center(child: CircularProgressIndicator())
                : friends.friends.isEmpty
                    ? _buildEmptyFriends(context, theme)
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                        itemCount: friends.friends.length,
                        itemBuilder: (_, i) => FriendCard(
                          friend: friends.friends[i],
                          onRemove: () => _confirmRemove(
                            context,
                            friends.friends[i].username,
                            friends,
                          ),
                        ),
                      ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyFriends(BuildContext context, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.people_outline,
            size: 72,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.25),
          ),
          const SizedBox(height: 16),
          Text(
            'Aún no tienes amigos',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Añade amigos para ver sus estadísticas',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LAYOUT MÓVIL / COMPACT+MEDIUM (< 840 dp)
// ─────────────────────────────────────────────────────────────────────────────

/// Layout con [TabBar] para móvil y tablet.
///
/// Tres pestañas: Amigos, Solicitudes e Invitaciones.
/// Los badges muestran el número de elementos pendientes en las pestañas 2 y 3.
class _CompactLayout extends StatelessWidget {
  final FriendsProvider friends;
  final InvitationsProvider invitations;

  const _CompactLayout({required this.friends, required this.invitations});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 3,
      child: AppShell(
        currentIndex: 3,
        appBar: CustomGradientAppBar(
          title: context.l10n.socialTitle,
          showBackButton: false,
          bottom: TabBar(
            labelColor: theme.colorScheme.onPrimaryContainer,
            unselectedLabelColor:
                theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.6),
            indicatorColor: theme.colorScheme.onPrimaryContainer,
            tabs: [
              const Tab(
                text: 'Amigos',
                icon: Icon(Icons.people_outline),
              ),
              Tab(
                text: 'Solicitudes',
                icon: _TabIconWithBadge(
                  icon: Icons.person_add_outlined,
                  count: friends.pendingCount,
                ),
              ),
              Tab(
                text: 'Invitaciones',
                icon: _TabIconWithBadge(
                  icon: Icons.mail_outline_rounded,
                  count: invitations.pendingCount,
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // ── Tab 1: Amigos ────────────────────────────────────────────────
            _MobileFriendsTab(friends: friends),
            // ── Tab 2: Solicitudes de amistad ────────────────────────────────
            _MobileFriendRequestsTab(friends: friends),
            // ── Tab 3: Invitaciones a listas ─────────────────────────────────
            _MobileInvitationsTab(invitations: invitations),
          ],
        ),
      ),
    );
  }
}

/// Tab de amigos para el layout móvil.
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
              ? ListView(
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
                              'Aún no tienes amigos',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 20),
                            FilledButton.icon(
                              onPressed: () =>
                                  _showAddFriendDialog(context, friends),
                              icon: const Icon(Icons.person_add_outlined),
                              label: const Text('Añadir amigo'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : Stack(
                  children: [
                    ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                      itemCount: friends.friends.length,
                      itemBuilder: (_, i) => FriendCard(
                        friend: friends.friends[i],
                        onRemove: () => _confirmRemove(
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
                        onPressed: () => _showAddFriendDialog(context, friends),
                        icon: const Icon(Icons.person_add_outlined),
                        label: const Text('Añadir'),
                      ),
                    ),
                  ],
                ),
    );
  }
}

/// Tab de solicitudes de amistad para el layout móvil.
class _MobileFriendRequestsTab extends StatelessWidget {
  final FriendsProvider friends;

  const _MobileFriendRequestsTab({required this.friends});

  @override
  Widget build(BuildContext context) {
    if (friends.isLoading) return const Center(child: CircularProgressIndicator());
    if (friends.pendingRequests.isEmpty) {
      return const _SectionEmpty(
        icon: Icons.people_outline,
        message: 'Sin solicitudes pendientes',
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
          return _FriendRequestTile(
            request: r,
            onAccept: () => friends.acceptRequest(r.id),
            onReject: () => friends.rejectRequest(r.id),
          );
        },
      ),
    );
  }
}

/// Tab de invitaciones a listas para el layout móvil.
class _MobileInvitationsTab extends StatelessWidget {
  final InvitationsProvider invitations;

  const _MobileInvitationsTab({required this.invitations});

  @override
  Widget build(BuildContext context) {
    if (invitations.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (invitations.pendingInvitations.isEmpty) {
      return const _SectionEmpty(
        icon: Icons.inbox_outlined,
        message: 'Sin invitaciones pendientes',
        large: true,
      );
    }
    return RefreshIndicator(
      onRefresh: invitations.loadPendingInvitations,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: invitations.pendingInvitations.length,
        itemBuilder: (_, i) => _InvitationTile(
          invitation: invitations.pendingInvitations[i],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WIDGETS COMPARTIDOS INTERNOS
// ─────────────────────────────────────────────────────────────────────────────

/// Encabezado de sección con icono, título y badge de contador opcional.
class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final int badge;

  const _SectionHeader({
    required this.icon,
    required this.title,
    this.badge = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
        if (badge > 0) ...[
          const SizedBox(width: 8),
          _Badge(count: badge),
        ],
      ],
    );
  }
}

/// Icono de pestaña con un badge rojo superpuesto en la esquina superior derecha.
///
/// Se usa en los tabs del [TabBar] móvil para mostrar el contador de elementos
/// pendientes manteniendo el layout estándar icono-arriba / texto-abajo.
class _TabIconWithBadge extends StatelessWidget {
  final IconData icon;
  final int count;

  const _TabIconWithBadge({required this.icon, required this.count});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon),
        if (count > 0)
          Positioned(
            top: -4,
            right: -8,
            child: _Badge(count: count),
          ),
      ],
    );
  }
}

/// Badge rojo circular con contador numérico.
class _Badge extends StatelessWidget {
  final int count;

  const _Badge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        count.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Placeholder de estado vacío para una sección sin elementos.
class _SectionEmpty extends StatelessWidget {
  final IconData icon;
  final String message;

  /// Cuando `large` es `true` ocupa toda la pantalla (para tabs móvil).
  final bool large;

  const _SectionEmpty({
    required this.icon,
    required this.message,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: large ? 64 : 36,
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.25),
        ),
        SizedBox(height: large ? 12 : 8),
        Text(
          message,
          style: (large
                  ? theme.textTheme.bodyLarge
                  : theme.textTheme.bodySmall)
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
      ],
    );

    if (large) return Center(child: content);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(child: content),
    );
  }
}

/// Indicador de carga para una sección.
class _SectionLoading extends StatelessWidget {
  const _SectionLoading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

/// Tile de solicitud de amistad pendiente con botones de aceptar y rechazar.
///
/// Muestra indicadores de carga individuales por botón mientras la operación
/// está en curso para evitar doble pulsación.
class _FriendRequestTile extends StatefulWidget {
  final dynamic request;
  final Future<bool> Function() onAccept;
  final Future<bool> Function() onReject;

  const _FriendRequestTile({
    required this.request,
    required this.onAccept,
    required this.onReject,
  });

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
                    'Quiere ser tu amigo',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
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
                    tooltip: 'Aceptar',
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
                    tooltip: 'Rechazar',
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

/// Tile de invitación a lista de colaboración con botones de aceptar y rechazar.
class _InvitationTile extends StatefulWidget {
  final InvitationModel invitation;

  const _InvitationTile({required this.invitation});

  @override
  State<_InvitationTile> createState() => _InvitationTileState();
}

class _InvitationTileState extends State<_InvitationTile> {
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
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Te invita a colaborar',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.list_alt_rounded, size: 14, color: scheme.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      inv.libraryName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: inv.readOnly
                          ? scheme.tertiaryContainer
                          : scheme.primaryContainer,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      inv.readOnly ? 'Lector' : 'Editor',
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
            Row(
              children: [
                Expanded(
                  child: _rejecting
                      ? const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : OutlinedButton(
                          onPressed: _accepting ? null : _handleReject,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          child: const Text('Rechazar'),
                        ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _accepting
                      ? const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : FilledButton(
                          onPressed: _rejecting ? null : _handleAccept,
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          child: const Text('Aceptar'),
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
        const SnackBar(content: Text('Invitación aceptada')),
      );
    }
    if (mounted) setState(() => _accepting = false);
  }

  Future<void> _handleReject() async {
    setState(() => _rejecting = true);
    await context.read<InvitationsProvider>().rejectInvitation(widget.invitation.id);
    if (mounted) setState(() => _rejecting = false);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HELPERS DE DIÁLOGOS (accesibles desde cualquier widget del árbol)
// ─────────────────────────────────────────────────────────────────────────────

/// Muestra un diálogo para enviar una solicitud de amistad por nombre de usuario.
void _showAddFriendDialog(BuildContext context, FriendsProvider friends) {
  final controller = TextEditingController();
  // `sending` se declara fuera del builder para que persista entre rebuilds.
  bool sending = false;

  showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) {
        return AlertDialog(
          title: const Text('Añadir amigo'),
          content: TextField(
            controller: controller,
            autofocus: true,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: 'Nombre de usuario',
              hintText: 'Username exacto',
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
                                : (friends.errorMessage ?? 'Error al enviar'),
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
        );
      },
    ),
  );
}

/// Muestra un diálogo de confirmación antes de eliminar a [username] de amigos.
void _confirmRemove(
  BuildContext context,
  String username,
  FriendsProvider friends,
) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Eliminar amigo'),
      content: Text('¿Eliminar a $username de tu lista de amigos?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () async {
            Navigator.pop(ctx);
            await friends.removeFriend(username);
          },
          child: const Text('Eliminar'),
        ),
      ],
    ),
  );
}
