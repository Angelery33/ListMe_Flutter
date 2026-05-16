import '../../core/services/api_client.dart';
import 'invitation_model.dart';

/// Proporciona operaciones de acceso a datos para invitaciones de compartición de bibliotecas,
/// comunicándose con la API REST del backend a través de [ApiClient].
class InvitationsRepository {
  final ApiClient _apiClient;

  /// Crea un [InvitationsRepository] utilizando el [_apiClient] proporcionado para la
  /// comunicación HTTP.
  InvitationsRepository(this._apiClient);

  /// Obtiene todas las invitaciones que están actualmente pendientes de respuesta para el
  /// usuario autenticado y las devuelve como una lista de [InvitationModel].
  /// Devuelve una lista vacía si el servidor devuelve `null` o una respuesta que no es una lista.
  Future<List<InvitationModel>> getPendingInvitations() async {
    final response = await _apiClient.dio.get('/invitations/pending');
    final data = response.data;
    if (data == null || data is! List) return [];
    return data.map((json) => InvitationModel.fromJson(json)).toList();
  }

  /// Envía una invitación para compartir la biblioteca identificada por [libraryId] al
  /// usuario con el [username] dado. El indicador [readOnly] controla si
  /// el invitado recibirá derechos de edición al aceptar.
  Future<void> sendInvitation(int libraryId, String username, bool readOnly) async {
    await _apiClient.dio.post('/invitations/library/$libraryId', data: {
      'username': username,
      'readOnly': readOnly,
    });
  }

  /// Marca la invitación identificada por [id] como aceptada, otorgando al
  /// destinatario acceso a la biblioteca compartida.
  Future<void> acceptInvitation(int id) async {
    await _apiClient.dio.put('/invitations/$id/accept');
  }

  /// Marca la invitación identificada por [id] como rechazada, declinando el
  /// uso compartido de la biblioteca sin otorgar ningún acceso.
  Future<void> rejectInvitation(int id) async {
    await _apiClient.dio.put('/invitations/$id/reject');
  }
}
