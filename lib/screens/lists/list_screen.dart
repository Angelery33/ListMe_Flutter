import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/items/item_model.dart';
import '../../data/lists/list_model.dart';
import '../../core/routes.dart';
import '../../providers/items/items_provider.dart';
import '../../providers/lists/lists_provider.dart';
import '../../core/utils/item_grouping_helper.dart';
import '../../widgets/lists/detail/list_detail_app_bar.dart';
import '../../widgets/lists/detail/list_sort_filter_bar.dart';
import '../../widgets/lists/detail/list_price_summary.dart';
import '../../widgets/lists/detail/list_section_header.dart';
import '../../widgets/lists/detail/active_items_section.dart';
import '../../widgets/items/item_card.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _collapsedSections = {};
  bool _isStatsVisible = true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    
    // Carga inicial
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final list = ModalRoute.of(context)!.settings.arguments as ListModel;
      if (list.id != null) {
        context.read<ItemsProvider>().fetchItemsByLibrary(list.id!);
      }
    });
  }

  void _onSearchChanged() {
    context.read<ItemsProvider>().setSearchQuery(_searchController.text);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final list = ModalRoute.of(context)!.settings.arguments as ListModel;
    final itemsProvider = context.watch<ItemsProvider>();

    // Agrupación usando el Helper centralizado
    final groupedItems = ItemGroupingHelper.groupItems(
      items: itemsProvider.items,
      list: list,
      filterGenre: itemsProvider.filterGenre,
      searchQuery: itemsProvider.searchQuery,
      sortOption: itemsProvider.sortOption,
    );

    final activeItems = itemsProvider.items.where((i) => i.current).toList();
    final totalAcquired = ItemGroupingHelper.calculateTotal(itemsProvider.items.where((i) => !i.wishlist).toList());
    final totalWishlist = ItemGroupingHelper.calculateTotal(itemsProvider.items.where((i) => i.wishlist).toList());

    return Scaffold(
      appBar: ListDetailAppBar(
        list: list,
        searchController: _searchController,
        onSettingsPressed: () => _navigateToListConfig(context, list),
        onMorePressed: () => _showLibraryOptions(context, list),
        onSharePressed: () => _showShareDialog(context, list),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddItem(context, list),
        child: const Icon(Icons.add_rounded),
      ),
      body: Column(
        children: [
          // Barra de Ordenación y Filtros
          ListSortFilterBar(
            currentSort: itemsProvider.sortOption,
            onSortChanged: itemsProvider.setSortOption,
            currentGenre: itemsProvider.filterGenre,
            availableGenres: itemsProvider.availableGenres,
            onGenreChanged: itemsProvider.setFilterGenre,
            supportsPrice: list.supportsPrice,
            isStatsVisible: _isStatsVisible,
            onStatsToggle: () => setState(() => _isStatsVisible = !_isStatsVisible),
          ),
          
          // Resumen de Precios (Estadísticas) — se oculta si el usuario pulsa el toggle
          if (list.supportsPrice && _isStatsVisible)
            ListPriceSummary(
              totalAcquired: totalAcquired,
              totalWishlist: totalWishlist,
              isVisible: _isStatsVisible,
            ),
            
          // Lista de Items
          Expanded(
            child: itemsProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => itemsProvider.fetchItemsByLibrary(list.id!),
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        // Sección "Disfrutando Ahora"
                        ActiveItemsSection(
                          items: activeItems,
                          isCompact: list.compact,
                          isGradeable: list.gradeable,
                          isThematic: list.thematic,
                          supportsPrice: list.supportsPrice,
                          supportsProgress: list.supportsProgress,
                          onTap: (item) => _navigateToItemDetails(context, item),
                          onLongPress: (item) => _showItemOptions(context, item, list),
                          onIncrement: list.supportsProgress
                              ? (item) => itemsProvider.incrementProgress(item)
                              : null,
                        ),
                        
                        // Items agrupados
                        if (groupedItems.isEmpty)
                          _buildEmptyState(itemsProvider.searchQuery.isNotEmpty)
                        else
                          ..._buildGroupedItems(groupedItems, list, itemsProvider),
                          
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildGroupedItems(
    Map<String, List<ItemModel>> grouped,
    ListModel list,
    ItemsProvider itemsProvider,
  ) {
    List<Widget> widgets = [];
    
    grouped.forEach((groupTitle, items) {
      final isCollapsed = _collapsedSections.contains(groupTitle);
      final groupPrice = ItemGroupingHelper.calculateTotal(items);

      widgets.add(
        ListSectionHeader(
          title: groupTitle,
          isCollapsed: isCollapsed,
          totalPrice: list.supportsPrice ? groupPrice : null,
          onTap: () {
            setState(() {
              if (isCollapsed) {
                _collapsedSections.remove(groupTitle);
              } else {
                _collapsedSections.add(groupTitle);
              }
            });
          },
        ),
      );

      if (!isCollapsed) {
        if (list.compact) {
          widgets.add(_buildGrid(items, list, itemsProvider));
        } else {
          widgets.addAll(
            items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: ItemCard(
                item: item,
                onTap: () => _navigateToItemDetails(context, item),
                onLongPress: () => _showItemOptions(context, item, list),
                isCompact: false,
                showStatus: list.supportsCompletion,
                isGradeable: list.gradeable,
                isThematic: list.thematic,
                supportsPrice: list.supportsPrice,
                supportsProgress: list.supportsProgress,
                onIncrement: list.supportsProgress
                    ? () => itemsProvider.incrementProgress(item)
                    : null,
              ),
            )),
          );
        }
      }
    });
    
    return widgets;
  }

  Widget _buildGrid(List<ItemModel> items, ListModel list, ItemsProvider itemsProvider) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        childAspectRatio: 0.7,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return ItemCard(
          item: item,
          onTap: () => _navigateToItemDetails(context, item),
          onLongPress: () => _showItemOptions(context, item, list),
          isCompact: true,
          showStatus: list.supportsCompletion,
          isGradeable: list.gradeable,
          isThematic: list.thematic,
          supportsPrice: list.supportsPrice,
          supportsProgress: list.supportsProgress,
          onIncrement: list.supportsProgress
              ? () => itemsProvider.incrementProgress(item)
              : null,
        );
      },
    );
  }

  Widget _buildEmptyState(bool isSearching) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: Center(
        child: Column(
          children: [
            Icon(
              isSearching ? Icons.search_off_rounded : Icons.library_books_outlined,
              size: 80,
              color: theme.colorScheme.primary.withValues(alpha: 0.2),
            ),
            const SizedBox(height: 16),
            Text(
              isSearching ? "No hay resultados para tu búsqueda" : "Esta lista está vacía",
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.primary.withValues(alpha: 0.5),
                fontWeight: FontWeight.bold,
              ),
            ),
            if (!isSearching) ...[
              const SizedBox(height: 8),
              Text(
                "Pulsa '+' para añadir tu primer elemento",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // --- Navegación y Diálogos ---

  void _navigateToItemDetails(BuildContext context, ItemModel item) {
    final list = ModalRoute.of(context)!.settings.arguments as ListModel;
    Navigator.pushNamed(
      context, 
      AppRoutes.itemDetail,
      arguments: {'item': item, 'list': list},
    ).then((_) {
      if (context.mounted && list.id != null) {
        context.read<ItemsProvider>().refreshItems(list.id!);
      }
    });
  }


  void _navigateToAddItem(BuildContext context, ListModel list) {
    Navigator.pushNamed(
      context, 
      AppRoutes.itemEntry, 
      arguments: {'list': list, 'item': null},
    ).then((_) {
      if (context.mounted && list.id != null) {
        context.read<ItemsProvider>().refreshItems(list.id!);
      }
    });
  }


  void _showItemOptions(BuildContext context, ItemModel item, ListModel list) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_rounded),
              title: const Text('Editar'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context, 
                  AppRoutes.itemEntry, 
                  arguments: {'list': list, 'item': item},
                ).then((_) {
                  if (context.mounted && list.id != null) {
                    context.read<ItemsProvider>().refreshItems(list.id!);
                  }
                });

              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_rounded, color: Colors.red),
              title: const Text('Eliminar', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _confirmDeleteItem(context, item, list);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteItem(BuildContext context, ItemModel item, ListModel list) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar elemento'),
        content: Text('¿Seguro que quieres eliminar "${item.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              if (item.id != null) {
                await context.read<ItemsProvider>().deleteItem(item.id!);
                if (context.mounted && list.id != null) {
                  context.read<ItemsProvider>().fetchItemsByLibrary(list.id!);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('"${item.name}" eliminado')),
                  );
                }
              }
            },
            child: const Text('ELIMINAR', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _navigateToListConfig(BuildContext context, ListModel list) {
    Navigator.pushNamed(
      context,
      AppRoutes.listConfig,
      arguments: list,
    ).then((_) {
      if (context.mounted && list.id != null) {
        context.read<ItemsProvider>().fetchItemsByLibrary(list.id!);
      }
    });
  }

  void _showLibraryOptions(BuildContext context, ListModel list) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete_rounded, color: Colors.red),
              title: const Text('Eliminar lista', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(ctx);
                _confirmDeleteList(context, list);
              },
            ),
          ],
        ),
      ),
    );
  }


  void _confirmDeleteList(BuildContext context, ListModel list) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Lista'),
        content: Text(
          '¿Estás seguro de que quieres eliminar la lista "${list.name}"? Se borrarán todos sus elementos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Cierra diálogo
              if (list.id != null) {
                await context.read<ListsProvider>().deleteList(list.id!);
                if (context.mounted) Navigator.pop(context); // Vuelve a la lista de listas
              }
            },
            child: const Text('ELIMINAR', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showShareDialog(BuildContext context, ListModel list) {
    // TODO: Diálogo de compartir lista
  }
}
