import '../../core/services/api_client.dart';
import 'invitation_model.dart';

class InvitationsRepository {
  final ApiClient _apiClient;

  InvitationsRepository(this._apiClient);

  Future<List<InvitationModel>> getPendingInvitations() async {
    final response = await _apiClient.dio.get('/invitations/pending');
    final data = response.data;
    if (data == null || data is! List) return [];
    return data.map((json) => InvitationModel.fromJson(json)).toList();
  }

  Future<void> sendInvitation(int libraryId, String username, bool readOnly) async {
    await _apiClient.dio.post('/invitations/library/$libraryId', data: {
      'username': username,
      'readOnly': readOnly,
    });
  }

  Future<void> acceptInvitation(int id) async {
    await _apiClient.dio.put('/invitations/$id/accept');
  }

  Future<void> rejectInvitation(int id) async {
    await _apiClient.dio.put('/invitations/$id/reject');
  }
}
