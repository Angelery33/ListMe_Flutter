import 'package:flutter/material.dart';
import '../../../core/i18n/l10n_extension.dart';

/// Cadenas de tipo de producto Funko predefinidas utilizadas como sugerencias de autocompletado en
/// el campo de tipo de producto de [EntryMainInfoSection].
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

/// Cadenas de edición Funko predefinidas utilizadas como sugerencias de autocompletado en el
/// campo de edición de [EntryMainInfoSection].
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

/// Sección de formulario para los campos de identidad principales de un elemento: nombre, descripción,
/// número de elemento opcional, tipo de producto y edición.
///
/// Renderiza condicionalmente campos adicionales basados en la configuración de la biblioteca.
/// Cuando [showImportButton] es verdadero, aparece un icono de descarga en la nube en el sufijo del campo
/// de nombre para activar un flujo de importación de API.
class EntryMainInfoSection extends StatefulWidget {
  /// Controlador vinculado al campo de texto del nombre del elemento.
  final TextEditingController nameController;

  /// Controlador vinculado al campo de texto de la descripción del elemento.
  final TextEditingController descController;

  /// Controlador para el campo opcional del número de elemento (ej. "42" para Funko #42).
  final TextEditingController? itemNumberController;

  /// Controlador para el campo opcional de tipo de producto con autocompletado de Funko.
  final TextEditingController? productTypeController;

  /// Controlador para el campo opcional de edición con autocompletado de Funko.
  final TextEditingController? editionController;

  /// Se llama cuando el usuario pulsa el botón de importar desde API en el campo de nombre.
  final VoidCallback? onImportPressed;

  /// Indica si se debe mostrar el botón de icono de importar desde API dentro del campo de nombre.
  final bool showImportButton;

  /// Indica si se debe renderizar el campo de número de elemento (requiere [itemNumberController]).
  final bool showItemNumber;

  /// Indica si se debe renderizar el campo de tipo de producto (requiere [productTypeController]).
  final bool showProductType;

  /// Indica si se debe renderizar el campo de edición (requiere [editionController]).
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
  State<EntryMainInfoSection> createState() => _EntryMainInfoSectionState();
}

class _EntryMainInfoSectionState extends State<EntryMainInfoSection> {
  final FocusNode _descFocus = FocusNode();
  final FocusNode _numberFocus = FocusNode();

  @override
  void dispose() {
    _descFocus.dispose();
    _numberFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // El último campo visible determina qué acción mostrar en nombre y descripción.
    final hasNumber = widget.showItemNumber && widget.itemNumberController != null;
    final hasExtra = widget.showProductType || widget.showEdition;

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
              controller: widget.nameController,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => _descFocus.requestFocus(),
              decoration: InputDecoration(
                labelText: context.l10n.entryItemName,
                prefixIcon: Icon(Icons.title_rounded, color: colorScheme.primary),
                suffixIcon: widget.showImportButton
                    ? IconButton(
                        icon: Icon(Icons.cloud_download_rounded, color: colorScheme.primary),
                        onPressed: widget.onImportPressed,
                        tooltip: context.l10n.entryImportFromApi,
                      )
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              textCapitalization: TextCapitalization.sentences,
              validator: (value) => (value == null || value.isEmpty)
                  ? context.l10n.itemNameRequired
                  : null,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: widget.descController,
              focusNode: _descFocus,
              // Descripción es multilinea: next pasa al siguiente campo si existe,
              // si no, done cierra el teclado.
              textInputAction: (hasNumber || hasExtra) ? TextInputAction.next : TextInputAction.done,
              onFieldSubmitted: (_) {
                if (hasNumber) {
                  _numberFocus.requestFocus();
                } else {
                  FocusScope.of(context).unfocus();
                }
              },
              decoration: InputDecoration(
                labelText: context.l10n.entryDescription,
                alignLabelWithHint: true,
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Icon(Icons.description_rounded, color: colorScheme.primary),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),

            if (hasNumber) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: widget.itemNumberController,
                focusNode: _numberFocus,
                keyboardType: TextInputType.number,
                textInputAction: hasExtra ? TextInputAction.next : TextInputAction.done,
                onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                decoration: InputDecoration(
                  labelText: context.l10n.itemItemNumber,
                  prefixIcon: Icon(Icons.numbers_rounded, color: colorScheme.primary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],

            if (widget.showProductType && widget.productTypeController != null) ...[
              const SizedBox(height: 16),
              _SuggestionField(
                controller: widget.productTypeController!,
                label: context.l10n.itemProductType,
                icon: Icons.category_rounded,
                suggestions: kFunkoProductTypes,
              ),
            ],

            if (widget.showEdition && widget.editionController != null) ...[
              const SizedBox(height: 16),
              _SuggestionField(
                controller: widget.editionController!,
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

/// Un campo de texto con sugerencias de autocompletado en línea de [suggestions] y un
/// botón de flecha desplegable para mostrar la lista completa de sugerencias como un menú emergente.
///
/// Utilizado para los campos de tipo de producto y edición donde se recomienda un conjunto predefinido
/// de valores pero aún se permite texto libre.
class _SuggestionField extends StatelessWidget {
  /// Controlador vinculado al [TextFormField] subyacente.
  final TextEditingController controller;

  /// Etiqueta mostrada en la decoración del campo.
  final String label;

  /// Icono de prefijo para la decoración del campo.
  final IconData icon;

  /// La lista de cadenas de sugerencias mostradas en la superposición de autocompletado y el
  /// menú emergente desplegable.
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
