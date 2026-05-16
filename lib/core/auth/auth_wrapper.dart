import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth/auth_provider.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/lists/lists_screen.dart';

/// Widget raíz que escucha a [AuthProvider] y dirige al usuario a la
/// pantalla correcta dependiendo del estado de autenticación.
///
/// - [AuthStatus.authenticated] → [ListsScreen] (inicio de la aplicación).
/// - [AuthStatus.unauthenticated] / [AuthStatus.error] → [LoginScreen].
/// - [AuthStatus.loading] / [AuthStatus.initial] → spinner de carga a pantalla completa
///   mostrado mientras se determina el estado de autenticación al inicio.
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        switch (auth.status) {
          case AuthStatus.authenticated:
            return const ListsScreen(); // Home removed, Lists is the root
          case AuthStatus.unauthenticated:
          case AuthStatus.error:
            return const LoginScreen();
          case AuthStatus.loading:
          case AuthStatus.initial:
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
        }
      },
    );
  }
}
