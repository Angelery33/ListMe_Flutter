import 'package:flutter/material.dart';
import '../../data/auth/auth_repository.dart';
import '../../data/auth/auth_models.dart';
import '../../core/services/logger_service.dart';

/// Represents the possible states of the authentication flow.
enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

/// Provider that manages authentication state for the entire app.
///
/// Wraps [AuthRepository] and exposes login, register and logout operations.
/// Automatically checks the stored session on construction so the UI can
/// react to an already-authenticated user without showing the login screen.
class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  final LoggerService _logger = LoggerService.instance;

  /// Current authentication status, drives routing decisions.
  AuthStatus _status = AuthStatus.initial;

  /// Human-readable error message set when an operation fails.
  String? _errorMessage;

  /// Creates an [AuthProvider] with the given [_authRepository] and
  /// immediately checks whether the user already has a valid session.
  AuthProvider(this._authRepository) {
    checkAuthStatus();
  }

  /// The current [AuthStatus] of the session.
  AuthStatus get status => _status;

  /// A user-friendly error message, or `null` when there is no error.
  String? get errorMessage => _errorMessage;

  /// Returns `true` while an async auth operation is in progress.
  bool get isLoading => _status == AuthStatus.loading;

  /// Queries the repository to determine if a session token already exists
  /// and updates [status] to [AuthStatus.authenticated] or
  /// [AuthStatus.unauthenticated] accordingly.
  Future<void> checkAuthStatus() async {
    final isLoggedIn = await _authRepository.isLoggedIn();
    _status = isLoggedIn
        ? AuthStatus.authenticated
        : AuthStatus.unauthenticated;
    notifyListeners();
  }

  /// Clears any outstanding [errorMessage] and notifies listeners so the UI
  /// can hide error banners without performing a new auth operation.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Converts a raw [error] object into a Spanish user-facing message.
  ///
  /// Matches known substrings such as 'connection', '401', 'timeout', and
  /// 'username' to return contextually appropriate feedback.
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

  /// Attempts to log in with the given [username] and [password].
  ///
  /// Sets [status] to [AuthStatus.loading] while the request is in flight.
  /// Returns `true` and transitions to [AuthStatus.authenticated] on success,
  /// or `false` and sets [errorMessage] on failure.
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

  /// Registers a new account with the given [username], [password] and [email].
  ///
  /// On success transitions to [AuthStatus.unauthenticated] so the user is
  /// redirected to the login screen. Returns `true` on success, `false` and
  /// populates [errorMessage] on failure.
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

  /// Clears the stored session token and transitions to
  /// [AuthStatus.unauthenticated], forcing the user back to the login screen.
  Future<void> logout() async {
    await _authRepository.logout();
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
