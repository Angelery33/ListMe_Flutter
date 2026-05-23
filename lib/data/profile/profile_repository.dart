import 'package:list_me/core/services/api_client.dart';
import 'package:list_me/core/services/logger_service.dart';
import 'package:list_me/data/auth/user_model.dart';

/// Proporciona operaciones de acceso a datos para el perfil del usuario autenticado,
/// comunicándose con la API REST del backend a través de [ApiClient].
///
/// Cubre la lectura del usuario actual, la actualización de los campos del perfil, el cambio de
/// contraseña y la eliminación permanente de la cuenta.
class ProfileRepository {
  final ApiClient _apiClient;
  final LoggerService _logger = LoggerService.instance;

  /// Crea un [ProfileRepository] utilizando el [_apiClient] proporcionado para la
  /// comunicación HTTP.
  ProfileRepository(this._apiClient);

  /// Obtiene el perfil del usuario actualmente autenticado de la API y
  /// lo devuelve como un [UserModel].
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

  /// Envía los datos actualizados del [user] a la API y devuelve el
  /// [UserModel] guardado según lo confirmado por el backend.
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

  /// Cambia la contraseña del usuario autenticado enviando [currentPassword]
  /// para verificación y [newPassword] como el valor de reemplazo.
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

  /// Actualiza la URL de la foto de perfil del usuario autenticado en el backend.
  ///
  /// El cliente es responsable de subir la imagen a Firebase Storage previamente y
  /// pasar la URL de descarga resultante. Devuelve el [UserModel] actualizado.
  Future<UserModel> updateProfilePhoto(String photoUrl) async {
    try {
      _logger.debug('ProfileRepository: Actualizando foto de perfil');
      final response = await _apiClient.dio.put(
        '/auth/profile/photo',
        data: {'photoUrl': photoUrl},
      );
      _logger.info('ProfileRepository: Foto de perfil actualizada');
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      _logger.error('ProfileRepository: Error al actualizar foto de perfil', e);
      rethrow;
    }
  }

  /// Elimina permanentemente la cuenta del usuario autenticado y todos los datos
  /// asociados del backend. Esta operación es irreversible.
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
