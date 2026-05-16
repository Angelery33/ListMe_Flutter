import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/invitations/invitations_provider.dart';
import '../../providers/lists/lists_provider.dart';
import '../../widgets/shared/custom_gradient_app_bar.dart';

/// Pantalla que enumera todas las invitaciones de colaboración pendientes para el usuario actual.
///
/// Cada tarjeta de invitación muestra el avatar del remitente, el nombre de la biblioteca y el
/// nivel de permiso (solo lectura o editor), con botones de aceptar y rechazar.
/// Aceptar una invitación activa una actualización de la lista de bibliotecas para que la biblioteca recién compartida
/// aparezca inmediatamente.
class InvitationsScreen extends StatefulWidget {
  const InvitationsScreen({super.key});

  @override
  State<InvitationsScreen> createState() => _InvitationsScreenState();
}

/// Estado para [InvitationsScreen].
///
/// Activa [InvitationsProvider.loadPendingInvitations] en el primer frame
/// para asegurar que se muestren datos frescos cada vez que se abra la pantalla.
class _InvitationsScreenState extends State<InvitationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InvitationsProvider>().loadPendingInvitations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<InvitationsProvider>();

    return Scaffold(
      appBar: CustomGradientAppBar(
        title: "Invitaciones",
        showBackButton: true,
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.pendingInvitations.isEmpty
              ? _buildEmptyState(context)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.pendingInvitations.length,
                  itemBuilder: (context, index) {
                    final invitation = provider.pendingInvitations[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: theme.colorScheme.primaryContainer,
                                  child: Text(invitation.senderUsername[0].toUpperCase()),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        invitation.senderUsername,
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        "Te invita a colaborar",
                                        style: theme.textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            Text(
                              "Lista: ${invitation.libraryName}",
                              style: theme.textTheme.titleSmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              invitation.readOnly ? "Permiso: Solo lectura" : "Permiso: Editor",
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => provider.rejectInvitation(invitation.id),
                                    child: const Text("Rechazar"),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      final success = await provider.acceptInvitation(invitation.id);
                                      if (success && context.mounted) {
                                        // Refrescar las listas
                                        context.read<ListsProvider>().fetchLists();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text("Invitación aceptada")),
                                        );
                                      }
                                    },
                                    child: const Text("Aceptar"),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  /// Devuelve el widget de estado vacío que se muestra cuando no hay invitaciones pendientes.
  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.mail_outline,
            size: 80,
            color: theme.colorScheme.primary.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 16),
          Text(
            "No tienes invitaciones pendientes",
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
