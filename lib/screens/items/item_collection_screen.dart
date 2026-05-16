import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/i18n/l10n_extension.dart';

import '../../data/items/item_model.dart';
import '../../data/lists/list_model.dart';
import '../../providers/items/item_details_provider.dart';
import '../../widgets/items/compact_item_card.dart';
import '../../widgets/shared/custom_gradient_app_bar.dart';
import 'item_detail_screen.dart';

/// Pantalla que muestra los sub-elementos (volúmenes, episodios, etc.) de una
/// colección [ItemModel].
///
/// Lee los datos de los sub-elementos de [ItemDetailsProvider] y permite al usuario
/// abrir sub-elementos individuales o añadir nuevos.
class ItemCollectionScreen extends StatefulWidget {
  /// El elemento de colección padre cuyos sub-elementos se muestran.
  final ItemModel parent;

  /// La biblioteca a la que pertenece [parent], pasada a las pantallas hijas para que
  /// puedan respetar la configuración a nivel de lista (por ejemplo, [ListModel.canEdit]).
  final ListModel? list;

  const ItemCollectionScreen({super.key, required this.parent, this.list});

  @override
  State<ItemCollectionScreen> createState() => _ItemCollectionScreenState();
}

/// Estado para [ItemCollectionScreen].
///
/// Activa la carga de sub-elementos en el primer frame y se actualiza después de regresar de
/// cualquier pantalla de detalle o entrada.
class _ItemCollectionScreenState extends State<ItemCollectionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ItemDetailsProvider>().loadSubItems();
    });
  }

  /// Navega a [ItemDetailScreen] para [sub] y actualiza los sub-elementos al
  /// regresar.
  Future<void> _openSubItem(ItemModel sub) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ItemDetailScreen(item: sub, list: widget.list),
      ),
    );
    if (mounted) {
      await context.read<ItemDetailsProvider>().loadSubItems();
    }
  }

  /// Abre la pantalla de entrada de elementos pre-rellenada con el ID del padre para que el nuevo
  /// elemento se vincule a esta colección, luego actualiza al regresar.
  Future<void> _addSubItem() async {
    final result = await Navigator.pushNamed(
      context,
      '/item-entry',
      arguments: {
        'list': widget.list,
        'parentId': widget.parent.id,
      },
    );
    if (result == true && mounted) {
      await context.read<ItemDetailsProvider>().loadSubItems();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ItemDetailsProvider>();
    final subItems = provider.subItems;

    return Scaffold(
      appBar: CustomGradientAppBar(
        title: '${widget.parent.name} · ${context.l10n.collectionTitle}',
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: context.l10n.commonAdd,
            onPressed: _addSubItem,
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : subItems.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.collections_bookmark_outlined, size: 64),
                        const SizedBox(height: 16),
                        Text(
                          context.l10n.collectionEmpty,
                          style: const TextStyle(fontStyle: FontStyle.italic),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _addSubItem,
                          icon: const Icon(Icons.add),
                          label: Text(context.l10n.collectionAddItem),
                        ),
                      ],
                    ),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate:
                      const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 160,
                    childAspectRatio: 1.0,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: subItems.length,
                  itemBuilder: (context, index) {
                    final sub = subItems[index];
                    return CompactItemCard(
                      item: sub,
                      onTap: () => _openSubItem(sub),
                    );
                  },
                ),
    );
  }
}
