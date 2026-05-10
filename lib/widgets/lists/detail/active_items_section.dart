import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/items/item_model.dart';
import '../../../core/providers/responsive_provider.dart';
import '../../items/item_card.dart';

class ActiveItemsSection extends StatelessWidget {
  final List<ItemModel> items;
  final bool isCompact;
  final bool isGradeable;
  final bool isThematic;
  final bool supportsPrice;
  final bool supportsProgress;
  final Function(ItemModel) onTap;
  final Function(ItemModel) onLongPress;
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
