import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/i18n/l10n_extension.dart';
import '../../data/lists/collaborator_model.dart';
import '../../providers/lists/lists_provider.dart';

/// Diálogo que muestra los colaboradores de una biblioteca y permite al
/// propietario gestionarlos: alternar su permiso de edición y expulsarlos.
///
/// Uso:
/// ```dart
/// showDialog(
///   context: context,
///   builder: (_) => CollaboratorsDialog(listId: list.id!, listName: list.name),
/// );
/// ```
class CollaboratorsDialog extends StatefulWidget {
  /// ID de la biblioteca cuyos colaboradores se gestionan.
  final int listId;

  /// Nombre de la biblioteca, mostrado en el subtítulo del diálogo.
  final String listName;

  /// Indica si el usuario actual es el propietario de la lista. Solo el
  /// propietario puede cambiar roles o expulsar colaboradores; el resto ve
  /// la lista en modo de solo lectura.
  final bool isOwner;

  const CollaboratorsDialog({
    super.key,
    required this.listId,
    required this.listName,
    this.isOwner = true,
  });

  @override
  State<CollaboratorsDialog> createState() => _CollaboratorsDialogState();
}

class _CollaboratorsDialogState extends State<CollaboratorsDialog> {
  List<CollaboratorModel> _collaborators = [];
  bool _loading = true;
  final Set<int> _busyUserIds = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final list = await context.read<ListsProvider>().getCollaborators(widget.listId);
      if (mounted) setState(() { _collaborators = list; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggleRole(CollaboratorModel collaborator, bool makeEditor) async {
    setState(() => _busyUserIds.add(collaborator.userId));
    final newRole = makeEditor ? 'editor' : 'viewer';
    final ok = await context
        .read<ListsProvider>()
        .updateCollaboratorRole(widget.listId, collaborator.userId, newRole);
    if (!mounted) return;
    setState(() {
      _busyUserIds.remove(collaborator.userId);
      if (ok) {
        final idx = _collaborators.indexWhere((c) => c.userId == collaborator.userId);
        if (idx != -1) {
          _collaborators[idx] = CollaboratorModel(
            userId: collaborator.userId,
            username: collaborator.username,
            role: newRole,
          );
        }
      }
    });
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Ha ocurrido un error. Inténtalo de nuevo.')),
      );
    }
  }

  Future<void> _confirmRemove(CollaboratorModel collaborator) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Expulsar colaborador'),
        content: Text(
          '¿Seguro que quieres expulsar a "${collaborator.username}" de esta lista? '
          'Perderá el acceso inmediatamente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(dialogContext.l10n.commonCancel.toUpperCase()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              dialogContext.l10n.commonDelete.toUpperCase(),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _busyUserIds.add(collaborator.userId));
    final ok = await context
        .read<ListsProvider>()
        .removeCollaborator(widget.listId, collaborator.userId);
    if (!mounted) return;
    setState(() {
      _busyUserIds.remove(collaborator.userId);
      if (ok) _collaborators.removeWhere((c) => c.userId == collaborator.userId);
    });
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Ha ocurrido un error. Inténtalo de nuevo.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return AlertDialog(
      title: const Text('Colaboradores'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lista: "${widget.listName}"',
              style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 14),
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_collaborators.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  children: [
                    Icon(Icons.people_outline, color: scheme.onSurfaceVariant),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Esta lista no tiene colaboradores todavía.',
                        style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ),
                  ],
                ),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 320),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _collaborators.length,
                  itemBuilder: (_, i) {
                    final c = _collaborators[i];
                    final busy = _busyUserIds.contains(c.userId);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: scheme.primaryContainer,
                            child: Text(
                              c.username.isNotEmpty ? c.username[0].toUpperCase() : '?',
                              style: TextStyle(color: scheme.onPrimaryContainer, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(c.username, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                                Text(
                                  c.isEditor ? 'Puede editar' : 'Solo puede ver',
                                  style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),
                          if (!widget.isOwner)
                            Switch(value: c.isEditor, onChanged: null)
                          else if (busy)
                            const SizedBox(
                              width: 24,
                              height: 24,
                              child: Padding(
                                padding: EdgeInsets.all(4),
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          else ...[
                            Switch(
                              value: c.isEditor,
                              onChanged: (val) => _toggleRole(c, val),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                              tooltip: 'Expulsar de la lista',
                              onPressed: () => _confirmRemove(c),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.commonClose.toUpperCase()),
        ),
      ],
    );
  }
}
