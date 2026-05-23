import 'package:flutter/material.dart';

/// Encabezado de sección con icono, título y badge de contador opcional.
class SocialSectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final int badge;

  const SocialSectionHeader({
    super.key,
    required this.icon,
    required this.title,
    this.badge = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
        if (badge > 0) ...[
          const SizedBox(width: 8),
          SocialBadge(count: badge),
        ],
      ],
    );
  }
}

/// Icono de pestaña con un badge rojo superpuesto en la esquina superior derecha.
///
/// Se usa en los tabs del [TabBar] móvil para mostrar el contador de elementos
/// pendientes manteniendo el layout estándar icono-arriba / texto-abajo.
class SocialTabIconWithBadge extends StatelessWidget {
  final IconData icon;
  final int count;

  const SocialTabIconWithBadge({
    super.key,
    required this.icon,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon),
        if (count > 0)
          Positioned(
            top: -4,
            right: -8,
            child: SocialBadge(count: count),
          ),
      ],
    );
  }
}

/// Badge rojo circular con contador numérico.
class SocialBadge extends StatelessWidget {
  final int count;

  const SocialBadge({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        count.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Placeholder de estado vacío para una sección sin elementos.
///
/// Cuando [large] es `true` ocupa toda la pantalla (usado en tabs móvil).
class SocialSectionEmpty extends StatelessWidget {
  final IconData icon;
  final String message;
  final bool large;

  const SocialSectionEmpty({
    super.key,
    required this.icon,
    required this.message,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: large ? 64 : 36,
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.25),
        ),
        SizedBox(height: large ? 12 : 8),
        Text(
          message,
          style: (large ? theme.textTheme.bodyLarge : theme.textTheme.bodySmall)
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
      ],
    );

    if (large) return Center(child: content);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(child: content),
    );
  }
}

/// Indicador de carga compacto para el interior de una sección.
class SocialSectionLoading extends StatelessWidget {
  const SocialSectionLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

/// Card con borde suave y padding uniforme usada en el panel lateral web.
class SocialFloatingCard extends StatelessWidget {
  final Widget header;
  final Widget child;

  const SocialFloatingCard({
    super.key,
    required this.header,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            header,
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
