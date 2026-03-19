import 'package:flutter/material.dart';

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
        title: const Text('Información'),
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
            const Text('Versión 0.1.0 Beta'),
            const SizedBox(height: 40),
            _buildInfoTile(
              context,
              title: 'Sobre el Proyecto',
              content: 'ListMe es una aplicación avanzada para la gestión de listas personales y compartidas, diseñada con Flutter.',
            ),
            const SizedBox(height: 16),
            _buildInfoTile(
              context,
              title: 'Desarrollador',
              content: 'Equipo de Desarrollo ListMe.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(BuildContext context, {required String title, required String content}) {
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