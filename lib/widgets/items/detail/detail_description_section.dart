import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/i18n/l10n_extension.dart';

import '../../../data/items/item_model.dart';
import '../../../providers/items/item_details_provider.dart';
import '../../shared/expandable_text.dart';

/// Renderiza la descripción de un elemento en la pantalla de detalles, proporcionando
/// opcionalmente un botón de edición en línea para que el usuario pueda actualizar el texto.
///
/// Cuando [canEdit] es verdadero, aparece un botón de icono para editar/añadir en la fila del encabezado.
/// Al pulsarlo se abre un diálogo multilínea respaldado por [ItemDetailsProvider.updateDescription].
class DetailDescriptionSection extends StatelessWidget {
  /// El elemento cuya descripción se muestra.
  final ItemModel item;

  /// Indica si se debe mostrar el botón de edición que permite al usuario actualizar la
  /// descripción. Se establece en falso en contextos de solo lectura.
  final bool canEdit;

  const DetailDescriptionSection({super.key, required this.item, this.canEdit = true});

  /// Abre un diálogo con un campo de texto multilínea precargado con la descripción
  /// actual. Al guardar, llama a [ItemDetailsProvider.updateDescription] con
  /// el resultado recortado.
  Future<void> _editDescription(BuildContext context) async {
    final controller = TextEditingController(text: item.description ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ctx.l10n.descriptionEdit),
        content: SizedBox(
          width: 500,
          child: TextField(
            controller: controller,
            maxLines: 10,
            minLines: 5,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: ctx.l10n.descriptionPlaceholder,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(ctx.l10n.commonCancel.toUpperCase()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: Text(ctx.l10n.commonSave.toUpperCase()),
          ),
        ],
      ),
    );
    if (result != null && context.mounted) {
      await context.read<ItemDetailsProvider>().updateDescription(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final description = item.description ?? '';
    final hasDescription = description.isNotEmpty;
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.notes, size: 20, color: primary),
                  const SizedBox(width: 10),
                  Text(
                    'DESCRIPCIÓN',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: primary,
                          letterSpacing: 1.2,
                        ),
                  ),
                ],
              ),
              if (canEdit)
                IconButton(
                  icon: Icon(
                    hasDescription ? Icons.edit_outlined : Icons.add,
                    size: 20,
                  ),
                  tooltip: hasDescription ? context.l10n.descriptionEdit : context.l10n.descriptionAdd,
                  onPressed: () => _editDescription(context),
                  color: primary,
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (!hasDescription)
            Text(
              'Sin descripción. Pulsa el botón para añadir una.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            )
          else
            ExpandableText(
              text: description,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.5,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
        ],
      ),
    );
  }
}
