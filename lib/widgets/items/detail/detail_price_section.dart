import 'package:flutter/material.dart';
import '../../../core/i18n/l10n_extension.dart';
import '../../../../data/items/item_model.dart';

class DetailPriceSection extends StatelessWidget {
  final ItemModel item;

  const DetailPriceSection({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    if (item.price == null || item.price == 0.0) return const SizedBox.shrink();

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(top: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.2),
        ),
      ),
      color: Theme.of(context).colorScheme.tertiaryContainer.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.payments_outlined,
                color: Theme.of(context).colorScheme.tertiary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.wishlist ? context.l10n.infoPriceEstimated : context.l10n.infoPriceCost,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.tertiary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
                Text(
                  "${item.price!.toStringAsFixed(2)} €",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onTertiaryContainer,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
