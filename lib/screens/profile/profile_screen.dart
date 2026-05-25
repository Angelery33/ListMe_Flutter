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
import 'package:list_me/core/services/logger_service.dart';

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
                      onPressed: () => _confirmLogout(context),
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
                    onPressed: () => _confirmDeleteAccount(context),
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

  void _showEditUsernameDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => _EditUsernameDialog(parentContext: context),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => _ChangePasswordDialog(parentContext: context),
    );
  }

  void _confirmLogout(BuildContext context) {
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
              await context.read<AuthProvider>().logout();
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

  void _confirmDeleteAccount(BuildContext context) {
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
              final profile = context.read<ProfileProvider>();
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

// ─────────────────────────────────────────────────────────────────────────────
// Diálogo de edición de nombre de usuario
// ─────────────────────────────────────────────────────────────────────────────

class _EditUsernameDialog extends StatefulWidget {
  final BuildContext parentContext;
  const _EditUsernameDialog({required this.parentContext});

  @override
  State<_EditUsernameDialog> createState() => _EditUsernameDialogState();
}

class _EditUsernameDialogState extends State<_EditUsernameDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final profile = widget.parentContext.read<ProfileProvider>();
    _controller = TextEditingController(text: profile.user?.username ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_controller.text.isEmpty) return;
    final profile = widget.parentContext.read<ProfileProvider>();
    final success = await profile.updateUsername(_controller.text);
    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(widget.parentContext).showSnackBar(
        SnackBar(content: Text(widget.parentContext.l10n.profileUsernameUpdated)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.profileEditUsername),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _submit(),
        decoration: InputDecoration(
          labelText: context.l10n.profileUser,
          border: const OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.commonCancel),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: Text(context.l10n.commonSave),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Diálogo de cambio de contraseña
// ─────────────────────────────────────────────────────────────────────────────

class _ChangePasswordDialog extends StatefulWidget {
  final BuildContext parentContext;
  const _ChangePasswordDialog({required this.parentContext});

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final _currentCtrl   = TextEditingController();
  final _newCtrl       = TextEditingController();
  final _confirmCtrl   = TextEditingController();
  final _newFocus      = FocusNode();
  final _confirmFocus  = FocusNode();

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    _newFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_newCtrl.text != _confirmCtrl.text) {
      ScaffoldMessenger.of(widget.parentContext).showSnackBar(
        SnackBar(content: Text(context.l10n.authPasswordsMismatch)),
      );
      return;
    }
    if (_newCtrl.text.length < 8) {
      ScaffoldMessenger.of(widget.parentContext).showSnackBar(
        SnackBar(content: Text(context.l10n.profilePasswordTooShort)),
      );
      return;
    }
    final profile = widget.parentContext.read<ProfileProvider>();
    final auth    = widget.parentContext.read<AuthProvider>();
    final success = await profile.changePassword(_currentCtrl.text, _newCtrl.text);
    if (success && mounted) {
      Navigator.pop(context);
      // El backend invalida el refresh token al cambiar contraseña → logout inmediato.
      await auth.logout();
      if (widget.parentContext.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          widget.parentContext, AppRoutes.login, (route) => false,
        );
        ScaffoldMessenger.of(widget.parentContext).showSnackBar(
          SnackBar(content: Text(widget.parentContext.l10n.profilePasswordChanged)),
        );
      }
    } else if (mounted) {
      ScaffoldMessenger.of(widget.parentContext).showSnackBar(
        SnackBar(content: Text(profile.errorMessage ?? 'Error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.profileChangePassword),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _currentCtrl,
            obscureText: true,
            autofocus: true,
            textInputAction: TextInputAction.next,
            onSubmitted: (_) => _newFocus.requestFocus(),
            decoration: InputDecoration(
              labelText: context.l10n.profileCurrentPassword,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _newCtrl,
            focusNode: _newFocus,
            obscureText: true,
            textInputAction: TextInputAction.next,
            onSubmitted: (_) => _confirmFocus.requestFocus(),
            decoration: InputDecoration(
              labelText: context.l10n.profileNewPassword,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _confirmCtrl,
            focusNode: _confirmFocus,
            obscureText: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              labelText: context.l10n.profileConfirmPassword,
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.commonCancel),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: Text(context.l10n.profileChange),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Avatar de perfil
// ─────────────────────────────────────────────────────────────────────────────

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
  final _logger = LoggerService.instance;

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
    final pickerService = ImagePickerService();
    final file = await pickerService.pickImage(source: source);

    if (file == null) return;

    if (mounted) setState(() => _uploading = true);

    final userId = profile.user?.id?.toString() ?? 'unknown';
    _logger.debug('[ProfileAvatar] subiendo foto para userId=$userId');

    String? url;
    try {
      url = await FirebaseStorageService().uploadProfilePhoto(file, userId);
    } catch (e) {
      _logger.error('[ProfileAvatar] Error Firebase al subir foto', e);
      if (mounted) {
        setState(() => _uploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error Firebase: $e')),
        );
      }
      return;
    }

    if (url == null) {
      if (mounted) {
        setState(() => _uploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Firebase devolvió URL nula')),
        );
      }
      return;
    }

    final success = await profile.updateProfilePhoto(url);
    _logger.debug('[ProfileAvatar] foto guardada en backend: $success');

    if (mounted) {
      setState(() => _uploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Foto actualizada correctamente'
                : 'Error al guardar: ${profile.errorMessage ?? context.l10n.profilePhotoSaveError}',
          ),
        ),
      );
    }
  }

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
