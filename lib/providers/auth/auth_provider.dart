import 'package:flutter/material.dart';
import '../../data/auth/auth_repository.dart';

/// Proveedor de estado de autenticación.
///
/// Gestiona el estado de sesión del usuario (login, logout, registro).
/// Se registra como un Provider global en main.dart al ser requerido en múltiples pantallas.
class AuthProvider extends ChangeNotifier {
  // ignore: unused_field
  final AuthRepository _authRepository;

  // ignore: prefer_final_fields
  bool _isLoading = false;
  String? _errorMessage;
  // ignore: prefer_final_fields
  bool _isAuthenticated = false;

  AuthProvider(this._authRepository);

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _isAuthenticated;

  // TODO: Implementar login, register y logout.
}
