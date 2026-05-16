import 'package:flutter/material.dart';
import '../../core/i18n/l10n_extension.dart';
import '../../core/config/routes.dart';
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

/// Estado para [HomeScreen].
///
/// Es Stateful para permitir futuros estados locales (por ejemplo, animaciones) sin cambiar la
/// API pública. Actualmente construye un diseño de menú estático e inmersivo.
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
                    title: context.l10n.homeListsTitle,
                    subtitle: context.l10n.homeListsSubtitle,
                    icon: Icons.list_alt_rounded,
                    onTap: () => Navigator.pushNamed(context, AppRoutes.lists),
                  ),
                  const SizedBox(height: 16),
                  MenuCard(
                    title: context.l10n.profileTitle,
                    subtitle: context.l10n.homeProfileSubtitle,
                    icon: Icons.person_rounded,
                    onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
                  ),
                  const SizedBox(height: 16),
                  MenuCard(
                    title: context.l10n.homeSettingsTitle,
                    subtitle: context.l10n.homeSettingsSubtitle,
                    icon: Icons.settings_rounded,
                    onTap: () => Navigator.pushNamed(context, AppRoutes.settings),
                  ),
                  const SizedBox(height: 16),
                  MenuCard(
                    title: context.l10n.infoTitle,
                    subtitle: context.l10n.homeInfoSubtitle,
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
