import 'package:flutter/material.dart';
import '../../../core/i18n/l10n_extension.dart';

const List<String> kFunkoProductTypes = [
  'Funko Pop!',
  'Funko Pop! Deluxe',
  'Funko Pop! Moments',
  'Funko Pop! Rides',
  'Funko Pop! Town',
  'Funko Pop! Albums',
  'Funko Pop! Movie Posters',
  'Funko Pop! Mega (10")',
  'Funko Pop! Super Sized (6")',
  'Funko Pop! Jumbo',
  'Funko Pocket Pop!',
  'Funko Bitty Pop!',
  'Funko Soda',
  'Funko Mystery Minis',
  'Funko Mini Vinyl',
  'Funko Rock Candy',
  'Funko Plushies',
  'Funko Loungefly',
  'Funko Dorbz',
  'Funko Hikari',
];

const List<String> kFunkoEditions = [
  'Estándar',
  'Chase',
  'Exclusive',
  'Flocked',
  'Glow in the Dark',
  'Metallic',
  'Diamond Collection',
  'Translucent',
  'Black Light',
  'Scented',
  'Special Edition',
  'Vaulted',
  'Convention Exclusive',
  'SDCC Exclusive',
  'NYCC Exclusive',
  'ECCC Exclusive',
  'Funko Shop Exclusive',
  'Hot Topic Exclusive',
  'BoxLunch Exclusive',
  'GameStop Exclusive',
  'Walmart Exclusive',
  'Target Exclusive',
  'Amazon Exclusive',
  'FYE Exclusive',
  'Best Buy Exclusive',
  'Funko Europe Exclusive',
  'Disney Parks Exclusive',
];

class EntryMainInfoSection extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController descController;
  final TextEditingController? itemNumberController;
  final TextEditingController? productTypeController;
  final TextEditingController? editionController;
  final VoidCallback? onImportPressed;
  final bool showImportButton;
  final bool showItemNumber;
  final bool showProductType;
  final bool showEdition;

  const EntryMainInfoSection({
    super.key,
    required this.nameController,
    required this.descController,
    this.itemNumberController,
    this.productTypeController,
    this.editionController,
    this.onImportPressed,
    this.showImportButton = false,
    this.showItemNumber = false,
    this.showProductType = false,
    this.showEdition = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 1,
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, context.l10n.itemSectionMain),
            const SizedBox(height: 16),

            TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: context.l10n.entryItemName,
                prefixIcon: Icon(
                  Icons.title_rounded,
                  color: colorScheme.primary,
                ),
                suffixIcon: showImportButton
                    ? IconButton(
                        icon: Icon(
                          Icons.cloud_download_rounded,
                          color: colorScheme.primary,
                        ),
                        onPressed: onImportPressed,
                        tooltip: context.l10n.entryImportFromApi,
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              textCapitalization: TextCapitalization.sentences,
              validator: (value) => (value == null || value.isEmpty)
                  ? context.l10n.itemNameRequired
                  : null,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: descController,
              decoration: InputDecoration(
                labelText: context.l10n.entryDescription,
                alignLabelWithHint: true,
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Icon(
                    Icons.description_rounded,
                    color: colorScheme.primary,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),

            if (showItemNumber && itemNumberController != null) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: itemNumberController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: context.l10n.itemItemNumber,
                  prefixIcon: Icon(
                    Icons.numbers_rounded,
                    color: colorScheme.primary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],

            if (showProductType && productTypeController != null) ...[
              const SizedBox(height: 16),
              _SuggestionField(
                controller: productTypeController!,
                label: context.l10n.itemProductType,
                icon: Icons.category_rounded,
                suggestions: kFunkoProductTypes,
              ),
            ],

            if (showEdition && editionController != null) ...[
              const SizedBox(height: 16),
              _SuggestionField(
                controller: editionController!,
                label: context.l10n.itemEdition,
                icon: Icons.bookmark_rounded,
                suggestions: kFunkoEditions,
              ),
            ],
          ],
        ),
      ),
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

class _SuggestionField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final List<String> suggestions;

  const _SuggestionField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.suggestions,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return RawAutocomplete<String>(
      textEditingController: controller,
      focusNode: FocusNode(),
      optionsBuilder: (TextEditingValue value) {
        final q = value.text.trim().toLowerCase();
        if (q.isEmpty) return suggestions;
        return suggestions.where((s) => s.toLowerCase().contains(q));
      },
      fieldViewBuilder: (context, textController, focusNode, onSubmit) {
        return TextFormField(
          controller: textController,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon, color: colorScheme.primary),
            suffixIcon: PopupMenuButton<String>(
              icon: Icon(Icons.arrow_drop_down, color: colorScheme.primary),
              tooltip: context.l10n.imageViewOptions,
              onSelected: (val) => controller.text = val,
              itemBuilder: (context) => suggestions
                  .map((s) => PopupMenuItem<String>(value: s, child: Text(s)))
                  .toList(),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          textCapitalization: TextCapitalization.words,
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(12),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 240),
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options.elementAt(index);
                  return ListTile(
                    dense: true,
                    title: Text(option),
                    onTap: () => onSelected(option),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
