import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/responsive_provider.dart';
import '../../data/items/item_model.dart';
import '../../data/lists/list_model.dart';
import '../../core/config/routes.dart';
import '../../providers/items/items_provider.dart';
import '../../providers/lists/lists_provider.dart';
import '../../core/utils/item_grouping_helper.dart';
import '../../widgets/lists/detail/list_detail_app_bar.dart';
import '../../widgets/lists/detail/list_sort_filter_bar.dart';
import '../../widgets/lists/detail/list_price_summary.dart';
import '../../widgets/lists/detail/list_section_header.dart';
import '../../widgets/lists/detail/active_items_section.dart';
import '../../widgets/items/item_card.dart';
import '../../widgets/shared/app_shell.dart';

class ListScreen extends StatefulWidget {
  final int listId;
  final String listName;
  final String? remoteId;
  final int? parentId;
  final ListModel? list;

  const ListScreen({
    super.key,
    required this.listId,
    required this.listName,
    this.remoteId,
    this.parentId,
    this.list,
  });

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _collapsedSections = {};
  bool _isStatsVisible = true;
  bool _isSearchVisible = false;
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
      // Soporta tanto argumentos del router como widget.list directo
      _currentList =
          widget.list ?? ListModel(id: widget.listId, name: widget.listName);
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadItems());
    }
  }

  void _loadItems() {
    final itemsProvider = context.read<ItemsProvider>();

    // Si ya tenemos el objeto list completo con id, usarlo
    if (_currentList.id != null && _currentList.id != 0) {
      itemsProvider.loadData(_currentList.id!);
    } else if (widget.remoteId != null) {
      itemsProvider.loadByRemoteId(widget.remoteId!);
    } else if (widget.parentId != null && widget.listId != 0) {
      itemsProvider.loadSubCollections(widget.parentId!, widget.listId);
    } else if (widget.listId != 0) {
      itemsProvider.loadData(widget.listId);
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
    final isSearching = itemsProvider.searchQuery.isNotEmpty;
    final theme = Theme.of(context);

    final groupedItems = ItemGroupingHelper.groupItems(
      items: itemsProvider.items,
      list: _currentList,
      filterGenre: itemsProvider.filterGenre,
      searchQuery: itemsProvider.searchQuery,
      sortOption: itemsProvider.sortOption,
      isSearching: isSearching,
    );

    final activeItems = itemsProvider.items.where((i) => i.current).toList();
    final totalAcquired = ItemGroupingHelper.calculateTotal(
      itemsProvider.items.where((i) => !i.wishlist).toList(),
    );
    final totalWishlist = ItemGroupingHelper.calculateTotal(
      itemsProvider.items.where((i) => i.wishlist).toList(),
    );

    return AppShell(
      currentIndex: 0,
      appBar: ListDetailAppBar(
        list: _currentList,
        searchController: _searchController,
        onSettingsPressed: () => _navigateToListConfig(),
        onMenuSelected: _handleMenuSelection,
        onSharePressed: () => _showShareDialog(),
        onSearchToggle: () =>
            setState(() => _isSearchVisible = !_isSearchVisible),
        isSearchVisible: _isSearchVisible,
        onEditPressed: () => _showEditListDialog(),
        onSyncPressed: () => _showSyncDialog(),
        onUploadPressed: widget.remoteId == null && widget.listId != 0
            ? () => _showUploadDialog()
            : null,
        isCloud: widget.remoteId != null,
        canEdit: widget.listId != 0 && widget.remoteId == null,
      ),
      floatingActionButton: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => _navigateToAddItem(),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          child: const Icon(Icons.add_rounded, size: 28),
        ),
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
                    onRefresh: () async {
                      _refreshItems();
                    },
                    child:
                        itemsProvider.items.isEmpty &&
                            itemsProvider.searchQuery.isEmpty &&
                            itemsProvider.filterGenre == null
                        ? ListView(
                            children: [
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.7,
                                child: _buildEmptyState(false),
                              ),
                            ],
                          )
                        : ListView(
                            padding: const EdgeInsets.all(16),
                            children: [
                              ActiveItemsSection(
                                items: activeItems,
                                isCompact: true,
                                isGradeable: _currentList.gradeable,
                                isThematic: _currentList.thematic,
                                supportsPrice: _currentList.supportsPrice,
                                supportsProgress: _currentList.supportsProgress,
                                onTap: _navigateToItemDetails,
                                onLongPress: _showItemOptions,
                                onIncrement: _currentList.supportsProgress
                                    ? (item) =>
                                          itemsProvider.incrementProgress(item)
                                    : null,
                              ),
                              if (groupedItems.isEmpty)
                                _buildEmptyState(
                                  itemsProvider.searchQuery.isNotEmpty,
                                )
                              else
                                ..._buildGroupedItems(
                                  groupedItems,
                                  itemsProvider,
                                ),
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
    final columns = context.read<ResponsiveProvider>().compactGridColumns;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
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

  void _refreshItems() async {
    final itemsProvider = context.read<ItemsProvider>();
    if (widget.remoteId != null) {
      itemsProvider.loadByRemoteId(widget.remoteId!);
    } else if (widget.parentId != null && widget.listId != 0) {
      itemsProvider.loadSubCollections(widget.parentId!, widget.listId);
    } else if (widget.listId != 0) {
      itemsProvider.loadData(widget.listId);
    }

    if (widget.listId != 0) {
      final listsProvider = context.read<ListsProvider>();
      final updatedList = listsProvider.lists.firstWhere(
        (l) => l.id == widget.listId,
        orElse: () => _currentList,
      );
      if (mounted) {
        setState(() {
          _currentList = updatedList;
        });
      }
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
    ).then((_) {
      _refreshItems();
    });
  }

  void _showEditListDialog() async {
    if (widget.listId == 0) return;
    await Navigator.pushNamed(
      context,
      AppRoutes.listConfig,
      arguments: _currentList,
    );
    if (mounted) {
      _refreshItems();
    }
  }

  void _showSyncDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sincronizar'),
        content: const Text(
          '¿Deseas sincronizar los elementos con el servidor?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCELAR'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sincronizando...')),
                );
                _refreshItems();
              }
            },
            child: const Text('SINCRONIZAR'),
          ),
        ],
      ),
    );
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

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'share':
        _showShareDialog();
        break;
      case 'edit':
        _showEditListDialog();
        break;
      case 'sync':
        _showSyncDialog();
        break;
      case 'delete':
        _confirmDeleteList();
        break;
    }
  }

  void _showUploadDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Subir a la nube'),
        content: const Text(
          '¿Quieres publicar esta lista en la nube? Esto permitirá compartirla con otras personas y sincronizarla entre tus dispositivos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await context.read<ListsProvider>().updateList(
                _currentList.id!,
                _currentList.copyWith(shared: true),
              );

              if (mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('¡Lista publicada con éxito!'),
                    ),
                  );
                  _refreshItems();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Error al publicar la lista')),
                  );
                }
              }
            },
            child: const Text('PUBLICAR'),
          ),
        ],
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
