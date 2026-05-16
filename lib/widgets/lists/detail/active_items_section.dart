import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/items/item_model.dart';
import '../../../core/providers/responsive_provider.dart';
import '../../items/item_card.dart';

/// Sección de carrusel horizontal que se muestra en la parte superior de la pantalla de detalles de la biblioteca
/// que destaca los elementos configurados actualmente con el estado "en progreso".
///
/// No renderiza nada cuando [items] está vacío para que no haya un espacio visual en el diseño.
class ActiveItemsSection extends StatelessWidget {
  /// La lista de elementos en progreso para mostrar en el carrusel.
  /// Cada elemento se renderiza como una [ItemCard] de ancho fijo.
  final List<ItemModel> items;

  /// Indica si se debe usar la variante compacta de tarjeta de elemento (menos relleno vertical).
  final bool isCompact;

  /// Indica si los elementos de esta biblioteca pueden ser puntuados/calificados.
  /// Se reenvía a [ItemCard] para mostrar condicionalmente la insignia de calificación.
  final bool isGradeable;

  /// Indica si la biblioteca está organizada por género/categoría.
  /// Se reenvía a [ItemCard] para mostrar condicionalmente el chip de género.
  final bool isThematic;

  /// Indica si los elementos rastrean un precio. Se reenvía a [ItemCard].
  final bool supportsPrice;

  /// Indica si los elementos rastrean el progreso de lectura/visualización. Se reenvía a [ItemCard].
  final bool supportsProgress;

  /// Se llama cuando el usuario toca una tarjeta de elemento para abrir la pantalla de detalles del elemento.
  final Function(ItemModel) onTap;

  /// Se llama cuando el usuario mantiene presionada una tarjeta de elemento (ej. para mostrar un menú contextual).
  final Function(ItemModel) onLongPress;

  /// Función de retorno opcional que se llama cuando el usuario toca el botón de incremento de progreso
  /// en una tarjeta de elemento. Cuando es `null`, el botón de incremento se oculta.
  final Function(ItemModel)? onIncrement;

  const ActiveItemsSection({
    super.key,
    required this.items,
    required this.isCompact,
    required this.isGradeable,
    required this.isThematic,
    required this.supportsPrice,
    required this.supportsProgress,
    required this.onTap,
    required this.onLongPress,
    this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final responsive = context.read<ResponsiveProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Icon(
                Icons.play_circle_fill_rounded,
                size: responsive.sectionHeaderFontSize + 6,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                "DISFRUTANDO AHORA",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  fontSize: responsive.sectionHeaderFontSize,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: responsive.activeCardHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Container(
                width: responsive.activeCardWidth,
                margin: const EdgeInsets.only(right: 12),
                child: ItemCard(
                  item: item,
                  onTap: () => onTap(item),
                  onLongPress: () => onLongPress(item),
                  isCompact: isCompact,
                  showStatus: false,
                  isGradeable: isGradeable,
                  isThematic: isThematic,
                  supportsPrice: supportsPrice,
                  supportsProgress: supportsProgress,
                  onIncrement: onIncrement != null
                      ? () => onIncrement!(item)
                      : null,
                ),
              );
            },
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Divider(height: 1),
        ),
      ],
    );
  }
}
