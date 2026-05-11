import 'package:list_me/core/services/api_client.dart';
import 'package:list_me/core/services/logger_service.dart';
import 'package:list_me/data/items/item_model.dart';
import 'package:list_me/data/items/item_image_model.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

class ItemsRepository {
  final ApiClient _apiClient;
  final LoggerService _logger = LoggerService.instance;

  ItemsRepository(this._apiClient);

  Future<List<ItemModel>> getAllItems({int? libraryId}) async {
    try {
      _logger.debug('ItemsRepository: Obteniendo todos los items');
      String endpoint = '/items';
      if (libraryId != null) {
        endpoint = '/items/library/$libraryId';
      }
      final response = await _apiClient.dio.get(endpoint);
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

  Future<void> deleteItemImage(int imageId) async {
    try {
      _logger.debug('ItemsRepository: Eliminando imagen $imageId');
      await _apiClient.dio.delete('/images/$imageId');
      _logger.info('ItemsRepository: Imagen $imageId eliminada');
    } catch (e) {
      _logger.error('ItemsRepository: Error al eliminar imagen $imageId', e);
      rethrow;
    }
  }

  Future<void> deleteItemImagesByItemId(int itemId) async {
    try {
      _logger.debug('ItemsRepository: Eliminando imágenes del item $itemId');
      await _apiClient.dio.delete('/images/item/$itemId');
      _logger.info('ItemsRepository: Imágenes del item $itemId eliminadas');
    } catch (e) {
      _logger.error(
        'ItemsRepository: Error al eliminar imágenes del item $itemId',
        e,
      );
      rethrow;
    }
  }

  Future<void> setFavoriteImage(int itemId, int imageId) async {
    try {
      _logger.debug('ItemsRepository: Marcando imagen $imageId como favorita');
      await _apiClient.dio.put('/images/$itemId/favorite/$imageId');
      _logger.info('ItemsRepository: Imagen $imageId marcada como favorita');
    } catch (e) {
      _logger.error('ItemsRepository: Error al marcar imagen como favorita', e);
      rethrow;
    }
  }

  Future<ItemImageModel> uploadImage(int itemId, String imagePath) async {
    try {
      _logger.debug('ItemsRepository: Subiendo imagen para ítem $itemId');

      final fileName = imagePath.split('/').last;

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(imagePath, filename: fileName),
        'itemId': itemId,
      });

      final response = await _apiClient.dio.post(
        '/images/upload',
        data: formData,
      );

      final imageModel = ItemImageModel.fromJson(response.data);
      _logger.info('ItemsRepository: Imagen subida exitosamente para ítem $itemId');
      return imageModel;
    } catch (e) {
      _logger.error('ItemsRepository: Error al subir imagen', e);
      rethrow;
    }
  }

  Future<ItemImageModel> uploadImageFromFile(int itemId, XFile imageFile) async {
    try {
      _logger.debug('ItemsRepository: Subiendo imagen para ítem $itemId');

      final bytes = await imageFile.readAsBytes();
      final fileName = imageFile.name;

      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          bytes,
          filename: fileName,
        ),
        'itemId': itemId,
      });

      final response = await _apiClient.dio.post(
        '/images/upload',
        data: formData,
      );

      final imageModel = ItemImageModel.fromJson(response.data);
      _logger.info('ItemsRepository: Imagen subida exitosamente para ítem $itemId');
      return imageModel;
    } catch (e) {
      _logger.error('ItemsRepository: Error al subir imagen', e);
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
