import 'package:flutter/material.dart';
import '../../core/routes.dart';
import '../../widgets/shared/custom_gradient_app_bar.dart';
import '../../widgets/shared/app_bottom_nav_bar.dart';

/// Pantalla de perfil del usuario con diseño estándar alineado al resto de la app.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const CustomGradientAppBar(title: 'Mi Perfil', showBackButton: false),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 1, // Perfil = 2
        onTap: (index) {
          if (index == 0) Navigator.pushReplacementNamed(context, AppRoutes.lists);
          if (index == 2) Navigator.pushNamed(context, AppRoutes.settings);
        },
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_outline_rounded,
              size: 100,
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 24),
            const Text(
              'Perfil de Usuario',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Sección en construcción'),
          ],
        ),
      ),
    );
  }
}
