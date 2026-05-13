import 'package:flutter/material.dart';
import '../../../core/i18n/l10n_extension.dart';

class ConfigDisplaySection extends StatelessWidget {
  final bool isThematic;
  final int genreLayoutMode;
  final ValueChanged<int?> onGenreLayoutModeChanged;

  const ConfigDisplaySection({
    super.key,
    required this.isThematic,
    required this.genreLayoutMode,
    required this.onGenreLayoutModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (!isThematic) return const SizedBox.shrink();

    return Card(
      elevation: 2,
      child: RadioGroup<int>(
        groupValue: genreLayoutMode,
        onChanged: onGenreLayoutModeChanged,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                context.l10n.listConfigDisplay,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            RadioListTile<int>(
              title: Text(context.l10n.commonNone),
              subtitle: Text(context.l10n.commonAll),
              value: 0,
            ),
            RadioListTile<int>(
              title: Text(context.l10n.listConfigCompact),
              subtitle: Text(context.l10n.listConfigThematic),
              value: 1,
            ),
            RadioListTile<int>(
              title: Text(context.l10n.listConfigCompact),
              subtitle: Text(context.l10n.listConfigCompactSubtitle),
              value: 2,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
