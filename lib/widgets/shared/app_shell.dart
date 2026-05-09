import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/config/routes.dart';
import '../../core/providers/responsive_provider.dart';
import '../../core/providers/sidebar_provider.dart';

/// Destinations shared between bottom bar and navigation rail.
const _destinations = [
  (icon: Icons.list_alt_outlined,   selectedIcon: Icons.list_alt_rounded,  label: 'Listas'),
  (icon: Icons.person_outline,      selectedIcon: Icons.person,             label: 'Perfil'),
  (icon: Icons.settings_outlined,   selectedIcon: Icons.settings,           label: 'Ajustes'),
  (icon: Icons.people_outline,      selectedIcon: Icons.people,             label: 'Social'),
];

/// Adaptive navigation shell.
///
/// compact  (< 600dp) → NavigationBar at the bottom (mobile style)
/// medium / expanded  → NavigationRail on the left  (desktop/tablet style)
///
/// Usage: replace Scaffold's [bottomNavigationBar] with this widget wrapping
/// the entire screen body.
class AppShell extends StatelessWidget {
  final int currentIndex;
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  const AppShell({
    super.key,
    required this.currentIndex,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
  });

  void _onTap(BuildContext context, int index) {
    if (index == currentIndex) return;
    switch (index) {
      case 0: Navigator.pushReplacementNamed(context, AppRoutes.lists);
      case 1: Navigator.pushReplacementNamed(context, AppRoutes.profile);
      case 2: Navigator.pushReplacementNamed(context, AppRoutes.settings);
      case 3: Navigator.pushReplacementNamed(context, AppRoutes.social);
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.watch<ResponsiveProvider>();
    final sidebar = context.watch<SidebarProvider>();

    if (responsive.useSideNav) {
      return _WideLayout(
        currentIndex: currentIndex,
        appBar: appBar,
        floatingActionButton: floatingActionButton,
        floatingActionButtonLocation: floatingActionButtonLocation,
        onTap: (i) => _onTap(context, i),
        body: body,
        isExpanded: sidebar.isExpanded,
        onToggleExpanded: () => sidebar.toggleExpanded(),
      );
    }

    return _CompactLayout(
      currentIndex: currentIndex,
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      onTap: (i) => _onTap(context, i),
      body: body,
    );
  }
}

// ── Compact: NavigationBar at the bottom ──────────────────────────────────────

class _CompactLayout extends StatelessWidget {
  final int currentIndex;
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final ValueChanged<int> onTap;

  const _CompactLayout({
    required this.currentIndex,
    required this.body,
    required this.onTap,
    this.appBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: isDark
              ? Border(
                  top: BorderSide(
                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
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
            destinations: _destinations
                .map(
                  (d) => NavigationDestination(
                    icon: Icon(d.icon),
                    selectedIcon: Icon(d.selectedIcon),
                    label: d.label,
                  ),
                )
                .toList(),
          ),
        ),
      ),
      body: body,
    );
  }
}

// ── Wide: NavigationRail on the left ─────────────────────────────────────────

class _WideLayout extends StatelessWidget {
  final int currentIndex;
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final ValueChanged<int> onTap;
  final bool isExpanded;
  final VoidCallback onToggleExpanded;

  const _WideLayout({
    required this.currentIndex,
    required this.body,
    required this.onTap,
    required this.isExpanded,
    required this.onToggleExpanded,
    this.appBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      body: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: isExpanded ? 175 : 80,
            color: theme.colorScheme.surface,
            child: Column(
              children: [
                Expanded(
                  child: NavigationRail(
                    extended: isExpanded,
                    selectedIndex: currentIndex,
                    onDestinationSelected: onTap,
                    backgroundColor: Colors.transparent,
                    indicatorColor: theme.colorScheme.primaryContainer,
                    selectedIconTheme: IconThemeData(color: theme.colorScheme.onPrimaryContainer),
                    unselectedIconTheme: IconThemeData(color: theme.colorScheme.onSurfaceVariant),
                    selectedLabelTextStyle: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    leading: isExpanded
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Text(
                              'ListMe',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : null,
                    destinations: _destinations
                        .map(
                          (d) => NavigationRailDestination(
                            icon: Icon(d.icon),
                            selectedIcon: Icon(d.selectedIcon),
                            label: Text(d.label),
                          ),
                        )
                        .toList(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: AnimatedOpacity(
                    opacity: isExpanded ? 1.0 : 0.7,
                    duration: const Duration(milliseconds: 300),
                    child: IconButton(
                      icon: Icon(
                        isExpanded ? Icons.keyboard_arrow_left : Icons.keyboard_arrow_right,
                        size: 20,
                      ),
                      onPressed: onToggleExpanded,
                      tooltip: isExpanded ? 'Contraer' : 'Expandir',
                    ),
                  ),
                ),
              ],
            ),
          ),
          VerticalDivider(
            thickness: 1,
            width: 1,
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
          Expanded(child: body),
        ],
      ),
    );
  }
}
