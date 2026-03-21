import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'settings_screen.dart';
import 'auth_screen.dart';
import 'user_profile_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              Theme.of(context).brightness == Brightness.dark
                  ? 'assets/images/bg_oscuro.png'
                  : 'assets/images/bg_claro.png',
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 600),
                        child: IntrinsicHeight(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 40),
                              // Logo and Title
                              Hero(
                                tag: 'app_logo',
                                child: Image.asset(
                                  'assets/images/logobiblio.png',
                                  height: 120,
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Colors.black87
                                      : null,
                                  colorBlendMode:
                                      Theme.of(context).brightness ==
                                          Brightness.light
                                      ? BlendMode.srcIn
                                      : null,
                                  errorBuilder: (context, child, error) => Icon(
                                    Icons.book,
                                    size: 100,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'ListMe',
                                style: Theme.of(context).textTheme.displaySmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                    ),
                              ),
                              const SizedBox(height: 10),
                              Consumer<AuthProvider>(
                                builder: (context, auth, _) {
                                  return Text(
                                    auth.isAuthenticated
                                        ? 'Conectado como: ${auth.user?.email}'
                                        : 'Accede para sincronizar con tu pareja',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                          fontStyle: auth.isAuthenticated
                                              ? null
                                              : FontStyle.italic,
                                        ),
                                  );
                                },
                              ),
                              const SizedBox(height: 60),

                              // Menu Options
                              Consumer<AuthProvider>(
                                builder: (context, auth, _) {
                                  return _MenuButton(
                                    icon: auth.isAuthenticated
                                        ? Icons.person
                                        : Icons.login,
                                    label: auth.isAuthenticated
                                        ? 'Mi Perfil'
                                        : 'Iniciar Sesión', // "Conectar Nube" treated as Login
                                    onTap: () {
                                      if (auth.isAuthenticated) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const UserProfileScreen(),
                                          ),
                                        );
                                      } else {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => const AuthScreen(),
                                          ),
                                        );
                                      }
                                    },
                                  );
                                },
                              ),
                              const SizedBox(height: 20),
                              _MenuButton(
                                icon: Icons.library_books,
                                label: 'Mis Listas',
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const HomeScreen(),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              _MenuButton(
                                icon: Icons.settings,
                                label: 'Ajustes',
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const SettingsScreen(),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: SizedBox(
        width: double.infinity,
        height: 64,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 2,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 28),
              const SizedBox(width: 15),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
