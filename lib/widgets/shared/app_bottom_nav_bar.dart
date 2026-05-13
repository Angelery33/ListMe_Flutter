import 'package:flutter/material.dart';
import '../../core/i18n/l10n_extension.dart';

/// Barra de navegación inferior compartida por todas las pantallas principales.
///
/// Contiene: Listas, Perfil, Ajustes, Social.
class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
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
              icon: const Icon(Icons.person_outline),
              selectedIcon: const Icon(Icons.person),
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
