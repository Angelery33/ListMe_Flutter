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
  void _showAddAttributeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => _AddAttributeDialog(
        initialTypes: widget.allTypes,
        onAdd: widget.onAdd,
        onCreateAttributeType: widget.onCreateAttributeType,
      ),
    );
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

class _AddAttributeDialog extends StatefulWidget {
  final List<AttributeTypeModel> initialTypes;
  final Function(AttributeItemModel) onAdd;
  final Future<AttributeTypeModel?> Function()? onCreateAttributeType;

  const _AddAttributeDialog({
    required this.initialTypes,
    required this.onAdd,
    this.onCreateAttributeType,
  });

  @override
  State<_AddAttributeDialog> createState() => _AddAttributeDialogState();
}

class _AddAttributeDialogState extends State<_AddAttributeDialog> {
  late List<AttributeTypeModel> _types;
  AttributeTypeModel? _selectedType;
  final TextEditingController _valueController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _types = List.of(widget.initialTypes);
    _selectedType = _types.isNotEmpty ? _types.first : null;
  }

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  void _confirm() {
    if (_selectedType != null && _valueController.text.isNotEmpty) {
      widget.onAdd(AttributeItemModel(
        attributeTypeId: _selectedType!.id!,
        idItem: 0,
        value: _valueController.text,
      ));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.attributesAdd),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: _types.isEmpty
                    ? Text(
                        context.l10n.attributesEmpty,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(fontStyle: FontStyle.italic),
                      )
                    : DropdownButtonFormField<AttributeTypeModel>(
                        initialValue: _selectedType,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: context.l10n.attributesType,
                        ),
                        items: _types
                            .map((t) => DropdownMenuItem(
                                  value: t,
                                  child: Text(t.name),
                                ))
                            .toList(),
                        onChanged: (val) => setState(() => _selectedType = val),
                      ),
              ),
              if (widget.onCreateAttributeType != null)
                IconButton(
                  icon: const Icon(Icons.add_rounded),
                  tooltip: context.l10n.attributesCreateType,
                  onPressed: () async {
                    final newType = await widget.onCreateAttributeType!();
                    if (!mounted) return;
                    if (newType != null) {
                      setState(() {
                        _types = [..._types, newType];
                        _selectedType = newType;
                      });
                    }
                  },
                ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _valueController,
            autofocus: _types.isNotEmpty,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _confirm(),
            decoration: InputDecoration(labelText: context.l10n.attributesValue),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.commonCancel),
        ),
        TextButton(
          onPressed: _confirm,
          child: Text(context.l10n.commonAdd),
        ),
      ],
    );
  }
}
