import 'package:flutter/material.dart';
import '../../../data/attributes/attribute_type_model.dart';
import '../../../data/attributes/attribute_item_model.dart';

class EntryAttributesSection extends StatelessWidget {
  final List<AttributeItemModel> attributes;
  final List<AttributeTypeModel> allTypes;
  final Function(AttributeItemModel) onRemove;
  final VoidCallback onAddRequest;

  const EntryAttributesSection({
    super.key,
    required this.attributes,
    required this.allTypes,
    required this.onRemove,
    required this.onAddRequest,
  });

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
              onPressed: onAddRequest,
              icon: const Icon(Icons.add_circle_outline_rounded),
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
        
        if (attributes.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              "No hay atributos añadidos.",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
            ),
          ),

        ...attributes.map((attr) {
          final type = allTypes.firstWhere(
            (t) => t.id == attr.attributeTypeId,
            orElse: () => AttributeTypeModel(name: "Desconocido", dataType: "TEXT"),
          );
          
          return ListTile(
            leading: const Icon(Icons.label_outline_rounded, size: 20),
            title: Text(type.name),
            subtitle: Text(attr.value),
            trailing: IconButton(
              icon: const Icon(Icons.remove_circle_outline_rounded, size: 20, color: Colors.redAccent),
              onPressed: () => onRemove(attr),
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
