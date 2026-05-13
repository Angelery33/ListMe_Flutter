import 'package:flutter/material.dart';
import '../../../core/i18n/l10n_extension.dart';

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
