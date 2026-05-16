import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../data/items/item_model.dart';

/// Muestra las fechas de inicio, finalización y adquisición de un elemento en la pantalla de
/// detalles.
///
/// Devuelve un widget vacío cuando ninguna de las tres fechas está establecida, para no
/// añadir desorden visual para los elementos sin seguimiento de fecha.
class DetailDatesSection extends StatelessWidget {
  /// El elemento cuyos campos de fecha se renderizan.
  final ItemModel item;

  const DetailDatesSection({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    if (item.startDate == null &&
        item.completionDate == null &&
        item.acquisitionDate == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "FECHAS",
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          if (item.startDate != null)
            _buildDateItem(
              context,
              "Fecha de Inicio",
              item.startDate!,
              Icons.calendar_today,
            ),
          if (item.completionDate != null)
            _buildDateItem(
              context,
              "Fecha de Finalización",
              item.completionDate!,
              Icons.check_circle_outline,
            ),
          if (item.acquisitionDate != null)
            _buildDateItem(
              context,
              "Fecha de Adquisición",
              item.acquisitionDate!,
              Icons.shopping_cart_outlined,
            ),
        ],
      ),
    );
  }

  /// Renderiza una única fila de fecha con [icon], una leyenda [label] y el
  /// [timestamp] (milisegundos desde la época) formateado como dd/MM/yyyy.
  Widget _buildDateItem(
    BuildContext context,
    String label,
    int timestamp,
    IconData icon,
  ) {
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
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
