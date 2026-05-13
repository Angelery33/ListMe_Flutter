import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/i18n/l10n_extension.dart';

import '../../../data/items/item_model.dart';
import '../../../data/lists/list_model.dart';
import '../../../providers/items/item_details_provider.dart';
import '../../../providers/items/items_provider.dart';
import '../../../screens/items/item_collection_screen.dart';
import '../../../screens/items/item_detail_screen.dart';
import '../../shared/universal_image.dart';

class DetailCollectionSection extends StatelessWidget {
  final ListModel? library;

  const DetailCollectionSection({super.key, this.library});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ItemDetailsProvider>();
    final item = provider.item;

    if (item == null || !item.collection) return const SizedBox.shrink();

    final subItems = provider.subItems;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CollectionHeader(item: item, library: library, count: subItems.length),
          const SizedBox(height: 8),
          if (subItems.isEmpty)
            _EmptyCollection(item: item)
          else
            _CollectionStrip(items: subItems, library: library),
        ],
      ),
    );
  }
}

class _CollectionHeader extends StatelessWidget {
  final ItemModel item;
  final ListModel? library;
  final int count;

  const _CollectionHeader({
    required this.item,
    required this.library,
    required this.count,
  });

  Future<void> _openGrid(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ItemCollectionScreen(parent: item, list: library),
      ),
    );
    if (context.mounted) {
      await context.read<ItemDetailsProvider>().loadSubItems();
    }
  }

  Future<void> _addItem(BuildContext context) async {
    final result = await Navigator.pushNamed(
      context,
      '/item-entry',
      arguments: {'list': library, 'parentId': item.id},
    );
    if (result == true && context.mounted) {
      await context.read<ItemDetailsProvider>().loadSubItems();
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            '${context.l10n.collectionTitle} ($count)',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: primary,
                  letterSpacing: 1.2,
                ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.grid_view),
          tooltip: context.l10n.collectionViewAll,
          color: primary,
          onPressed: () => _openGrid(context),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          tooltip: context.l10n.collectionAddItem,
          color: primary,
          onPressed: () => _addItem(context),
        ),
      ],
    );
  }
}

class _EmptyCollection extends StatelessWidget {
  final ItemModel item;

  const _EmptyCollection({required this.item});

  Future<void> _generate(BuildContext context) async {
    final detailsProvider = context.read<ItemDetailsProvider>();
    final itemsProvider = context.read<ItemsProvider>();
    final messenger = ScaffoldMessenger.of(context);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ctx.l10n.collectionGenerateTitle),
        content: Text(ctx.l10n.collectionGenerateConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(ctx.l10n.commonCancel.toUpperCase()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(ctx.l10n.commonAccept.toUpperCase()),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final created = await detailsProvider.generateVolumes();
    if (created > 0) {
      await itemsProvider.fetchItemsByLibrary(item.idLibrary);
    }
    messenger.showSnackBar(
      SnackBar(content: Text(context.l10n.collectionGenerateResult(created))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ItemDetailsProvider>();
    final canGenerate = item.totalVolume != null && item.totalVolume! > 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Center(
        child: Column(
          children: [
            Text(
              context.l10n.collectionEmpty,
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
            if (canGenerate) ...[
              const SizedBox(height: 16),
              provider.isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      onPressed: () => _generate(context),
                      icon: const Icon(Icons.auto_awesome),
                      label: Text(
                        context.l10n.collectionGenerate,
                      ),
                    ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CollectionStrip extends StatelessWidget {
  final List<ItemModel> items;
  final ListModel? library;

  const _CollectionStrip({required this.items, required this.library});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) => _CollectionCard(
          item: items[index],
          library: library,
        ),
      ),
    );
  }
}

class _CollectionCard extends StatelessWidget {
  final ItemModel item;
  final ListModel? library;

  const _CollectionCard({required this.item, required this.library});

  Future<void> _open(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ItemDetailScreen(item: item, list: library),
      ),
    );
    if (context.mounted) {
      await context.read<ItemDetailsProvider>().loadSubItems();
    }
  }

  @override
  Widget build(BuildContext context) {
    final imagePath = item.imagePath ?? item.remoteImageUrl ?? '';

    return GestureDetector(
      onTap: () => _open(context),
      child: Container(
        width: 110,
        margin: const EdgeInsets.only(right: 12),
        child: Card(
          elevation: 3,
          clipBehavior: Clip.antiAlias,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Stack(
            fit: StackFit.expand,
            children: [
              UniversalImage(
                imagePath,
                remoteImageUrl: item.remoteImageUrl,
                fit: BoxFit.cover,
                itemId: item.id,
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.1),
                        Colors.black.withValues(alpha: 0.8),
                      ],
                      stops: const [0.0, 0.6, 1.0],
                    ),
                  ),
                ),
              ),
              if (item.externalRating != null)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, size: 10, color: Colors.amber),
                        const SizedBox(width: 2),
                        Text(
                          item.externalRating!.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Positioned(
                bottom: 6,
                left: 4,
                right: 4,
                child: Text(
                  item.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(blurRadius: 2, color: Colors.black)],
                  ),
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
