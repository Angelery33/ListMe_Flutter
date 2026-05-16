/// Representa un valor de atributo concreto asignado a un elemento específico.
///
/// Cada [AttributeItemModel] vincula una definición de [AttributeTypeModel] a un
/// elemento, almacenando el [value] real para ese atributo. Por ejemplo, un elemento
/// podría tener un atributo de tipo "Director" con el valor "Christopher Nolan".
class AttributeItemModel {
  /// El identificador único de este registro de atributo-elemento, o `null` cuando aún no se ha
  /// guardado en el backend.
  final int? id;

  /// El valor de cadena de este atributo para el elemento asociado.
  final String value;

  /// El identificador del elemento al que pertenece este valor de atributo.
  final int idItem;

  /// El identificador del [AttributeTypeModel] que define lo que representa este
  /// atributo (por ejemplo, "Director", "Editorial").
  final int attributeTypeId;

  const AttributeItemModel({
    this.id,
    required this.value,
    required this.idItem,
    required this.attributeTypeId,
  });

  /// Crea un [AttributeItemModel] a partir de un mapa JSON devuelto por la API,
  /// mapeando `attributeItemId` al [id].
  factory AttributeItemModel.fromJson(Map<String, dynamic> json) {
    return AttributeItemModel(
      id: json['attributeItemId'] as int?,
      value: json['value'] as String,
      idItem: json['idItem'] as int,
      attributeTypeId: json['attributeTypeId'] as int,
    );
  }

  /// Convierte este modelo a un mapa JSON adecuado para enviar a la API.
  /// La clave `attributeItemId` se omite cuando el [id] es `null` (creación).
  Map<String, dynamic> toJson() => {
    if (id != null) 'attributeItemId': id,
    'value': value,
    'idItem': idItem,
    'attributeTypeId': attributeTypeId,
  };
}
