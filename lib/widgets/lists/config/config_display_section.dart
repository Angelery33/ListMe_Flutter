import 'package:flutter/material.dart';

class ConfigDisplaySection extends StatelessWidget {
  final bool isThematic;
  final int genreLayoutMode;
  final ValueChanged<int> onGenreLayoutModeChanged;

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
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Configuración de Visualización",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),
          RadioListTile<int>(
            title: const Text("Ignorar Temáticas"),
            subtitle: const Text("Estándar / Mezclado"),
            value: 0,
            groupValue: genreLayoutMode,
            onChanged: (v) {
              if (v != null) onGenreLayoutModeChanged(v);
            },
          ),
          RadioListTile<int>(
            title: const Text("Secciones con Cabeceras"),
            subtitle: const Text("Agrupar ítems por su tema con un título"),
            value: 1,
            groupValue: genreLayoutMode,
            onChanged: (v) {
              if (v != null) onGenreLayoutModeChanged(v);
            },
          ),
          RadioListTile<int>(
            title: const Text("Agrupado sin Cabeceras"),
            subtitle: const Text("Ordenados por tema pero de forma continua"),
            value: 2,
            groupValue: genreLayoutMode,
            onChanged: (v) {
              if (v != null) onGenreLayoutModeChanged(v);
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
