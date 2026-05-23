import 'package:list_me/core/services/api_client.dart';
import 'package:list_me/core/services/logger_service.dart';
import 'package:list_me/data/friends/friend_model.dart';
import 'package:list_me/data/friends/friendship_request_model.dart';

/// Proporciona operaciones de acceso a datos para la gestión de amistades,
/// comunicándose con la API REST del backend a través de [ApiClient].
///
/// Cubre el ciclo completo: enviar solicitud, obtener solicitudes pendientes,
/// aceptar, rechazar, obtener lista de amigos con estadísticas y eliminar amistad.
class FriendsRepository {
  final ApiClient _apiClient;
  final LoggerService _logger = LoggerService.instance;

  /// Crea un [FriendsRepository] utilizando el [_apiClient] proporcionado para la
  /// comunicación HTTP.
  FriendsRepository(this._apiClient);

  /// Envía una solicitud de amistad al usuario con el nombre [username].
  ///
  /// Devuelve el [FriendshipRequestModel] de la solicitud creada.
  Future<FriendshipRequestModel> sendRequest(String username) async {
    try {
      _logger.debug('FriendsRepository: Enviando solicitud a $username');
      final response = await _apiClient.dio.post('/friends/request/$username');
      return FriendshipRequestModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      _logger.error('FriendsRepository: Error al enviar solicitud', e);
      rethrow;
    }
  }

  /// Obtiene todas las solicitudes de amistad pendientes recibidas por el usuario autenticado.
  Future<List<FriendshipRequestModel>> getPendingRequests() async {
    try {
      _logger.debug('FriendsRepository: Cargando solicitudes pendientes');
      final response = await _apiClient.dio.get('/friends/requests/pending');
      return (response.data as List)
          .map((e) => FriendshipRequestModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _logger.error('FriendsRepository: Error al cargar solicitudes', e);
      rethrow;
    }
  }

  /// Acepta la solicitud de amistad con el identificador [id].
  Future<void> acceptRequest(int id) async {
    try {
      _logger.debug('FriendsRepository: Aceptando solicitud $id');
      await _apiClient.dio.put('/friends/requests/$id/accept');
      _logger.info('FriendsRepository: Solicitud $id aceptada');
    } catch (e) {
      _logger.error('FriendsRepository: Error al aceptar solicitud', e);
      rethrow;
    }
  }

  /// Rechaza la solicitud de amistad con el identificador [id].
  Future<void> rejectRequest(int id) async {
    try {
      _logger.debug('FriendsRepository: Rechazando solicitud $id');
      await _apiClient.dio.put('/friends/requests/$id/reject');
      _logger.info('FriendsRepository: Solicitud $id rechazada');
    } catch (e) {
      _logger.error('FriendsRepository: Error al rechazar solicitud', e);
      rethrow;
    }
  }

  /// Obtiene la lista de amigos del usuario autenticado con sus estadísticas de uso.
  Future<List<FriendModel>> getFriends() async {
    try {
      _logger.debug('FriendsRepository: Cargando lista de amigos');
      final response = await _apiClient.dio.get('/friends');
      return (response.data as List)
          .map((e) => FriendModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _logger.error('FriendsRepository: Error al cargar amigos', e);
      rethrow;
    }
  }

  /// Elimina la amistad entre el usuario autenticado y el usuario con nombre [username].
  Future<void> removeFriend(String username) async {
    try {
      _logger.debug('FriendsRepository: Eliminando amigo $username');
      await _apiClient.dio.delete('/friends/$username');
      _logger.info('FriendsRepository: Amigo $username eliminado');
    } catch (e) {
      _logger.error('FriendsRepository: Error al eliminar amigo', e);
      rethrow;
    }
  }
}
