import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/item_details_provider.dart';
import '../../providers/item_provider.dart';
import '../../data/models.dart';
import '../app_theme.dart';
import '../components/responsive_container.dart';
import 'item_entry_screen.dart';

import '../widgets/details/item_details_image_carousel.dart';
import '../widgets/details/item_details_info_list.dart';

class ItemDetailsScreen extends StatefulWidget {
  final int itemId;
  final Item? item;

  const ItemDetailsScreen({super.key, required this.itemId, this.item});

  @override
  State<ItemDetailsScreen> createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen> {
  late ItemDetailsProvider _detailsProvider;

  @override
  void initState() {
    super.initState();
    _detailsProvider = ItemDetailsProvider();
    _loadData();
  }

  void _loadData() {
    Future.microtask(
      () => _detailsProvider.loadItemDetails(
        widget.itemId,
        initialItem: widget.item,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _detailsProvider,
      child: Consumer<ItemDetailsProvider>(
        builder: (context, detailsProvider, child) {
          final item = detailsProvider.item;

          if (detailsProvider.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (item == null) {
            return Scaffold(
              appBar: AppBar(title: const Text("Detalles")),
              body: const Center(child: Text('Elemento no encontrado')),
            );
          }

          return PopScope(
            canPop: true,
            onPopInvokedWithResult: (didPop, result) {
              if (didPop) {
                detailsProvider.syncLibrary();
              }
            },
            child: Scaffold(
              appBar: AppBar(
                flexibleSpace: AppTheme.getAppBarGradient(context),
                title: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (detailsProvider.parentName != null)
                      GestureDetector(
                        onTap: () {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          } else {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ItemDetailsScreen(itemId: item.parentId!),
                              ),
                            );
                          }
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.arrow_back, // Better icon for "Go Up"
                              size: 11,
                              color: Colors.white70,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                detailsProvider.parentName!.toUpperCase(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ItemEntryScreen(
                            libraryId: item.idLibrary,
                            item: item,
                          ),
                        ),
                      );
                      if (result == true && mounted) {
                        _loadData();
                        Provider.of<ItemProvider>(
                          context,
                          listen: false,
                        ).loadData(item.idLibrary);
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _confirmDelete(context, detailsProvider),
                  ),
                ],
              ),
              body: ResponsiveContainer(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. Header Image Carousel
                      ItemDetailsImageCarousel(
                        item: item,
                        imagePaths: detailsProvider.imagePaths,
                      ),

                      // 2. Info Content
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ItemDetailsInfoList(
                          item: item,
                          detailsProvider: detailsProvider,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    ItemDetailsProvider detailsProvider,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Eliminar elemento"),
        content: const Text(
          "¿Estás seguro de que quieres eliminar este elemento?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx); // Close dialog
              final libId = detailsProvider.item?.idLibrary;
              try {
                await detailsProvider.deleteItem(widget.itemId);

                if (context.mounted) {
                  Navigator.pop(context, true); // Close details screen
                  // Refresh library list
                  if (libId != null) {
                    Provider.of<ItemProvider>(
                      context,
                      listen: false,
                    ).loadData(libId);
                  }
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error al eliminar: $e")),
                  );
                }
              }
            },
            child: const Text("ELIMINAR", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
