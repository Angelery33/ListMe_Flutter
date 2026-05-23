import 'package:flutter/material.dart';
import 'route_observer.dart';

/// Envuelve un [child] y ejecuta [onEnter] cada vez que esta ruta se vuelve
/// visible: al ser empujada por primera vez o al quedar expuesta tras el pop
/// de una ruta superior.
///
/// Útil para recargar datos sin convertir una pantalla StatelessWidget en
/// StatefulWidget ni modificar su lógica interna.
///
/// Ejemplo:
/// ```dart
/// RefreshOnEnter(
///   onEnter: () => context.read<MyProvider>().refresh(),
///   child: const MyScreen(),
/// )
/// ```
class RefreshOnEnter extends StatefulWidget {
  final Widget child;
  final VoidCallback onEnter;

  const RefreshOnEnter({
    super.key,
    required this.onEnter,
    required this.child,
  });

  @override
  State<RefreshOnEnter> createState() => _RefreshOnEnterState();
}

class _RefreshOnEnterState extends State<RefreshOnEnter> with RouteAware {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) appRouteObserver.subscribe(this, route);
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    super.dispose();
  }

  void _scheduleRefresh() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onEnter();
    });
  }

  @override
  void didPush() => _scheduleRefresh();

  @override
  void didPopNext() => _scheduleRefresh();

  @override
  void didPop() {}

  @override
  void didPushNext() {}

  @override
  Widget build(BuildContext context) => widget.child;
}
