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
    final hPadding = responsive.isCompact
        ? responsive.horizontalPadding
        : responsive.horizontalPadding + 48;
    final padding = EdgeInsets.fromLTRB(hPadding, 32, hPadding, 200);

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

    // Medium / Expanded: cuatro columnas con altura dinámica por fila.
    // El padding se aplica al Column interior para que LayoutBuilder
    // reciba el ancho real disponible y calcule colWidth correctamente.
    final lists = listsProvider.lists;
    const cols = 4;
    const colSpacing = 20.0;
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth
            - padding.left
            - padding.right
            - colSpacing * (cols - 1);
        final colWidth = availableWidth / cols;
        final rows = <Widget>[];
        for (int i = 0; i < lists.length; i += cols) {
          rows.add(Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(cols, (j) {
              final idx = i + j;
              return [
                if (j > 0) const SizedBox(width: colSpacing),
                SizedBox(
                  width: colWidth,
                  child: idx < lists.length
                      ? _buildListCard(lists[idx], webLayout: true)
                      : const SizedBox.shrink(),
                ),
              ];
            }).expand((w) => w).toList(),
          ));
          if (i + cols < lists.length) rows.add(const SizedBox(height: 12));
        }
        return Align(
          alignment: Alignment.topLeft,
          child: SingleChildScrollView(
            child: Padding(
              padding: padding,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: rows,
              ),
            ),
          ),
        );
      },
    );
  }

  /// Construye una [ListCard] para [list] configurada para navegar y realizar acciones de editar, eliminar y
  /// compartir.
  Widget _buildListCard(ListModel list, {bool webLayout = false}) {
    return ListCard(
      key: ValueKey(list.id),
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
