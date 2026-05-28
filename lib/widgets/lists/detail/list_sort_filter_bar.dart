import 'package:flutter/material.dart';
import '../../../core/i18n/l10n_extension.dart';
import '../../../core/utils/item_grouping_helper.dart';

/// Barra de herramientas que se muestra debajo de la barra de aplicaciones en la pantalla de detalles de la biblioteca.
///
/// Combina un menú emergente de ordenación, un interruptor opcional de estadísticas de precios y una
/// fila desplazable horizontalmente de [FilterChip]s de género para que el usuario pueda
/// filtrar rápidamente los elementos por género.
class ListSortFilterBar extends StatelessWidget {
  /// El orden de clasificación actualmente activo, mostrado como el elemento seleccionado en el menú emergente.
  final SortOption currentSort;

  /// Se llama cuando el usuario elige una opción de ordenación diferente del menú emergente.
  final Function(SortOption) onSortChanged;

  /// El filtro de género actualmente activo, o `null` cuando se selecciona "Todo".
  final String? currentGenre;

  /// La lista de nombres de género para renderizar como chips de filtro.
  final List<String> availableGenres;

  /// Se llama cuando el usuario toca un chip de género o el chip "Todo".
  /// Pasa el nombre del género seleccionado, o `null` cuando se toca "Todo".
  final Function(String?) onGenreChanged;

  /// Indica si esta biblioteca rastrea los precios de los elementos.
  /// Cuando es `true`, se muestra un botón de icono para alternar las estadísticas antes del botón de ordenación.
  final bool supportsPrice;

  /// Indica si el panel de estadísticas de precios está actualmente visible.
  /// Controla el icono relleno frente al contorneado en el botón de alternancia de estadísticas.
  final bool isStatsVisible;

  /// Se llama cuando el usuario toca el botón de icono para alternar las estadísticas.
  /// Solo relevante cuando [supportsPrice] es `true`.
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
          // Fila de ordenación y filtrado
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
                        ? context.l10n.commonClose
                        : context.l10n.commonAll,
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
                  tooltip: context.l10n.sortTitle,
                  initialValue: currentSort,
                  onSelected: onSortChanged,
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<SortOption>>[
                        PopupMenuItem(
                          value: SortOption.dateNewest,
                          child: Text(context.l10n.sortDateNewest),
                        ),
                        PopupMenuItem(
                          value: SortOption.dateOldest,
                          child: Text(context.l10n.sortDateOldest),
                        ),
                        PopupMenuItem(
                          value: SortOption.nameAsc,
                          child: Text(context.l10n.sortNameAZ),
                        ),
                        PopupMenuItem(
                          value: SortOption.nameDesc,
                          child: Text(context.l10n.sortNameZA),
                        ),
                        PopupMenuItem(
                          value: SortOption.scoreHighLow,
                          child: Text(context.l10n.sortScoreHighLow),
                        ),
                        PopupMenuItem(
                          value: SortOption.scoreLowHigh,
                          child: Text(context.l10n.sortScoreLowHigh),
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
                          label: Text(context.l10n.commonAll),
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
