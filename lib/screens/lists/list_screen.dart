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
  late ListModel _currentList;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _currentList = ModalRoute.of(context)!.settings.arguments as ListModel;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_currentList.id != null) {
          context.read<ItemsProvider>().fetchItemsByLibrary(_currentList.id!);
        }
      });
    }
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
    final itemsProvider = context.watch<ItemsProvider>();

    final groupedItems = ItemGroupingHelper.groupItems(
      items: itemsProvider.items,
      list: _currentList,
      filterGenre: itemsProvider.filterGenre,
      searchQuery: itemsProvider.searchQuery,
      sortOption: itemsProvider.sortOption,
    );

    final activeItems = itemsProvider.items.where((i) => i.current).toList();
    final totalAcquired = ItemGroupingHelper.calculateTotal(
      itemsProvider.items.where((i) => !i.wishlist).toList(),
    );
    final totalWishlist = ItemGroupingHelper.calculateTotal(
      itemsProvider.items.where((i) => i.wishlist).toList(),
    );

    return Scaffold(
      appBar: ListDetailAppBar(
        list: _currentList,
        searchController: _searchController,
        onSettingsPressed: () => _navigateToListConfig(),
        onMorePressed: () => _showLibraryOptions(),
        onSharePressed: () => _showShareDialog(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddItem,
        child: const Icon(Icons.add_rounded),
      ),
      body: Column(
        children: [
          ListSortFilterBar(
            currentSort: itemsProvider.sortOption,
            onSortChanged: itemsProvider.setSortOption,
            currentGenre: itemsProvider.filterGenre,
            availableGenres: itemsProvider.availableGenres,
            onGenreChanged: itemsProvider.setFilterGenre,
            supportsPrice: _currentList.supportsPrice,
            isStatsVisible: _isStatsVisible,
            onStatsToggle: () =>
                setState(() => _isStatsVisible = !_isStatsVisible),
          ),
          if (_currentList.supportsPrice && _isStatsVisible)
            ListPriceSummary(
              totalAcquired: totalAcquired,
              totalWishlist: totalWishlist,
              isVisible: _isStatsVisible,
            ),
          Expanded(
            child: itemsProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () =>
                        itemsProvider.fetchItemsByLibrary(_currentList.id!),
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        ActiveItemsSection(
                          items: activeItems,
                          isCompact: _currentList.compact,
                          isGradeable: _currentList.gradeable,
                          isThematic: _currentList.thematic,
                          supportsPrice: _currentList.supportsPrice,
                          supportsProgress: _currentList.supportsProgress,
                          onTap: _navigateToItemDetails,
                          onLongPress: _showItemOptions,
                          onIncrement: _currentList.supportsProgress
                              ? (item) => itemsProvider.incrementProgress(item)
                              : null,
                        ),
                        if (groupedItems.isEmpty)
                          _buildEmptyState(itemsProvider.searchQuery.isNotEmpty)
                        else
                          ..._buildGroupedItems(groupedItems, itemsProvider),
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
          totalPrice: _currentList.supportsPrice ? groupPrice : null,
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
        if (_currentList.compact) {
          widgets.add(_buildGrid(items, itemsProvider));
        } else {
          widgets.addAll(
            items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: ItemCard(
                  item: item,
                  onTap: () => _navigateToItemDetails(item),
                  onLongPress: () => _showItemOptions(item),
                  isCompact: false,
                  showStatus: _currentList.supportsCompletion,
                  isGradeable: _currentList.gradeable,
                  isThematic: _currentList.thematic,
                  supportsPrice: _currentList.supportsPrice,
                  supportsProgress: _currentList.supportsProgress,
                  onIncrement: _currentList.supportsProgress
                      ? () => itemsProvider.incrementProgress(item)
                      : null,
                ),
              ),
            ),
          );
        }
      }
    });

    return widgets;
  }

  Widget _buildGrid(List<ItemModel> items, ItemsProvider itemsProvider) {
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
          onTap: () => _navigateToItemDetails(item),
          onLongPress: () => _showItemOptions(item),
          isCompact: true,
          showStatus: _currentList.supportsCompletion,
          isGradeable: _currentList.gradeable,
          isThematic: _currentList.thematic,
          supportsPrice: _currentList.supportsPrice,
          supportsProgress: _currentList.supportsProgress,
          onIncrement: _currentList.supportsProgress
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
              isSearching
                  ? Icons.search_off_rounded
                  : Icons.library_books_outlined,
              size: 80,
              color: theme.colorScheme.primary.withValues(alpha: 0.2),
            ),
            const SizedBox(height: 16),
            Text(
              isSearching
                  ? "No hay resultados para tu búsqueda"
                  : "Esta lista está vacía",
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

  void _refreshItems() {
    if (_currentList.id != null) {
      context.read<ItemsProvider>().refreshItems(_currentList.id!);
    }
  }

  void _navigateToItemDetails(ItemModel item) {
    Navigator.pushNamed(
      context,
      AppRoutes.itemDetail,
      arguments: {'item': item, 'list': _currentList},
    ).then((_) => _refreshItems());
  }

  void _navigateToAddItem() {
    Navigator.pushNamed(
      context,
      AppRoutes.itemEntry,
      arguments: {'list': _currentList, 'item': null},
    ).then((_) => _refreshItems());
  }

  void _navigateToListConfig() {
    Navigator.pushNamed(
      context,
      AppRoutes.listConfig,
      arguments: _currentList,
    ).then((_) => _refreshItems());
  }

  void _showItemOptions(ItemModel item) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_rounded),
              title: const Text('Editar'),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.pushNamed(
                  context,
                  AppRoutes.itemEntry,
                  arguments: {'list': _currentList, 'item': item},
                ).then((_) => _refreshItems());
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_rounded, color: Colors.red),
              title: const Text(
                'Eliminar',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _confirmDeleteItem(item);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteItem(ItemModel item) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar elemento'),
        content: Text('¿Seguro que quieres eliminar "${item.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('CANCELAR'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              if (item.id != null) {
                await context.read<ItemsProvider>().deleteItem(item.id!);
                if (mounted) {
                  _refreshItems();
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

  void _showLibraryOptions() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete_rounded, color: Colors.red),
              title: const Text(
                'Eliminar lista',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _confirmDeleteList();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteList() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar Lista'),
        content: Text(
          '¿Estás seguro de que quieres eliminar "${_currentList.name}"? Se borrarán todos sus elementos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('CANCELAR'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              if (_currentList.id != null) {
                final success = await context.read<ListsProvider>().deleteList(
                  _currentList.id!,
                );
                if (success && mounted) {
                  Navigator.pop(context);
                }
              }
            },
            child: const Text('ELIMINAR', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showShareDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Compartir lista'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Comparte "${_currentList.name}" con otros usuarios.'),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Email del usuario',
                hintText: 'usuario@ejemplo.com',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCELAR'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Invitación enviada')),
              );
            },
            child: const Text('ENVIAR'),
          ),
        ],
      ),
    );
  }
}
