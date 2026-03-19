import 'package:flutter/material.dart';

/// Widget compartido para mostrar el logo de la app junto al título "ListMe".
class AppLogoTitle extends StatelessWidget {
  final double logoHeight;
  final double fontSize;
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
