import 'package:flutter/material.dart';
import '../../providers/settings/settings_provider.dart';

/// Widget especializado para ajustar el tamaño de fuente mediante un slider.
///
/// Renderiza un [Slider] entre factores de escala pequeños (0.85×) y grandes (1.40×)
/// con dos iconos indicadores de tamaño decorativos en cada extremo. Mover el control deslizante
/// aplica inmediatamente la nueva escala a través de [SettingsProvider.setFontScale].
class FontScaleSelector extends StatelessWidget {
  /// El proveedor de ajustes que contiene [SettingsProvider.fontScale] y expone
  /// [SettingsProvider.setFontScale]. Suministrado por el llamador para que el widget
  /// no necesite su propia búsqueda de Provider.
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
