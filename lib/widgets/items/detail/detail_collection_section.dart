import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/items/item_details_provider.dart';


class DetailCollectionSection extends StatelessWidget {
  const DetailCollectionSection({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ItemDetailsProvider>();
    final item = provider.item;
    
    if (item == null || !item.collection) return const SizedBox.shrink();

    final subItems = provider.subItems;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "COLECCIÓN (${subItems.length})",
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
                letterSpacing: 1.2,
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.grid_view),
                  tooltip: "Ver todos",
                  color: Theme.of(context).colorScheme.primary,
                  onPressed: () {
                    // Navigate to a filtered list or something
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Vista de colección en desarrollo")),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () {
                    // Add subitem logic
                  },
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (subItems.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1)),
            ),
            child: const Center(
              child: Text(
                "Esta colección está vacía.",
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ),
          )
        else
          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: subItems.length,
              itemBuilder: (context, index) {
                final sub = subItems[index];
                return Stack(
                  children: [
                    Container(
                      width: 100,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(12),
                        image: sub.imagePath != null
                            ? DecorationImage(
                                image: NetworkImage(sub.imagePath!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      child: Container(
                        width: 100,
                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                        ),
                        child: Text(
                          sub.name,
                          style: const TextStyle(color: Colors.white, fontSize: 10),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
      ],
    );
  }
}
