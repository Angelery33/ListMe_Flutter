import 'dart:async';
import 'package:dio/dio.dart';
import 'package:list_me/core/services/auth_service.dart';
import 'package:list_me/core/config/constants.dart';
import 'package:list_me/core/services/logger_service.dart';
import 'package:list_me/core/services/token_storage.dart';

// Controlador global que emite un evento cuando la sesión expira sin poder
// renovarse, para que AuthProvider pueda redirigir al login sin depender
// de la jerarquía de widgets.
final _logoutController = StreamController<void>.broadcast();

/// Cliente HTTP singleton basado en [Dio] que maneja la autenticación JWT,
/// el refresco transparente de tokens y el encolado de solicitudes.
///
/// Cada solicitud saliente adjunta automáticamente el token Bearer almacenado.
/// Cuando el servidor devuelve un 401 con un encabezado `x-token-expired` (o un
/// mensaje "Unauthorized"), el cliente intenta un refresco silencioso del token a través de
/// [AuthService] y reintenta la solicitud original. Las solicitudes concurrentes que
/// llegan durante un refresco se encolan y se vuelven a ejecutar una vez que el nuevo token esté
/// disponible.
class ApiClient {
  /// Instancia global singleton.
  static final ApiClient instance = ApiClient._();
  static final LoggerService _logger = LoggerService.instance;
  late final Dio _dio;
  final AuthService _authService = AuthService.instance;
  bool _isRefreshing = false;
  final List<Completer<bool>> _queuedRequests = [];

  /// Stream que emite cuando el refresh falla y los tokens son borrados.
  /// [AuthProvider] escucha este stream para redirigir al login automáticamente.
  static Stream<void> get authLogoutStream => _logoutController.stream;

  ApiClient._() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
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
              bool refreshSuccess = false;
              try {
                final refreshed = await _authService.refreshToken();
                refreshSuccess = refreshed;

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
                  // Notifica a AuthProvider para que redirija al login
                  _logoutController.add(null);
                }
              } finally {
                _isRefreshing = false;
                // Pasa el resultado real para que las peticiones encoladas
                // sepan si deben reintentar o propagar el error
                _processQueuedRequests(success: refreshSuccess);
              }
            }
          }
          return handler.next(e);
        },
      ),
    );

    _dio.interceptors.add(
      LogInterceptor(
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
      ),
    );
  }

  /// La instancia subyacente de [Dio], expuesta para que los repositorios puedan realizar solicitudes
  /// tipadas mientras siguen beneficiándose de los interceptores de autenticación.
  Dio get dio => _dio;

  /// Resuelve todas las peticiones encoladas con [success].
  ///
  /// Cuando [success] es `false` las peticiones encoladas propagan el error
  /// original en lugar de reintentar con un token inexistente.
  void _processQueuedRequests({bool success = false}) {
    for (final completer in _queuedRequests) {
      if (!completer.isCompleted) {
        completer.complete(success);
      }
    }
    _queuedRequests.clear();
  }
}
