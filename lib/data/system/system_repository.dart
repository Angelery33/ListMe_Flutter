import '../../core/services/api_client.dart';
import 'user_stats_model.dart';

/// Proporciona operaciones de acceso a datos para información a nivel de sistema, como la
/// versión de la API y estadísticas de usuario agregadas, comunicándose con la API REST
/// del backend a través de [ApiClient].
class SystemRepository {
  final ApiClient _apiClient;

  /// Crea un [SystemRepository] utilizando el [_apiClient] proporcionado para la
  /// comunicación HTTP.
  SystemRepository(this._apiClient);

  /// Obtiene la cadena de la versión actual de la API del backend y la devuelve.
  /// Esto es útil para mostrar información de la versión en la pantalla de configuración y para
  /// comprobaciones de compatibilidad.
  Future<String> getApiVersion() async {
    final response = await _apiClient.dio.get('/system/version');
    return response.data['version'];
  }

  /// Obtiene estadísticas agregadas para el usuario autenticado (por ejemplo, bibliotecas
  /// y elementos totales) y las devuelve como un [UserStatsModel].
  Future<UserStatsModel> getUserStats() async {
    final response = await _apiClient.dio.get('/system/stats');
    return UserStatsModel.fromJson(response.data);
  }
}
