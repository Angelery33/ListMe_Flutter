import 'package:list_me/core/api_client.dart';
import 'package:list_me/core/services/logger_service.dart';
import 'package:list_me/data/items/item_model.dart';
import 'package:list_me/data/items/item_image_model.dart';

class ItemsRepository {
  final ApiClient _apiClient;
  final LoggerService _logger = LoggerService.instance;

  ItemsRepository(this._apiClient);

  Future<List<ItemModel>> getAllItems() async {
    try {
      _logger.debug('ItemsRepository: Obteniendo todos los items');
      final response = await _apiClient.dio.get('/items');
      final result = (response.data as List)
          .map((json) => ItemModel.fromJson(json))
          .toList();
      _logger.debug('ItemsRepository: Obtenidos ${result.length} items');
      return result;
    } catch (e) {
      _logger.error('ItemsRepository: Error al obtener items', e);
      rethrow;
    }
  }

  Future<List<ItemModel>> getItemsByLibrary(int libraryId) async {
    try {
      _logger.debug('ItemsRepository: Obteniendo items de lista $libraryId');
      final response = await _apiClient.dio.get('/items/library/$libraryId');
      final result = (response.data as List)
          .map((json) => ItemModel.fromJson(json))
          .toList();
      _logger.debug(
        'ItemsRepository: Obtenidos ${result.length} items de lista $libraryId',
      );
      return result;
    } catch (e) {
      _logger.error(
        'ItemsRepository: Error al obtener items de lista $libraryId',
        e,
      );
      rethrow;
    }
  }

  Future<ItemModel> getItemById(int id) async {
    try {
      _logger.debug('ItemsRepository: Obteniendo item con id: $id');
      final response = await _apiClient.dio.get('/items/$id');
      return ItemModel.fromJson(response.data);
    } catch (e) {
      _logger.error('ItemsRepository: Error al obtener item $id', e);
      rethrow;
    }
  }

  Future<ItemModel> createItem(ItemModel item) async {
    try {
      _logger.debug('ItemsRepository: Creando item: ${item.name}');
      final response = await _apiClient.dio.post('/items', data: item.toJson());
      _logger.info('ItemsRepository: Item creado: ${item.name}');
      return ItemModel.fromJson(response.data);
    } catch (e) {
      _logger.error('ItemsRepository: Error al crear item', e);
      rethrow;
    }
  }

  Future<ItemModel> updateItem(int id, ItemModel item) async {
    try {
      _logger.debug('ItemsRepository: Actualizando item $id: ${item.name}');
      final response = await _apiClient.dio.put(
        '/items/$id',
        data: item.toJson(),
      );
      _logger.info('ItemsRepository: Item $id actualizado');
      return ItemModel.fromJson(response.data);
    } catch (e) {
      _logger.error('ItemsRepository: Error al actualizar item $id', e);
      rethrow;
    }
  }

  Future<void> deleteItem(int id) async {
    try {
      _logger.debug('ItemsRepository: Eliminando item $id');
      await _apiClient.dio.delete('/items/$id');
      _logger.info('ItemsRepository: Item $id eliminado');
    } catch (e) {
      _logger.error('ItemsRepository: Error al eliminar item $id', e);
      rethrow;
    }
  }

  Future<List<ItemImageModel>> getItemImages(int itemId) async {
    try {
      _logger.debug('ItemsRepository: Obteniendo imágenes del item $itemId');
      final response = await _apiClient.dio.get('/images/item/$itemId');
      return (response.data as List)
          .map((json) => ItemImageModel.fromJson(json))
          .toList();
    } catch (e) {
      _logger.error(
        'ItemsRepository: Error al obtener imágenes del item $itemId',
        e,
      );
      rethrow;
    }
  }

  Future<ItemImageModel> createItemImage(ItemImageModel image) async {
    try {
      _logger.debug(
        'ItemsRepository: Creando imagen para item ${image.idItem}',
      );
      final response = await _apiClient.dio.post(
        '/images',
        data: image.toJson(),
      );
      return ItemImageModel.fromJson(response.data);
    } catch (e) {
      _logger.error('ItemsRepository: Error al crear imagen', e);
      rethrow;
    }
  }

  Future<List<ItemModel>> getSubCollections(int parentId, int libraryId) async {
    try {
      _logger.debug(
        'ItemsRepository: Obteniendo subcollections parent=$parentId, library=$libraryId',
      );
      final response = await _apiClient.dio.get(
        '/items/library/$libraryId/parent/$parentId',
      );
      final result = (response.data as List)
          .map((json) => ItemModel.fromJson(json))
          .toList();
      _logger.debug(
        'ItemsRepository: Obtenidas ${result.length} subcollections',
      );
      return result;
    } catch (e) {
      _logger.error('ItemsRepository: Error al obtener subcollections', e);
      rethrow;
    }
  }

  Future<List<ItemModel>> getItemsByRemoteId(String remoteId) async {
    try {
      _logger.debug(
        'ItemsRepository: Obteniendo items de lista remota $remoteId',
      );
      final response = await _apiClient.dio.get(
        '/items/library/remote/$remoteId',
      );
      final result = (response.data as List)
          .map((json) => ItemModel.fromJson(json))
          .toList();
      _logger.debug(
        'ItemsRepository: Obtenidos ${result.length} items remotos',
      );
      return result;
    } catch (e) {
      _logger.error('ItemsRepository: Error al obtener items remotos', e);
      rethrow;
    }
  }
}
