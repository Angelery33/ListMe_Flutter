import 'package:list_me/core/services/api_client.dart';
import 'package:list_me/core/services/logger_service.dart';
import 'package:list_me/data/attributes/attribute_type_model.dart';
import 'package:list_me/data/attributes/attribute_item_model.dart';

class AttributesRepository {
  final ApiClient _apiClient;
  final LoggerService _logger = LoggerService.instance;

  AttributesRepository(this._apiClient);

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
