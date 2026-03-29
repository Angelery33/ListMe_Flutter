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
    return Stack(
      children: [
        // Fondo dinámico basado en gradiente o color sólido
        Positioned.fill(
          child: AppTheme.appBarGradient(context),
        ),
        // Sombra suave en la parte inferior
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
        SafeArea(
          child: AppBar(
            title: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            automaticallyImplyLeading: showBackButton,
            actions: actions,
            leading: leading,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
