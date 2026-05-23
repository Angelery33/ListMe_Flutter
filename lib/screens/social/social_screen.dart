import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:list_me/core/providers/responsive_provider.dart';
import 'package:list_me/providers/friends/friends_provider.dart';
import 'package:list_me/providers/invitations/invitations_provider.dart';
import 'package:list_me/widgets/social/social_compact_layout.dart';
import 'package:list_me/widgets/social/social_expanded_layout.dart';

/// Pantalla social principal de la aplicación.
///
/// Delega el rendering a uno de dos layouts según el breakpoint:
/// - [SocialExpandedLayout] para pantallas anchas (≥ 840 dp): tres columnas
///   con amigos, feed y panel de solicitudes/invitaciones.
/// - [SocialCompactLayout] para móvil y tablet (< 840 dp): TabBar con tres
///   pestañas.
///
/// Dispara la carga de datos en [initState] para que ambos layouts los reciban
/// hidratados desde el primer frame.
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
      return SocialExpandedLayout(friends: friends, invitations: invitations);
    }
    return SocialCompactLayout(friends: friends, invitations: invitations);
  }
}
