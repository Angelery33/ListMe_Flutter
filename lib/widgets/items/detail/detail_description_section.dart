import 'package:flutter/material.dart';
import '../../../../data/items/item_model.dart';
// Note: ExpandableText was a custom widget in the original project.
// We'll build a simplified inline version here or rely on standard Text if it's too complex.

class DetailDescriptionSection extends StatefulWidget {
  final ItemModel item;

  const DetailDescriptionSection({super.key, required this.item});

  @override
  State<DetailDescriptionSection> createState() => _DetailDescriptionSectionState();
}

class _DetailDescriptionSectionState extends State<DetailDescriptionSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.item.description == null || widget.item.description!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.notes,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 10),
              Text(
                "DESCRIPCIÓN",
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Text(
              widget.item.description!,
              maxLines: _expanded ? null : 4,
              overflow: _expanded ? TextOverflow.visible : TextOverflow.fade,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.5,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          if (!_expanded && widget.item.description!.length > 150)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: GestureDetector(
                onTap: () => setState(() => _expanded = true),
                child: Text(
                  "Leer más",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
