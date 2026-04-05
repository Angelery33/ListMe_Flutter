import 'package:flutter/material.dart';
import '../../../data/attributes/attribute_type_model.dart';
import '../../../data/attributes/attribute_item_model.dart';

class EntryAttributesSection extends StatefulWidget {
  final List<AttributeItemModel> attributes;
  final List<AttributeTypeModel> allTypes;
  final Function(AttributeItemModel) onAdd;
  final Function(int) onRemove;

  const EntryAttributesSection({
    super.key,
    required this.attributes,
    required this.allTypes,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  State<EntryAttributesSection> createState() => _EntryAttributesSectionState();
}

class _EntryAttributesSectionState extends State<EntryAttributesSection> {
  void _showAddAttributeDialog(BuildContext context) {
    if (widget.allTypes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No hay tipos de atributos disponibles")),
      );
      return;
    }

    AttributeTypeModel? selectedType = widget.allTypes.first;
    TextEditingController valueController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Añadir Atributo"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<AttributeTypeModel>(
                    value: selectedType,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: "Tipo de atributo",
                    ),
                    items: widget.allTypes.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type.name),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setStateDialog(() => selectedType = val);
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: valueController,
                    decoration: const InputDecoration(labelText: "Valor"),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancelar"),
                ),
                TextButton(
                  onPressed: () {
                    if (selectedType != null &&
                        valueController.text.isNotEmpty) {
                      widget.onAdd(
                        AttributeItemModel(
                          attributeTypeId: selectedType!.id!,
                          idItem: 0,
                          value: valueController.text,
                        ),
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: const Text("Añadir"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle(context, "Atributos Personalizados"),
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
              "No hay atributos añadidos.",
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
              orElse: () =>
                  AttributeTypeModel(name: "Desconocido", dataType: "TEXT"),
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
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title.toUpperCase(),
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }
}
