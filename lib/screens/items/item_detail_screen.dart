import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/items/item_model.dart';
import '../../data/items/items_repository.dart';
import '../../data/lists/list_model.dart';
import '../../providers/items/item_details_provider.dart';
import '../../providers/items/items_provider.dart';

import '../../widgets/items/detail/detail_image_carousel.dart';
import '../../widgets/items/detail/detail_info_section.dart';
import '../../widgets/items/detail/detail_progress_section.dart';
import '../../widgets/items/detail/detail_rating_section.dart';
import '../../widgets/items/detail/detail_description_section.dart';
import '../../widgets/items/detail/detail_dates_section.dart';
import '../../widgets/items/detail/detail_collection_section.dart';
import '../../widgets/items/detail/detail_gallery_section.dart';
import '../../widgets/items/detail/detail_attributes_section.dart';

class ItemDetailScreen extends StatefulWidget {
  final ItemModel item;
  final ListModel? list;

  const ItemDetailScreen({super.key, required this.item, this.list});

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  late ItemDetailsProvider _detailsProvider;

  @override
  void initState() {
    super.initState();
    final repository = context.read<ItemsRepository>();
    _detailsProvider = ItemDetailsProvider(repository);
    _detailsProvider.loadItemDetails(widget.item.id!, initialItem: widget.item);
  }

  @override
  void dispose() {
    _detailsProvider.dispose();
    super.dispose();
  }

  void _onEditTapped(BuildContext context, ItemModel currentItem) async {
    await Navigator.pushNamed(
      context,
      '/item-entry',
      arguments: {'list': widget.list, 'item': currentItem},
    );

    if (context.mounted && widget.item.id != null) {
      _detailsProvider.loadItemDetails(widget.item.id!);
      final listId = currentItem.idLibrary;
      context.read<ItemsProvider>().fetchItemsByLibrary(listId);
    }
  }

  void _onDeleteTapped(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar elemento'),
        content: const Text(
          '¿Estás seguro de que quieres eliminar este elemento de la lista?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('ELIMINAR', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final itemsProvider = context.read<ItemsProvider>();
      final success = await itemsProvider.deleteItem(widget.item.id!);

      if (success && context.mounted) {
        Navigator.pop(context, true);
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              itemsProvider.errorMessage ?? 'Error eliminando el elemento',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _detailsProvider,
      child: Consumer<ItemDetailsProvider>(
        builder: (context, provider, child) {
          final item = provider.item ?? widget.item;
          final library = widget.list;

          return Scaffold(
            body: CustomScrollView(
              slivers: [
                _buildSliverAppBar(context, item),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DetailInfoSection(item: item, library: library),
                        const SizedBox(height: 16),
                        DetailProgressSection(library: library),
                        DetailRatingSection(library: library),
                        DetailDescriptionSection(item: item),
                        DetailCollectionSection(library: library),
                        DetailDatesSection(item: item),
                        DetailAttributesSection(),
                        DetailGallerySection(item: item),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, ItemModel item) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () => _onEditTapped(context, item),
        ),
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () => _onDeleteTapped(context),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          item.name,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        background: DetailImageCarousel(
          item: item,
          images: _detailsProvider.images,
        ),
      ),
    );
  }
}
