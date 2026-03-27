import 'package:flutter/material.dart';

class ConfigTypeSection extends StatelessWidget {
  final String? selectedCategory;
  final ValueChanged<String?> onChanged;

  const ConfigTypeSection({
    super.key,
    required this.selectedCategory,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Tipo de Lista",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Categoría para Importar',
                prefixIcon: Icon(Icons.import_contacts),
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: null, child: Text("General / Otros")),
                DropdownMenuItem(value: "Book", child: Text("Libros")),
                DropdownMenuItem(value: "Manga", child: Text("Manga")),
                DropdownMenuItem(value: "Comic", child: Text("Cómic")),
                DropdownMenuItem(value: "Anime", child: Text("Anime")),
                DropdownMenuItem(value: "Movie", child: Text("Películas")),
                DropdownMenuItem(value: "Series", child: Text("Series / TV")),
                DropdownMenuItem(value: "Figures", child: Text("Figuras")),
                DropdownMenuItem(value: "Funko", child: Text("Funko Pop")),
              ],
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}
