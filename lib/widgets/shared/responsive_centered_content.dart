import 'package:flutter/material.dart';

/// Centra el contenido y restringe su ancho máximo en pantallas grandes (web/escritorio).
///
/// En dispositivos móviles, el widget se expande para llenar el ancho disponible; en ventanas gráficas más anchas
/// limita el contenido a [maxWidth] y lo centra horizontalmente, evitando
/// líneas de texto excesivamente anchas o campos de formulario de gran tamaño.
class ResponsiveCenteredContent extends StatelessWidget {
  /// El widget que se va a centrar y restringir.
  final Widget child;

  /// El ancho máximo en píxeles lógicos antes de que el contenido deje de expandirse.
  /// Por defecto es 800, lo que funciona bien para pantallas con muchos formularios.
  final double maxWidth;

  /// Relleno horizontal (y opcionalmente vertical) aplicado dentro de
  /// [ConstrainedBox] para que el contenido no toque los bordes.
  final EdgeInsets padding;

  const ResponsiveCenteredContent({
    super.key,
    required this.child,
    this.maxWidth = 800,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
