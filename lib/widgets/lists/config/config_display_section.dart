import 'package:flutter/material.dart';

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
                "Configuración de Visualización",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const RadioListTile<int>(
              title: Text("Ignorar Temáticas"),
              subtitle: Text("Estándar / Mezclado"),
              value: 0,
            ),
            const RadioListTile<int>(
              title: Text("Secciones con Cabeceras"),
              subtitle: Text("Agrupar ítems por su tema con un título"),
              value: 1,
            ),
            const RadioListTile<int>(
              title: Text("Agrupado sin Cabeceras"),
              subtitle: Text("Ordenados por tema pero de forma continua"),
              value: 2,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
