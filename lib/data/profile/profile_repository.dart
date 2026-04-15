import 'package:list_me/core/services/api_client.dart';
import 'package:list_me/core/services/logger_service.dart';
import 'package:list_me/data/auth/user_model.dart';

class ProfileRepository {
  final ApiClient _apiClient;
  final LoggerService _logger = LoggerService.instance;

  ProfileRepository(this._apiClient);

  Future<UserModel> getCurrentUser() async {
    try {
      _logger.debug('ProfileRepository: Obteniendo datos del usuario actual');
      final response = await _apiClient.dio.get('/auth/me');
      _logger.debug('ProfileRepository: Datos obtenidos: ${response.data}');
      return UserModel.fromJson(response.data);
    } catch (e) {
      _logger.error('ProfileRepository: Error al obtener usuario', e);
      rethrow;
    }
  }

  Future<UserModel> updateProfile(UserModel user) async {
    try {
      _logger.debug('ProfileRepository: Actualizando perfil');
      final response = await _apiClient.dio.put(
        '/auth/profile',
        data: user.toJson(),
      );
      _logger.info('ProfileRepository: Perfil actualizado');
      return UserModel.fromJson(response.data);
    } catch (e) {
      _logger.error('ProfileRepository: Error al actualizar perfil', e);
      rethrow;
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      _logger.debug('ProfileRepository: Cambiando contraseña');
      await _apiClient.dio.post(
        '/auth/change-password',
        data: {'currentPassword': currentPassword, 'newPassword': newPassword},
      );
      _logger.info('ProfileRepository: Contraseña cambiada exitosamente');
    } catch (e) {
      _logger.error('ProfileRepository: Error al cambiar contraseña', e);
      rethrow;
    }
  }

  Future<void> deleteAccount() async {
    try {
      _logger.debug('ProfileRepository: Eliminando cuenta');
      await _apiClient.dio.delete('/auth/account');
      _logger.info('ProfileRepository: Cuenta eliminada');
    } catch (e) {
      _logger.error('ProfileRepository: Error al eliminar cuenta', e);
      rethrow;
    }
  }
}
