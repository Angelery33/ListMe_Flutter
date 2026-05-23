import 'package:flutter/material.dart';
import 'route_observer.dart';

/// Mixin para [State] que recarga datos cada vez que su ruta se vuelve visible,
/// tanto al ser empujada por primera vez ([didPush]) como al quedar expuesta
/// tras hacer pop de una ruta superior ([didPopNext]).
///
/// Uso:
/// ```dart
/// class _MyScreenState extends State<MyScreen>
///     with RouteRefreshMixin<MyScreen> {
///   @override
///   void onRouteVisible() {
///     context.read<MyProvider>().refresh();
///   }
/// }
/// ```
mixin RouteRefreshMixin<T extends StatefulWidget> on State<T>
    implements RouteAware {
  /// Implementa la lógica de recarga. Se invoca al entrar en la ruta y al
  /// volver a ella desde una ruta secundaria.
  void onRouteVisible();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    appRouteObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    super.dispose();
  }

  // ── RouteAware ──────────────────────────────────────────────────────────────

  /// Ruta empujada por primera vez (equivalente a initState para rutas nombradas).
  @override
  void didPush() => onRouteVisible();

  /// La ruta superior fue eliminada y esta vuelve a ser visible.
  @override
  void didPopNext() => onRouteVisible();

  /// No necesitamos reacción al hacer pop de esta ruta ni al empujar otra encima.
  @override
  void didPop() {}
  @override
  void didPushNext() {}
}
