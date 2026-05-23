import 'package:flutter/material.dart';

/// Observer global de rutas. Se registra en [MaterialApp.navigatorObservers]
/// y permite que cualquier [State] con [RouteRefreshMixin] se suscriba para
/// recibir notificaciones cuando su ruta se vuelve visible.
final RouteObserver<ModalRoute<void>> appRouteObserver =
    RouteObserver<ModalRoute<void>>();
