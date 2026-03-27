import 'package:list_me/core/api_client.dart';
import 'package:list_me/core/token_storage.dart';
import 'package:list_me/data/auth/auth_models.dart';

class AuthRepository {
  final ApiClient _apiClient;

  AuthRepository(this._apiClient);

  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/login',
        data: request.toJson(),
      );
      final loginResponse = LoginResponse.fromJson(response.data);
      
      // Save tokens
      await TokenStorage.saveTokens(
        accessToken: loginResponse.accessToken,
        refreshToken: loginResponse.refreshToken,
      );
      
      return loginResponse;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> register(RegisterRequest request) async {
    try {
      await _apiClient.dio.post(
        '/auth/register',
        data: request.toJson(),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await TokenStorage.clearTokens();
  }

  // Helper to check if logged in
  Future<bool> isLoggedIn() async {
    final token = await TokenStorage.getAccessToken();
    return token != null;
  }
}
