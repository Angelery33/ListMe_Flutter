import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/i18n/l10n_extension.dart';
import '../../../data/lists/collaborator_model.dart';
import '../../../providers/invitations/invitations_provider.dart';
import '../../../providers/lists/lists_provider.dart';

/// Sección de la pantalla de configuración que permite al propietario invitar
/// colaboradores y ver/eliminar los ya existentes.
///
/// Solo se renderiza cuando el usuario es propietario y la biblioteca ya tiene [libraryId].
class ConfigCollaborationSection extends StatefulWidget {
  /// ID del servidor de la biblioteca. `null` oculta la sección (lista no guardada aún).
  final int? libraryId;

  /// `true` cuando el usuario actual es el propietario de la biblioteca.
  final bool isOwner;

  const ConfigCollaborationSection({
    super.key,
    required this.libraryId,
    required this.isOwner,
  });

  @override
  State<ConfigCollaborationSection> createState() =>
      _ConfigCollaborationSectionState();
}

/// Estado para [ConfigCollaborationSection].
///
/// Carga la lista de colaboradores al iniciar y permite enviar invitaciones
/// y eliminar colaboradores existentes.
class _ConfigCollaborationSectionState
    extends State<ConfigCollaborationSection> {
  /// Controlador del campo donde el propietario escribe el nombre de usuario del invitado.
  final _usernameController = TextEditingController();

  /// Si el colaborador invitado tendrá solo lectura. Valor por defecto seguro.
  bool _isReadOnly = true;

  /// Lista de colaboradores activos cargada desde el servidor.
  List<CollaboratorModel> _collaborators = [];

  /// Indica si la lista de colaboradores se está cargando.
  bool _loadingCollaborators = false;

  @override
  void initState() {
    super.initState();
    if (widget.isOwner && widget.libraryId != null) {
      _loadCollaborators();
    }
  }

  /// Obtiene los colaboradores actuales de la biblioteca desde el servidor.
  Future<void> _loadCollaborators() async {
    setState(() => _loadingCollaborators = true);
    try {
      final list = await context
          .read<ListsProvider>()
          .getCollaborators(widget.libraryId!);
      if (mounted) setState(() => _collaborators = list);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loadingCollaborators = false);
    }
  }

  /// Envía la invitación al usuario introducido en [_usernameController].
  Future<void> _sendInvitation() async {
    if (_usernameController.text.trim().isEmpty) return;
    if (widget.libraryId == null) return;

    final provider = context.read<InvitationsProvider>();
    final success = await provider.sendInvitation(
      widget.libraryId!,
      _usernameController.text.trim(),
      _isReadOnly,
    );

    if (mounted) {
      if (success) {
        _usernameController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.listsInviteSent)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Error: ${provider.error ?? 'No se pudo enviar'}")),
        );
      }
    }
  }

  /// Muestra un diálogo de confirmación y elimina al [collaborator] de la biblioteca.
  Future<void> _confirmRemove(CollaboratorModel collaborator) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Eliminar colaborador"),
        content:
            Text('¿Eliminar a "${collaborator.username}" de esta biblioteca?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(ctx.l10n.commonCancel.toUpperCase()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              ctx.l10n.commonDelete.toUpperCase(),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final ok = await context
        .read<ListsProvider>()
        .removeCollaborator(widget.libraryId!, collaborator.userId);

    if (mounted) {
      if (ok) {
        setState(
            () => _collaborators.removeWhere((c) => c.userId == collaborator.userId));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  '"${collaborator.username}" eliminado de la biblioteca')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error al eliminar colaborador")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isOwner || widget.libraryId == null) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            "COLABORACIÓN",
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
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Current collaborators ──────────────────────────────────
                if (_loadingCollaborators)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_collaborators.isNotEmpty) ...[
                  Text(
                    "Colaboradores actuales",
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._collaborators.map(
                    (c) => ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        radius: 16,
                        backgroundColor:
                            theme.colorScheme.primaryContainer,
                        child: Text(
                          c.username[0].toUpperCase(),
                          style: TextStyle(
                              fontSize: 13,
                              color: theme.colorScheme.onPrimaryContainer),
                        ),
                      ),
                      title: Text(c.username,
                          style: theme.textTheme.bodyMedium),
                      subtitle: Text(
                        c.isEditor ? "Editor" : "Solo lectura",
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.person_remove_outlined,
                            color: Colors.red, size: 20),
                        tooltip: "Eliminar colaborador",
                        onPressed: () => _confirmRemove(c),
                      ),
                    ),
                  ),
                  const Divider(height: 24),
                ],

                // ── Invite new collaborator ────────────────────────────────
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: "Nombre de usuario",
                    hintText: "Ej: maria_92",
                    prefixIcon: Icon(Icons.person_add_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Permiso de solo lectura",
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    Switch(
                      value: _isReadOnly,
                      onChanged: (val) => setState(() => _isReadOnly = val),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _sendInvitation,
                    icon: const Icon(Icons.send_rounded),
                    label: const Text("Enviar Invitación"),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "El usuario recibirá una notificación en su app para aceptar la colaboración.",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
