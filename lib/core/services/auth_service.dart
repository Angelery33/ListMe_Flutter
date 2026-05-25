import 'package:dio/dio.dart';
import 'package:list_me/core/services/api_client.dart';
import 'package:list_me/core/services/logger_service.dart';
import 'package:list_me/core/services/token_storage.dart';
import 'package:list_me/data/auth/auth_models.dart';

/// Servicio singleton responsable de la lógica de refresco de JWT.
///
/// Utiliza una instancia de [Dio] dedicada (sin el interceptor de autenticación) para evitar
/// bucles de refresco infinitos. Si se llama mientras ya hay un refresco en progreso,
/// devuelve `false` inmediatamente — el encolado de peticiones concurrentes lo gestiona
/// [ApiClient] directamente.
class AuthService {
  /// Instancia global singleton.
  static final AuthService instance = AuthService._();
  final LoggerService _logger = LoggerService.instance;
  bool _isRefreshing = false;

  AuthService._();

  /// Intercambia el token de refresco almacenado por un nuevo par de tokens de acceso/refresco.
  ///
  /// Devuelve `true` cuando los tokens se refrescan y persisten correctamente,
  /// o `false` si no hay ningún token de refresco disponible, el servidor lo rechaza, o
  /// ocurre cualquier error de red. En caso de fallo, los tokens almacenados se borran para que
  /// el usuario sea redirigido a la pantalla de inicio de sesión en la próxima solicitud protegida.
  Future<bool> refreshToken() async {
    if (_isRefreshing) {
      _logger.debug('AuthService: Ya hay un refresh en progreso, esperando...');
      return false;
    }

    _isRefreshing = true;

    try {
      final refreshToken = await TokenStorage.getRefreshToken();
      if (refreshToken == null) {
        _logger.warning('AuthService: No hay refresh token disponible');
        await TokenStorage.clearTokens();
        return false;
      }

      _logger.debug('AuthService: Intentando refrescar token...');

      // Instancia de Dio sin interceptor para evitar recursión infinita
      final dio = Dio(
        BaseOptions(
          baseUrl: ApiClient.instance.dio.options.baseUrl,
          contentType: 'application/json',
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      final response = await dio.post(
        'auth/refresh',
        data: TokenRefreshRequest(refreshToken: refreshToken).toJson(),
      );

      if (response.statusCode == 200) {
        final loginResponse = LoginResponse.fromJson(response.data);
        await TokenStorage.saveTokens(
          accessToken: loginResponse.accessToken,
          refreshToken: loginResponse.refreshToken,
        );
        _logger.info('AuthService: Token refrescado exitosamente');
        return true;
      } else {
        _logger.warning('AuthService: Error al refrescar - status ${response.statusCode}');
        await TokenStorage.clearTokens();
        return false;
      }
    } catch (e) {
      _logger.error('AuthService: Error al refrescar token: $e', e);
      await TokenStorage.clearTokens();
      return false;
    } finally {
      _isRefreshing = false;
    }
  }
}
