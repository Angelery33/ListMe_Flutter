import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../data/items/item_model.dart';

class DetailDatesSection extends StatelessWidget {
  final ItemModel item;

  const DetailDatesSection({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    if (item.startDate == null && item.completionDate == null && item.acquisitionDate == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          "FECHAS",
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.outline,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        if (item.startDate != null)
          _buildDateItem(context, "Fecha de Inicio", item.startDate!, Icons.calendar_today),
        if (item.completionDate != null)
          _buildDateItem(context, "Fecha de Finalización", item.completionDate!, Icons.check_circle_outline),
        if (item.acquisitionDate != null)
          _buildDateItem(context, "Fecha de Adquisición", item.acquisitionDate!, Icons.shopping_cart_outlined),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildDateItem(BuildContext context, String label, int timestamp, IconData icon) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              Text(
                DateFormat('dd/MM/yyyy').format(date),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
