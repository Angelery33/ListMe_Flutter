import 'package:flutter/material.dart';
import '../../core/i18n/l10n_extension.dart';

/// Un widget de texto que trunca el contenido largo y proporciona un botón de alternancia
/// "leer más / leer menos".
///
/// Cuando [text] es más corto que los caracteres de [collapseThreshold], el texto completo siempre se
/// muestra sin ningún botón de alternancia, evitando elementos innecesarios en la IU para
/// descripciones cortas.
class ExpandableText extends StatefulWidget {
  /// La cadena completa para mostrar. El contenido más corto que [collapseThreshold]
  /// se muestra tal cual sin ninguna lógica de colapso.
  final String text;

  /// [TextStyle] opcional aplicado al texto del cuerpo.
  final TextStyle? style;

  /// El número máximo de líneas visibles cuando el widget está en estado
  /// colapsado. Por defecto es 5.
  final int collapsedMaxLines;

  /// El recuento mínimo de caracteres que activa el comportamiento de colapso.
  /// Los textos con esta longitud o inferior siempre son totalmente visibles. Por defecto es 250.
  final int collapseThreshold;

  const ExpandableText({
    super.key,
    required this.text,
    this.style,
    this.collapsedMaxLines = 5,
    this.collapseThreshold = 250,
  });

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

/// Estado para [ExpandableText].
///
/// Rastrea si el texto está expandido o colapsado actualmente.
class _ExpandableTextState extends State<ExpandableText> {
  /// Indica si el texto completo es visible actualmente.
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.text.length <= widget.collapseThreshold) {
      return Text(widget.text, style: widget.style);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.text,
          maxLines: _expanded ? null : widget.collapsedMaxLines,
          overflow:
              _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
          style: widget.style,
        ),
        TextButton(
          onPressed: () => setState(() => _expanded = !_expanded),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: const Size(0, 0),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            _expanded ? context.l10n.descriptionReadLess : context.l10n.descriptionReadMore,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}
