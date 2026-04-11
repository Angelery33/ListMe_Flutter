import 'package:flutter/material.dart';

class ConfigRatingProgressSection extends StatelessWidget {
  final bool isGradeable;
  final int ratingScale;
  final ValueChanged<int> onRatingScaleChanged;

  final bool supportsProgress;
  final String? progressType;
  final ValueChanged<String?> onProgressTypeChanged;
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
                "Configuración de Puntuación",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                initialValue: ratingScale,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Escala de Puntuación',
                  prefixIcon: Icon(Icons.score),
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 5,
                    child: Text("Sobre 5 Estrellas (1-5)"),
                  ),
                  DropdownMenuItem(
                    value: 10,
                    child: Text("Sobre 10 (Estándar)"),
                  ),
                  DropdownMenuItem(
                    value: 100,
                    child: Text("Sobre 100 (Porcentaje)"),
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
                "Configuración de Progreso",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: progressType,
                decoration: const InputDecoration(
                  labelText: 'Tipo de seguimiento',
                  prefixIcon: Icon(Icons.settings_overscan),
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: null, child: Text("Ninguno")),
                  DropdownMenuItem(value: "Manual", child: Text("Manual")),
                  DropdownMenuItem(value: "Libro", child: Text("Libro")),
                  DropdownMenuItem(value: "Serie", child: Text("Serie")),
                  DropdownMenuItem(value: "Anime", child: Text("Anime")),
                  DropdownMenuItem(value: "Manga", child: Text("Manga")),
                ],
                onChanged: onProgressTypeChanged,
              ),
              if (progressType == "Manual") ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: customProgressUnitController,
                  decoration: const InputDecoration(
                    labelText: 'Unidad personalizada',
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
