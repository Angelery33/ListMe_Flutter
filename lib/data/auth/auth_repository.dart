import 'package:list_me/core/api_client.dart';
import 'package:list_me/core/services/logger_service.dart';
import 'package:list_me/core/token_storage.dart';
import 'package:list_me/data/auth/auth_models.dart';

class AuthRepository {
  final ApiClient _apiClient;
  final LoggerService _logger = LoggerService.instance;

  AuthRepository(this._apiClient);

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

  Future<void> logout() async {
    _logger.debug('AuthRepository: Cerrando sesión');
    await TokenStorage.clearTokens();
  }

  Future<bool> isLoggedIn() async {
    final token = await TokenStorage.getAccessToken();
    return token != null;
  }
}
