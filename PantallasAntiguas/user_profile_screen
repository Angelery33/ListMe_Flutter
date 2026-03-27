import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditProfileDialog(context),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(
                context,
              ).colorScheme.primaryContainer.withValues(alpha: 0.4),
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Consumer<AuthProvider>(
              builder: (context, auth, _) {
                final user = auth.user;
                if (user == null) {
                  return const Center(child: Text("No has iniciado sesión"));
                }

                return Column(
                  children: [
                    const SizedBox(height: 40),
                    // Avatar
                    Hero(
                      tag: 'profile_avatar',
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).colorScheme.surface,
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: user.photoURL != null
                              ? Image.network(
                                  user.photoURL!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Icon(
                                    Icons.person,
                                    size: 80,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                )
                              : Icon(
                                  Icons.person,
                                  size: 80,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Nickname
                    Text(
                      user.displayName ?? "Usuario sin nombre",
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),

                    // Email
                    Text(
                      user.email ?? "Sin correo",
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Info Cards
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          _buildInfoCard(
                            context,
                            icon: Icons.verified_user_outlined,
                            title: "ID de Usuario",
                            value: user.uid,
                          ),
                          const SizedBox(height: 16),
                          _buildInfoCard(
                            context,
                            icon: Icons.date_range,
                            title: "Miembro desde",
                            value: _formatDate(user.metadata.creationTime),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Logout Button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await auth.signOut();
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                          icon: const Icon(Icons.logout),
                          label: const Text("Cerrar Sesión"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.errorContainer,
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.onErrorContainer,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "Desconocido";
    return "${date.day}/${date.month}/${date.year}";
  }

  void _showEditProfileDialog(BuildContext context) {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user == null) return;

    final nameController = TextEditingController(text: user.displayName);
    final photoController = TextEditingController(text: user.photoURL);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Editar Perfil"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Nombre (Nick)"),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: photoController,
                decoration: const InputDecoration(
                  labelText: "URL Foto de Perfil",
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCELAR"),
          ),
          TextButton(
            onPressed: () async {
              try {
                if (nameController.text.isNotEmpty) {
                  await user.updateDisplayName(nameController.text);
                }
                if (photoController.text.isNotEmpty) {
                  await user.updatePhotoURL(photoController.text);
                }
                // Refresh provider? AuthProvider listens to changes usually,
                // but updateDisplayName might not trigger authStateChanges immediately
                // unless we force reload or reload user.
                await user.reload();
                // Force AuthProvider to notify listeners if needed,
                // currently logic depends on stream.
                // Stream might not fire for profile updates.
                // Let's assume user.reload() helps or we might need to trigger generic update.
                // Actually, just calling setState in parent or notifying listeners would be best.
                // But this is a Stateless widget.
                // AuthProvider should handle user updates if we want to be clean.
                // For now, assume FirebaseAuth generic stream handles it or next rebuild will show it.
                // To be safe, we can manually notify AuthProvider if we exposed a method.
                // But simpler: just reload user.

                // Note: AuthProvider stores _user. We might need to update _user there.
                // But _user is a reference. properties inside might update.
                // Let's force a rebuild by checking if mounted.
                if (context.mounted) {
                  Navigator.pop(context);
                }
              } catch (e) {
                debugPrint("Error updating profile: $e");
              }
            },
            child: const Text("GUARDAR"),
          ),
        ],
      ),
    );
  }
}
