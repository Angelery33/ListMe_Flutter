import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/invitations/invitations_provider.dart';

class ConfigCollaborationSection extends StatefulWidget {
  final int? libraryId;
  final bool isOwner;

  const ConfigCollaborationSection({
    super.key,
    required this.libraryId,
    required this.isOwner,
  });

  @override
  State<ConfigCollaborationSection> createState() => _ConfigCollaborationSectionState();
}

class _ConfigCollaborationSectionState extends State<ConfigCollaborationSection> {
  final _usernameController = TextEditingController();
  bool _isReadOnly = true;

  void _sendInvitation() async {
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
          const SnackBar(content: Text("Invitación enviada correctamente")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${provider.error ?? 'No se pudo enviar'}")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isOwner || widget.libraryId == null) return const SizedBox.shrink();

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
              children: [
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
