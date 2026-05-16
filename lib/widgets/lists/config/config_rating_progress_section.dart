import 'package:flutter/material.dart';
import '../../../core/i18n/l10n_extension.dart';

/// Sección de configuración que controla la escala de puntuación y el tipo de
/// seguimiento de progreso para una biblioteca.
///
/// Se renderiza de forma condicional:
/// - La subsección de puntuación aparece solo cuando [isGradeable] es `true`.
/// - La subsección de progreso aparece solo cuando [supportsProgress] es `true`.
/// - Si no se establece ninguno de los indicadores, el widget devuelve un [SizedBox] vacío.
class ConfigRatingProgressSection extends StatelessWidget {
  /// Indica si los elementos de esta biblioteca pueden recibir una puntuación numérica.
  final bool isGradeable;

  /// La escala de puntuación actualmente seleccionada (5, 10 o 100).
  final int ratingScale;

  /// Se llama cuando el usuario elige una escala de puntuación diferente del desplegable.
  final ValueChanged<int> onRatingScaleChanged;

  /// Indica si los elementos de esta biblioteca rastrean un contador de progreso.
  final bool supportsProgress;

  /// La clave de tipo de progreso actualmente seleccionada (ej. `"Libro"`, `"Manga"`,
  /// `"Anime"`, `"Serie"`, `"Manual"`, o `null` para ninguno).
  final String? progressType;

  /// Se llama cuando el usuario selecciona un tipo de progreso diferente.
  final ValueChanged<String?> onProgressTypeChanged;

  /// Controlador para la etiqueta de unidad de progreso personalizada que se muestra cuando [progressType]
  /// es `"Manual"` (ej. "Artículo", "Nivel", "Misión").
  final TextEditingController customProgressUnitController;

  const ConfigRatingProgressSection({
    super.key,
    required this.isGradeable,
    required this.ratingScale,
    required this.onRatingScaleChanged,
    required this.supportsProgress,
    required this.progressType,
    required this.onProgressTypeChanged,
    required this.customProgressUnitController,
  });

  @override
  Widget build(BuildContext context) {
    if (!isGradeable && !supportsProgress) return const SizedBox.shrink();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isGradeable) ...[
              Text(
                context.l10n.itemScore,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                initialValue: ratingScale,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: context.l10n.itemScore,
                  prefixIcon: Icon(Icons.score),
                  border: OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(
                    value: 5,
                    child: Text(context.l10n.ratingScale5),
                  ),
                  DropdownMenuItem(
                    value: 10,
                    child: Text(context.l10n.ratingScale10),
                  ),
                  DropdownMenuItem(
                    value: 100,
                    child: Text(context.l10n.ratingScale100),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) onRatingScaleChanged(val);
                },
              ),
              if (supportsProgress) const SizedBox(height: 24),
            ],

            if (supportsProgress) ...[
              Text(
                context.l10n.listConfigProgress,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: progressType,
                decoration: InputDecoration(
                  labelText: context.l10n.listConfigProgressType,
                  prefixIcon: Icon(Icons.settings_overscan),
                  border: OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(value: null, child: Text(context.l10n.commonNone)),
                  DropdownMenuItem(value: "Manual", child: Text(context.l10n.progressTypeManual)),
                  DropdownMenuItem(value: "Libro", child: Text(context.l10n.progressTypeBook)),
                  DropdownMenuItem(value: "Serie", child: Text(context.l10n.progressTypeSeries)),
                  DropdownMenuItem(value: "Anime", child: Text(context.l10n.progressTypeAnime)),
                  DropdownMenuItem(value: "Manga", child: Text(context.l10n.progressTypeManga)),
                ],
                onChanged: onProgressTypeChanged,
              ),
              if (progressType == "Manual") ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: customProgressUnitController,
                  decoration: InputDecoration(
                    labelText: context.l10n.listConfigProgressType,
                    hintText: 'ej: Artículo, Nivel, Misión...',
                    prefixIcon: Icon(Icons.edit),
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
