import 'package:list_me/core/api_client.dart';
import 'package:list_me/data/attributes/attribute_type_model.dart';
import 'package:list_me/data/attributes/attribute_item_model.dart';

class AttributesRepository {
  final ApiClient _apiClient;

  AttributesRepository(this._apiClient);

  // Attribute Types (Global definitions)
  Future<List<AttributeTypeModel>> getAllAttributeTypes() async {
    try {
      final response = await _apiClient.dio.get('/attribute-types');
      return (response.data as List)
          .map((json) => AttributeTypeModel.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<AttributeTypeModel> createAttributeType(AttributeTypeModel type) async {
    try {
      final response = await _apiClient.dio.post(
        '/attribute-types',
        data: type.toJson(),
      );
      return AttributeTypeModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  // Attribute Items (Specific values for an item)
  Future<List<AttributeItemModel>> getItemAttributes(int itemId) async {
    try {
      final response = await _apiClient.dio.get('/attribute-items/item/$itemId');
      return (response.data as List)
          .map((json) => AttributeItemModel.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<AttributeItemModel> addAttributeToItem(AttributeItemModel attribute) async {
    try {
      final response = await _apiClient.dio.post(
        '/attribute-items',
        data: attribute.toJson(),
      );
      return AttributeItemModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeAttributeFromItem(int attributeItemId) async {
    try {
      await _apiClient.dio.delete('/attribute-items/$attributeItemId');
    } catch (e) {
      rethrow;
    }
  }
}
