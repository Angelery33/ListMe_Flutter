import 'package:flutter/material.dart';
import '../../../data/lists/library_genre_model.dart';

class EntryPropertiesSection extends StatelessWidget {
  final String? genre;
  final List<LibraryGenreModel> availableGenres;
  final Function(String?) onGenreChanged;
  final Function(String?) onGenreSaved;
  final VoidCallback? onAddGenrePressed;
  final TextEditingController priceController;
  final double score;
  final Function(String) onScoreChanged;
  final Function(double) onStarTap;
  final bool supportsPrice;
  final bool isGradeable;
  final bool isThematic;
  final int ratingScale;

  const EntryPropertiesSection({
    super.key,
    required this.genre,
    required this.availableGenres,
    required this.onGenreChanged,
    required this.onGenreSaved,
    required this.onAddGenrePressed,
    required this.priceController,
    required this.score,
    required this.onScoreChanged,
    required this.onStarTap,
    this.supportsPrice = false,
    this.isGradeable = false,
    this.isThematic = false,
    this.ratingScale = 10,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 1,
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, "Categorización y Valoración"),
            const SizedBox(height: 16),

            if (isGradeable) ...[
              _buildScoreSection(context),
              const SizedBox(height: 16),
            ],

            if (isThematic) ...[
              _buildGenreDropdown(context),
              const SizedBox(height: 16),
            ],

            if (supportsPrice) ...[
              TextFormField(
                controller: priceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: "Precio pagado",
                  prefixIcon: const Icon(Icons.euro_rounded),
                  suffixText: "€",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildScoreSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final maxScore = ratingScale.toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                "Puntuación Personal",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                score.toStringAsFixed(ratingScale == 100 ? 0 : 1),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: score.clamp(0, maxScore),
                min: 0,
                max: maxScore,
                divisions: ratingScale == 5
                    ? 10
                    : (ratingScale == 100 ? 100 : 20),
                label: score.toStringAsFixed(ratingScale == 100 ? 0 : 1),
                onChanged: (val) => onScoreChanged(val.toString()),
              ),
            ),
            // Star visualization
            ...List.generate(5, (index) {
              double fraction;
              if (ratingScale == 5) {
                fraction = score - index;
              } else if (ratingScale == 100) {
                fraction = (score / 20.0) - index;
              } else {
                fraction = (score / 2.0) - index;
              }

              IconData icon;
              if (fraction >= 0.75) {
                icon = Icons.star;
              } else if (fraction >= 0.25) {
                icon = Icons.star_half;
              } else {
                icon = Icons.star_border;
              }

              return GestureDetector(
                onTap: () {
                  double newScore;
                  if (ratingScale == 5) {
                    newScore = (index + 1).toDouble();
                  } else if (ratingScale == 100) {
                    newScore = (index + 1) * 20.0;
                  } else {
                    newScore = (index + 1) * 2.0;
                  }
                  onStarTap(newScore);
                },
                child: Icon(icon, color: colorScheme.primary, size: 28),
              );
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildGenreDropdown(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: availableGenres.isNotEmpty
              ? DropdownButtonFormField<String>(
                  value:
                      (genre != null &&
                          availableGenres.any((g) => g.name == genre))
                      ? genre
                      : null,
                  decoration: InputDecoration(
                    labelText: "Género / Categoría",
                    prefixIcon: const Icon(Icons.category_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text("Sin categoría"),
                    ),
                    ...availableGenres.map(
                      (g) =>
                          DropdownMenuItem(value: g.name, child: Text(g.name)),
                    ),
                  ],
                  onChanged: onGenreChanged,
                  onSaved: onGenreSaved,
                )
              : TextFormField(
                  initialValue: genre,
                  decoration: InputDecoration(
                    labelText: "Género / Categoría",
                    prefixIcon: const Icon(Icons.category_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onSaved: onGenreSaved,
                  onChanged: onGenreChanged,
                ),
        ),
        if (onAddGenrePressed != null) ...[
          const SizedBox(width: 8),
          Container(
            margin: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: onAddGenrePressed,
              icon: const Icon(Icons.add_circle_outline),
              color: Theme.of(context).colorScheme.primary,
              tooltip: 'Añadir nuevo género',
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
