import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/config/routes.dart';
import '../../core/providers/responsive_provider.dart';
import '../../data/lists/list_model.dart';
import '../../providers/lists/lists_provider.dart';
import '../../widgets/lists/list_card.dart';
import '../../widgets/lists/empty_lists_state.dart';
import '../../widgets/shared/custom_gradient_app_bar.dart';
import '../../widgets/shared/app_shell.dart';

class ListsScreen extends StatefulWidget {
  const ListsScreen({super.key});

  @override
  State<ListsScreen> createState() => _ListsScreenState();
}

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
    final theme = Theme.of(context);

    return AppShell(
      currentIndex: 0,
      appBar: const CustomGradientAppBar(
        title: 'Mis Listas',
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
              child: _buildListBody(listsProvider, responsive),
            ),
    );
  }

  Widget _buildListBody(ListsProvider listsProvider, ResponsiveProvider responsive) {
    final padding = EdgeInsets.fromLTRB(
      responsive.horizontalPadding,
      16,
      responsive.horizontalPadding,
      100,
    );

    // Compact: reorderable single-column list
    if (responsive.isCompact) {
      return ReorderableListView.builder(
        padding: padding,
        itemCount: listsProvider.lists.length,
        onReorder: listsProvider.reorderLists,
        itemBuilder: (context, index) =>
            _buildListCard(listsProvider.lists[index]),
      );
    }

    // Medium / Expanded: grid that grows with screen width
    final maxCrossAxisExtent = responsive.isExpanded ? 360.0 : 420.0;
    return GridView.builder(
      padding: padding,
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: maxCrossAxisExtent,
        mainAxisExtent: 80,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: listsProvider.lists.length,
      itemBuilder: (context, index) =>
          _buildListCard(listsProvider.lists[index]),
    );
  }

  Widget _buildListCard(ListModel list) {
    return ListCard(
      key: ValueKey(list.id),
      list: list,
      onTap: () => Navigator.pushNamed(context, AppRoutes.list, arguments: list),
      onEdit: () async {
        await Navigator.pushNamed(context, AppRoutes.listConfig, arguments: list);
        if (mounted) context.read<ListsProvider>().fetchLists();
      },
      onDelete: () => _confirmDeleteList(list),
    );
  }

  void _confirmDeleteList(ListModel list) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar Lista'),
        content: Text(
          '¿Estás seguro de que quieres eliminar "${list.name}"? Se borrarán todos sus elementos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('CANCELAR'),
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
                    SnackBar(content: Text('"${list.name}" eliminada')),
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
}
