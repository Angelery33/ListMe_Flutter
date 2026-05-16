import 'package:flutter/material.dart';

/// Barra de resumen compacta que muestra estadísticas de precios agregadas para una biblioteca.
///
/// Muestra el monto total gastado en elementos adquiridos y el presupuesto proyectado
/// en los elementos de la lista de deseos. No renderiza nada cuando [isVisible] es `false`, lo que
/// permite al padre ocultarlo sin eliminarlo del árbol.
class ListPriceSummary extends StatelessWidget {
  /// El precio sumado de todos los elementos que no están en la lista de deseos (adquiridos) en la biblioteca.
  final double totalAcquired;

  /// El precio sumado de todos los elementos de la lista de deseos, que representa el presupuesto necesario
  /// para adquirirlos.
  final double totalWishlist;

  /// Controla si se muestra la barra de resumen. Cuando es `false`, el widget
  /// se colapsa en un [SizedBox] vacío para que el diseño no se vea afectado.
  final bool isVisible;

  const ListPriceSummary({
    super.key,
    required this.totalAcquired,
    required this.totalWishlist,
    this.isVisible = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            context,
            "Gastado",
            "${totalAcquired.toStringAsFixed(2)}€",
            Icons.account_balance_wallet_outlined,
          ),
          _buildStatItem(
            context,
            "Presupuesto",
            "${totalWishlist.toStringAsFixed(2)}€",
            Icons.shopping_cart_outlined,
          ),
        ],
      ),
    );
  }

  /// Construye una única columna de estadísticas etiquetada con un icono, una [label] y una
  /// cadena de [value] formateada.
  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: colorScheme.primary),
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
        ),
      ],
    );
  }
}
