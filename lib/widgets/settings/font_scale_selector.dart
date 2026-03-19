import 'package:flutter/material.dart';
import '../../providers/settings/settings_provider.dart';

/// Widget especializado para ajustar el tamaño de fuente mediante un slider.
class FontScaleSelector extends StatelessWidget {
  final SettingsProvider settings;

  const FontScaleSelector({
    super.key,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.text_fields_rounded, size: 16, color: Colors.grey),
            Expanded(
              child: Slider(
                value: settings.fontScale,
                min: 0.85,
                max: 1.40,
                divisions: 5,
                activeColor: theme.colorScheme.primary,
                onChanged: (val) => settings.setFontScale(val),
              ),
            ),
            const Icon(Icons.text_fields_rounded, size: 32, color: Colors.grey),
          ],
        ),
      ],
    );
  }
}
