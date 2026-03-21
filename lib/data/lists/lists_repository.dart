/// Repositorio de listas de usuario.
/// 
/// Gestiona las operaciones CRUD contra los endpoints de listas de la API REST.
import 'package:list_me/core/api_client.dart';
import 'package:list_me/data/lists/list_model.dart';
import 'package:list_me/data/lists/library_genre_model.dart';
import 'package:list_me/data/lists/share_request_model.dart';

class ListsRepository {
  final ApiClient _apiClient;

  ListsRepository(this._apiClient);

  Future<List<ListModel>> getAllLibraries() async {
    try {
      final response = await _apiClient.dio.get('/libraries');
      return (response.data as List)
          .map((json) => ListModel.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<ListModel> getLibraryById(int id) async {
    try {
      final response = await _apiClient.dio.get('/libraries/$id');
      return ListModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<ListModel> createLibrary(ListModel library) async {
    try {
      final response = await _apiClient.dio.post(
        '/libraries',
        data: library.toJson(),
      );
      return ListModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<ListModel> updateLibrary(int id, ListModel library) async {
    try {
      final response = await _apiClient.dio.put(
        '/libraries/$id',
        data: library.toJson(),
      );
      return ListModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteLibrary(int id) async {
    try {
      await _apiClient.dio.delete('/libraries/$id');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> shareLibrary(int id, ShareRequestModel request) async {
    try {
      await _apiClient.dio.post(
        '/libraries/$id/share',
        data: request.toJson(),
      );
    } catch (e) {
      rethrow;
    }
  }

  // Genre management
  Future<List<LibraryGenreModel>> getLibraryGenres(int libraryId) async {
    try {
      final response = await _apiClient.dio.get('/library-genres/library/$libraryId');
      return (response.data as List)
          .map((json) => LibraryGenreModel.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
