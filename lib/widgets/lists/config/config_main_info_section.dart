import 'package:flutter/material.dart';
import '../../../core/i18n/l10n_extension.dart';

/// Sección de configuración para los metadatos esenciales de la biblioteca: nombre y descripción.
///
/// Proporciona un campo de nombre obligatorio (con validación) y un campo de descripción
/// multilínea opcional. Ambos controladores pertenecen a la pantalla principal
/// para que pueda leer sus valores al guardar.
class ConfigMainInfoSection extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: context.l10n.listConfigNameLabel,
                prefixIcon: Icon(Icons.list_alt),
                border: OutlineInputBorder(),
              ),
              validator: (v) => v!.isEmpty ? context.l10n.commonRequired : null,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: descController,
              decoration: InputDecoration(
                labelText: context.l10n.listConfigDescriptionOptional,
                prefixIcon: Icon(Icons.description),
                border: OutlineInputBorder(),
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
