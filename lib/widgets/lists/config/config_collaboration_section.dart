import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/invitations/invitations_provider.dart';

/// Widget de sección para la pantalla de configuración de la lista que permite al propietario
/// invitar a otros usuarios a colaborar en una biblioteca.
///
/// Solo se renderiza cuando el usuario actual es el propietario Y la biblioteca ya
/// tiene un [libraryId] asignado por el servidor. No renderiza nada en caso contrario.
class ConfigCollaborationSection extends StatefulWidget {
  /// El ID del servidor de la biblioteca que se está configurando.
  /// Cuando es `null`, la sección se oculta porque la biblioteca aún no se ha guardado.
  final int? libraryId;

  /// Indica si el usuario actual es el propietario de esta biblioteca.
  /// Los no propietarios no pueden invitar a colaboradores, por lo que la sección se oculta para ellos.
  final bool isOwner;

  const ConfigCollaborationSection({
    super.key,
    required this.libraryId,
    required this.isOwner,
  });

  @override
  State<ConfigCollaborationSection> createState() => _ConfigCollaborationSectionState();
}

/// Estado para [ConfigCollaborationSection].
///
/// Gestiona el campo de texto del nombre de usuario y el interruptor de permiso de solo lectura,
/// y envía las solicitudes de invitación a través de [InvitationsProvider].
class _ConfigCollaborationSectionState extends State<ConfigCollaborationSection> {
  /// Controlador para el campo de entrada de nombre de usuario donde el propietario escribe el nombre de usuario del invitado.
  final _usernameController = TextEditingController();

  /// Indica si el colaborador invitado debe tener acceso de solo lectura.
  /// Por defecto es `true` para evitar conceder acceso de escritura accidentalmente.
  bool _isReadOnly = true;

  /// Envía una solicitud de invitación a través de [InvitationsProvider].
  ///
  /// Valida que el campo de nombre de usuario no esté vacío y que el ID de la biblioteca esté configurado,
  /// luego muestra un [SnackBar] de éxito o error según el resultado.
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
