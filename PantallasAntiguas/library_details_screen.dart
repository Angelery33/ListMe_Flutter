import 'package:flutter/material.dart';
import '../../providers/auth_provider.dart';
import '../../services/cloud_sync_service.dart';
import 'package:provider/provider.dart';
import '../../data/models.dart';
import '../../providers/item_provider.dart';
import '../../providers/library_provider.dart';
import '../../data/database_helper.dart';
import 'item_details_screen.dart';
import 'item_entry_screen.dart';
import 'library_entry_screen.dart';
import '../components/item_card.dart';
import '../app_theme.dart';
import '../components/responsive_container.dart';

class LibraryDetailsScreen extends StatefulWidget {
  final int? idLibrary;
  final String libraryName;
  final String? remoteId;
  final int? parentId;

  const LibraryDetailsScreen({
    super.key,
    required this.idLibrary,
    required this.libraryName,
    this.remoteId,
    this.parentId,
  });

  @override
  State<LibraryDetailsScreen> createState() => _LibraryDetailsScreenState();
}

class _LibraryDetailsScreenState extends State<LibraryDetailsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _collapsedSections = {};
  bool _isStatsVisible = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      if (widget.parentId != null && widget.idLibrary != null) {
        Provider.of<ItemProvider>(
          context,
          listen: false,
        ).loadSubCollections(widget.parentId!, widget.idLibrary!);
      } else if (widget.idLibrary != null && widget.idLibrary != -1) {
        Provider.of<ItemProvider>(
          context,
          listen: false,
        ).loadData(widget.idLibrary!);
      } else {
        // Handle shared library without local ID
        _handleSharedLibrary();
      }
    });
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (!mounted) return;
    Provider.of<ItemProvider>(
      context,
      listen: false,
    ).setSearchQuery(_searchController.text);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ItemProvider>(
      builder: (context, itemProvider, child) {
        final currentLib = itemProvider.currentLibrary;
        final displayName = currentLib?.name ?? widget.libraryName;

        return Scaffold(
          appBar: AppBar(
            flexibleSpace: AppTheme.getAppBarGradient(context),
            automaticallyImplyLeading: true,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/logobiblio.png',
                  height: 40,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(displayName, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            actions: [
              Consumer<AuthProvider>(
                builder: (context, auth, _) {
                  if (currentLib?.isCloud ?? false) {
                    return IconButton(
                      icon: const Icon(Icons.person_add_alt_1),
                      tooltip: 'Compartir lista',
                      onPressed: () => _showShareDialog(context, currentLib!),
                    );
                  } else {
                    return IconButton(
                      icon: const Icon(Icons.cloud_upload_outlined),
                      tooltip: 'Subir a la nube',
                      onPressed: () {
                        if (auth.isAuthenticated && currentLib != null) {
                          _showUploadDialog(
                            context,
                            currentLib,
                            auth.user!.uid,
                            auth.user!.email!,
                          );
                        } else if (!auth.isAuthenticated) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Inicia sesión para usar la nube'),
                            ),
                          );
                        }
                      },
                    );
                  }
                },
              ),
              Consumer<AuthProvider>(
                builder: (context, auth, _) {
                  final isOwner = currentLib?.ownerId == auth.user?.uid;
                  return PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'sync') {
                        if (currentLib?.remoteId != null &&
                            currentLib?.idLibrary != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Sincronizando items...'),
                            ),
                          );
                          try {
                            if (currentLib?.idLibrary == null) return;
                            await itemProvider.syncTwoWay(
                              currentLib!.idLibrary!,
                            );
                            if (!mounted) return;

                            // syncTwoWay already refreshes the item list in the provider
                            if (context.mounted) {
                              ScaffoldMessenger.of(
                                context,
                              ).hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Sincronización completada'),
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(
                                context,
                              ).hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            }
                          }
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('No es una lista en la nube'),
                              ),
                            );
                          }
                        }
                      } else if (value == 'edit') {
                        _showEditLibraryDialog(context);
                      } else if (value == 'delete') {
                        _showDeleteLibraryDialog(context);
                      }
                    },
                    itemBuilder: (context) => [
                      if (isOwner)
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('Editar Lista'),
                        ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text(
                          'Eliminar Lista',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ),
            ),
          ),
          body: itemProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: () async {
                    if (widget.parentId != null && widget.idLibrary != null) {
                      await itemProvider.loadSubCollections(
                        widget.parentId!,
                        widget.idLibrary!,
                      );
                    } else if (widget.idLibrary != null) {
                      await itemProvider.syncTwoWay(widget.idLibrary!);
                    }
                  },
                  child: ResponsiveContainer(
                    child: Column(
                      children: [
                        // Sorting & Filter Row
                        Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Theme.of(
                                  context,
                                ).colorScheme.outlineVariant,
                                width: 1,
                              ),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 8.0,
                          ),
                          child: Row(
                            children: [
                              PopupMenuButton<SortOption>(
                                icon: Icon(
                                  Icons.sort,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                tooltip: "Ordenar",
                                onSelected: (option) =>
                                    itemProvider.setSortOption(option),
                                itemBuilder: (BuildContext context) =>
                                    <PopupMenuEntry<SortOption>>[
                                      const PopupMenuItem(
                                        value: SortOption.dateNewest,
                                        child: Text('Fecha (Más reciente)'),
                                      ),
                                      const PopupMenuItem(
                                        value: SortOption.dateOldest,
                                        child: Text('Fecha (Más antiguo)'),
                                      ),
                                      const PopupMenuItem(
                                        value: SortOption.nameAsc,
                                        child: Text('Nombre (A-Z)'),
                                      ),
                                      const PopupMenuItem(
                                        value: SortOption.nameDesc,
                                        child: Text('Nombre (Z-A)'),
                                      ),
                                      const PopupMenuItem(
                                        value: SortOption.scoreHighLow,
                                        child: Text('Puntuación (Alta-Baja)'),
                                      ),
                                      const PopupMenuItem(
                                        value: SortOption.scoreLowHigh,
                                        child: Text('Puntuación (Baja-Alta)'),
                                      ),
                                    ],
                              ),
                              const SizedBox(width: 8),
                              Container(
                                height: 24,
                                width: 1,
                                color: Theme.of(
                                  context,
                                ).colorScheme.outlineVariant,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      if (currentLib != null &&
                                          currentLib.supportsPrice)
                                        IconButton(
                                          icon: Icon(
                                            _isStatsVisible
                                                ? Icons.insert_chart
                                                : Icons.insert_chart_outlined,
                                            color: _isStatsVisible
                                                ? Theme.of(
                                                    context,
                                                  ).colorScheme.primary
                                                : Colors.grey,
                                            size: 20,
                                          ),
                                          tooltip: _isStatsVisible
                                              ? "Ocultar estadísticas"
                                              : "Mostrar estadísticas",
                                          onPressed: () => setState(
                                            () => _isStatsVisible =
                                                !_isStatsVisible,
                                          ),
                                        ),
                                      const SizedBox(width: 4),
                                      FilterChip(
                                        label: const Text('Todos'),
                                        padding: EdgeInsets.zero,
                                        visualDensity: VisualDensity.compact,
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        selected:
                                            itemProvider.filterGenre == null,
                                        onSelected: (selected) =>
                                            itemProvider.setFilterGenre(null),
                                      ),
                                      const SizedBox(width: 8),
                                      ...itemProvider.availableGenres.map((
                                        genre,
                                      ) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            right: 8.0,
                                          ),
                                          child: FilterChip(
                                            label: Text(genre),
                                            padding: EdgeInsets.zero,
                                            visualDensity:
                                                VisualDensity.compact,
                                            materialTapTargetSize:
                                                MaterialTapTargetSize
                                                    .shrinkWrap,
                                            selected:
                                                itemProvider.filterGenre ==
                                                genre,
                                            onSelected: (selected) =>
                                                itemProvider.setFilterGenre(
                                                  selected ? genre : null,
                                                ),
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (currentLib != null &&
                            currentLib.supportsPrice &&
                            _isStatsVisible)
                          _buildPriceSummary(itemProvider),
                        Expanded(
                          child:
                              itemProvider.items.isEmpty &&
                                  !itemProvider.isLoading &&
                                  itemProvider.searchQuery.isEmpty &&
                                  itemProvider.filterGenre == null
                              ? ListView(
                                  children: [
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                          0.7,
                                      child: _buildEmptyState(),
                                    ),
                                  ],
                                )
                              : Builder(
                                  builder: (context) {
                                    final grouped = _buildGroupedList(
                                      context,
                                      itemProvider,
                                    );
                                    return ListView(
                                      padding: const EdgeInsets.all(16),
                                      children: [
                                        if (currentLib != null)
                                          _buildActiveItemsSection(
                                            itemProvider,
                                            currentLib,
                                          ),
                                        ...grouped,
                                        if (itemProvider.items.isNotEmpty &&
                                            grouped.isEmpty)
                                          Padding(
                                            padding: const EdgeInsets.all(60.0),
                                            child: Center(
                                              child: Column(
                                                children: [
                                                  Icon(
                                                    Icons.search_off,
                                                    size: 48,
                                                    color: Colors.grey
                                                        .withValues(alpha: 0.5),
                                                  ),
                                                  const SizedBox(height: 16),
                                                  Text(
                                                    "No se encontraron resultados para el filtro seleccionado.",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        const SizedBox(height: 80),
                                      ],
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.all(24.0),
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ItemEntryScreen(
                      libraryId: widget.idLibrary!,
                      parentId: widget.parentId,
                    ),
                  ),
                ).then((value) {
                  if (value == true && widget.idLibrary != null) {
                    if (widget.parentId != null) {
                      itemProvider.loadSubCollections(
                        widget.parentId!,
                        widget.idLibrary!,
                      );
                    } else {
                      itemProvider.loadData(widget.idLibrary!);
                      Provider.of<LibraryProvider>(
                        context,
                        listen: false,
                      ).loadLibraries();
                    }
                  }
                });
              },
              child: const Icon(Icons.add),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildGroupedList(BuildContext context, ItemProvider provider) {
    final items = provider.items;
    final lib = provider.currentLibrary;

    if (lib == null) return [];

    bool isSearching = provider.searchQuery.isNotEmpty;

    if (isSearching) {
      if (lib.isCompact) {
        return [_buildGrid(items, lib, provider)];
      }
      return items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: ItemCard(
                item: item,
                onTap: () => _navigateToDetails(item),
                onLongPress: () => _showItemOptions(context, item, lib),
                showStatus: lib.supportsCompletion,
                isCompact: lib.isCompact,
                isGradeable: lib.isGradeable,
                isThematic: lib.isThematic,
                supportsPrice: lib.supportsPrice,
                supportsProgress: lib.supportsProgress,
                onIncrement: () => provider.incrementProgress(item),
              ),
            ),
          )
          .toList();
    }

    if (lib.supportsCompletion) {
      final pending = items.where((i) => i.status == "PENDING").toList();
      final inProgress = items.where((i) => i.status == "IN_PROGRESS").toList();
      final completed = items.where((i) => i.status == "COMPLETED").toList();

      List<Widget> sections = [];

      if (pending.isNotEmpty) {
        final price = _calculateTotal(pending);
        final title =
            "Pendiente (${pending.length})${lib.supportsPrice ? ' - $price€' : ''}";
        sections.add(_buildSectionHeader(title));
        if (!_collapsedSections.contains(title)) {
          sections.addAll(_buildThematicList(pending, lib, provider));
        }
      }
      if (inProgress.isNotEmpty) {
        final price = _calculateTotal(inProgress);
        final title =
            "En Progreso (${inProgress.length})${lib.supportsPrice ? ' - $price€' : ''}";
        sections.add(_buildSectionHeader(title));
        if (!_collapsedSections.contains(title)) {
          sections.addAll(_buildThematicList(inProgress, lib, provider));
        }
      }
      if (completed.isNotEmpty) {
        final price = _calculateTotal(completed);
        final title =
            "Completado (${completed.length})${lib.supportsPrice ? ' - $price€' : ''}";
        sections.add(_buildSectionHeader(title));
        if (!_collapsedSections.contains(title)) {
          sections.addAll(_buildThematicList(completed, lib, provider));
        }
      }
      return sections;
    }

    if (lib.supportsWishlist) {
      final acquired = items.where((i) => !i.isWishlist).toList();
      final wishlist = items.where((i) => i.isWishlist).toList();

      List<Widget> sections = [];
      if (acquired.isNotEmpty) {
        final price = _calculateTotal(acquired);
        final title =
            "Adquirido (${acquired.length})${lib.supportsPrice ? ' - $price€' : ''}";
        sections.add(_buildSectionHeader(title));
        if (!_collapsedSections.contains(title)) {
          sections.addAll(_buildThematicList(acquired, lib, provider));
        }
      }
      if (wishlist.isNotEmpty) {
        final price = _calculateTotal(wishlist);
        final title =
            "Lista de Deseos (${wishlist.length})${lib.supportsPrice ? ' - $price€' : ''}";
        sections.add(_buildSectionHeader(title));
        if (!_collapsedSections.contains(title)) {
          sections.addAll(_buildThematicList(wishlist, lib, provider));
        }
      }
      return sections;
    }

    return _buildThematicList(items, lib, provider);
  }

  List<Widget> _buildThematicList(
    List<Item> items,
    Library lib,
    ItemProvider provider,
  ) {
    if (lib.isCompact) {
      if (!lib.isThematic || lib.genreLayoutMode == 0) {
        return [_buildGrid(items, lib, provider)];
      }

      Map<String, List<Item>> groups = {};
      List<String> order = [];

      for (var genreName in provider.availableGenres) {
        final gItems = items.where((i) => i.genre == genreName).toList();
        if (gItems.isNotEmpty) {
          groups[genreName] = gItems;
          order.add(genreName);
        }
      }

      final processedIds = groups.values
          .expand((e) => e)
          .map((i) => i.idItem)
          .toSet();
      final remaining = items
          .where((i) => !processedIds.contains(i.idItem))
          .toList();

      if (remaining.isNotEmpty) {
        groups["Otros"] = remaining;
        order.add("Otros");
      }

      List<Widget> widgets = [];
      for (var key in order) {
        final groupItems = groups[key] ?? [];
        if (groupItems.isEmpty) continue;

        if (lib.genreLayoutMode == 1) {
          widgets.add(
            Padding(
              padding: const EdgeInsets.only(left: 0, top: 12.0, bottom: 8.0),
              child: Text(
                key.toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  fontSize: 12,
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.8),
                ),
              ),
            ),
          );
        }
        widgets.add(_buildGrid(groupItems, lib, provider));
      }
      return widgets;
    }

    if (!lib.isThematic || lib.genreLayoutMode == 0) {
      return items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: _buildItemCard(item, lib, provider),
            ),
          )
          .toList();
    }

    Map<String, List<Item>> groups = {};
    List<String> order = [];

    for (var genreName in provider.availableGenres) {
      final gItems = items.where((i) => i.genre == genreName).toList();
      if (gItems.isNotEmpty) {
        groups[genreName] = gItems;
        order.add(genreName);
      }
    }

    final processedIds = groups.values
        .expand((e) => e)
        .map((i) => i.idItem)
        .toSet();
    final remaining = items
        .where((i) => !processedIds.contains(i.idItem))
        .toList();

    if (remaining.isNotEmpty) {
      groups["Otros"] = remaining;
      order.add("Otros");
    }

    List<Widget> widgets = [];
    for (var key in order) {
      final groupItems = groups[key] ?? [];
      if (groupItems.isEmpty) continue;

      if (lib.genreLayoutMode == 1) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 12.0, bottom: 4.0),
            child: Text(
              key.toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                fontSize: 12,
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.8),
              ),
            ),
          ),
        );
      }

      widgets.addAll(
        groupItems.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: _buildItemCard(item, lib, provider),
          ),
        ),
      );
    }

    return widgets;
  }

  Widget _buildSectionHeader(String title) {
    final bool isCollapsed = _collapsedSections.contains(title);
    return InkWell(
      onTap: () {
        setState(() {
          if (isCollapsed) {
            _collapsedSections.remove(title);
          } else {
            _collapsedSections.add(title);
          }
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        margin: const EdgeInsets.only(top: 24.0, bottom: 8.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border(
            left: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 4,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title.toUpperCase(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            Icon(
              isCollapsed
                  ? Icons.add_circle_outline
                  : Icons.remove_circle_outline,
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.5),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToDetails(Item item) {
    if (widget.parentId != null) {
      // Reverting to push to ensure we can go back to the subcollection list
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ItemDetailsScreen(itemId: item.idItem!, item: item),
        ),
      ).then((_) {
        // Refresh when coming back
        if (!mounted) return;
        Provider.of<ItemProvider>(
          context,
          listen: false,
        ).loadSubCollections(widget.parentId!, widget.idLibrary!);
      });
    } else {
      // For main library, push so we can come back to list
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ItemDetailsScreen(itemId: item.idItem!, item: item),
        ),
      ).then((_) {
        if (!mounted) return;
        Provider.of<ItemProvider>(
          context,
          listen: false,
        ).loadData(widget.idLibrary!);
      });
    }
  }

  void _showItemOptions(BuildContext context, Item item, Library lib) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(item.name),
        children: [
          SimpleDialogOption(
            onPressed: () async {
              Navigator.pop(context);
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      ItemEntryScreen(libraryId: lib.idLibrary!, item: item),
                ),
              );
              if (mounted) {
                if (widget.parentId != null) {
                  Provider.of<ItemProvider>(
                    context,
                    listen: false,
                  ).loadSubCollections(widget.parentId!, lib.idLibrary!);
                } else {
                  Provider.of<ItemProvider>(
                    context,
                    listen: false,
                  ).loadData(lib.idLibrary!);
                }
              }
            },
            child: const Row(
              children: [Icon(Icons.edit), SizedBox(width: 16), Text('Editar')],
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              _showItemDeleteConfirmation(context, item, lib);
            },
            child: const Row(
              children: [
                Icon(Icons.delete, color: Colors.red),
                SizedBox(width: 16),
                Text('Eliminar', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showItemDeleteConfirmation(
    BuildContext context,
    Item item,
    Library lib,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Elemento'),
        content: Text('¿Seguro que quieres eliminar "${item.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final provider = Provider.of<ItemProvider>(
                context,
                listen: false,
              );
              await provider.deleteItem(item);

              if (mounted) {
                if (widget.parentId != null) {
                  provider.loadSubCollections(widget.parentId!, lib.idLibrary!);
                } else {
                  provider.loadData(lib.idLibrary!);
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('"${item.name}" eliminado')),
                );
              }
            },
            child: const Text('ELIMINAR', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showEditLibraryDialog(BuildContext context) async {
    if (widget.idLibrary == null) return;

    final lib = await DatabaseHelper.instance.getLibraryById(widget.idLibrary!);
    if (lib != null && context.mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => LibraryEntryScreen(library: lib)),
      );

      if (mounted) {
        Provider.of<LibraryProvider>(context, listen: false).loadLibraries();
        Provider.of<ItemProvider>(
          context,
          listen: false,
        ).loadData(widget.idLibrary!);
      }
    }
  }

  void _showDeleteLibraryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Lista'),
        content: Text(
          '¿Estás seguro de que quieres eliminar la lista "${widget.libraryName}"? Se borrarán todos sus elementos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
          ),
          TextButton(
            onPressed: () {
              if (widget.idLibrary != null) {
                Provider.of<LibraryProvider>(
                  context,
                  listen: false,
                ).deleteLibrary(widget.idLibrary!);
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Close screen
              }
            },
            child: const Text('ELIMINAR', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSummary(ItemProvider provider) {
    final items = provider.items;
    final acquired = items.where((i) => !i.isWishlist).toList();
    final wishlist = items.where((i) => i.isWishlist).toList();

    final totalAcquired = _calculateTotal(acquired);
    final totalWishlist = _calculateTotal(wishlist);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            "Gastado",
            "$totalAcquired€",
            Icons.account_balance_wallet_outlined,
          ),
          _buildStatItem(
            "Presupuesto",
            "$totalWishlist€",
            Icons.shopping_cart_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  String _calculateTotal(List<Item> items) {
    double total = 0;
    for (var i in items) {
      total += i.price ?? 0;
    }
    return total.toStringAsFixed(2);
  }

  Widget _buildActiveItemsSection(ItemProvider provider, Library lib) {
    final activeItems = provider.items.where((i) => i.isCurrent).toList();
    if (activeItems.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 0, top: 0, bottom: 8),
          child: Row(
            children: [
              Icon(
                Icons.play_circle_fill,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                "DISFRUTANDO AHORA",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        if (lib.isCompact)
          _buildGrid(activeItems, lib, provider)
        else
          SizedBox(
            height: 160,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              itemCount: activeItems.length,
              itemBuilder: (context, index) {
                final item = activeItems[index];
                return Container(
                  width: 150,
                  margin: const EdgeInsets.only(right: 12),
                  child: ItemCard(
                    item: item,
                    onTap: () => _navigateToDetails(item),
                    onLongPress: () => _showItemOptions(context, item, lib),
                    isCompact: true, // Force compact for this section
                    isGradeable: lib.isGradeable,
                    isThematic: lib.isThematic,
                    supportsPrice: lib.supportsPrice,
                    supportsProgress: lib.supportsProgress,
                    onIncrement: () => provider.incrementProgress(item),
                  ),
                );
              },
            ),
          ),
        const Divider(height: 32),
      ],
    );
  }

  Widget _buildGrid(List<Item> items, Library lib, ItemProvider provider) {
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
        return _buildItemCard(item, lib, provider);
      },
    );
  }

  Widget _buildItemCard(Item item, Library lib, ItemProvider provider) {
    return ItemCard(
      item: item,
      onTap: () => _navigateToDetails(item),
      onLongPress: () => _showItemOptions(context, item, lib),
      showStatus: lib.supportsCompletion,
      isCompact: lib.isCompact,
      isGradeable: lib.isGradeable,
      isThematic: lib.isThematic,
      supportsPrice: lib.supportsPrice,
      supportsProgress: lib.supportsProgress,
      onIncrement: () => provider.incrementProgress(item),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.library_books_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 16),
          Text(
            "Esta lista está vacía",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.5),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Pulsa '+' para añadir tu primer elemento",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  void _showUploadDialog(
    BuildContext context,
    Library lib,
    String userId,
    String userEmail,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Subir a la nube'),
        content: const Text(
          '¿Quieres publicar esta lista en la nube? Esto permitirá compartirla con otras personas y sincronizarla entre tus dispositivos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              _showLoadingOverlay();
              try {
                final remoteId = await CloudSyncService.instance.uploadLibrary(
                  lib,
                  userId,
                  userEmail,
                );
                await CloudSyncService.instance.syncItemsToCloud(
                  lib.idLibrary!,
                  remoteId,
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Lista publicada')),
                  );
                  // Force local refresh
                  Provider.of<LibraryProvider>(
                    context,
                    listen: false,
                  ).loadLibraries();
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error al subir: $e')));
                }
              } finally {
                _hideLoadingOverlay();
              }
            },
            child: const Text('PUBLICAR'),
          ),
        ],
      ),
    );
  }

  void _showShareDialog(BuildContext context, Library lib) {
    showDialog(
      context: context,
      builder: (context) => _CollaboratorsDialog(library: lib),
    );
  }

  void _showLoadingOverlay() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
  }

  void _hideLoadingOverlay() {
    Navigator.of(context, rootNavigator: true).pop();
  }

  void _handleSharedLibrary() async {
    // If we have a remoteId but no idLibrary, we should find or import
    if (widget.remoteId != null) {
      // 1. Try to find locally by remoteId
      final localLib = await DatabaseHelper.instance.getLibraryByRemoteId(
        widget.remoteId!,
      );
      if (localLib != null && mounted) {
        Provider.of<ItemProvider>(
          context,
          listen: false,
        ).loadData(localLib.idLibrary!);
        return;
      }

      // 2. If not found, suggest importing
      if (mounted) {
        _showImportDialog();
      }
    }
  }

  void _showImportDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Lista Compartida'),
        content: Text(
          '¿Quieres descargar "${widget.libraryName}" a tu dispositivo para empezar a trabajar con ella?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              _showLoadingOverlay();
              try {
                // Fetch the REAL library data from Firestore
                final remoteLib = await CloudSyncService.instance
                    .getLibraryMetadata(widget.remoteId!);

                if (remoteLib == null) {
                  if (mounted) {
                    _hideLoadingOverlay();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Error: No se encontró la lista o no tienes permisos',
                        ),
                      ),
                    );
                  }
                  return;
                }

                // Create local copy with REAL metadata
                // We reset idLibrary to null so SQLite generates a new local ID
                // But we KEEP the original ownerId, name, etc.
                final newLib = Library(
                  idLibrary: null, // Let SQLite generate local ID
                  name: remoteLib.name,
                  type: remoteLib.type,
                  supportsCompletion: remoteLib.supportsCompletion,
                  isGradeable: remoteLib.isGradeable,
                  isThematic: remoteLib.isThematic,
                  supportsWishlist: remoteLib.supportsWishlist,
                  tracksDates: remoteLib.tracksDates,
                  supportsPrice: remoteLib.supportsPrice,
                  description: remoteLib.description,
                  genreLayoutMode: remoteLib.genreLayoutMode,
                  isCompact: remoteLib.isCompact,
                  isCloud: true,
                  remoteId: widget.remoteId,
                  ownerId:
                      remoteLib.ownerId, // IMPORTANT: Use real ownerId (UID)
                  ownerEmail: remoteLib.ownerEmail, // Use display email
                );

                final newId = await DatabaseHelper.instance.insertLibrary(
                  newLib,
                );

                // Download items
                await CloudSyncService.instance.downloadRemoteItems(
                  widget.remoteId!,
                  newId,
                );

                if (mounted) {
                  Provider.of<LibraryProvider>(
                    context,
                    listen: false,
                  ).loadLibraries();
                  Provider.of<ItemProvider>(
                    context,
                    listen: false,
                  ).loadData(newId);

                  // Show success and maybe exit or refresh
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Lista importada correctamente'),
                    ),
                  );

                  // Refresh current screen to show newly imported data?
                  // Actually, if we just imported it, we are currently viewing "remote view" (empty).
                  // We should probably redirect to the new local library or just reload.
                  // Since this screen handles both, just reloading might work but widget.idLibrary is null.
                  // Ideally, we should replace this screen with one pointing to the new local ID.
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LibraryDetailsScreen(
                        idLibrary: newId,
                        libraryName: newLib.name,
                      ),
                    ),
                  );
                }
              } catch (e) {
                if (mounted)
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $e')));
              } finally {
                if (mounted) _hideLoadingOverlay();
              }
            },
            child: const Text('DESCARGAR'),
          ),
        ],
      ),
    );
  }
}

class _CollaboratorsDialog extends StatefulWidget {
  final Library library;

  const _CollaboratorsDialog({required this.library});

  @override
  State<_CollaboratorsDialog> createState() => _CollaboratorsDialogState();
}

class _CollaboratorsDialogState extends State<_CollaboratorsDialog> {
  late Future<List<String>> _collaboratorsFuture;
  final TextEditingController _emailController = TextEditingController();
  String? _currentUserUid;

  @override
  void initState() {
    super.initState();
    _loadCollaborators();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currentUser = Provider.of<AuthProvider>(context, listen: false).user;
    _currentUserUid = currentUser?.uid;
  }

  void _loadCollaborators() {
    if (widget.library.remoteId != null) {
      _collaboratorsFuture = CloudSyncService.instance.getCollaborators(
        widget.library.remoteId!,
      );
    } else {
      _collaboratorsFuture = Future.value([]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOwner = widget.library.ownerId == _currentUserUid;
    final displayOwner = widget.library.ownerEmail ?? widget.library.ownerId;

    return AlertDialog(
      title: const Text('Colaboradores'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isOwner && widget.library.ownerId != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Text(
                    'Propietario: $displayOwner',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),

              const Text(
                'Personas con acceso:',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 8),

              FutureBuilder<List<String>>(
                future: _collaboratorsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  final collaborators = snapshot.data ?? [];
                  if (collaborators.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text('Solo tú tienes acceso.'),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: collaborators.length,
                    itemBuilder: (context, index) {
                      final email = collaborators[index];
                      // Hide owner if in list (check against display email or id)
                      if (email == widget.library.ownerEmail ||
                          email == widget.library.ownerId)
                        return const SizedBox.shrink();

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(email),
                        trailing: isOwner
                            ? IconButton(
                                icon: const Icon(Icons.close, size: 18),
                                onPressed: () async {
                                  await CloudSyncService.instance
                                      .removeCollaborator(
                                        widget.library.remoteId!,
                                        email,
                                      );
                                  setState(() {
                                    _loadCollaborators();
                                  });
                                },
                              )
                            : null,
                      );
                    },
                  );
                },
              ),

              if (isOwner) ...[
                const Divider(),
                const SizedBox(height: 8),
                const Text(
                  'Invitar nuevo:',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          hintText: 'email@ejemplo.com',
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () async {
                        final email = _emailController.text.trim();
                        if (email.isNotEmpty &&
                            widget.library.remoteId != null) {
                          try {
                            // Show loading
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Enviando invitación...'),
                              ),
                            );

                            await CloudSyncService.instance.inviteCollaborator(
                              widget.library.remoteId!,
                              email,
                            );
                            _emailController.clear();
                            setState(() {
                              _loadCollaborators();
                            });
                            if (mounted) {
                              ScaffoldMessenger.of(
                                context,
                              ).hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Invitación enviada a $email'),
                                ),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(
                                context,
                              ).hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            }
                          }
                        }
                      },
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        if (!isOwner)
          TextButton(
            onPressed: () async {
              // Leave library
              if (widget.library.idLibrary != null) {
                // deleteLibrary now handles both local delete and Cloud Leave/Delete depending on ownership
                await Provider.of<LibraryProvider>(
                  context,
                  listen: false,
                ).deleteLibrary(widget.library.idLibrary!);

                if (mounted) {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Close screen
                }
              }
            },
            child: const Text(
              'DEJAR DE SEGUIR',
              style: TextStyle(color: Colors.red),
            ),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CERRAR'),
        ),
      ],
    );
  }
}
