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
          _logger.error('API Error: ${e.message}', e, e.stackTrace);
          if (e.response?.statusCode == 401) {
            _logger.warning('Token expirado o inválido, intentando refresh...');

            final refreshed = await _authService.refreshToken();

            if (refreshed) {
              final newToken = await TokenStorage.getAccessToken();
              e.requestOptions.headers['Authorization'] = 'Bearer $newToken';

              final retryResponse = await _dio.fetch(e.requestOptions);
              return handler.resolve(retryResponse);
            } else {
              _logger.warning('No se pudo refrescar el token');
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
}
