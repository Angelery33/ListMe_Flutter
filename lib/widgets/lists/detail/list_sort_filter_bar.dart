import 'package:flutter/material.dart';
import '../../../core/utils/item_grouping_helper.dart';

class ListSortFilterBar extends StatelessWidget {
  final SortOption currentSort;
  final Function(SortOption) onSortChanged;
  final String? currentGenre;
  final List<String> availableGenres;
  final Function(String?) onGenreChanged;
  final bool supportsPrice;
  final bool isStatsVisible;
  final VoidCallback? onStatsToggle;

  const ListSortFilterBar({
    super.key,
    required this.currentSort,
    required this.onSortChanged,
    required this.currentGenre,
    required this.availableGenres,
    required this.onGenreChanged,
    this.supportsPrice = false,
    this.isStatsVisible = true,
    this.onStatsToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Sort and filter row
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
            child: Row(
              children: [
                // Stats toggle — solo si la lista soporta precios
                if (supportsPrice) ...[
                  IconButton(
                    icon: Icon(
                      isStatsVisible
                          ? Icons.insert_chart
                          : Icons.insert_chart_outlined,
                      color: isStatsVisible ? colorScheme.primary : Colors.grey,
                      size: 20,
                    ),
                    tooltip: isStatsVisible
                        ? 'Ocultar estadísticas'
                        : 'Mostrar estadísticas',
                    onPressed: onStatsToggle,
                  ),
                  Container(
                    height: 24,
                    width: 1,
                    color: colorScheme.outlineVariant,
                  ),
                  const SizedBox(width: 4),
                ],
                // Botón de Ordenación
                PopupMenuButton<SortOption>(
                  icon: Icon(Icons.sort_rounded, color: colorScheme.primary),
                  tooltip: "Ordenar",
                  initialValue: currentSort,
                  onSelected: onSortChanged,
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<SortOption>>[
                        const PopupMenuItem(
                          value: SortOption.dateNewest,
                          child: Text('Fecha (Más reciente)'),
                        ),
                        const PopupMenuItem(
                          value: SortOption.dateOldest,
                          child: Text('Fecha (Más antiguo)'),
                        ),
                        const PopupMenuItem(
                          value: SortOption.nameAsc,
                          child: Text('Nombre (A-Z)'),
                        ),
                        const PopupMenuItem(
                          value: SortOption.nameDesc,
                          child: Text('Nombre (Z-A)'),
                        ),
                        const PopupMenuItem(
                          value: SortOption.scoreHighLow,
                          child: Text('Puntuación (Alta-Baja)'),
                        ),
                        const PopupMenuItem(
                          value: SortOption.scoreLowHigh,
                          child: Text('Puntuación (Baja-Alta)'),
                        ),
                      ],
                ),
                const SizedBox(width: 8),
                Container(
                  height: 24,
                  width: 1,
                  color: colorScheme.outlineVariant,
                ),
                const SizedBox(width: 8),

                // Chips de Género
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FilterChip(
                          label: const Text('Todos'),
                          selected: currentGenre == null,
                          onSelected: (selected) => onGenreChanged(null),
                          visualDensity: VisualDensity.compact,
                        ),
                        const SizedBox(width: 8),
                        ...availableGenres.map((genre) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: FilterChip(
                              label: Text(genre),
                              selected: currentGenre == genre,
                              onSelected: (selected) =>
                                  onGenreChanged(selected ? genre : null),
                              visualDensity: VisualDensity.compact,
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
