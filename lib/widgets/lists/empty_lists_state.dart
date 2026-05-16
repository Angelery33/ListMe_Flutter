import 'package:flutter/material.dart';

/// Widget informativo de estado vacío que se muestra cuando el usuario aún no tiene bibliotecas.
///
/// Guía al usuario hacia el FAB mostrando un icono grande, un titular y
/// un breve mensaje de instrucción. Centrado verticalmente dentro de su padre.
class EmptyListsState extends StatelessWidget {
  const EmptyListsState({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icono con efecto visual premium
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.playlist_add_rounded,
                size: 80,
                color: theme.colorScheme.primary.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'No tienes listas aún',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Toca el botón inferior para crear tu primera lista y empezar a organizar tus tareas.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40), // Espacio extra para guiar la vista hacia el FAB
          ],
        ),
      ),
    );
  }
}
