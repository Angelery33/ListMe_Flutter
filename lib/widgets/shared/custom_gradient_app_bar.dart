import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';

/// Un AppBar personalizado con un fondo degradado basado en el tema elegido.
///
/// Implementa [PreferredSizeWidget] para poder ser usado directamente
/// en el slot `appBar` de un [Scaffold].
///
/// El degradado (o color sólido para Titanium claro) se aplica como una capa
/// [Positioned.fill] detrás de una [AppBar] transparente, manteniendo todo el comportamiento
/// estándar de la [AppBar] (botón de retroceso, acciones, título centrado, etc.)
/// mientras se cambia el fondo por el degradado de marca de la aplicación.
class CustomGradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// El texto mostrado como título de la barra de aplicaciones.
  final String title;

  /// Widgets de acción opcionales colocados en el área final de la barra.
  final List<Widget>? actions;

  /// Widget de encabezado personalizado opcional. Cuando es `null`, el botón de retroceso se muestra
  /// automáticamente si [showBackButton] es `true`.
  final Widget? leading;

  /// La altura de la barra en píxeles lógicos. Por defecto es [kToolbarHeight].
  final double height;

  /// Indica si se debe mostrar automáticamente un botón de navegación hacia atrás cuando el widget
  /// no está en la raíz de la pila de navegación.
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
        SafeArea(
          child: AppBar(
            title: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.white,
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
