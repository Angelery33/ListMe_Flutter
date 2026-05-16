import 'package:flutter/material.dart';
import '../../../core/i18n/l10n_extension.dart';

/// Sección de configuración que permite al usuario asignar una categoría de contenido a
/// una biblioteca (ej. Libro, Anime, Película, etc.).
///
/// La categoría impulsa el comportamiento de la IU en otras partes de la aplicación; por ejemplo,
/// qué API de búsqueda externa se consultan al agregar elementos. Seleccionar `null`
/// crea una biblioteca genérica de contenido mixto.
class ConfigTypeSection extends StatelessWidget {
  /// La clave de categoría actualmente seleccionada, o `null` para una biblioteca genérica.
  final String? selectedCategory;

  /// Se llama cuando el usuario elige una categoría diferente del desplegable.
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
              context.l10n.listConfigType,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: selectedCategory,
              decoration: InputDecoration(
                labelText: context.l10n.listConfigType,
                prefixIcon: Icon(Icons.import_contacts),
                border: OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(value: null, child: Text(context.l10n.categoryGenericMixed)),
                DropdownMenuItem(value: "Book", child: Text(context.l10n.categoryBook)),
                DropdownMenuItem(value: "Manga", child: Text(context.l10n.categoryManga)),
                DropdownMenuItem(value: "Comic", child: Text(context.l10n.categoryComic)),
                DropdownMenuItem(value: "Anime", child: Text(context.l10n.categoryAnime)),
                DropdownMenuItem(value: "Movie", child: Text(context.l10n.categoryMovie)),
                DropdownMenuItem(value: "Series", child: Text(context.l10n.categorySeries)),
                DropdownMenuItem(value: "Figures", child: Text(context.l10n.categoryFigures)),
                DropdownMenuItem(value: "Funko", child: Text(context.l10n.categoryFunko)),
              ],
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}
