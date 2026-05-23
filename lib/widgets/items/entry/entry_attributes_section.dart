import 'package:flutter/material.dart';
import '../../../core/i18n/l10n_extension.dart';
import '../../../data/attributes/attribute_type_model.dart';
import '../../../data/attributes/attribute_item_model.dart';

/// Una sección de formulario para gestionar la lista de atributos personalizados de un elemento durante
/// la entrada / edición.
///
/// Muestra un [ListTile] para cada atributo existente con un botón de eliminar, y
/// proporciona botones de acción para añadir un nuevo valor de atributo o crear un nuevo
/// tipo de atributo desde cero.
class EntryAttributesSection extends StatefulWidget {
  /// La lista actual de valores de atributos ya añadidos al elemento.
  final List<AttributeItemModel> attributes;

  /// Todos los tipos de atributos disponibles en la biblioteca, mostrados en el menú desplegable
  /// del diálogo de adición.
  final List<AttributeTypeModel> allTypes;

  /// Se llama con el nuevo [AttributeItemModel] cuando el usuario confirma el diálogo de
  /// adición.
  final Function(AttributeItemModel) onAdd;

  /// Se llama con el índice de la lista del atributo que el usuario desea eliminar.
  final Function(int) onRemove;

  /// Fábrica opcional llamada cuando el usuario desea crear un tipo de atributo
  /// completamente nuevo. Devuelve el [AttributeTypeModel] creado, o nulo al cancelar.
  final Future<AttributeTypeModel?> Function()? onCreateAttributeType;

  const EntryAttributesSection({
    super.key,
    required this.attributes,
    required this.allTypes,
    required this.onAdd,
    required this.onRemove,
    this.onCreateAttributeType,
  });

  @override
  State<EntryAttributesSection> createState() => _EntryAttributesSectionState();
}

/// Estado para [EntryAttributesSection]. Contiene ayudantes de diálogo que requieren
/// acceso a las funciones de retorno del widget.
class _EntryAttributesSectionState extends State<EntryAttributesSection> {
  /// Abre un diálogo que permite al usuario elegir un tipo de atributo e introducir
  /// un valor. Incluye un botón [+] junto al selector para crear un tipo nuevo
  /// sin cerrar el diálogo.
  void _showAddAttributeDialog(BuildContext context) {
    // Copia local de tipos para poder añadir uno nuevo sin cerrar el diálogo.
    List<AttributeTypeModel> dialogTypes = List.of(widget.allTypes);
    AttributeTypeModel? selectedType =
        dialogTypes.isNotEmpty ? dialogTypes.first : null;
    final valueController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setStateDialog) {
            void confirm() {
              if (selectedType != null && valueController.text.isNotEmpty) {
                widget.onAdd(AttributeItemModel(
                  attributeTypeId: selectedType!.id!,
                  idItem: 0,
                  value: valueController.text,
                ));
                Navigator.pop(dialogContext);
              }
            }

            return AlertDialog(
              title: Text(dialogContext.l10n.attributesAdd),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Selector de tipo + botón crear nuevo tipo
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: dialogTypes.isEmpty
                            ? Text(
                                dialogContext.l10n.attributesEmpty,
                                style: Theme.of(dialogContext)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(fontStyle: FontStyle.italic),
                              )
                            : DropdownButtonFormField<AttributeTypeModel>(
                                initialValue: selectedType,
                                isExpanded: true,
                                decoration: InputDecoration(
                                  labelText: dialogContext.l10n.attributesType,
                                ),
                                items: dialogTypes
                                    .map((t) => DropdownMenuItem(
                                          value: t,
                                          child: Text(t.name),
                                        ))
                                    .toList(),
                                onChanged: (val) =>
                                    setStateDialog(() => selectedType = val),
                              ),
                      ),
                      if (widget.onCreateAttributeType != null)
                        IconButton(
                          icon: const Icon(Icons.add_rounded),
                          tooltip: dialogContext.l10n.attributesCreateType,
                          onPressed: () async {
                            final newType =
                                await widget.onCreateAttributeType!();
                            if (newType != null) {
                              setStateDialog(() {
                                dialogTypes = [...dialogTypes, newType];
                                selectedType = newType;
                              });
                            }
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: valueController,
                    autofocus: dialogTypes.isNotEmpty,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => confirm(),
                    decoration: InputDecoration(
                        labelText: dialogContext.l10n.attributesValue),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(dialogContext.l10n.commonCancel),
                ),
                TextButton(
                  onPressed: confirm,
                  child: Text(dialogContext.l10n.commonAdd),
                ),
              ],
            );
          },
        );
      },
    ).then((_) => valueController.dispose());
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildSectionTitle(context, context.l10n.itemSectionAttributes),
                ),
                IconButton(
                  onPressed: () => _showAddAttributeDialog(context),
                  icon: const Icon(Icons.add_circle_outline_rounded),
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),

            if (widget.attributes.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  context.l10n.attributesEmpty,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                ),
              )
            else
              ...widget.attributes.asMap().entries.map((entry) {
                final index = entry.key;
                final attr = entry.value;
                final type = widget.allTypes.firstWhere(
                  (t) => t.id == attr.attributeTypeId,
                  orElse: () => AttributeTypeModel(
                    name: context.l10n.commonUnknown,
                    dataType: "TEXT",
                  ),
                );

                return ListTile(
                  leading: const Icon(Icons.label_outline_rounded, size: 20),
                  title: Text(type.name),
                  subtitle: Text(attr.value),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.remove_circle_outline_rounded,
                      size: 20,
                      color: Colors.redAccent,
                    ),
                    onPressed: () => widget.onRemove(index),
                  ),
                  contentPadding: EdgeInsets.zero,
                );
              }),
          ],
        ),
      ),
    );
  }

  /// Renderiza la etiqueta del encabezado de la sección con estilo en color primario en mayúsculas.
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title.toUpperCase(),
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.bold,
        letterSpacing: 1,
      ),
    );
  }
}
