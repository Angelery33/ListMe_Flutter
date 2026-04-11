import 'package:flutter/material.dart';
import '../../data/auth/auth_repository.dart';
import '../../data/auth/auth_models.dart';
import '../../core/services/logger_service.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  final LoggerService _logger = LoggerService.instance;

  AuthStatus _status = AuthStatus.initial;
  String? _errorMessage;

  AuthProvider(this._authRepository) {
    checkAuthStatus();
  }

  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == AuthStatus.loading;

  Future<void> checkAuthStatus() async {
    final isLoggedIn = await _authRepository.isLoggedIn();
    _status = isLoggedIn
        ? AuthStatus.authenticated
        : AuthStatus.unauthenticated;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  String _extractUserFriendlyError(dynamic error) {
    final errorStr = error.toString().toLowerCase();
    if (errorStr.contains('connection') || errorStr.contains('socket')) {
      return 'Error de conexión. Verifica tu internet.';
    }
    if (errorStr.contains('401') || errorStr.contains('unauthorized')) {
      return 'Usuario o contraseña incorrectos.';
    }
    if (errorStr.contains('timeout')) {
      return 'Tiempo de espera agotado. Intenta de nuevo.';
    }
    if (errorStr.contains('username')) {
      return 'El usuario ya existe.';
    }
    return 'Error al iniciar sesión. Intenta de nuevo.';
  }

  Future<bool> login(String username, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.login(
        LoginRequest(username: username, password: password),
      );
      _status = AuthStatus.authenticated;
      _logger.info('Login exitoso para usuario: $username');
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = _extractUserFriendlyError(e);
      _logger.error('Error en login para $username', e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String username, String password, String email) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.register(
        RegisterRequest(username: username, password: password, email: email),
      );
      _status = AuthStatus.unauthenticated;
      _logger.info('Registro exitoso para usuario: $username');
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = _extractUserFriendlyError(e);
      _logger.error('Error en registro para $username', e);
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
