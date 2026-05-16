import 'package:flutter/material.dart';
import '../../core/i18n/l10n_extension.dart';

/// Pantalla de información de la aplicación ListMe.
///
/// Muestra información sobre la aplicación, como su nombre, versión y autor.
class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.infoTitle),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: Image.asset(
                'assets/images/logobiblio.png',
                height: 100,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'ListMe',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text('${context.l10n.settingsVersion} 0.2.0 (Build 2)'),
            const SizedBox(height: 40),
            _buildInfoTile(
              context,
              title: context.l10n.infoTitle,
              content:
                  'ListMe es una aplicación avanzada para la gestión de listas personales y compartidas, diseñada con Flutter.',
            ),
          ],
        ),
      ),
    );
  }

  /// Construye un mosaico de tarjeta redondeada que muestra un [title] y un cuerpo de [content].
  ///
  /// Se utiliza para presentar cada bloque de información en la pantalla de información con un
  /// estilo visual consistente.
  Widget _buildInfoTile(BuildContext context,
      {required String title, required String content}) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(content),
        ],
      ),
    );
  }
}
