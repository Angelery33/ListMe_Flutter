import 'package:flutter/material.dart';

class EntryMainInfoSection extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController descController;
  final String? itemNumberLabel;
  final TextEditingController? itemNumberController;

  const EntryMainInfoSection({
    super.key,
    required this.nameController,
    required this.descController,
    this.itemNumberLabel,
    this.itemNumberController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, "Información Principal"),
        const SizedBox(height: 16),
        
        // Campo Nombre
        TextFormField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: "Nombre / Título",
            prefixIcon: Icon(Icons.title_rounded, color: colorScheme.primary),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          textCapitalization: TextCapitalization.sentences,
          validator: (value) => (value == null || value.isEmpty) ? "El nombre es obligatorio" : null,
        ),
        const SizedBox(height: 16),

        // Campo Descripción
        TextFormField(
          controller: descController,
          decoration: InputDecoration(
            labelText: "Descripción",
            alignLabelWithHint: true,
            prefixIcon: Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Icon(Icons.description_rounded, color: colorScheme.primary),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          maxLines: 3,
          textCapitalization: TextCapitalization.sentences,
        ),

        // Campo Especial (opcional, ej: Número de Funko)
        if (itemNumberLabel != null && itemNumberController != null) ...[
          const SizedBox(height: 16),
          TextFormField(
            controller: itemNumberController,
            decoration: InputDecoration(
              labelText: itemNumberLabel,
              prefixIcon: Icon(Icons.numbers_rounded, color: colorScheme.primary),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title.toUpperCase(),
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }
}
