import 'package:flutter/material.dart';
import '../../../core/i18n/l10n_extension.dart';
import '../../../data/lists/library_genre_model.dart';

/// Sección de formulario para propiedades opcionales del elemento: puntuación personal, género y precio.
///
/// Cada bloque se muestra solo cuando la biblioteca lo admite a través del interruptor booleano
/// correspondiente ([isGradeable], [isThematic], [supportsPrice]).
class EntryPropertiesSection extends StatelessWidget {
  /// El nombre del género seleccionado actualmente, o nulo cuando no hay ninguno seleccionado.
  final String? genre;

  /// Opciones de género obtenidas de la configuración de la biblioteca para rellenar el
  /// menú desplegable. Recurre a un campo de texto libre cuando la lista está vacía.
  final List<LibraryGenreModel> availableGenres;

  /// Se llama cuando el valor del menú desplegable de género cambia durante la interacción.
  final Function(String?) onGenreChanged;

  /// Se llama con el valor del género seleccionado actualmente cuando se guarda el formulario.
  final Function(String?) onGenreSaved;

  /// Se llama cuando el usuario pulsa el botón de "añadir género" junto al menú desplegable.
  final VoidCallback? onAddGenrePressed;

  /// Controlador vinculado al campo de texto del precio.
  final TextEditingController priceController;

  /// Valor de puntuación actual reflejado en el campo numérico y la fila de estrellas.
  final double score;

  /// Se llama con la cadena de puntuación formateada cuando cambia el campo numérico.
  final Function(String) onScoreChanged;

  /// Se llama con la puntuación calculada cuando el usuario toca una estrella en la fila.
  final Function(double) onStarTap;

  /// Indica si se debe renderizar el campo de texto del precio.
  final bool supportsPrice;

  /// Indica si se debe renderizar el campo de puntuación y la fila de estrellas.
  final bool isGradeable;

  /// Indica si se debe renderizar el menú desplegable de género o el campo de texto libre.
  final bool isThematic;

  /// La escala de calificación (5, 10 o 100) que controla la conversión de estrella a puntuación.
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
    return Card(
      elevation: 1,
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, context.l10n.itemSectionProperties),
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
                  labelText: context.l10n.itemPrice,
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

  /// Construye el editor de puntuación: un campo de texto numérico limitado a [ratingScale]
  /// y una fila de cinco iconos de estrellas que establecen la puntuación al tocar.
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
                context.l10n.listConfigRatingTitle,
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
                score.toStringAsFixed(2),
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
              child: TextFormField(
                initialValue: score.toStringAsFixed(2),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  hintText: "0.00 - ${maxScore.toInt()}",
                  prefixIcon: const Icon(Icons.score_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                onChanged: (val) {
                  final parsed = double.tryParse(val);
                  if (parsed != null) {
                    final clamped = parsed.clamp(0.0, maxScore);
                    onScoreChanged(clamped.toStringAsFixed(2));
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
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

  /// Construye ya sea un menú desplegable (cuando [availableGenres] no está vacío) o un campo
  /// de texto libre para el género, además de un botón de icono opcional para añadir género.
  Widget _buildGenreDropdown(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: availableGenres.isNotEmpty
              ? DropdownButtonFormField<String>(
                  initialValue:
                      (genre != null &&
                          availableGenres.any((g) => g.name == genre))
                      ? genre
                      : null,
                  decoration: InputDecoration(
                    labelText: context.l10n.itemGenre,
                    prefixIcon: const Icon(Icons.category_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: null,
                      child: Text(context.l10n.commonNone),
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
                    labelText: context.l10n.itemGenre,
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
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              tooltip: context.l10n.listConfigGenresAdd,
            ),
          ),
        ],
      ],
    );
  }

  /// Renderiza la etiqueta del encabezado de la sección con estilo en color primario en mayúsculas.
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
