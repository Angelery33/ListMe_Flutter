import 'package:flutter/material.dart';

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
              decoration: const InputDecoration(
                labelText: "Nombre *",
                prefixIcon: Icon(Icons.list_alt),
                border: OutlineInputBorder(),
              ),
              validator: (v) => v!.isEmpty ? "Requerido" : null,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: "Descripción (Opcional)",
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
