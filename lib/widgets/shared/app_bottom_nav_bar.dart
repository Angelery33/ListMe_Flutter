import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/i18n/l10n_extension.dart';
import '../../providers/invitations/invitations_provider.dart';

/// Barra de navegación inferior compartida por todas las pantallas principales.
///
/// Contiene: Listas, Perfil, Ajustes, Social.
///
/// Envuelve la [NavigationBar] de Flutter dentro de un [Container] estilizado que añade un
/// borde superior redondeado, un borde adaptativo para el modo oscuro y una suave sombra paralela
/// para elevarla visualmente por encima del contenido de la pantalla.
class AppBottomNavBar extends StatelessWidget {
  /// El índice basado en cero del destino de navegación actualmente activo.
  /// Se pasa directamente a [NavigationBar.selectedIndex].
  final int currentIndex;

  /// Se llama cuando el usuario toca una pestaña de destino.
  /// Recibe el índice del destino tocado para que el llamador pueda actualizar la
  /// pantalla seleccionada.
  final ValueChanged<int> onTap;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final pendingCount = context.watch<InvitationsProvider>().pendingCount;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: isDark
            ? Border(
                top: BorderSide(
                  color: theme.colorScheme.outlineVariant.withValues(
                    alpha: 0.2,
                  ),
                  width: 1,
                ),
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.4)
                : Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: NavigationBar(
          height: 65,
          elevation: 0,
          backgroundColor: Colors.transparent,
          indicatorColor: theme.colorScheme.primaryContainer,
          selectedIndex: currentIndex,
          onDestinationSelected: onTap,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.list_alt_outlined),
              selectedIcon: const Icon(Icons.list_alt_rounded),
              label: context.l10n.navLists,
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: pendingCount > 0,
                label: Text(pendingCount > 9 ? '9+' : '$pendingCount'),
                child: const Icon(Icons.person_outline),
              ),
              selectedIcon: Badge(
                isLabelVisible: pendingCount > 0,
                label: Text(pendingCount > 9 ? '9+' : '$pendingCount'),
                child: const Icon(Icons.person),
              ),
              label: context.l10n.navProfile,
            ),
            NavigationDestination(
              icon: const Icon(Icons.settings_outlined),
              selectedIcon: const Icon(Icons.settings),
              label: context.l10n.navSettings,
            ),
            NavigationDestination(
              icon: const Icon(Icons.people_outline),
              selectedIcon: const Icon(Icons.people),
              label: context.l10n.navSocial,
            ),
          ],
        ),
      ),
    );
  }
}
