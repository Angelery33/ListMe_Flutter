import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/services/api_client.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/token_storage.dart';
import '../../core/config/navigator_key.dart';
import '../../core/config/routes.dart';
import '../../data/auth/auth_repository.dart';
import '../../data/auth/auth_models.dart';
import '../../core/services/logger_service.dart';

/// Representa los posibles estados del flujo de autenticación.
enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

/// Proveedor que gestiona el estado de autenticación de toda la aplicación.
///
/// Envuelve [AuthRepository] y expone las operaciones de login, registro y logout.
/// Comprueba automáticamente la sesión almacenada en la construcción para que la UI
/// pueda reaccionar a un usuario ya autenticado sin mostrar la pantalla de login.
class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  final LoggerService _logger = LoggerService.instance;

  /// Estado de autenticación actual, determina las decisiones de enrutamiento.
  AuthStatus _status = AuthStatus.initial;

  /// Mensaje de error legible por el usuario, establecido cuando una operación falla.
  String? _errorMessage;

  /// Suscripción al stream de logout forzado de [ApiClient].
  late final StreamSubscription<void> _logoutSubscription;

  /// Crea un [AuthProvider] con el [_authRepository] proporcionado y
  /// comprueba de inmediato si el usuario ya tiene una sesión válida.
  ///
  /// También escucha [ApiClient.authLogoutStream] para redirigir al login
  /// automáticamente cuando el refresh token falla o expira.
  AuthProvider(this._authRepository) {
    _logoutSubscription = ApiClient.authLogoutStream.listen((_) {
      _logger.warning('AuthProvider: sesión expirada, redirigiendo al login');
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      // Limpia toda la pila de navegación y va al login sin importar en qué
      // pantalla esté el usuario cuando el token expira
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        AppRoutes.login,
        (_) => false,
      );
    });
    checkAuthStatus();
  }

  @override
  void dispose() {
    _logoutSubscription.cancel();
    super.dispose();
  }

  /// El [AuthStatus] actual de la sesión.
  AuthStatus get status => _status;

  /// Mensaje de error para el usuario, o `null` cuando no hay ningún error.
  String? get errorMessage => _errorMessage;

  /// Devuelve `true` mientras una operación de autenticación asíncrona está en curso.
  bool get isLoading => _status == AuthStatus.loading;

  /// Comprueba si existe sesión y la renueva proactivamente en cada arranque.
  ///
  /// Si hay refresh token, intenta refrescarlo inmediatamente para mantener la sesión
  /// activa sin que el usuario tenga que volver a iniciar sesión (hasta que el refresh
  /// token caduque en el servidor, típicamente 30 días).
  /// Si el refresco falla (token expirado o sin conexión pero hay access token local),
  /// se mantiene autenticado y el interceptor reactivo de [ApiClient] gestionará
  /// el siguiente fallo 401.
  Future<void> checkAuthStatus() async {
    final refreshToken = await TokenStorage.getRefreshToken();
    final accessToken = await TokenStorage.getAccessToken();

    if (refreshToken != null) {
      final refreshed = await AuthService.instance.refreshToken();
      if (refreshed) {
        _logger.info('AuthProvider: Sesión renovada proactivamente al arrancar');
        _status = AuthStatus.authenticated;
      } else {
        // Re-leer tokens para saber si el fallo fue de red (tokens conservados)
        // o el servidor los rechazó (tokens borrados).
        final currentRefreshToken = await TokenStorage.getRefreshToken();
        final currentAccessToken = await TokenStorage.getAccessToken();
        if (currentAccessToken != null || currentRefreshToken != null) {
          // Error de red transitorio: tokens siguen en storage, quedamos autenticados
          _logger.warning('AuthProvider: Refresco falló por red, tokens conservados, continuamos autenticados');
          _status = AuthStatus.authenticated;
        } else {
          // Servidor rechazó el refresh (tokens borrados): forzar login
          _logger.warning('AuthProvider: Servidor rechazó el refresh, redirigiendo al login');
          _status = AuthStatus.unauthenticated;
        }
      }
    } else if (accessToken != null) {
      _status = AuthStatus.authenticated;
    } else {
      _status = AuthStatus.unauthenticated;
    }

    notifyListeners();
  }

  /// Limpia cualquier [errorMessage] pendiente y notifica a los listeners para que la UI
  /// pueda ocultar los banners de error sin realizar una nueva operación de autenticación.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Convierte un objeto [error] en bruto en un mensaje en español para el usuario.
  ///
  /// Coincide con subcadenas conocidas como 'connection', '401', 'timeout' y
  /// 'username' para devolver un mensaje contextualmente apropiado.
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

  /// Intenta iniciar sesión con el [username] y [password] proporcionados.
  ///
  /// Establece [status] a [AuthStatus.loading] mientras la solicitud está en curso.
  /// Devuelve `true` y transiciona a [AuthStatus.authenticated] en caso de éxito,
  /// o `false` y establece [errorMessage] en caso de fallo.
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

  /// Registra una nueva cuenta con el [username], [password] y [email] proporcionados.
  ///
  /// En caso de éxito transiciona a [AuthStatus.unauthenticated] para que el usuario
  /// sea redirigido a la pantalla de login. Devuelve `true` en caso de éxito, `false`
  /// y rellena [errorMessage] en caso de fallo.
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

  /// Elimina el token de sesión almacenado y transiciona a
  /// [AuthStatus.unauthenticated], forzando al usuario de vuelta a la pantalla de login.
  Future<void> logout() async {
    await _authRepository.logout();
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
