import 'package:flutter/material.dart';
import 'package:flutter_reorderable_grid_view/widgets/reorderable_builder.dart';
import 'package:flutter_reorderable_grid_view/entities/order_update_entity.dart';
import 'package:provider/provider.dart';
import '../../core/config/routes.dart';
import '../../core/i18n/l10n_extension.dart';
import '../../core/providers/responsive_provider.dart';
import '../../data/lists/list_model.dart';
import '../../providers/lists/lists_provider.dart';
import '../../providers/settings/settings_provider.dart';
import '../../widgets/lists/list_card.dart';
import '../../widgets/lists/empty_lists_state.dart';
import '../../widgets/shared/custom_gradient_app_bar.dart';
import '../../widgets/shared/app_shell.dart';
import '../../providers/friends/friends_provider.dart';
import '../../widgets/lists/share_friend_dialog.dart';

/// Pantalla que muestra todas las bibliotecas del usuario actual.
///
/// En pantallas compactas, las bibliotecas se muestran en una lista de una sola
/// columna reordenable. En pantallas medianas y expandidas, cambian a una cuadrícula adaptable.
/// Un botón de acción flotante abre [ListConfigScreen] para crear una nueva biblioteca.
class ListsScreen extends StatefulWidget {
  const ListsScreen({super.key});

  @override
  State<ListsScreen> createState() => _ListsScreenState();
}

/// Estado para [ListsScreen].
///
/// Activa la obtención de la lista en el primer frame para que los datos en caché obsoletos se actualicen
/// inmediatamente cuando aparece la pantalla.
class _ListsScreenState extends State<ListsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<ListsProvider>().fetchLists();
    });
  }

  @override
  Widget build(BuildContext context) {
    final listsProvider = context.watch<ListsProvider>();
    final responsive = context.watch<ResponsiveProvider>();
    final settings = context.watch<SettingsProvider>();
    final theme = Theme.of(context);

    return AppShell(
      currentIndex: 0,
      appBar: CustomGradientAppBar(
        title: context.l10n.listsTitle,
        showBackButton: false,
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
          onPressed: () async {
            await Navigator.pushNamed(context, AppRoutes.listConfig);
            if (mounted) context.read<ListsProvider>().fetchLists();
          },
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          child: const Icon(Icons.add_rounded, size: 28),
        ),
      ),
      body: listsProvider.lists.isEmpty
          ? const EmptyListsState()
          : RefreshIndicator(
              onRefresh: () async {
                await context.read<ListsProvider>().fetchLists();
              },
              child: _buildListBody(listsProvider, responsive, settings.sharedListsLayout),
            ),
    );
  }

  Widget _buildListBody(ListsProvider listsProvider, ResponsiveProvider responsive, SharedListsLayout layout) {
    final hPadding = responsive.isCompact
        ? responsive.horizontalPadding
        : responsive.horizontalPadding + 48;

    final owned = listsProvider.lists.where((l) => l.owner).toList();
    final shared = listsProvider.lists.where((l) => !l.owner).toList();

    // Pestaña: aplica en todos los breakpoints cuando hay listas ajenas
    if (layout == SharedListsLayout.tab && shared.isNotEmpty) {
      return _buildTabLayout(owned, shared, responsive, hPadding, listsProvider);
    }

    final showHeader = layout == SharedListsLayout.section && shared.isNotEmpty;

    // Compact + Medium: lista con slivers
    if (responsive.isCompact || responsive.isMedium) {
      return _buildListView(owned, shared, showHeader, hPadding, listsProvider);
    }

    // Expanded: sin listas ajenas → grid reordenable original
    if (shared.isEmpty) {
      final padding = EdgeInsets.fromLTRB(hPadding, 32, hPadding, 200);
      return _ReorderableGrid(
        lists: owned,
        padding: padding,
        onReorder: (o, n) => listsProvider.reorderOwnedLists(o, n, adjustIndex: false),
        buildCard: (list) => _buildListCard(list, webLayout: true),
      );
    }

    // Expanded con listas ajenas: "Al final" → grid reordenable + ajenas bloqueadas
    if (layout == SharedListsLayout.bottom) {
      final allLists = [...owned, ...shared];
      final lockedIndices = List.generate(shared.length, (i) => owned.length + i);
      final padding = EdgeInsets.fromLTRB(hPadding, 32, hPadding, 200);
      return _ReorderableGrid(
        lists: allLists,
        lockedIndices: lockedIndices,
        padding: padding,
        onReorder: (o, n) => listsProvider.reorderOwnedLists(o, n, adjustIndex: false),
        buildCard: (list) => _buildListCard(list, webLayout: true),
      );
    }

    // Expanded + sección: dos SliverGrids sin reordenación
    return _buildGridSections(owned, shared, hPadding);
  }

  Widget _buildListView(
    List<ListModel> owned,
    List<ListModel> shared,
    bool showHeader,
    double hPadding,
    ListsProvider listsProvider,
  ) {
    // Número total de ítems: propios + encabezado opcional + ajenos
    final hasHeader = showHeader && shared.isNotEmpty;
    final totalItems = owned.length + (hasHeader ? 1 : 0) + shared.length;

    return ReorderableListView.builder(
      padding: EdgeInsets.fromLTRB(hPadding, 32, hPadding, 200),
      buildDefaultDragHandles: false,
      itemCount: totalItems,
      onReorder: (oldIndex, newIndex) {
        // Solo se permite reordenar dentro del bloque de listas propias
        if (oldIndex >= owned.length) return;
        if (newIndex > owned.length) newIndex = owned.length;
        listsProvider.reorderOwnedLists(oldIndex, newIndex);
      },
      itemBuilder: (context, index) {
        if (index < owned.length) {
          final list = owned[index];
          return ReorderableDragStartListener(
            key: ValueKey(list.id),
            index: index,
            child: _buildListCard(list),
          );
        }
        if (hasHeader && index == owned.length) {
          return _SectionHeader(
            key: const ValueKey('__section_header__'),
            label: context.l10n.listsSharedWithMe,
            hPadding: hPadding,
          );
        }
        final sharedIndex = index - owned.length - (hasHeader ? 1 : 0);
        return KeyedSubtree(
          key: ValueKey('shared_${shared[sharedIndex].id}'),
          child: _buildListCard(shared[sharedIndex]),
        );
      },
    );
  }

  Widget _buildGridSections(List<ListModel> owned, List<ListModel> shared, double hPadding) {
    const colSpacing = 20.0;
    const minColWidth = 400.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final usableWidth = constraints.maxWidth - hPadding * 2;
        final cols = (usableWidth / (minColWidth + colSpacing)).floor().clamp(2, 6);
        final delegate = SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cols,
          crossAxisSpacing: colSpacing,
          mainAxisSpacing: 12,
          mainAxisExtent: 110,
        );

        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(hPadding, 32, hPadding, 0),
              sliver: SliverGrid(
                gridDelegate: delegate,
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildListCard(owned[index], webLayout: true),
                  childCount: owned.length,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _SectionHeader(label: context.l10n.listsSharedWithMe, hPadding: hPadding),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(hPadding, 8, hPadding, 200),
              sliver: SliverGrid(
                gridDelegate: delegate,
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildListCard(shared[index], webLayout: true),
                  childCount: shared.length,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTabLayout(
    List<ListModel> owned,
    List<ListModel> shared,
    ResponsiveProvider responsive,
    double hPadding,
    ListsProvider listsProvider,
  ) {
    final theme = Theme.of(context);
    final isGrid = !responsive.isCompact && !responsive.isMedium;
    final padding = EdgeInsets.fromLTRB(hPadding, 32, hPadding, 200);

    Widget ownedView;
    if (isGrid) {
      ownedView = _ReorderableGrid(
        lists: owned,
        padding: padding,
        onReorder: (o, n) => listsProvider.reorderOwnedLists(o, n, adjustIndex: false),
        buildCard: (list) => _buildListCard(list, webLayout: true),
      );
    } else {
      ownedView = ReorderableListView.builder(
        padding: padding,
        buildDefaultDragHandles: false,
        itemCount: owned.length,
        onReorder: listsProvider.reorderOwnedLists,
        itemBuilder: (context, index) {
          final list = owned[index];
          return ReorderableDragStartListener(
            key: ValueKey(list.id),
            index: index,
            child: _buildListCard(list),
          );
        },
      );
    }

    final Widget sharedView = isGrid
        ? _StaticGrid(lists: shared, hPadding: hPadding)
        : ListView.builder(
            padding: padding,
            itemCount: shared.length,
            itemBuilder: (context, index) => _buildListCard(shared[index]),
          );

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            labelColor: theme.colorScheme.primary,
            indicatorColor: theme.colorScheme.primary,
            tabs: [
              Tab(text: context.l10n.listsMyLists),
              Tab(text: context.l10n.listsSharedWithMe),
            ],
          ),
          Expanded(
            child: TabBarView(children: [ownedView, sharedView]),
          ),
        ],
      ),
    );
  }

  /// Construye una [ListCard] para [list] configurada para navegar y realizar acciones de editar, eliminar y
  /// compartir.
  Widget _buildListCard(ListModel list, {bool webLayout = false}) {
    return ListCard(
      key: webLayout ? null : ValueKey(list.id),
      list: list,
      webLayout: webLayout,
      onTap: () => Navigator.pushNamed(context, AppRoutes.list, arguments: list),
      onEdit: () async {
        await Navigator.pushNamed(context, AppRoutes.listConfig, arguments: list);
        if (mounted) context.read<ListsProvider>().fetchLists();
      },
      onDelete: () => _confirmDeleteList(list),
      onShare: () => _showShareDialog(list),
    );
  }

  /// Muestra el diálogo de invitación con selector de amigos para [list].
  void _showShareDialog(ListModel list) {
    final friends = context.read<FriendsProvider>().friends;
    showDialog(
      context: context,
      builder: (_) => ShareFriendDialog(
        listId: list.id!,
        listName: list.name,
        friends: friends,
      ),
    );
  }

  /// Muestra un diálogo de confirmación y elimina [list] a través de [ListsProvider] al
  /// confirmar.
  void _confirmDeleteList(ListModel list) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.listsDeleteTitle),
        content: Text('${context.l10n.listsDeleteMessage}\n\n"${list.name}"'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(context.l10n.commonCancel.toUpperCase()),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              if (list.id != null) {
                final success = await context
                    .read<ListsProvider>()
                    .deleteList(list.id!);
                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('"${list.name}"')),
                  );
                }
              }
            },
            child: Text(
              context.l10n.commonDelete.toUpperCase(),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Grid reordenable para el breakpoint expanded (tablet horizontal / escritorio)
// ─────────────────────────────────────────────────────────────────────────────

class _ReorderableGrid extends StatefulWidget {
  final List<ListModel> lists;
  final EdgeInsets padding;
  final void Function(int oldIndex, int newIndex) onReorder;
  final Widget Function(ListModel list) buildCard;
  final List<int> lockedIndices;

  const _ReorderableGrid({
    required this.lists,
    required this.padding,
    required this.onReorder,
    required this.buildCard,
    this.lockedIndices = const [],
  });

  @override
  State<_ReorderableGrid> createState() => _ReorderableGridState();
}

class _ReorderableGridState extends State<_ReorderableGrid> {
  final _scrollController = ScrollController();
  final _gridKey = GlobalKey();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const colSpacing = 20.0;
    const minColWidth = 400.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final usableWidth =
            constraints.maxWidth - widget.padding.left - widget.padding.right;
        final cols =
            (usableWidth / (minColWidth + colSpacing)).floor().clamp(2, 6);

        final gridItems = widget.lists
            .map((list) => SizedBox(
                  key: ValueKey(list.id),
                  height: 110,
                  child: widget.buildCard(list),
                ))
            .toList();

        return ReorderableBuilder(
          scrollController: _scrollController,
          lockedIndices: widget.lockedIndices,
          onReorder: (List<OrderUpdateEntity> entities) {
            for (final entity in entities) {
              widget.onReorder(entity.oldIndex, entity.newIndex);
            }
          },
          children: gridItems,
          builder: (children) => GridView(
            key: _gridKey,
            controller: _scrollController,
            padding: widget.padding,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cols,
              crossAxisSpacing: colSpacing,
              mainAxisSpacing: 12,
              mainAxisExtent: 110,
            ),
            children: children,
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Encabezado de sección para separar listas propias de ajenas
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  final double hPadding;

  const _SectionHeader({super.key, required this.label, required this.hPadding});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(hPadding, 24, hPadding, 4),
      child: Text(
        label.toUpperCase(),
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Grid estático (no reordenable) para listas ajenas en modo expanded
// ─────────────────────────────────────────────────────────────────────────────

class _StaticGrid extends StatelessWidget {
  final List<ListModel> lists;
  final double hPadding;

  const _StaticGrid({required this.lists, required this.hPadding});

  @override
  Widget build(BuildContext context) {
    const colSpacing = 20.0;
    const minColWidth = 400.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final usableWidth = constraints.maxWidth - hPadding * 2;
        final cols = (usableWidth / (minColWidth + colSpacing)).floor().clamp(2, 6);

        return GridView.builder(
          padding: EdgeInsets.fromLTRB(hPadding, 32, hPadding, 200),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            crossAxisSpacing: colSpacing,
            mainAxisSpacing: 12,
            mainAxisExtent: 110,
          ),
          itemCount: lists.length,
          itemBuilder: (context, index) {
            final list = lists[index];
            // Necesita acceso a contexto del State para navegación y acciones
            return _StaticGridCardProxy(list: list);
          },
        );
      },
    );
  }
}

// Proxy que obtiene callbacks del árbol de widgets para las cards en _StaticGrid
class _StaticGridCardProxy extends StatelessWidget {
  final ListModel list;
  const _StaticGridCardProxy({required this.list});

  @override
  Widget build(BuildContext context) {
    return ListCard(
      key: ValueKey(list.id),
      list: list,
      webLayout: true,
      onTap: () => Navigator.pushNamed(context, AppRoutes.list, arguments: list),
      onEdit: () async {
        await Navigator.pushNamed(context, AppRoutes.listConfig, arguments: list);
        context.read<ListsProvider>().fetchLists();
      },
      onDelete: () => _confirmDelete(context, list),
      onShare: () => _showShare(context, list),
    );
  }

  void _confirmDelete(BuildContext context, ListModel list) {
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.listsDeleteTitle),
        content: Text('${l10n.listsDeleteMessage}\n\n"${list.name}"'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.commonCancel.toUpperCase()),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              if (list.id != null) {
                await context.read<ListsProvider>().deleteList(list.id!);
              }
            },
            child: Text(
              l10n.commonDelete.toUpperCase(),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showShare(BuildContext context, ListModel list) {
    final friends = context.read<FriendsProvider>().friends;
    showDialog(
      context: context,
      builder: (_) => ShareFriendDialog(
        listId: list.id!,
        listName: list.name,
        friends: friends,
      ),
    );
  }
}
