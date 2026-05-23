import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/i18n/l10n_extension.dart';
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
import '../../providers/friends/friends_provider.dart';
import '../../widgets/lists/share_friend_dialog.dart';
import '../../widgets/lists/detail/list_table_view.dart';

/// Pantalla que muestra los elementos dentro de una sola biblioteca.
///
/// Admite tres contextos de carga: una biblioteca local ([listId] con un objeto [list]
/// opcional), una lista remota compartida ([remoteId]) y una subcolección
/// ([parentId]). La pantalla se adapta a las opciones de la lista para mostrar u ocultar
/// resúmenes de precios, indicadores de progreso, filtros de género y el botón flotante.
class ListScreen extends StatefulWidget {
  /// El ID de la biblioteca a mostrar. `0` cuando solo se conoce el [remoteId].
  final int listId;

  /// Nombre visible mostrado en la barra de la aplicación mientras se carga el objeto [list] completo.
  final String listName;

  /// Identificador de lista compartida remota, establecido al visualizar una biblioteca pública.
  final String? remoteId;

  /// ID del elemento padre cuando la pantalla muestra una subcolección.
  final int? parentId;

  /// El objeto [ListModel] completo, pasado directamente desde la pantalla de listas para
  /// evitar una obtención adicional.
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

/// Estado para [ListScreen].
///
/// Gestiona la visibilidad de la búsqueda, el estado de colapso de las secciones, la alternancia entre tabla/cuadrícula y
/// la carga de elementos según el contexto actual (local, remoto o subcolección).
class _ListScreenState extends State<ListScreen> {
  final TextEditingController _searchController = TextEditingController();

  /// Títulos de las secciones que el usuario ha colapsado manualmente.
  final Set<String> _collapsedSections = {};

  /// Indica si la fila de resumen de precios/estadísticas es visible.
  bool _isStatsVisible = true;

  /// Indica si la barra de búsqueda está expandida debajo de la barra de la aplicación.
  bool _isSearchVisible = false;

  /// Indica si se deben renderizar los elementos en vista de tabla (solo disponible en pantallas anchas).
  bool _isTableView = false;

  /// El [ListModel] resuelto utilizado en toda esta pantalla.
  late ListModel _currentList;

  // ── Caché de cálculos costosos ─────────────────────────────────────────────
  Map<String, List<ItemModel>> _groupedItems = {};
  List<ItemModel> _activeItems = [];
  double _totalAcquired = 0;
  double _totalWishlist = 0;

  /// Inputs del último cálculo para detectar si hay que recalcular.
  List<ItemModel>? _lastItems;
  String? _lastFilterGenre;
  String? _lastSearchQuery;
  dynamic _lastSortOption;

  /// Recalcula groupedItems y totales solo si algún input ha cambiado.
  void _recalculateIfNeeded(ItemsProvider p) {
    if (identical(_lastItems, p.items) &&
        _lastFilterGenre == p.filterGenre &&
        _lastSearchQuery == p.searchQuery &&
        _lastSortOption == p.sortOption) return;

    _lastItems = p.items;
    _lastFilterGenre = p.filterGenre;
    _lastSearchQuery = p.searchQuery;
    _lastSortOption = p.sortOption;

    _groupedItems = ItemGroupingHelper.groupItems(
      items: p.items,
      list: _currentList,
      filterGenre: p.filterGenre,
      searchQuery: p.searchQuery,
      sortOption: p.sortOption,
      isSearching: p.searchQuery.isNotEmpty,
    );
    _activeItems = p.items.where((i) => i.current).toList();
    _totalAcquired = ItemGroupingHelper.calculateTotal(
      p.items.where((i) => !i.wishlist).toList(),
    );
    _totalWishlist = ItemGroupingHelper.calculateTotal(
      p.items.where((i) => i.wishlist).toList(),
    );
  }

  /// Guardia para asegurar que [didChangeDependencies] solo se inicialice una vez.
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

  /// Carga los elementos de la fuente adecuada basándose en los argumentos del widget.
  void _loadItems() {
    final itemsProvider = context.read<ItemsProvider>();
    // Reset search state whenever a (new) list is opened.
    itemsProvider.setSearchQuery('');
    _searchController.clear();
    setState(() => _isSearchVisible = false);

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

  /// Envía el texto de búsqueda actual al [ItemsProvider] para que los resultados se filtren.
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
    final responsive = context.watch<ResponsiveProvider>();
    final theme = Theme.of(context);
    final showTable = _isTableView && !responsive.isCompact;

    _recalculateIfNeeded(itemsProvider);
    final groupedItems = _groupedItems;
    final activeItems = _activeItems;
    final totalAcquired = _totalAcquired;
    final totalWishlist = _totalWishlist;

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
        showTableToggle: !responsive.isCompact,
        isTableView: showTable,
        onTableToggle: () => setState(() => _isTableView = !_isTableView),
      ),
      floatingActionButton: _currentList.canEdit
          ? Container(
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
            )
          : null,
      body: showTable
          ? ListTableView(
              list: _currentList,
              items: itemsProvider.items,
            )
          : Column(
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

  /// Devuelve un [ItemCard] ya configurado con las propiedades de [_currentList].
  ///
  /// Centraliza los 10+ parámetros comunes que antes se repetían en [_buildItemList],
  /// [_buildGrid] y [_buildStandardGrid].
  Widget _buildItemCard(
    ItemModel item,
    ItemsProvider itemsProvider, {
    required bool isCompact,
  }) {
    return ItemCard(
      item: item,
      onTap: () => _navigateToItemDetails(item),
      onLongPress: () => _showItemOptions(item),
      isCompact: isCompact,
      showStatus: _currentList.supportsCompletion,
      isGradeable: _currentList.gradeable,
      isThematic: _currentList.thematic,
      supportsPrice: _currentList.supportsPrice,
      supportsProgress: _currentList.supportsProgress,
      onIncrement: _currentList.supportsProgress
          ? () => itemsProvider.incrementProgress(item)
          : null,
    );
  }

  /// Construye la lista completa de encabezados de sección + widgets de elementos para [grouped].
  ///
  /// Cada sección puede colapsarse/expandirse tocando su encabezado. Los títulos de las secciones
  /// colapsadas se rastrean en [_collapsedSections].
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
          title: groupLabelFor(context, groupTitle),
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
        widgets.addAll(
          _buildSectionContent(items, itemsProvider),
        );
      }
    });

    return widgets;
  }

  /// Renderiza el contenido de una sección (puede ser plano o con sub-agrupación
  /// temática si la lista es temática con secciones de estado/wishlist).
  List<Widget> _buildSectionContent(
    List<ItemModel> items,
    ItemsProvider itemsProvider,
  ) {
    final responsive = context.read<ResponsiveProvider>();
    final useSubGenres =
        _currentList.thematic &&
        _currentList.genreLayoutMode == 1 &&
        (_currentList.supportsCompletion || _currentList.supportsWishlist);

    if (useSubGenres) {
      final subGroups = ItemGroupingHelper.subGroupByGenre(items);
      final List<Widget> widgets = [];
      subGroups.forEach((genre, genreItems) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 12, bottom: 6),
            child: Text(
              genre.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.4,
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.75),
              ),
            ),
          ),
        );
        if (_currentList.compact) {
          widgets.add(_buildGrid(genreItems, itemsProvider));
        } else if (responsive.isExpanded) {
          widgets.add(_buildStandardGrid(genreItems, itemsProvider));
        } else {
          widgets.addAll(_buildItemList(genreItems, itemsProvider));
        }
      });
      return widgets;
    }

    if (_currentList.compact) {
      return [_buildGrid(items, itemsProvider)];
    }
    if (responsive.isExpanded) {
      return [_buildStandardGrid(items, itemsProvider)];
    }
    return _buildItemList(items, itemsProvider);
  }

  /// Construye una lista vertical de [ItemCard]s para [items].
  List<Widget> _buildItemList(List<ItemModel> items, ItemsProvider itemsProvider) {
    return items
        .map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: _buildItemCard(item, itemsProvider, isCompact: false),
          ),
        )
        .toList();
  }

  /// Construye una cuadrícula compacta de portadas para [items] utilizando el recuento de columnas
  /// adaptativo de [ResponsiveProvider.compactGridColumns].
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
      itemBuilder: (context, index) =>
          _buildItemCard(items[index], itemsProvider, isCompact: true),
    );
  }

  /// Construye una cuadrícula de dos columnas para pantalla ancha para [items] donde cada tarjeta se
  /// renderiza en estilo no compacto (fila de lista).
  Widget _buildStandardGrid(List<ItemModel> items, ItemsProvider itemsProvider) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 4.2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) =>
          _buildItemCard(items[index], itemsProvider, isCompact: false),
    );
  }

  /// Devuelve el widget de estado vacío que se muestra cuando la lista no tiene elementos o cuando
  /// una búsqueda no arroja resultados.
  ///
  /// Cuando [isSearching] is `true`, se muestra una ilustración y un mensaje específicos de la búsqueda;
  /// de lo contrario, se muestra el estado vacío de "añade tu primer elemento".
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
                  ? context.l10n.listEmptySearch
                  : context.l10n.listEmptyTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.primary.withValues(alpha: 0.5),
                fontWeight: FontWeight.bold,
              ),
            ),
            if (!isSearching) ...[
              const SizedBox(height: 8),
              Text(
                context.l10n.listEmptyMessage,
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

  /// Vuelve a obtener los elementos de la fuente activa (remota, subcolección o biblioteca
  /// local) y actualiza [_currentList] desde el proveedor de listas.
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

  /// Navega a [ItemDetailScreen] para [item] y actualiza al volver.
  void _navigateToItemDetails(ItemModel item) {
    Navigator.pushNamed(
      context,
      AppRoutes.itemDetail,
      arguments: {'item': item, 'list': _currentList},
    ).then((_) => _refreshItems());
  }

  /// Abre la pantalla de entrada de elementos para añadir un nuevo elemento a la lista actual.
  void _navigateToAddItem() {
    Navigator.pushNamed(
      context,
      AppRoutes.itemEntry,
      arguments: {'list': _currentList, 'item': null},
    ).then((_) => _refreshItems());
  }

  /// Abre [ListConfigScreen] para [_currentList] y actualiza al volver.
  void _navigateToListConfig() {
    Navigator.pushNamed(
      context,
      AppRoutes.listConfig,
      arguments: _currentList,
    ).then((_) {
      _refreshItems();
    });
  }

  /// Navega a la pantalla de configuración de la lista para editar y actualiza al volver.
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

  /// Muestra un diálogo de confirmación antes de sincronizar (volver a obtener) la lista de elementos.
  void _showSyncDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ctx.l10n.commonSync),
        content: Text(ctx.l10n.listsSyncing),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(ctx.l10n.commonCancel.toUpperCase()),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(context.l10n.listsSyncing)),
                );
                _refreshItems();
              }
            },
            child: Text(ctx.l10n.commonSync.toUpperCase()),
          ),
        ],
      ),
    );
  }

  /// Muestra una hoja inferior con opciones de edición y eliminación para [item].
  ///
  /// Sin efecto cuando [_currentList.canEdit] es `false` (lista compartida de solo lectura).
  void _showItemOptions(ItemModel item) {
    if (!_currentList.canEdit) return;
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_rounded),
              title: Text(ctx.l10n.commonEdit),
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
              title: Text(
                ctx.l10n.commonDelete,
                style: const TextStyle(color: Colors.red),
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

  /// Muestra un diálogo de confirmación y elimina [item] al confirmar.
  void _confirmDeleteItem(ItemModel item) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(dialogContext.l10n.itemDeleteTitle),
        content: Text('${dialogContext.l10n.itemDeleteMessage}\n\n"${item.name}"'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(dialogContext.l10n.commonCancel.toUpperCase()),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              if (item.id != null) {
                await context.read<ItemsProvider>().deleteItem(item.id!);
                if (mounted) {
                  _refreshItems();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('"${item.name}"')),
                  );
                }
              }
            },
            child: Text(
              dialogContext.l10n.commonDelete.toUpperCase(),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  /// Despacha las cadenas de acción del menú desde el menú de desbordamiento de la barra de la aplicación.
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
      case 'leave':
        _confirmLeaveList();
        break;
    }
  }

  /// Muestra un diálogo de confirmación y abandona [_currentList] al confirmar,
  /// eliminándola de la vista del usuario y cerrando la pantalla.
  void _confirmLeaveList() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(dialogContext.l10n.listLeaveTitle),
        content: Text(dialogContext.l10n.listLeaveConfirm(_currentList.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(dialogContext.l10n.commonCancel.toUpperCase()),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              if (_currentList.id != null) {
                final success = await context
                    .read<ListsProvider>()
                    .leaveLibrary(_currentList.id!);
                if (success && mounted) {
                  Navigator.pop(context);
                }
              }
            },
            child: Text(
              dialogContext.l10n.listLeaveAction,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  /// Muestra un diálogo que permite al propietario publicar la lista en la nube
  /// para que pueda compartirse con otros usuarios a través de un ID remoto.
  void _showUploadDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ctx.l10n.listsUploadCloud),
        content: Text(ctx.l10n.listsUploadCloud),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(ctx.l10n.commonCancel.toUpperCase()),
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
                    SnackBar(content: Text(context.l10n.listsPublished)),
                  );
                  _refreshItems();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(context.l10n.listsPublishError)),
                  );
                }
              }
            },
            child: Text(ctx.l10n.commonPublish.toUpperCase()),
          ),
        ],
      ),
    );
  }

  /// Muestra un diálogo de confirmación de eliminación y elimina [_currentList] del
  /// servidor al confirmar, luego cierra la pantalla.
  void _confirmDeleteList() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(dialogContext.l10n.listsDeleteTitle),
        content: Text('${dialogContext.l10n.listsDeleteMessage}\n\n"${_currentList.name}"'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(dialogContext.l10n.commonCancel.toUpperCase()),
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
            child: Text(
              dialogContext.l10n.commonDelete.toUpperCase(),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  /// Muestra un diálogo para enviar una invitación de colaboración para [_currentList]
  /// eligiendo entre los amigos del usuario. Los amigos que ya son colaboradores
  /// de esta lista quedan excluidos de la selección.
  void _showShareDialog() {
    final listId = _currentList.id;
    if (listId == null) return;
    showDialog(
      context: context,
      builder: (_) => ShareFriendDialog(
        listId: listId,
        listName: _currentList.name,
        friends: context.read<FriendsProvider>().friends,
      ),
    );
  }
}
