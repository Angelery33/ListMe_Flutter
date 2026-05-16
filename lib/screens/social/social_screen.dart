import 'package:flutter/material.dart';
import '../../core/i18n/l10n_extension.dart';
import '../../widgets/shared/custom_gradient_app_bar.dart';
import '../../widgets/shared/app_shell.dart';

/// Pantalla de marcador de posición para futuras funciones sociales.
///
/// Actualmente renderiza un cuerpo vacío. Las futuras iteraciones mostrarán listas de
/// amigos, feeds de bibliotecas compartidas y actividad de la comunidad aquí.
class SocialScreen extends StatelessWidget {
  const SocialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentIndex: 3,
      appBar: CustomGradientAppBar(
        title: context.l10n.socialTitle,
        showBackButton: false,
      ),
      body: const Center(child: Text('—')),
    );
  }
}
