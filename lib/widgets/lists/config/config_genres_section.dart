import 'package:flutter/material.dart';
import '../../../data/lists/library_genre_model.dart';

class ConfigGenresSection extends StatelessWidget {
  final bool isThematic;
  final List<LibraryGenreModel> displayedGenres;
  final TextEditingController genreController;
  final VoidCallback onAddGenre;
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
                    decoration: const InputDecoration(
                      hintText: "Nuevo Género",
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
                  label: const Text("Añadir"),
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
