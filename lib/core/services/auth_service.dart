import 'dart:async';
import 'package:dio/dio.dart';
import 'package:list_me/core/services/api_client.dart';
import 'package:list_me/core/services/logger_service.dart';
import 'package:list_me/core/services/token_storage.dart';
import 'package:list_me/data/auth/auth_models.dart';

class AuthService {
  static final AuthService instance = AuthService._();
  final LoggerService _logger = LoggerService.instance;
  bool _isRefreshing = false;
  final List<Completer<bool>> _queuedRequests = [];

  AuthService._();

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

      _logger.debug('AuthService: Intentando refrescar token con refresh token: ${refreshToken.substring(0, 20)}...');

      // Crear una nueva instancia de Dio SIN interceptor para evitar recursión infinita
      final dio = Dio(
        BaseOptions(
          baseUrl: ApiClient.instance.dio.options.baseUrl,
          contentType: 'application/json',
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      // POST a la ruta correcta (sin barra inicial ya que baseUrl incluye /api/v1)
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
      _processQueuedRequests();
    }
  }

  void _processQueuedRequests() {
    for (final completer in _queuedRequests) {
      completer.complete(_isAuthenticated());
    }
    _queuedRequests.clear();
  }

  Future<bool> _isAuthenticated() async {
    final token = await TokenStorage.getAccessToken();
    return token != null;
  }

  void queueRequest(Completer<bool> completer) {
    _queuedRequests.add(completer);
  }
}
