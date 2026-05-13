import '../../core/services/api_client.dart';
import 'user_stats_model.dart';

class SystemRepository {
  final ApiClient _apiClient;

  SystemRepository(this._apiClient);

  Future<String> getApiVersion() async {
    final response = await _apiClient.dio.get('/system/version');
    return response.data['version'];
  }

  Future<UserStatsModel> getUserStats() async {
    final response = await _apiClient.dio.get('/system/stats');
    return UserStatsModel.fromJson(response.data);
  }
}
