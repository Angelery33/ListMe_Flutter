import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/items/item_model.dart';
import '../../data/items/items_repository.dart';
import '../../providers/items/item_details_provider.dart';
import '../../providers/items/items_provider.dart';


// Modulos
import '../../widgets/items/detail/detail_image_carousel.dart';
import '../../widgets/items/detail/detail_header_tags.dart';
import '../../widgets/items/detail/detail_price_section.dart';
import '../../widgets/items/detail/detail_progress_section.dart';
import '../../widgets/items/detail/detail_rating_section.dart';
import '../../widgets/items/detail/detail_description_section.dart';
import '../../widgets/items/detail/detail_dates_section.dart';
import '../../widgets/items/detail/detail_collection_section.dart';
import '../../widgets/items/detail/detail_gallery_section.dart';

class ItemDetailScreen extends StatefulWidget {
  final ItemModel item;

  const ItemDetailScreen({super.key, required this.item});

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  late ItemDetailsProvider _detailsProvider;

  @override
  void initState() {
    super.initState();
    // Instanciar el provider especifico de detalles
    final repository = context.read<ItemsRepository>();
    _detailsProvider = ItemDetailsProvider(repository);
    
    // Cargar los detalles del item, pasando el item local inicial
    _detailsProvider.loadItemDetails(widget.item.id!, initialItem: widget.item);
  }

  @override
  void dispose() {
    _detailsProvider.dispose();
    super.dispose();
  }

  void _onEditTapped(BuildContext context, ItemModel currentItem) async {
    // Extraer la lista desde los argumentos del route (proporcionados por ListScreen)
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final list = args['list'];
    
    if (list != null) {
      await Navigator.pushNamed(
        context,
        '/item-entry', // AppRoutes.itemEntry
        arguments: {'list': list, 'item': currentItem},
      );
      
      // Reaload the item when coming back from editing
      if (context.mounted && widget.item.id != null) {
        _detailsProvider.loadItemDetails(widget.item.id!);
        // Sync with parent provider too
        final listId = currentItem.idLibrary;
        context.read<ItemsProvider>().fetchItemsByLibrary(listId);
      }
    }
  }

  void _onDeleteTapped(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Eliminar elemento"),
        content: const Text("¿Estás seguro de que quieres eliminar este elemento de la lista?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("ELIMINAR", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final itemsProvider = context.read<ItemsProvider>();
      final success = await itemsProvider.deleteItem(widget.item.id!);
      
      if (success && context.mounted) {
        Navigator.pop(context, true); // Devuelve tru porque fue eliminado
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(itemsProvider.errorMessage ?? "Error eliminando el elemento")),
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

          return Scaffold(
            appBar: AppBar(
              title: Text(item.name),
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
            ),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DetailImageCarousel(item: item, images: provider.images),
                  
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DetailHeaderTags(item: item),
                        DetailPriceSection(item: item),
                        DetailProgressSection(),
                        DetailRatingSection(),
                        DetailDescriptionSection(item: item),
                        DetailCollectionSection(),
                        DetailDatesSection(item: item),
                        DetailGallerySection(item: item),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
