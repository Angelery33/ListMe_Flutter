import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/items/item_details_provider.dart';

class DetailProgressSection extends StatelessWidget {
  const DetailProgressSection({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ItemDetailsProvider>();
    final item = provider.item;
    if (item == null) return const SizedBox.shrink();

    final current = item.currentProgress ?? 0;
    final total = item.totalProgress;
    final String unit = item.progressUnit ?? 'unidades';

    // ProgressBar calculation
    double progressPercent = 0.0;
    if (total != null && total > 0) {
      progressPercent = (current / total).clamp(0.0, 1.0);
    } else if (current > 0) {
      // Fake progress if no total
      progressPercent = 0.1;
    }

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "PROGRESO ($unit)".toUpperCase(),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                "$current ${total != null && total > 0 ? '/ $total' : ''}",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progressPercent,
                    minHeight: 12,
                    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      progressPercent == 1.0 
                          ? Colors.green 
                          : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              if (total == null || current < total)
                ElevatedButton.icon(
                  onPressed: () => provider.incrementProgress(),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text("1"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                )
              else 
                Icon(Icons.check_circle, color: Colors.green, size: 36),
            ],
          ),
        ],
      ),
    );
  }
}
