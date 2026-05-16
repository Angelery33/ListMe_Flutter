import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/i18n/l10n_extension.dart';
import '../../../../data/items/item_model.dart';
import '../../../../data/lists/list_model.dart';
import '../../../../providers/items/item_details_provider.dart';

/// Muestra controles de seguimiento de progreso para un elemento en la pantalla de detalle.
///
/// Se adapta al [ListModel.progressType] de la biblioteca: los libros muestran capítulos y
/// páginas; las series/anime muestran temporadas y episodios; el manga muestra volúmenes, capítulos
/// y páginas; Funko muestra la cantidad; todo lo demás utiliza un contador genérico.
/// Los botones de incrementar/decrementar llaman a [ItemDetailsProvider] para que
/// los cambios se guarden inmediatamente.
class DetailProgressSection extends StatelessWidget {
  /// La biblioteca propietaria cuya configuración de [ListModel.progressType], [ListModel.canEdit] y
  /// [ListModel.supportsProgress] controla el comportamiento de la sección.
  final ListModel? library;

  const DetailProgressSection({super.key, this.library});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ItemDetailsProvider>();
    final item = provider.item;

    final supportsProgress =
        library?.supportsProgress ?? (item?.totalProgress != null);
    if (item == null || !supportsProgress) return const SizedBox.shrink();

    final progressType = library?.progressType;
    final canEdit = library?.canEdit ?? true;

    if (progressType == null) {
      return _buildBasicProgress(context, item, provider, canEdit: canEdit);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(
              context,
            ).colorScheme.primaryContainer.withValues(alpha: 0.5),
            Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.trending_up,
                size: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                context.l10n.progressProgress.toUpperCase(),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._buildProgressFields(context, item, provider, progressType, canEdit: canEdit),
        ],
      ),
    );
  }

  /// Renderiza una barra de progreso simple con un botón "+1" para bibliotecas que no
  /// definen un [progressType] estructurado. Muestra una marca de verificación verde una vez que el
  /// elemento está completado.
  Widget _buildBasicProgress(
    BuildContext context,
    ItemModel item,
    ItemDetailsProvider provider, {
    bool canEdit = true,
  }) {
    final current = item.currentProgress ?? 0;
    final total = item.totalProgress;
    final unit = item.progressUnit ?? 'unidades';
    final percentage = (total != null && total > 0)
        ? (current / total).clamp(0.0, 1.0)
        : 0.0;

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${context.l10n.progressProgress} ($unit)".toUpperCase(),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                '$current ${total != null && total > 0 ? '/ $total' : ''}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: percentage,
                    minHeight: 12,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      percentage == 1.0
                          ? Colors.green
                          : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              if (canEdit && (total == null || current < total))
                ElevatedButton.icon(
                  onPressed: () => provider.incrementProgress(),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('1'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                )
              else if (total != null && current >= total)
                const Icon(Icons.check_circle, color: Colors.green, size: 36),
            ],
          ),
        ],
      ),
    );
  }

  /// Devuelve la lista de filas de campos de progreso apropiadas para [progressType].
  /// Cada fila es producida por [_buildProgressRow] y conectada al método del
  /// proveedor correspondiente para que al pulsar incrementar/decrementar se guarde el cambio.
  List<Widget> _buildProgressFields(
    BuildContext context,
    ItemModel item,
    ItemDetailsProvider provider,
    String? progressType, {
    bool canEdit = true,
  }) {
    List<Widget> widgets = [];

    if (progressType == 'Libro') {
      widgets.add(
        _buildProgressRow(
          context,
          context.l10n.progressChapter,
          item.chapter ?? 0,
          item.totalChapter,
          () => provider.updateProgressField('chapter', (item.chapter ?? 0) + 1),
          () => provider.updateProgressField('chapter', (item.chapter ?? 0) - 1),
          (val) => provider.updateProgressField('chapter', val),
          canEdit: canEdit,
        ),
      );
      widgets.add(
        _buildProgressRow(
          context,
          context.l10n.progressPage,
          item.page ?? 0,
          item.totalPage,
          () => provider.updateProgressField('page', (item.page ?? 0) + 1),
          () => provider.updateProgressField('page', (item.page ?? 0) - 1),
          (val) => provider.updateProgressField('page', val),
          canEdit: canEdit,
        ),
      );
    } else if (progressType == 'Serie' || progressType == 'Anime') {
      widgets.add(
        _buildProgressRow(
          context,
          context.l10n.progressSeason,
          item.season ?? 0,
          item.totalSeason,
          () => provider.updateProgressField('season', (item.season ?? 0) + 1),
          () => provider.updateProgressField('season', (item.season ?? 0) - 1),
          (val) => provider.updateProgressField('season', val),
          canEdit: canEdit,
        ),
      );
      widgets.add(
        _buildProgressRow(
          context,
          context.l10n.progressEpisode,
          item.chapter ?? 0,
          item.totalChapter,
          () => provider.updateProgressField('chapter', (item.chapter ?? 0) + 1),
          () => provider.updateProgressField('chapter', (item.chapter ?? 0) - 1),
          (val) => provider.updateProgressField('chapter', val),
          canEdit: canEdit,
        ),
      );
    } else if (progressType == 'Manga') {
      widgets.add(
        _buildProgressRow(
          context,
          context.l10n.progressVolume,
          item.volume ?? 0,
          item.totalVolume,
          () => provider.updateProgressField('volume', (item.volume ?? 0) + 1),
          () => provider.updateProgressField('volume', (item.volume ?? 0) - 1),
          (val) => provider.updateProgressField('volume', val),
          canEdit: canEdit,
        ),
      );
      widgets.add(
        _buildProgressRow(
          context,
          context.l10n.progressChapter,
          item.chapter ?? 0,
          item.totalChapter,
          () => provider.updateProgressField('chapter', (item.chapter ?? 0) + 1),
          () => provider.updateProgressField('chapter', (item.chapter ?? 0) - 1),
          (val) => provider.updateProgressField('chapter', val),
          canEdit: canEdit,
        ),
      );
      widgets.add(
        _buildProgressRow(
          context,
          context.l10n.progressPage,
          item.page ?? 0,
          item.totalPage,
          () => provider.updateProgressField('page', (item.page ?? 0) + 1),
          () => provider.updateProgressField('page', (item.page ?? 0) - 1),
          (val) => provider.updateProgressField('page', val),
          canEdit: canEdit,
        ),
      );
    } else {
      widgets.add(
        _buildProgressRow(
          context,
          library?.customProgressUnit ??
              item.progressUnit ??
              context.l10n.progressProgress,
          item.currentProgress ?? 0,
          item.totalProgress,
          () => provider.incrementProgress(),
          () => provider.decrementProgress(),
          (val) => provider.updateProgress(val, item.totalProgress),
          canEdit: canEdit,
        ),
      );
    }

    return widgets;
  }

  /// Construye una única fila de progreso etiquetada que muestra [current] / [total] con
  /// botones de decrementar e incrementar. El texto de la etiqueta es pulsable (cuando
  /// [canEdit]) para abrir un diálogo para escribir manualmente un valor exacto, que
  /// luego llama a [onManualSet].
  ///
  /// [onIncrement] se llama cuando se pulsa el botón "+".
  /// [onDecrement] se llama cuando se pulsa el botón "-".
  /// [onManualSet] se llama con el entero analizado cuando el usuario envía el
  /// diálogo de entrada manual.
  Widget _buildProgressRow(
    BuildContext context,
    String label,
    int current,
    int? total,
    VoidCallback onIncrement,
    VoidCallback onDecrement,
    Function(int) onManualSet, {
    bool canEdit = true,
  }) {
    final percentage = (total != null && total > 0)
        ? (current / total * 100).toStringAsFixed(1)
        : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: canEdit
                      ? () async {
                          final controller =
                              TextEditingController(text: current.toString());
                          final newVal = await showDialog<int>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: Text('Establecer $label'),
                              content: TextField(
                                controller: controller,
                                keyboardType: TextInputType.number,
                                autofocus: true,
                                decoration: InputDecoration(
                                  suffixText: total != null ? '/ $total' : null,
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text('CANCELAR'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(
                                    ctx,
                                    int.tryParse(controller.text),
                                  ),
                                  child: const Text('GUARDAR'),
                                ),
                              ],
                            ),
                          );
                          if (newVal != null) {
                            onManualSet(newVal);
                          }
                        }
                      : null,
                  child: Text(
                    '$label: $current${total != null ? ' / $total' : ''}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      decoration: canEdit ? TextDecoration.underline : null,
                      decorationStyle: TextDecorationStyle.dotted,
                    ),
                  ),
                ),
              ),
              if (canEdit)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, size: 20),
                      onPressed: onDecrement,
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, size: 20),
                      onPressed: onIncrement,
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
              if (percentage != null) ...[
                const SizedBox(width: 12),
                Text(
                  '$percentage%',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
          if (total != null && total > 0) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: current / total,
                minHeight: 8,
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
