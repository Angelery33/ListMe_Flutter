import 'dart:ui';
import 'package:flutter/material.dart';

/// Tarjeta de menú con efecto Glassmorphism diseñada específicamente para la Home.
///
/// Utiliza [BackdropFilter] con un desenfoque gaussiano sutil para crear una apariencia
/// de vidrio esmerilado sobre el fondo degradado de la pantalla de inicio. Cada tarjeta representa una sola
/// sección navegable de la aplicación.
class MenuCard extends StatelessWidget {
  /// El encabezado principal que se muestra dentro de la tarjeta (ej. "Mis Listas").
  final String title;

  /// Una breve línea descriptiva debajo de [title] que explica lo que contiene la sección.
  final String subtitle;

  /// El icono mostrado en el cuadrado de color en el lado izquierdo de la tarjeta.
  final IconData icon;

  /// Se llama cuando el usuario toca la tarjeta para navegar a la pantalla correspondiente.
  final VoidCallback onTap;

  const MenuCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(icon, size: 32, color: Colors.white),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white54, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
