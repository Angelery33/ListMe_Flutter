import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../data/items/item_model.dart';
import '../../../../data/lists/list_model.dart';
import '../../../../providers/items/item_details_provider.dart';

class DetailProgressSection extends StatelessWidget {
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

    if (progressType == null) {
      return _buildBasicProgress(context, item, provider);
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
                'PROGRESO ACTUAL',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._buildProgressFields(context, item, provider, progressType),
        ],
      ),
    );
  }

  Widget _buildBasicProgress(
    BuildContext context,
    ItemModel item,
    ItemDetailsProvider provider,
  ) {
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
                'PROGRESO ($unit)'.toUpperCase(),
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
              if (total == null || current < total)
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
              else
                const Icon(Icons.check_circle, color: Colors.green, size: 36),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildProgressFields(
    BuildContext context,
    ItemModel item,
    ItemDetailsProvider provider,
    String? progressType,
  ) {
    List<Widget> widgets = [];

    if (progressType == 'Libro') {
      if (item.totalChapter != null && item.totalChapter! > 0) {
        widgets.add(
          _buildProgressRow(
            context,
            'Capítulo',
            item.chapter ?? 0,
            item.totalChapter,
            () => provider.updateProgressField(
              'chapter',
              (item.chapter ?? 0) + 1,
            ),
            () => provider.updateProgressField(
              'chapter',
              (item.chapter ?? 0) - 1,
            ),
          ),
        );
      }
      if (item.totalPage != null && item.totalPage! > 0) {
        widgets.add(
          _buildProgressRow(
            context,
            'Página',
            item.page ?? 0,
            item.totalPage,
            () => provider.updateProgressField('page', (item.page ?? 0) + 1),
            () => provider.updateProgressField('page', (item.page ?? 0) - 1),
          ),
        );
      }
    } else if (progressType == 'Serie' || progressType == 'Anime') {
      if (item.totalSeason != null && item.totalSeason! > 0) {
        widgets.add(
          _buildProgressRow(
            context,
            'Temporada',
            item.season ?? 0,
            item.totalSeason,
            () =>
                provider.updateProgressField('season', (item.season ?? 0) + 1),
            () =>
                provider.updateProgressField('season', (item.season ?? 0) - 1),
          ),
        );
      }
      if (item.totalChapter != null && item.totalChapter! > 0) {
        widgets.add(
          _buildProgressRow(
            context,
            'Episodio',
            item.chapter ?? 0,
            item.totalChapter,
            () => provider.updateProgressField(
              'chapter',
              (item.chapter ?? 0) + 1,
            ),
            () => provider.updateProgressField(
              'chapter',
              (item.chapter ?? 0) - 1,
            ),
          ),
        );
      }
    } else if (progressType == 'Manga') {
      if (item.totalVolume != null && item.totalVolume! > 0) {
        widgets.add(
          _buildProgressRow(
            context,
            'Tomo',
            item.volume ?? 0,
            item.totalVolume,
            () =>
                provider.updateProgressField('volume', (item.volume ?? 0) + 1),
            () =>
                provider.updateProgressField('volume', (item.volume ?? 0) - 1),
          ),
        );
      }
      if (item.totalChapter != null && item.totalChapter! > 0) {
        widgets.add(
          _buildProgressRow(
            context,
            'Capítulo',
            item.chapter ?? 0,
            item.totalChapter,
            () => provider.updateProgressField(
              'chapter',
              (item.chapter ?? 0) + 1,
            ),
            () => provider.updateProgressField(
              'chapter',
              (item.chapter ?? 0) - 1,
            ),
          ),
        );
      }
      if (item.totalPage != null && item.totalPage! > 0) {
        widgets.add(
          _buildProgressRow(
            context,
            'Página',
            item.page ?? 0,
            item.totalPage,
            () => provider.updateProgressField('page', (item.page ?? 0) + 1),
            () => provider.updateProgressField('page', (item.page ?? 0) - 1),
          ),
        );
      }
    } else {
      widgets.add(
        _buildProgressRow(
          context,
          library?.customProgressUnit ?? item.progressUnit ?? 'Progreso',
          item.currentProgress ?? 0,
          item.totalProgress,
          () => provider.incrementProgress(),
          () => provider.decrementProgress(),
        ),
      );
    }

    return widgets;
  }

  Widget _buildProgressRow(
    BuildContext context,
    String label,
    int current,
    int? total,
    VoidCallback onIncrement,
    VoidCallback onDecrement,
  ) {
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
                child: Text(
                  '$label: $current${total != null ? ' / $total' : ''}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
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
