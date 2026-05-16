import 'package:list_me/core/services/api_client.dart';
import 'package:list_me/core/services/logger_service.dart';
import 'package:list_me/data/attributes/attribute_type_model.dart';
import 'package:list_me/data/attributes/attribute_item_model.dart';

/// Proporciona operaciones de acceso a datos para tipos de atributos y valores
/// de atributos de elementos, comunicándose con la API REST del backend a través de [ApiClient].
///
/// Los tipos de atributos definen definiciones de metadatos reutilizables (por ejemplo, "Director"),
/// mientras que los elementos de atributo almacenan los valores reales asignados a elementos específicos.
class AttributesRepository {
  final ApiClient _apiClient;
  final LoggerService _logger = LoggerService.instance;

  /// Crea un [AttributesRepository] utilizando el [_apiClient] proporcionado para
  /// realizar solicitudes HTTP.
  AttributesRepository(this._apiClient);

  /// Obtiene todas las definiciones de tipos de atributos de la API y las devuelve como una
  /// lista de [AttributeTypeModel].
  Future<List<AttributeTypeModel>> getAllAttributeTypes() async {
    try {
      _logger.debug('AttributesRepository: Obteniendo tipos de atributos');
      final response = await _apiClient.dio.get('/attribute-types');
      return (response.data as List)
          .map((json) => AttributeTypeModel.fromJson(json))
          .toList();
    } catch (e) {
      _logger.error(
        'AttributesRepository: Error al obtener tipos de atributos',
        e,
      );
      rethrow;
    }
  }

  /// Crea una nueva definición de tipo de atributo en el backend utilizando los datos de
  /// [type] y devuelve el [AttributeTypeModel] persistido con su id asignado.
  Future<AttributeTypeModel> createAttributeType(
    AttributeTypeModel type,
  ) async {
    try {
      _logger.debug(
        'AttributesRepository: Creando tipo de atributo: ${type.name}',
      );
      final response = await _apiClient.dio.post(
        '/attribute-types',
        data: type.toJson(),
      );
      _logger.info(
        'AttributesRepository: Tipo de atributo creado: ${type.name}',
      );
      return AttributeTypeModel.fromJson(response.data);
    } catch (e) {
      _logger.error('AttributesRepository: Error al crear tipo de atributo', e);
      rethrow;
    }
  }

  /// Obtiene todos los valores de atributo asignados al elemento identificado por [itemId]
  /// y los devuelve como una lista de [AttributeItemModel].
  Future<List<AttributeItemModel>> getItemAttributes(int itemId) async {
    try {
      _logger.debug(
        'AttributesRepository: Obteniendo atributos del item $itemId',
      );
      final response = await _apiClient.dio.get(
        '/attribute-items/item/$itemId',
      );
      return (response.data as List)
          .map((json) => AttributeItemModel.fromJson(json))
          .toList();
    } catch (e) {
      _logger.error(
        'AttributesRepository: Error al obtener atributos del item $itemId',
        e,
      );
      rethrow;
    }
  }

  /// Persiste un nuevo valor de atributo descrito por [attribute] en el backend
  /// y devuelve el [AttributeItemModel] guardado con su id asignado.
  Future<AttributeItemModel> addAttributeToItem(
    AttributeItemModel attribute,
  ) async {
    try {
      _logger.debug(
        'AttributesRepository: Agregando atributo al item ${attribute.idItem}',
      );
      final response = await _apiClient.dio.post(
        '/attribute-items',
        data: attribute.toJson(),
      );
      _logger.info(
        'AttributesRepository: Atributo agregado al item ${attribute.idItem}',
      );
      return AttributeItemModel.fromJson(response.data);
    } catch (e) {
      _logger.error('AttributesRepository: Error al agregar atributo', e);
      rethrow;
    }
  }

  /// Elimina el registro de elemento de atributo identificado por [attributeItemId] del
  /// backend, eliminando permanentemente ese valor del elemento.
  Future<void> removeAttributeFromItem(int attributeItemId) async {
    try {
      _logger.debug(
        'AttributesRepository: Eliminando atributo $attributeItemId',
      );
      await _apiClient.dio.delete('/attribute-items/$attributeItemId');
      _logger.info('AttributesRepository: Atributo $attributeItemId eliminado');
    } catch (e) {
      _logger.error(
        'AttributesRepository: Error al eliminar atributo $attributeItemId',
        e,
      );
      rethrow;
    }
  }
}
