import 'package:flutter/material.dart';
import '../../../core/i18n/l10n_extension.dart';

/// Sección de configuración para los metadatos esenciales de la biblioteca: nombre y descripción.
///
/// Proporciona un campo de nombre obligatorio (con validación) y un campo de descripción
/// multilínea opcional. Ambos controladores pertenecen a la pantalla principal
/// para que pueda leer sus valores al guardar.
class ConfigMainInfoSection extends StatefulWidget {
  /// Controlador para el campo de texto del nombre de la biblioteca.
  /// El campo es obligatorio; se muestra un error de validación cuando está vacío.
  final TextEditingController nameController;

  /// Controlador para el campo de texto de descripción opcional de la biblioteca.
  /// Permite hasta tres líneas visibles de texto libre.
  final TextEditingController descController;

  const ConfigMainInfoSection({
    super.key,
    required this.nameController,
    required this.descController,
  });

  @override
  State<ConfigMainInfoSection> createState() => _ConfigMainInfoSectionState();
}

class _ConfigMainInfoSectionState extends State<ConfigMainInfoSection> {
  final FocusNode _descFocus = FocusNode();

  @override
  void dispose() {
    _descFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: widget.nameController,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => _descFocus.requestFocus(),
              decoration: const InputDecoration(
                labelText: 'Nombre',
                prefixIcon: Icon(Icons.list_alt),
                border: OutlineInputBorder(),
              ),
              validator: (v) => v!.isEmpty ? context.l10n.commonRequired : null,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: widget.descController,
              focusNode: _descFocus,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
              decoration: InputDecoration(
                labelText: context.l10n.listConfigDescriptionOptional,
                prefixIcon: const Icon(Icons.description),
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
          ],
        ),
      ),
    );
  }
}
