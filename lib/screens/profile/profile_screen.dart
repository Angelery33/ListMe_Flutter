import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:list_me/core/i18n/l10n_extension.dart';
import 'package:list_me/providers/auth/auth_provider.dart';
import 'package:list_me/providers/profile/profile_provider.dart';
import 'package:list_me/widgets/shared/custom_gradient_app_bar.dart';
import 'package:list_me/widgets/shared/app_shell.dart';
import 'package:list_me/widgets/shared/responsive_centered_content.dart';
import 'package:list_me/core/config/routes.dart';
import 'package:list_me/providers/invitations/invitations_provider.dart';
import 'package:list_me/screens/social/invitations_screen.dart';

/// Pantalla que muestra el perfil del usuario autenticado, estadísticas de uso y
/// acciones de gestión de cuenta.
///
/// Muestra un avatar circular con la inicial del nombre de usuario, una sección de cuenta
/// (editar nombre de usuario, cambiar contraseña, invitaciones), una sección de estadísticas y botones de
/// cierre de sesión / eliminación de cuenta.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profile = context.watch<ProfileProvider>();
    final auth = context.read<AuthProvider>();
    final invitations = context.watch<InvitationsProvider>();

    if (invitations.isStale && !invitations.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        invitations.loadPendingInvitations();
      });
    }

    return AppShell(
      currentIndex: 1,
      appBar: CustomGradientAppBar(
        title: context.l10n.profileTitle,
        showBackButton: false,
      ),
      body: profile.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: ResponsiveCenteredContent(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Text(
                      (profile.user?.username ?? 'U')[0].toUpperCase(),
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    profile.user?.username ?? 'Usuario',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (profile.user?.email != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      profile.user!.email!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  if (profile.errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: theme.colorScheme.onErrorContainer,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              profile.errorMessage!,
                              style: TextStyle(
                                color: theme.colorScheme.onErrorContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                  _buildSection(
                    context,
                    title: context.l10n.profileSectionAccount,
                    children: [
                      _buildListTile(
                        context,
                        icon: Icons.person_outline,
                        title: context.l10n.profileEditProfile,
                        subtitle: context.l10n.profileEditSubtitle,
                        onTap: () => _showEditUsernameDialog(context),
                      ),
                      _buildListTile(
                        context,
                        icon: Icons.lock_outline,
                        title: context.l10n.profileChangePassword,
                        subtitle: context.l10n.profileChangePasswordSubtitle,
                        onTap: () => _showChangePasswordDialog(context),
                      ),
                      _buildListTile(
                        context,
                        icon: Icons.mail_outline,
                        title: "Invitaciones",
                        subtitle: "Gestiona tus solicitudes de colaboración",
                        badgeCount: invitations.pendingCount,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const InvitationsScreen(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSection(
                    context,
                    title: context.l10n.profileSectionStats,
                    children: [
                      _buildStatTile(
                        context,
                        icon: Icons.list_alt_rounded,
                        title: context.l10n.profileStatsLists,
                        value: profile.stats?.totalLibraries.toString() ?? '0',
                      ),
                      _buildStatTile(
                        context,
                        icon: Icons.check_circle_outline,
                        title: "Elementos totales",
                        value: profile.stats?.totalItems.toString() ?? '0',
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _confirmLogout(context, auth),
                      icon: const Icon(Icons.logout),
                      label: Text(context.l10n.settingsLogout),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () => _confirmDeleteAccount(context, profile),
                    icon: const Icon(Icons.delete_forever, color: Colors.red),
                    label: Text(
                      context.l10n.profileDeleteAccount,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (profile.apiVersion != null)
                    Text(
                      'API Version: ${profile.apiVersion}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                      ),
                    ),
                ],
              ),
              ),
            ),
    );
  }

  /// Construye una sección de tarjeta con título que contiene los widgets [children].
  ///
  /// El [title] se muestra como una pequeña etiqueta en mayúsculas encima de la tarjeta para
  /// agrupar visualmente las filas de ajustes relacionados.
  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title.toUpperCase(),
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
          child: Column(children: children),
        ),
      ],
    );
  }

  /// Construye un [ListTile] que se puede tocar con [icon], [title] y [subtitle].
  ///
  /// Cuando [badgeCount] es mayor que cero, se muestra una placa roja tipo píldora junto a
  /// [title] para indicar elementos pendientes (por ejemplo, invitaciones pendientes).
  Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    int badgeCount = 0,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Row(
        children: [
          Text(title),
          if (badgeCount > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.error,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                badgeCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  /// Construye un [ListTile] de solo lectura que muestra un [value] estadístico junto con un
  /// [title] descriptivo y un [icon] principal.
  Widget _buildStatTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(title),
      trailing: Text(
        value,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  /// Muestra un [AlertDialog] con un campo de texto rellenado previamente con el nombre de usuario
  /// actual, y llama a [ProfileProvider.updateUsername] al guardar.
  void _showEditUsernameDialog(BuildContext context) {
    final profile = context.read<ProfileProvider>();
    final controller = TextEditingController(
      text: profile.user?.username ?? '',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.profileEditUsername),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: ctx.l10n.profileUser,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(ctx.l10n.commonCancel),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                final success = await profile.updateUsername(controller.text);
                if (success && ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(context.l10n.profileUsernameUpdated)),
                  );
                }
              }
            },
            child: Text(ctx.l10n.commonSave),
          ),
        ],
      ),
    );
  }

  /// Muestra un [AlertDialog] con tres campos de contraseña (actual, nueva, confirmar)
  /// y llama a [ProfileProvider.changePassword] al guardar después de una validación básica.
  void _showChangePasswordDialog(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ctx.l10n.profileChangePassword),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              obscureText: true,
              decoration: InputDecoration(
            labelText: ctx.l10n.profileCurrentPassword,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: InputDecoration(
            labelText: ctx.l10n.profileNewPassword,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
            labelText: ctx.l10n.profileConfirmPassword,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(ctx.l10n.commonCancel),
          ),
          ElevatedButton(
            onPressed: () async {
              if (newPasswordController.text !=
                  confirmPasswordController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(ctx.l10n.authPasswordsMismatch)),
                );
                return;
              }
              if (newPasswordController.text.length < 8) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(ctx.l10n.profilePasswordTooShort),
                  ),
                );
                return;
              }
              final profile = context.read<ProfileProvider>();
              final success = await profile.changePassword(
                currentPasswordController.text,
                newPasswordController.text,
              );
              if (success && ctx.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(ctx.l10n.profilePasswordChanged)),
                );
              } else if (ctx.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(profile.errorMessage ?? 'Error')),
                );
              }
            },
            child: Text(ctx.l10n.profileChange),
          ),
        ],
      ),
    );
  }

  /// Muestra un diálogo de confirmación antes de llamar a [AuthProvider.logout] y
  /// navegar a la pantalla de inicio de sesión.
  void _confirmLogout(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ctx.l10n.profileLogoutTitle),
        content: Text(ctx.l10n.profileLogoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(ctx.l10n.commonCancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await auth.logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.login,
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(ctx.l10n.profileLogoutTitle),
          ),
        ],
      ),
    );
  }

  /// Muestra un diálogo de confirmación antes de llamar a [ProfileProvider.deleteAccount].
  ///
  /// Si tiene éxito, cierra la sesión a través de [AuthProvider] y navega a la pantalla de inicio de sesión.
  void _confirmDeleteAccount(BuildContext context, ProfileProvider profile) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ctx.l10n.profileDeleteAccount),
        content: Text(ctx.l10n.profileDeleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(ctx.l10n.commonCancel),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await profile.deleteAccount();
              if (success && ctx.mounted) {
                Navigator.pop(ctx);
                await context.read<AuthProvider>().logout();
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.login,
                    (route) => false,
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(ctx.l10n.commonDelete),
          ),
        ],
      ),
    );
  }
}
