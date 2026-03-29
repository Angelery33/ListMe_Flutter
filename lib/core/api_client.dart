import 'package:dio/dio.dart';
import 'package:list_me/core/constants.dart';
import 'package:list_me/core/services/logger_service.dart';
import 'package:list_me/core/token_storage.dart';

class ApiClient {
  static final LoggerService _logger = LoggerService.instance;
  late final Dio _dio;

  ApiClient() {
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
            _logger.warning('Token expirado o inválido');
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
