import 'package:list_me/core/api_client.dart';
import 'package:list_me/data/items/item_model.dart';
import 'package:list_me/data/items/item_image_model.dart';

class ItemsRepository {
  final ApiClient _apiClient;

  ItemsRepository(this._apiClient);

  Future<List<ItemModel>> getAllItems() async {
    try {
      final response = await _apiClient.dio.get('/items');
      return (response.data as List)
          .map((json) => ItemModel.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ItemModel>> getItemsByLibrary(int libraryId) async {
    try {
      final response = await _apiClient.dio.get('/items/library/$libraryId');
      return (response.data as List)
          .map((json) => ItemModel.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<ItemModel> getItemById(int id) async {
    try {
      final response = await _apiClient.dio.get('/items/$id');
      return ItemModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<ItemModel> createItem(ItemModel item) async {
    try {
      final response = await _apiClient.dio.post(
        '/items',
        data: item.toJson(),
      );
      return ItemModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<ItemModel> updateItem(int id, ItemModel item) async {
    try {
      final response = await _apiClient.dio.put(
        '/items/$id',
        data: item.toJson(),
      );
      return ItemModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteItem(int id) async {
    try {
      await _apiClient.dio.delete('/items/$id');
    } catch (e) {
      rethrow;
    }
  }

  // Image management
  Future<List<ItemImageModel>> getItemImages(int itemId) async {
    try {
      final response = await _apiClient.dio.get('/images/item/$itemId');
      return (response.data as List)
          .map((json) => ItemImageModel.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
