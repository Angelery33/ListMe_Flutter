import 'package:list_me/core/services/api_client.dart';
import 'package:list_me/core/services/logger_service.dart';
import 'package:list_me/core/services/token_storage.dart';
import 'package:list_me/data/auth/auth_models.dart';

/// Maneja todas las operaciones de autenticación: inicio de sesión, registro, cierre de sesión y
/// consultas de estado de sesión. Persiste los tokens a través de [TokenStorage] después de un
/// inicio de sesión exitoso para que las llamadas posteriores a la API puedan adjuntar el token de acceso
/// automáticamente.
class AuthRepository {
  final ApiClient _apiClient;
  final LoggerService _logger = LoggerService.instance;

  /// Crea un [AuthRepository] utilizando el [_apiClient] proporcionado para la
  /// comunicación HTTP.
  AuthRepository(this._apiClient);

  /// Envía [request] al punto de conexión de inicio de sesión, persiste el par de tokens devueltos
  /// en [TokenStorage] y devuelve la [LoginResponse] que contiene ambos
  /// tokens.
  Future<LoginResponse> login(LoginRequest request) async {
    try {
      _logger.debug(
        'AuthRepository: Intentando login con usuario: ${request.username}',
      );
      final response = await _apiClient.dio.post(
        '/auth/login',
        data: request.toJson(),
      );
      final loginResponse = LoginResponse.fromJson(response.data);

      await TokenStorage.saveTokens(
        accessToken: loginResponse.accessToken,
        refreshToken: loginResponse.refreshToken,
      );

      _logger.info('AuthRepository: Login exitoso para ${request.username}');
      return loginResponse;
    } catch (e) {
      _logger.error('AuthRepository: Error en login', e);
      rethrow;
    }
  }

  /// Envía [request] al punto de conexión de registro para crear una nueva cuenta de
  /// usuario. No persiste los tokens; el usuario debe iniciar sesión después de registrarse.
  Future<void> register(RegisterRequest request) async {
    try {
      _logger.debug(
        'AuthRepository: Intentando registro para ${request.username}',
      );
      await _apiClient.dio.post('/auth/register', data: request.toJson());
      _logger.info('AuthRepository: Registro exitoso para ${request.username}');
    } catch (e) {
      _logger.error('AuthRepository: Error en registro', e);
      rethrow;
    }
  }

  /// Borra todos los tokens almacenados localmente, finalizando efectivamente la sesión actual
  /// sin contactar con el servidor.
  Future<void> logout() async {
    _logger.debug('AuthRepository: Cerrando sesión');
    await TokenStorage.clearTokens();
  }

  /// Devuelve `true` si existe un token de acceso válido en el almacenamiento local, lo que significa
  /// que actualmente se considera que el usuario ha iniciado sesión.
  Future<bool> isLoggedIn() async {
    final token = await TokenStorage.getAccessToken();
    return token != null;
  }
}
