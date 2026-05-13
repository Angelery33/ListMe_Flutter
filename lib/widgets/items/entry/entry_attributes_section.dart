import 'package:flutter/material.dart';
import '../../../core/i18n/l10n_extension.dart';
import '../../../data/attributes/attribute_type_model.dart';
import '../../../data/attributes/attribute_item_model.dart';

class EntryAttributesSection extends StatefulWidget {
  final List<AttributeItemModel> attributes;
  final List<AttributeTypeModel> allTypes;
  final Function(AttributeItemModel) onAdd;
  final Function(int) onRemove;
  final Future<String?> Function()? onCreateAttributeType;

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

class _EntryAttributesSectionState extends State<EntryAttributesSection> {
  void _showAddAttributeDialog(BuildContext context) {
    if (widget.allTypes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.attributesEmpty)),
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
              title: Text(context.l10n.attributesAdd),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<AttributeTypeModel>(
                    initialValue: selectedType,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: context.l10n.attributesType,
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
                  child: Text(context.l10n.commonAdd),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showCreateTypeDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(context.l10n.attributeNewType),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(labelText: context.l10n.attributesNewTypeName),
            textCapitalization: TextCapitalization.sentences,
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(context.l10n.commonCancel),
            ),
            TextButton(
              onPressed: () async {
                final name = controller.text.trim();
                if (name.isNotEmpty && widget.onCreateAttributeType != null) {
                  final newType = await widget.onCreateAttributeType!();
                  if (newType != null && dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                  } else if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                  }
                }
              },
              child: Text(context.l10n.commonCreate),
            ),
          ],
        );
      },
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
                if (widget.onCreateAttributeType != null)
                  IconButton(
                    onPressed: () => _showCreateTypeDialog(context),
                    icon: const Icon(Icons.add_rounded),
                    color: Theme.of(context).colorScheme.secondary,
                    tooltip: context.l10n.attributesCreateType,
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
