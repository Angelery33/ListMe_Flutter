import 'package:flutter/material.dart';
import '../../../core/i18n/l10n_extension.dart';

class ConfigMainInfoSection extends StatelessWidget {
  final TextEditingController nameController;
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
