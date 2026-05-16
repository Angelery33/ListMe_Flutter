import 'package:flutter/material.dart';
import '../../data/items/item_model.dart';
import 'standard_item_card.dart';
import 'compact_item_card.dart';

/// Un widget de tarjeta para elementos de lista que alterna entre
/// vista estándar ([StandardItemCard]) y compacta ([CompactItemCard]).
///
/// Actúa como un despachador: cuando [isCompact] es true, delega en
/// [CompactItemCard], de lo contrario en [StandardItemCard].
class ItemCard extends StatelessWidget {
  /// El modelo de datos del elemento a renderizar.
  final ItemModel item;

  /// Se llama cuando se toca la tarjeta para abrir la pantalla de detalles del elemento.
  final VoidCallback onTap;

  /// Se llama cuando se mantiene presionada la tarjeta, ej. para mostrar un menú contextual.
  final VoidCallback? onLongPress;

  /// Indica si se debe renderizar el indicador de estado de finalización (punto + etiqueta).
  final bool showStatus;

  /// Cuando es true, se renderiza como una celda de cuadrícula cuadrada ([CompactItemCard]) en lugar de
  /// una fila de lista horizontal ([StandardItemCard]).
  final bool isCompact;

  /// Indica si se debe mostrar la insignia de puntuación numérica cuando el elemento ha sido calificado.
  final bool isGradeable;

  /// Indica si se debe mostrar la información de género/temática.
  final bool isThematic;

  /// Indica si se debe mostrar el precio del elemento cuando haya uno disponible.
  final bool supportsPrice;

  /// Indica si se debe renderizar una barra de progreso y el texto de progreso en la tarjeta.
  final bool supportsProgress;

  /// Función de retorno opcional para incrementar el progreso del elemento en una unidad
  /// directamente desde la lista (atajo de acción rápida).
  final VoidCallback? onIncrement;

  const ItemCard({
    super.key,
    required this.item,
    required this.onTap,
    this.onLongPress,
    this.showStatus = true,
    this.isCompact = false,
    this.isGradeable = true,
    this.isThematic = true,
    this.supportsPrice = true,
    this.supportsProgress = false,
    this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return CompactItemCard(
        item: item,
        onTap: onTap,
        onLongPress: onLongPress,
        isGradeable: isGradeable,
        supportsProgress: supportsProgress,
      );
    }

    return StandardItemCard(
      item: item,
      onTap: onTap,
      onLongPress: onLongPress,
      showStatus: showStatus,
      isGradeable: isGradeable,
      isThematic: isThematic,
      supportsPrice: supportsPrice,
      supportsProgress: supportsProgress,
    );
  }
}
