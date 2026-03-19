import 'package:flutter/material.dart';
import '../../core/routes.dart';
import '../../widgets/home/menu_card.dart';
import '../../widgets/shared/app_logo_title.dart';

/// Pantalla de inicio de la aplicación ListMe.
/// 
/// Presenta un menú central con las opciones principales sobre un fondo completo.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand, // Forzamos al Stack a llenar toda la pantalla
        children: [
          // Fondo compartido inmersivo
          Image.asset(
            'assets/images/background.png',
            fit: BoxFit.cover,
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.2),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 80),
                  // Decoración superior (Imagen del Logo + Título)
                  const AppLogoTitle(),
                  const SizedBox(height: 84),
                  // Menú central de tarjetas
                  MenuCard(
                    title: 'Mis Listas',
                    subtitle: 'Gestiona tus tareas y notas',
                    icon: Icons.list_alt_rounded,
                    onTap: () => Navigator.pushNamed(context, AppRoutes.lists),
                  ),
                  const SizedBox(height: 16),
                  MenuCard(
                    title: 'Mi Perfil',
                    subtitle: 'Configura tu cuenta de usuario',
                    icon: Icons.person_rounded,
                    onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
                  ),
                  const SizedBox(height: 16),
                  MenuCard(
                    title: 'Ajustes App',
                    subtitle: 'Temas, fuentes y notificaciones',
                    icon: Icons.settings_rounded,
                    onTap: () => Navigator.pushNamed(context, AppRoutes.settings),
                  ),
                  const SizedBox(height: 16),
                  MenuCard(
                    title: 'Información',
                    subtitle: 'Información de la aplicación',
                    icon: Icons.info_rounded,
                    onTap: () => Navigator.pushNamed(context, AppRoutes.info),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
