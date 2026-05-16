import 'package:flutter/material.dart';
import '../../../core/i18n/l10n_extension.dart';
import '../../../data/lists/library_genre_model.dart';

/// Sección de configuración para gestionar la lista de géneros/categorías de una biblioteca temática.
///
/// Muestra un campo de texto para agregar nuevos géneros y una lista desplazable de entradas existentes
/// de [LibraryGenreModel], cada una con un botón de eliminar.
/// Solo visible cuando [isThematic] es `true`.
class ConfigGenresSection extends StatelessWidget {
  /// Indica si la biblioteca es temática (utiliza agrupación por géneros).
  /// Cuando es `false`, esta sección se renderiza como un widget vacío.
  final bool isThematic;

  /// La lista actual de géneros a mostrar.
  final List<LibraryGenreModel> displayedGenres;

  /// Controlador para el campo de texto "agregar nuevo género".
  final TextEditingController genreController;

  /// Se llama cuando el usuario toca el botón "Agregar" para confirmar la adición de un nuevo género.
  final VoidCallback onAddGenre;

  /// Se llama cuando el usuario toca el icono de eliminar en una entrada de género existente.
  ///
  /// Recibe el [LibraryGenreModel] a eliminar y su [index] actual en la lista.
  final void Function(LibraryGenreModel genre, int index) onDeleteGenre;

  const ConfigGenresSection({
    super.key,
    required this.isThematic,
    required this.displayedGenres,
    required this.genreController,
    required this.onAddGenre,
    required this.onDeleteGenre,
  });

  @override
  Widget build(BuildContext context) {
    if (!isThematic) return const SizedBox.shrink();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Personalizar Géneros / Categorías",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: genreController,
                    decoration: InputDecoration(
                      hintText: context.l10n.listConfigGenresAdd,
                      prefixIcon: Icon(Icons.label_outline),
                      border: OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: onAddGenre,
                  icon: const Icon(Icons.add),
                  label: Text(context.l10n.commonAdd),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (displayedGenres.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Sin géneros definidos.",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ...displayedGenres.asMap().entries.map((entry) {
              final idx = entry.key;
              final g = entry.value;
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                color: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                child: ListTile(
                  leading: const Icon(Icons.label),
                  title: Text(g.name),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () => onDeleteGenre(g, idx),
                  ),
                  dense: true,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
