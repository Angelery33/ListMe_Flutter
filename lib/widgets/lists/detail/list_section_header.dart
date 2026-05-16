import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/responsive_provider.dart';

/// Encabezado de sección táctil utilizado para etiquetar y colapsar/expandir un grupo de estados
/// en la vista de detalles de la biblioteca.
///
/// Presenta un acento de borde izquierdo de color, un [title] en mayúsculas, una etiqueta
/// secundaria de precio opcional y un icono de colapsar/expandir que refleja [isCollapsed].
class ListSectionHeader extends StatelessWidget {
  /// El título de la sección mostrado en mayúsculas (ej. "COMPLETADO", "PENDIENTE").
  final String title;

  /// Indica si el cuerpo de la sección está actualmente colapsado (oculto).
  /// Controla qué icono se muestra (agregar vs. eliminar).
  final bool isCollapsed;

  /// Se llama cuando el usuario toca el encabezado para alternar el estado colapsado.
  final VoidCallback onTap;

  /// Precio total opcional de los elementos en esta sección.
  /// Se muestra como una etiqueta secundaria cuando no es nulo y es mayor que cero.
  final double? totalPrice;

  const ListSectionHeader({
    super.key,
    required this.title,
    required this.isCollapsed,
    required this.onTap,
    this.totalPrice,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final responsive = context.read<ResponsiveProvider>();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        margin: const EdgeInsets.only(top: 24.0, bottom: 8.0),
        decoration: BoxDecoration(
          color: colorScheme.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border(
            left: BorderSide(
              color: colorScheme.primary,
              width: 4,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.toUpperCase(),
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w900,
                      fontSize: responsive.sectionHeaderFontSize,
                      letterSpacing: 1.5,
                    ),
                  ),
                  if (totalPrice != null && totalPrice! > 0)
                    Text(
                      "${totalPrice!.toStringAsFixed(2)}€",
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.primary.withValues(alpha: 0.7),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              isCollapsed
                  ? Icons.add_circle_outline_rounded
                  : Icons.remove_circle_outline_rounded,
              color: colorScheme.primary.withValues(alpha: 0.5),
              size: responsive.sectionHeaderFontSize + 6,
            ),
          ],
        ),
      ),
    );
  }
}
