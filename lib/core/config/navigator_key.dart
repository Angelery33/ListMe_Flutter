import 'package:flutter/material.dart';

/// Clave global del [Navigator] raíz de la aplicación.
///
/// Permite navegar imperativamante desde fuera del árbol de widgets
/// (p. ej. desde [AuthProvider] al expirar la sesión).
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
