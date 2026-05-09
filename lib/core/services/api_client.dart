import 'dart:async';
import 'package:dio/dio.dart';
import 'package:list_me/core/services/auth_service.dart';
import 'package:list_me/core/config/constants.dart';
import 'package:list_me/core/services/logger_service.dart';
import 'package:list_me/core/services/token_storage.dart';

class ApiClient {
  static final ApiClient instance = ApiClient._();
  static final LoggerService _logger = LoggerService.instance;
  late final Dio _dio;
  final AuthService _authService = AuthService.instance;
  bool _isRefreshing = false;
  final List<Completer<bool>> _queuedRequests = [];

  ApiClient._() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        contentType: 'application/json',
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await TokenStorage.getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          _logger.error('API Error: ${e.message} (Status: ${e.response?.statusCode})', e, e.stackTrace);

          // Verificar si es un error de token expirado
          if (e.response?.statusCode == 401) {
            final isTokenExpired = e.response?.headers['x-token-expired']?.contains('true') ?? false;

            if (isTokenExpired || e.message?.contains('Unauthorized') == true) {
              _logger.warning('Token expirado o inválido, intentando refresh...');

              // Si ya hay un refresh en progreso, esperar a que termine
              if (_isRefreshing) {
                _logger.debug('Refresh en progreso, encolando solicitud...');
                final completer = Completer<bool>();
                _queuedRequests.add(completer);
                final success = await completer.future;

                if (success) {
                  final newToken = await TokenStorage.getAccessToken();
                  if (newToken != null) {
                    e.requestOptions.headers['Authorization'] = 'Bearer $newToken';
                    final retryResponse = await _dio.fetch(e.requestOptions);
                    return handler.resolve(retryResponse);
                  }
                }
                return handler.next(e);
              }

              _isRefreshing = true;
              try {
                final refreshed = await _authService.refreshToken();

                if (refreshed) {
                  _logger.info('Token refrescado exitosamente, reintentando solicitud...');
                  final newToken = await TokenStorage.getAccessToken();

                  if (newToken != null) {
                    e.requestOptions.headers['Authorization'] = 'Bearer $newToken';
                    final retryResponse = await _dio.fetch(e.requestOptions);
                    return handler.resolve(retryResponse);
                  }
                } else {
                  _logger.warning('No se pudo refrescar el token, redirigiendo a login');
                  await TokenStorage.clearTokens();
                }
              } finally {
                _isRefreshing = false;
                _processQueuedRequests();
              }
            }
          }
          return handler.next(e);
        },
      ),
    );

    // Logger for debugging
    _dio.interceptors.add(
      LogInterceptor(
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
      ),
    );
  }

  Dio get dio => _dio;

  void _processQueuedRequests() {
    for (final completer in _queuedRequests) {
      if (!completer.isCompleted) {
        completer.complete(true);
      }
    }
    _queuedRequests.clear();
  }
}
