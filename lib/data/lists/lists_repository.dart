import 'package:list_me/core/api_client.dart';
import 'package:list_me/core/services/logger_service.dart';
import 'package:list_me/data/lists/list_model.dart';
import 'package:list_me/data/lists/library_genre_model.dart';
import 'package:list_me/data/lists/share_request_model.dart';

class ListsRepository {
  final ApiClient _apiClient;
  final LoggerService _logger = LoggerService.instance;

  ListsRepository(this._apiClient);

  Future<List<ListModel>> getAllLibraries() async {
    try {
      _logger.debug('ListsRepository: Obteniendo todas las listas');
      final response = await _apiClient.dio.get('/libraries');
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

  Future<ListModel> createLibrary(ListModel library) async {
    try {
      _logger.debug('ListsRepository: Creando lista: ${library.name}');
      final response = await _apiClient.dio.post(
        '/libraries',
        data: library.toJson(),
      );
      _logger.info('ListsRepository: Lista creada: ${library.name}');
      return ListModel.fromJson(response.data);
    } catch (e) {
      _logger.error('ListsRepository: Error al crear lista', e);
      rethrow;
    }
  }

  Future<ListModel> updateLibrary(int id, ListModel library) async {
    try {
      _logger.debug('ListsRepository: Actualizando lista $id: ${library.name}');
      final response = await _apiClient.dio.put(
        '/libraries/$id',
        data: library.toJson(),
      );
      _logger.info('ListsRepository: Lista $id actualizada');
      return ListModel.fromJson(response.data);
    } catch (e) {
      _logger.error('ListsRepository: Error al actualizar lista $id', e);
      rethrow;
    }
  }

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
