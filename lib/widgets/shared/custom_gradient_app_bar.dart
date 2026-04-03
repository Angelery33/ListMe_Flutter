import 'package:flutter/material.dart';
import '../../core/theme.dart';

/// Un AppBar personalizado con un fondo degradado basado en el tema elegido.
/// 
/// Implementa [PreferredSizeWidget] para poder ser usado directamente
/// en el slot `appBar` de un [Scaffold].
class CustomGradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final double height;
  final bool showBackButton;

  const CustomGradientAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.height = kToolbarHeight,
    this.showBackButton = true,
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    // En Titanium claro el fondo es blanco → texto e íconos deben ser negros
    final useDarkText = AppTheme.appBarUsesDarkText(context);
    final fgColor = useDarkText ? Colors.black : Colors.white;

    return Stack(
      children: [
        // Fondo dinámico basado en gradiente o color sólido
        Positioned.fill(
          child: AppTheme.appBarGradient(context),
        ),
        // Sombra suave en la parte inferior (solo en Titanium claro)
        if (useDarkText)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 1,
              color: Colors.black12,
            ),
          ),
        SafeArea(
          child: AppBar(
            title: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: fgColor,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            automaticallyImplyLeading: showBackButton,
            actions: actions,
            leading: leading,
            iconTheme: IconThemeData(color: fgColor),
          ),
        ),
      ],
    );
  }
}
