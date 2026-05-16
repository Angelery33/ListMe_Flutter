import 'package:list_me/core/services/api_client.dart';
import 'package:list_me/core/services/logger_service.dart';
import 'package:list_me/data/items/item_model.dart';
import 'package:list_me/data/items/item_image_model.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';

/// Proporciona operaciones de acceso a datos para elementos y sus imágenes asociadas,
/// comunicándose con la API REST del backend a través de [ApiClient].
///
/// Soporta CRUD completo para elementos, gestión de imágenes (subida, eliminación, favorita)
/// y consultas especializadas como sub-colecciones y elementos por ID de biblioteca remota.
class ItemsRepository {
  final ApiClient _apiClient;
  final LoggerService _logger = LoggerService.instance;

  /// Crea un [ItemsRepository] utilizando el [_apiClient] proporcionado para la
  /// comunicación HTTP.
  ItemsRepository(this._apiClient);

  /// Obtiene los elementos de la API y los devuelve como una lista de [ItemModel].
  ///
  /// Cuando se proporciona [libraryId], solo se devuelven los elementos que pertenecen a esa biblioteca;
  /// de lo contrario, se devuelven todos los elementos accesibles para el usuario autenticado.
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

  /// Obtiene el elemento identificado por [id] de la API y lo devuelve como un
  /// [ItemModel].
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

  /// Guarda un nuevo [item] en el backend y devuelve el [ItemModel] guardado
  /// con su ID asignado.
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

  /// Actualiza el elemento identificado por [id] con los datos en [item] y devuelve
  /// el [ItemModel] actualizado según lo confirmado por el backend.
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

  /// Elimina permanentemente el elemento identificado por [id] del backend.
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

  /// Obtiene todas las imágenes asociadas con el elemento identificado por [itemId] y
  /// las devuelve como una lista de [ItemImageModel], ordenadas con la imagen
  /// favorita primero.
  Future<List<ItemImageModel>> getItemImages(int itemId) async {
    try {
      _logger.debug('ItemsRepository: Obteniendo imágenes del item $itemId');
      final response = await _apiClient.dio.get('/images/item/$itemId');
      final images = (response.data as List)
          .map((json) => ItemImageModel.fromJson(json))
          .toList();
      images.sort((a, b) {
        if (a.isFavorite == b.isFavorite) return 0;
        return a.isFavorite ? -1 : 1;
      });
      return images;
    } catch (e) {
      _logger.error(
        'ItemsRepository: Error al obtener imágenes del item $itemId',
        e,
      );
      rethrow;
    }
  }

  /// Crea un registro de imagen descrito por [image] en el backend utilizando JSON
  /// (para imágenes basadas en URL) y devuelve el [ItemImageModel] guardado.
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

  /// Elimina permanentemente la imagen identificada por [imageId] del backend.
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

  /// Elimina todas las imágenes asociadas con el elemento identificado por [itemId] en una
  /// única solicitud por lotes al backend.
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

  /// Marca la imagen identificada por [imageId] como la favorita para el elemento
  /// identificado por [itemId], para que se muestre como la imagen de portada principal.
  Future<void> setFavoriteImage(int itemId, int imageId) async {
    try {
      _logger.debug('ItemsRepository: Marcando imagen $imageId como favorita');
      await _apiClient.dio.put('/images/item/$itemId/favorite/$imageId');
      _logger.info('ItemsRepository: Imagen $imageId marcada como favorita');
    } catch (e) {
      _logger.error('ItemsRepository: Error al marcar imagen como favorita', e);
      rethrow;
    }
  }

  /// Sube el archivo de imagen ubicado en [imagePath] para el elemento identificado por
  /// [itemId] utilizando una solicitud multipart form-data y devuelve el
  /// [ItemImageModel] guardado.
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

  /// Sube la imagen representada por [imageFile] para el elemento identificado por
  /// [itemId] utilizando una solicitud multipart form-data y devuelve el
  /// [ItemImageModel] guardado.
  ///
  /// Lee los bytes del archivo de [imageFile], resuelve el tipo MIME y
  /// garantiza que el nombre del archivo tenga una extensión válida antes de enviarlo.
  Future<ItemImageModel> uploadImageFromFile(int itemId, XFile imageFile) async {
    try {
      _logger.debug('ItemsRepository: Subiendo imagen para ítem $itemId');

      final bytes = await imageFile.readAsBytes();
      final originalName = imageFile.name;
      final mimeType = _resolveMimeType(originalName, imageFile.mimeType);
      final fileName = _ensureFileExtension(originalName, mimeType);
      final mimeParts = mimeType.split('/');

      _logger.debug(
        'ItemsRepository: Upload - filename=$fileName, mimeType=$mimeType, size=${bytes.length} bytes',
      );

      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          bytes,
          filename: fileName,
          contentType: MediaType(mimeParts[0], mimeParts[1]),
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

  /// Determina el tipo MIME para una imagen dado su [fileName] y una
  /// indicación opcional de [xfileMimeType] del selector de archivos de la plataforma.
  ///
  /// Prefiere [xfileMimeType] cuando es una cadena `image/*` válida; de lo contrario,
  /// recurre a inspeccionar la extensión del [fileName]. Por defecto es
  /// `image/jpeg` cuando la extensión es desconocida.
  String _resolveMimeType(String fileName, String? xfileMimeType) {
    if (xfileMimeType != null && xfileMimeType.isNotEmpty && xfileMimeType.startsWith('image/')) {
      return xfileMimeType;
    }
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
    return 'image/jpeg';
  }

  /// Garantiza que [fileName] tenga una extensión de archivo consistente con [mimeType].
  ///
  /// Si [fileName] ya contiene una extensión corta (≤ 5 caracteres) se devuelve
  /// sin cambios; de lo contrario, se añade la extensión adecuada basada en
  /// [mimeType].
  String _ensureFileExtension(String fileName, String mimeType) {
    final hasExtension = fileName.contains('.') &&
        fileName.split('.').last.length <= 5;
    if (hasExtension) return fileName;
    switch (mimeType) {
      case 'image/png':
        return '$fileName.png';
      case 'image/webp':
        return '$fileName.webp';
      default:
        return '$fileName.jpg';
    }
  }

  /// Obtiene todos los elementos hijos (entradas de sub-colección) que pertenecen al
  /// elemento padre identificado por [parentId] dentro de la biblioteca [libraryId], y
  /// los devuelve como una lista de [ItemModel].
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

  /// Obtiene los elementos que pertenecen a la biblioteca compartida identificada por la
  /// cadena remota [remoteId] y los devuelve como una lista de [ItemModel].
  ///
  /// Esto se utiliza para cargar elementos de bibliotecas compartidas por otros usuarios donde
  /// solo se conoce el identificador remoto.
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
