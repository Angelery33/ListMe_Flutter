import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/config/routes.dart';
import '../../core/i18n/l10n_extension.dart';
import '../../core/providers/responsive_provider.dart';
import '../../data/lists/list_model.dart';
import '../../providers/lists/lists_provider.dart';
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
              child: _buildListBody(listsProvider, responsive),
            ),
    );
  }

  /// Construye una lista reordenable (compacta) o una cuadrícula adaptable (mediana /
  /// expandida) dependiendo de [responsive.isCompact].
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
    final maxCrossAxisExtent = responsive.isExpanded ? 520.0 : 560.0;
    return GridView.builder(
      padding: padding,
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: maxCrossAxisExtent,
        mainAxisExtent: 110,
        crossAxisSpacing: 18,
        mainAxisSpacing: 12,
      ),
      itemCount: listsProvider.lists.length,
      itemBuilder: (context, index) =>
          _buildListCard(listsProvider.lists[index]),
    );
  }

  /// Construye una [ListCard] para [list] configurada para navegar y realizar acciones de editar, eliminar y
  /// compartir.
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
