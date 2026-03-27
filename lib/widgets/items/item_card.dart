import 'package:flutter/material.dart';
import '../../data/items/item_model.dart';
import 'standard_item_card.dart';
import 'compact_item_card.dart';

/// Un widget de tarjeta para elementos de lista que alterna entre 
/// vista estándar y compacta.
class ItemCard extends StatelessWidget {
  final ItemModel item;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool showStatus;
  final bool isCompact;
  final bool isGradeable;
  final bool isThematic;
  final bool supportsPrice;
  final bool supportsProgress;
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
