import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/routes.dart';
import '../../providers/lists/lists_provider.dart';
import '../../widgets/lists/list_card.dart';
import '../../widgets/lists/empty_lists_state.dart';
import '../../widgets/shared/custom_gradient_app_bar.dart';
import '../../widgets/shared/app_bottom_nav_bar.dart';

/// Pantalla principal que muestra el listado de listas del usuario.
/// 
/// Permite reordenar mediante drag & drop, editar, eliminar y crear nuevas listas.
class ListsScreen extends StatefulWidget {
  const ListsScreen({super.key});

  @override
  State<ListsScreen> createState() => _ListsScreenState();
}

class _ListsScreenState extends State<ListsScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar listas cuando la pantalla se muestra (después del login)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ListsProvider>().fetchLists();
    });
  }

  @override
  Widget build(BuildContext context) {
    final listsProvider = context.watch<ListsProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const CustomGradientAppBar(title: 'Mis Listas', showBackButton: false),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 0, // Listas = 0
        onTap: (index) {
          if (index == 1) Navigator.pushNamed(context, AppRoutes.profile);
          if (index == 2) Navigator.pushNamed(context, AppRoutes.settings);
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        extendedPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.listConfig);
        },
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded, size: 18),
        label: const Text('NUEVA LISTA', style: TextStyle(fontSize: 16)),
      ),
      body: listsProvider.lists.isEmpty
          ? const EmptyListsState()
          : Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: ReorderableListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100), // Espacio para el FAB centrado
                itemCount: listsProvider.lists.length,
                onReorder: (oldIndex, newIndex) {
                  listsProvider.reorderLists(oldIndex, newIndex);
                },
                itemBuilder: (context, index) {
                  final list = listsProvider.lists[index];
                  return ListCard(
                    key: ValueKey(list.id),
                    list: list,
                    onTap: () {
                      Navigator.pushNamed(
                        context, 
                        AppRoutes.list,
                        arguments: list,
                      );
                    },
                    onEdit: () {
                      Navigator.pushNamed(
                        context, 
                        AppRoutes.listConfig,
                        arguments: list,
                      );
                    },
                    onDelete: () {
                      // TODO: Implementar eliminación satisfactoria
                    },
                  );
                },
              ),
            ),
    );
  }
}
