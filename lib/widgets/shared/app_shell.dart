import 'package:flutter/material.dart';
import '../../core/i18n/l10n_extension.dart';
import 'package:provider/provider.dart';
import '../../core/config/routes.dart';
import '../../core/providers/responsive_provider.dart';
import '../../core/providers/sidebar_provider.dart';

/// Pares de icono/icono seleccionado para cada destino de navegación.
///
/// Destinos compartidos entre la barra inferior y el riel de navegación.
/// Las etiquetas se resuelven a través de l10n en el momento de la construcción.
const _destinationIcons = [
  (icon: Icons.list_alt_outlined,   selectedIcon: Icons.list_alt_rounded),
  (icon: Icons.person_outline,      selectedIcon: Icons.person),
  (icon: Icons.settings_outlined,   selectedIcon: Icons.settings),
  (icon: Icons.people_outline,      selectedIcon: Icons.people),
];

/// Construye la lista completa de destinos (icono + icono seleccionado + etiqueta localizada)
/// para el [BuildContext] actual.
List<({IconData icon, IconData selectedIcon, String label})> _destinationsFor(
  BuildContext context,
) {
  final l = context.l10n;
  final labels = [l.navLists, l.navProfile, l.navSettings, l.navSocial];
  return [
    for (var i = 0; i < _destinationIcons.length; i++)
      (
        icon: _destinationIcons[i].icon,
        selectedIcon: _destinationIcons[i].selectedIcon,
        label: labels[i],
      ),
  ];
}

/// Capa de navegación adaptativa.
///
/// compact  (< 600dp) → NavigationBar en la parte inferior (estilo móvil)
/// medium / expanded  → NavigationRail a la izquierda (estilo escritorio/tablet)
///
/// Uso: reemplace el [bottomNavigationBar] del Scaffold con este widget que envuelve
/// todo el cuerpo de la pantalla.
class AppShell extends StatelessWidget {
  /// El índice basado en cero del destino de nivel superior actualmente activo.
  final int currentIndex;

  /// El widget de contenido principal colocado dentro del cuerpo del [Scaffold].
  final Widget body;

  /// Barra de aplicaciones opcional colocada en la parte superior del [Scaffold].
  final PreferredSizeWidget? appBar;

  /// Botón de acción flotante (FAB) opcional reenviado a [Scaffold.floatingActionButton].
  final Widget? floatingActionButton;

  /// Controla dónde se ancla el FAB dentro del scaffold.
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  const AppShell({
    super.key,
    required this.currentIndex,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
  });

  /// Navega a la pantalla correspondiente al [index] utilizando rutas con nombre.
  /// No hace nada cuando el [index] es igual al [currentIndex] para evitar empujes duplicados.
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

/// Diseño móvil utilizado cuando el ancho de la pantalla está por debajo del punto de interrupción de la navegación lateral.
///
/// Envuelve un [Scaffold] con una [NavigationBar] estilizada en la parte inferior.
class _CompactLayout extends StatelessWidget {
  /// El índice basado en cero del destino actualmente activo.
  final int currentIndex;

  /// El widget del cuerpo de la pantalla.
  final Widget body;

  /// Barra de aplicaciones opcional.
  final PreferredSizeWidget? appBar;

  /// FAB opcional.
  final Widget? floatingActionButton;

  /// Posición de anclaje del FAB.
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  /// Se llama cuando el usuario toca un destino de la navegación inferior.
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
            destinations: _destinationsFor(context)
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

/// Diseño para tablet/escritorio utilizado cuando el ancho de la pantalla supera el
/// punto de interrupción de la navegación lateral.
///
/// Renderiza un [NavigationRail] animado a la izquierda que se puede alternar
/// entre un modo colapsado solo con iconos y un modo expandido con etiquetas.
class _WideLayout extends StatelessWidget {
  /// El índice basado en cero del destino actualmente activo.
  final int currentIndex;

  /// El widget del cuerpo de la pantalla colocado a la derecha del riel.
  final Widget body;

  /// Barra de aplicaciones opcional.
  final PreferredSizeWidget? appBar;

  /// FAB opcional.
  final Widget? floatingActionButton;

  /// Posición de anclaje del FAB.
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  /// Se llama cuando el usuario toca un destino del riel.
  final ValueChanged<int> onTap;

  /// Indica si el riel de navegación está en su estado expandido (con etiquetas).
  final bool isExpanded;

  /// Se llama cuando el usuario toca el botón de alternancia colapsar/expandir en la
  /// parte inferior del riel.
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
                    destinations: _destinationsFor(context)
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
                      tooltip: isExpanded ? context.l10n.expandCollapse : context.l10n.expandExpand,
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
