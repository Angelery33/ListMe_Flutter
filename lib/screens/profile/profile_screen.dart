import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:list_me/core/i18n/l10n_extension.dart';
import 'package:list_me/providers/auth/auth_provider.dart';
import 'package:list_me/providers/profile/profile_provider.dart';
import 'package:list_me/widgets/shared/custom_gradient_app_bar.dart';
import 'package:list_me/widgets/shared/app_shell.dart';
import 'package:list_me/widgets/shared/responsive_centered_content.dart';
import 'package:list_me/core/config/routes.dart';
import 'package:list_me/core/services/firebase_storage_service.dart';
import 'package:list_me/core/services/image_picker_service.dart';

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
                  const _ProfileAvatar(),
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
                        title: context.l10n.profileTotalItems,
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
    final controller = TextEditingController(text: profile.user?.username ?? '');

    Future<void> submit(BuildContext ctx) async {
      if (controller.text.isNotEmpty) {
        final success = await profile.updateUsername(controller.text);
        if (success && ctx.mounted) {
          Navigator.pop(ctx);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.profileUsernameUpdated)),
          );
        }
      }
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.profileEditUsername),
        content: TextField(
          controller: controller,
          autofocus: true,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => submit(ctx),
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
            onPressed: () => submit(ctx),
            child: Text(ctx.l10n.commonSave),
          ),
        ],
      ),
    ).then((_) => controller.dispose());
  }

  /// Muestra un [AlertDialog] con tres campos de contraseña (actual, nueva, confirmar)
  /// y llama a [ProfileProvider.changePassword] al guardar después de una validación básica.
  void _showChangePasswordDialog(BuildContext context) {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    final newFocus = FocusNode();
    final confirmFocus = FocusNode();

    Future<void> submit(BuildContext ctx) async {
      if (newCtrl.text != confirmCtrl.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ctx.l10n.authPasswordsMismatch)),
        );
        return;
      }
      if (newCtrl.text.length < 8) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ctx.l10n.profilePasswordTooShort)),
        );
        return;
      }
      final profile = context.read<ProfileProvider>();
      final auth = context.read<AuthProvider>();
      final success = await profile.changePassword(currentCtrl.text, newCtrl.text);
      if (success && ctx.mounted) {
        Navigator.pop(ctx);
        // El backend invalida el refresh token al cambiar contraseña,
        // así que hacemos logout inmediato para evitar errores posteriores.
        await auth.logout();
        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context, AppRoutes.login, (route) => false,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(ctx.l10n.profilePasswordChanged)),
          );
        }
      } else if (ctx.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(profile.errorMessage ?? 'Error')),
        );
      }
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ctx.l10n.profileChangePassword),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentCtrl,
              obscureText: true,
              autofocus: true,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => newFocus.requestFocus(),
              decoration: InputDecoration(
                labelText: ctx.l10n.profileCurrentPassword,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newCtrl,
              focusNode: newFocus,
              obscureText: true,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => confirmFocus.requestFocus(),
              decoration: InputDecoration(
                labelText: ctx.l10n.profileNewPassword,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmCtrl,
              focusNode: confirmFocus,
              obscureText: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => submit(ctx),
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
            onPressed: () => submit(ctx),
            child: Text(ctx.l10n.profileChange),
          ),
        ],
      ),
    ).then((_) {
      currentCtrl.dispose();
      newCtrl.dispose();
      confirmCtrl.dispose();
      newFocus.dispose();
      confirmFocus.dispose();
    });
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

/// Avatar de perfil interactivo que muestra la foto del usuario o su inicial.
///
/// Al tocar el avatar se presenta una hoja inferior con las opciones de cámara y galería.
/// Tras seleccionar una imagen, la sube a Firebase Storage y persiste la URL en el backend
/// a través de [ProfileProvider.updateProfilePhoto].
class _ProfileAvatar extends StatefulWidget {
  const _ProfileAvatar();

  @override
  State<_ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<_ProfileAvatar> {
  bool _uploading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final profile = context.watch<ProfileProvider>();
    final photoUrl = profile.user?.photoUrl;
    final username = profile.user?.username ?? 'U';

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        GestureDetector(
          onTap: _uploading ? null : () => _pickAndUpload(context),
          child: ClipOval(
            child: Container(
              key: ValueKey(photoUrl),
              width: 100,
              height: 100,
              color: scheme.primaryContainer,
              child: (photoUrl != null && photoUrl.isNotEmpty)
                  ? Image.network(
                      photoUrl,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Center(
                        child: Text(
                          username[0].toUpperCase(),
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: scheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: Text(
                        username[0].toUpperCase(),
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: scheme.onPrimaryContainer,
                        ),
                      ),
                    ),
            ),
          ),
        ),
        if (_uploading)
          const Positioned.fill(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.black38,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
          ),
        if (!_uploading)
          Container(
            decoration: BoxDecoration(
              color: scheme.primary,
              shape: BoxShape.circle,
              border: Border.all(color: scheme.surface, width: 2),
            ),
            child: Icon(Icons.camera_alt, size: 18, color: scheme.onPrimary),
          ),
      ],
    );
  }

  Future<void> _pickAndUpload(BuildContext context) async {
    final source = await _showSourceSheet(context);
    if (source == null) return;

    final profile = context.read<ProfileProvider>();
    final l10n = context.l10n;

    final pickerService = ImagePickerService();
    final file = await pickerService.pickImage(source: source);
    debugPrint('[ProfileAvatar] file picked: ${file?.path}');

    if (file == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: no se pudo obtener la imagen')),
        );
      }
      return;
    }

    if (!mounted) {
      debugPrint('[ProfileAvatar] not mounted after pickImage');
      return;
    }
    setState(() => _uploading = true);

    final userId = profile.user?.id?.toString() ?? 'unknown';
    debugPrint('[ProfileAvatar] uploading for userId=$userId');
    final storageService = FirebaseStorageService();
    final url = await storageService.uploadProfilePhoto(file, userId);
    debugPrint('[ProfileAvatar] firebase url=$url');

    if (!mounted) return;

    if (url == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: fallo al subir a Firebase Storage')),
      );
      setState(() => _uploading = false);
      return;
    }

    final success = await profile.updateProfilePhoto(url);
    debugPrint('[ProfileAvatar] backend save success=$success, errorMsg=${profile.errorMessage}');

    if (!mounted) return;
    setState(() => _uploading = false);

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: ${profile.errorMessage ?? l10n.profilePhotoSaveError}')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto actualizada correctamente')),
      );
    }
  }

  /// Muestra una hoja inferior para elegir entre cámara y galería.
  /// Devuelve `null` si el usuario cancela.
  Future<ImageSource?> _showSourceSheet(BuildContext context) async {
    return showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(context.l10n.profilePickerGallery),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: Text(context.l10n.profilePickerCamera),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
