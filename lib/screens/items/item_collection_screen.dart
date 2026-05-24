import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/i18n/l10n_extension.dart';
import '../../core/utils/item_grouping_helper.dart';

import '../../data/items/item_model.dart';
import '../../data/lists/list_model.dart';
import '../../providers/items/item_details_provider.dart';
import '../../widgets/items/compact_item_card.dart';
import '../../widgets/shared/custom_gradient_app_bar.dart';
import 'item_detail_screen.dart';

enum _CollectionSort { score, name }

/// Pantalla que muestra los sub-elementos de una colección agrupados por estado
/// y ordenados por puntuación o alfabéticamente dentro de cada grupo.
class ItemCollectionScreen extends StatefulWidget {
  final ItemModel parent;
  final ListModel? list;

  const ItemCollectionScreen({super.key, required this.parent, this.list});

  @override
  State<ItemCollectionScreen> createState() => _ItemCollectionScreenState();
}

class _ItemCollectionScreenState extends State<ItemCollectionScreen> {
  _CollectionSort _sort = _CollectionSort.score;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ItemDetailsProvider>().loadSubItems();
    });
  }

  Future<void> _openSubItem(ItemModel sub) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ItemDetailScreen(item: sub, list: widget.list),
      ),
    );
    if (mounted) {
      await context.read<ItemDetailsProvider>().loadSubItems();
    }
  }

  Future<void> _addSubItem() async {
    final result = await Navigator.pushNamed(
      context,
      '/item-entry',
      arguments: {'list': widget.list, 'parentId': widget.parent.id},
    );
    if (result == true && mounted) {
      await context.read<ItemDetailsProvider>().loadSubItems();
    }
  }

  Map<String, List<ItemModel>> _groupAndSort(List<ItemModel> items) {
    final sorted = List<ItemModel>.from(items);
    if (_sort == _CollectionSort.score) {
      sorted.sort((a, b) => (b.score ?? -1).compareTo(a.score ?? -1));
    } else {
      sorted.sort((a, b) => a.name.compareTo(b.name));
    }

    const statusOrder = ['IN_PROGRESS', 'PENDING', 'PAUSED', 'DROPPED', 'COMPLETED'];
    const statusToKey = {
      'PENDING': kGroupKeyPending,
      'IN_PROGRESS': kGroupKeyInProgress,
      'PAUSED': kGroupKeyPaused,
      'DROPPED': kGroupKeyDropped,
      'COMPLETED': kGroupKeyCompleted,
    };

    final hasAnyStatus = sorted.any((i) => i.status != null && i.status != 'PENDING');

    if (!hasAnyStatus) return {'': sorted};

    final grouped = <String, List<ItemModel>>{};
    for (final status in statusOrder) {
      final key = statusToKey[status]!;
      final group = sorted.where((i) => i.status == status).toList();
      if (group.isNotEmpty) grouped[key] = group;
    }
    final knownStatuses = statusToKey.keys.toSet();
    final rest = sorted.where((i) => !knownStatuses.contains(i.status)).toList();
    if (rest.isNotEmpty) grouped[kGroupKeyPending] ??= rest;

    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ItemDetailsProvider>();
    final subItems = provider.subItems;
    final grouped = _groupAndSort(subItems);
    final canEdit = widget.list?.canEdit ?? true;

    return Scaffold(
      appBar: CustomGradientAppBar(
        title: '${widget.parent.name} · ${context.l10n.collectionTitle}',
        showBackButton: true,
        actions: [
          IconButton(
            icon: Icon(
              _sort == _CollectionSort.score
                  ? Icons.sort_by_alpha
                  : Icons.star_outline,
            ),
            tooltip: _sort == _CollectionSort.score
                ? context.l10n.sortNameAZ
                : context.l10n.sortScore,
            onPressed: () => setState(() {
              _sort = _sort == _CollectionSort.score
                  ? _CollectionSort.name
                  : _CollectionSort.score;
            }),
          ),
        ],
      ),
      floatingActionButton: canEdit
          ? FloatingActionButton(
              onPressed: _addSubItem,
              tooltip: context.l10n.collectionAddItem,
              child: const Icon(Icons.add_rounded),
            )
          : null,
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : subItems.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.collections_bookmark_outlined, size: 64),
                        const SizedBox(height: 16),
                        Text(
                          context.l10n.collectionEmpty,
                          style: const TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
                  children: [
                    for (final entry in grouped.entries) ...[
                      if (entry.key.isNotEmpty)
                        _SectionHeader(groupKey: entry.key),
                      _CollectionGrid(
                        items: entry.value,
                        list: widget.list,
                        onTap: _openSubItem,
                      ),
                      const SizedBox(height: 12),
                    ],
                  ],
                ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String groupKey;
  const _SectionHeader({required this.groupKey});

  @override
  Widget build(BuildContext context) {
    final label = groupLabelFor(context, groupKey);
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 6, left: 4),
      child: Text(
        label.toUpperCase(),
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _CollectionGrid extends StatelessWidget {
  final List<ItemModel> items;
  final ListModel? list;
  final void Function(ItemModel) onTap;

  const _CollectionGrid({
    required this.items,
    required this.list,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = (constraints.maxWidth / 90).floor().clamp(2, 12);
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            childAspectRatio: 9 / (16 * 0.8),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final sub = items[index];
            return CompactItemCard(
              item: sub,
              isGradeable: list?.gradeable ?? true,
              supportsProgress: list?.supportsProgress ?? false,
              onTap: () => onTap(sub),
            );
          },
        );
      },
    );
  }
}
