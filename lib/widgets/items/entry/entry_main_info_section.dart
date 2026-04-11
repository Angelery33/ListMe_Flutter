import 'package:flutter/material.dart';

class EntryMainInfoSection extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController descController;
  final TextEditingController? itemNumberController;
  final TextEditingController? productTypeController;
  final TextEditingController? editionController;
  final VoidCallback? onImportPressed;
  final bool showImportButton;
  final bool showItemNumber;
  final bool showProductType;
  final bool showEdition;

  const EntryMainInfoSection({
    super.key,
    required this.nameController,
    required this.descController,
    this.itemNumberController,
    this.productTypeController,
    this.editionController,
    this.onImportPressed,
    this.showImportButton = false,
    this.showItemNumber = false,
    this.showProductType = false,
    this.showEdition = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 1,
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, "Información Principal"),
            const SizedBox(height: 16),

            TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Nombre / Título",
                prefixIcon: Icon(
                  Icons.title_rounded,
                  color: colorScheme.primary,
                ),
                suffixIcon: showImportButton
                    ? IconButton(
                        icon: Icon(
                          Icons.cloud_download_rounded,
                          color: colorScheme.primary,
                        ),
                        onPressed: onImportPressed,
                        tooltip: 'Importar desde API',
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              textCapitalization: TextCapitalization.sentences,
              validator: (value) => (value == null || value.isEmpty)
                  ? "El nombre es obligatorio"
                  : null,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: descController,
              decoration: InputDecoration(
                labelText: "Descripción",
                alignLabelWithHint: true,
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Icon(
                    Icons.description_rounded,
                    color: colorScheme.primary,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),

            if (showItemNumber && itemNumberController != null) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: itemNumberController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Número de Item",
                  prefixIcon: Icon(
                    Icons.numbers_rounded,
                    color: colorScheme.primary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],

            if (showProductType && productTypeController != null) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: productTypeController,
                decoration: InputDecoration(
                  labelText: "Tipo de Producto",
                  prefixIcon: Icon(
                    Icons.category_rounded,
                    color: colorScheme.primary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],

            if (showEdition && editionController != null) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: editionController,
                decoration: InputDecoration(
                  labelText: "Edición",
                  prefixIcon: Icon(
                    Icons.bookmark_rounded,
                    color: colorScheme.primary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
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
