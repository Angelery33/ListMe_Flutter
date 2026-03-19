import 'package:flutter/material.dart';

/// Widget informativo que se muestra cuando el usuario no tiene ninguna lista creada.
class EmptyListsState extends StatelessWidget {
  const EmptyListsState({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.playlist_add_rounded,
            size: 100,
            color: theme.hintColor.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 24),
          const Text(
            'No tienes listas aún',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Toca el botón "+" para crear tu primera lista',
            style: TextStyle(color: theme.hintColor),
          ),
        ],
      ),
    );
  }
}
