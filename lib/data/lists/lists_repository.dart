import 'package:list_me/core/services/api_client.dart';
import 'package:list_me/core/services/logger_service.dart';
import 'package:list_me/data/lists/list_model.dart';
import 'package:list_me/data/lists/library_genre_model.dart';
import 'package:list_me/data/lists/share_request_model.dart';

/// Proporciona operaciones de acceso a datos para bibliotecas (listas) y sus etiquetas
/// de género, comunicándose con la API REST del backend a través de [ApiClient].
///
/// Cubre CRUD completo para bibliotecas, reordenación, uso compartido y gestión de
/// etiquetas de género por biblioteca.
class ListsRepository {
  final ApiClient _apiClient;
  final LoggerService _logger = LoggerService.instance;

  /// Crea un [ListsRepository] utilizando el [_apiClient] proporcionado para la
  /// comunicación HTTP.
  ListsRepository(this._apiClient);

  /// Obtiene todas las bibliotecas accesibles para el usuario autenticado y las devuelve
  /// como una lista de [ListModel].
  Future<List<ListModel>> getAllLibraries() async {
    try {
      _logger.debug('ListsRepository: Obteniendo todas las listas');
      final response = await _apiClient.dio.get('/libraries');
      _logger.debug('ListsRepository: Respuesta del servidor (GET /libraries): ${response.data}');
      final result = (response.data as List)
          .map((json) => ListModel.fromJson(json))
          .toList();
      _logger.debug('ListsRepository: Obtenidas ${result.length} listas');
      return result;
    } catch (e) {
      _logger.error('ListsRepository: Error al obtener listas', e);
      rethrow;
    }
  }

  /// Obtiene la biblioteca identificada por [id] y la devuelve como un [ListModel].
  Future<ListModel> getLibraryById(int id) async {
    try {
      _logger.debug('ListsRepository: Obteniendo lista con id: $id');
      final response = await _apiClient.dio.get('/libraries/$id');
      return ListModel.fromJson(response.data);
    } catch (e) {
      _logger.error('ListsRepository: Error al obtener lista $id', e);
      rethrow;
    }
  }

  /// Guarda una nueva [library] en el backend y devuelve el [ListModel] guardado
  /// con su ID asignado.
  Future<ListModel> createLibrary(ListModel library) async {
    try {
      _logger.debug('ListsRepository: Creando lista: ${library.name}');
      final requestData = library.toJson();
      _logger.debug('ListsRepository: Datos enviados (POST /libraries): $requestData');
      final response = await _apiClient.dio.post(
        '/libraries',
        data: requestData,
      );
      _logger.info('ListsRepository: Respuesta del servidor (POST /libraries): ${response.data}');
      return ListModel.fromJson(response.data);
    } catch (e) {
      _logger.error('ListsRepository: Error al crear lista', e);
      rethrow;
    }
  }

  /// Actualiza la biblioteca identificada por [id] con los datos en [library] y
  /// devuelve el [ListModel] actualizado según lo confirmado por el backend.
  Future<ListModel> updateLibrary(int id, ListModel library) async {
    try {
      _logger.debug('ListsRepository: Actualizando lista $id: ${library.name}');
      final requestData = library.toJson();
      _logger.debug('ListsRepository: Datos enviados (PUT /libraries/$id): $requestData');
      final response = await _apiClient.dio.put(
        '/libraries/$id',
        data: requestData,
      );
      _logger.info('ListsRepository: Respuesta del servidor (PUT /libraries/$id): ${response.data}');
      return ListModel.fromJson(response.data);
    } catch (e) {
      _logger.error('ListsRepository: Error al actualizar lista $id', e);
      rethrow;
    }
  }

  /// Elimina permanentemente la biblioteca identificada por [id] del backend.
  Future<void> deleteLibrary(int id) async {
    try {
      _logger.debug('ListsRepository: Eliminando lista $id');
      await _apiClient.dio.delete('/libraries/$id');
      _logger.info('ListsRepository: Lista $id eliminada');
    } catch (e) {
      _logger.error('ListsRepository: Error al eliminar lista $id', e);
      rethrow;
    }
  }

  /// Envía el nuevo orden de clasificación de las bibliotecas al backend. [items] es una lista
  /// de mapas, cada uno con entradas `{"idLibrary": id, "position": pos}`.
  Future<void> reorderLibraries(List<Map<String, int>> items) async {
    try {
      _logger.debug('ListsRepository: Reordenando listas');
      await _apiClient.dio.put('/libraries/reorder', data: items);
      _logger.info('ListsRepository: Listas reordenadas');
    } catch (e) {
      _logger.error('ListsRepository: Error al reordenar listas', e);
      rethrow;
    }
  }

  /// Comparte la biblioteca identificada por [id] con otro usuario como se describe en
  /// [request], que especifica el nombre de usuario de destino y el nivel de acceso.
  Future<void> shareLibrary(int id, ShareRequestModel request) async {
    try {
      _logger.debug('ListsRepository: Compartiendo lista $id');
      await _apiClient.dio.post('/libraries/$id/share', data: request.toJson());
      _logger.info('ListsRepository: Lista $id compartida');
    } catch (e) {
      _logger.error('ListsRepository: Error al compartir lista $id', e);
      rethrow;
    }
  }

  /// Obtiene todas las etiquetas de género definidas para la biblioteca identificada por [libraryId]
  /// y las devuelve como una lista de [LibraryGenreModel].
  Future<List<LibraryGenreModel>> getLibraryGenres(int libraryId) async {
    try {
      _logger.debug('ListsRepository: Obteniendo géneros de lista $libraryId');
      final response = await _apiClient.dio.get(
        '/library-genres/library/$libraryId',
      );
      return (response.data as List)
          .map((json) => LibraryGenreModel.fromJson(json))
          .toList();
    } catch (e) {
      _logger.error(
        'ListsRepository: Error al obtener géneros de lista $libraryId',
        e,
      );
      rethrow;
    }
  }

  /// Guarda la nueva etiqueta de género [genre] en el backend y devuelve el
  /// [LibraryGenreModel] guardado con su ID asignado.
  Future<LibraryGenreModel> addLibraryGenre(LibraryGenreModel genre) async {
    try {
      _logger.debug('ListsRepository: Agregando género: ${genre.name}');
      final response = await _apiClient.dio.post(
        '/library-genres',
        data: genre.toJson(),
      );
      _logger.info('ListsRepository: Género ${genre.name} agregado');
      return LibraryGenreModel.fromJson(response.data);
    } catch (e) {
      _logger.error('ListsRepository: Error al agregar género', e);
      rethrow;
    }
  }

  /// Elimina permanentemente la etiqueta de género identificada por [genreId] del
  /// backend, eliminándola de la lista de géneros de la biblioteca.
  Future<void> deleteLibraryGenre(int genreId) async {
    try {
      _logger.debug('ListsRepository: Eliminando género $genreId');
      await _apiClient.dio.delete('/library-genres/$genreId');
      _logger.info('ListsRepository: Género $genreId eliminado');
    } catch (e) {
      _logger.error('ListsRepository: Error al eliminar género $genreId', e);
      rethrow;
    }
  }
}
