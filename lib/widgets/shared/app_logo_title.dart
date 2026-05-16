import 'package:flutter/material.dart';

/// Widget compartido para mostrar el logo de la app junto al título "ListMe".
///
/// Se utiliza en encabezados, pantallas de inicio y páginas de inicio de sesión donde la identidad de marca
/// debe ser prominente. Tanto [logoHeight] como [fontSize] son configurables
/// para que el widget se adapte a diferentes tamaños de contenedor.
class AppLogoTitle extends StatelessWidget {
  /// La altura de la imagen del logo en píxeles lógicos.
  /// Por defecto es 50, lo que funciona bien para encabezados de pantalla completa.
  final double logoHeight;

  /// El tamaño de fuente de la etiqueta de texto "ListMe".
  /// Por defecto es 36 para emparejarse naturalmente con el [logoHeight] por defecto.
  final double fontSize;

  /// El color aplicado al texto "ListMe".
  /// Por defecto es blanco para su uso en fondos oscuros o con degradado.
  final Color color;

  const AppLogoTitle({
    super.key,
    this.logoHeight = 50,
    this.fontSize = 36,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/images/logobiblio.png',
          height: logoHeight,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 10),
        Text(
          'ListMe',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            color: color,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}
