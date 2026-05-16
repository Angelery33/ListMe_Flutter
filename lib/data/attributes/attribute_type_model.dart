/// Define un tipo de atributo personalizado que se puede adjuntar a los elementos de una biblioteca.
///
/// Los tipos de atributos son definiciones reutilizables (por ejemplo, "Director", "ISBN",
/// "Editorial") que describen el tipo de metadatos adicionales que puede tener un elemento.
/// Los valores reales por elemento se almacenan en [AttributeItemModel].
class AttributeTypeModel {
  /// El identificador único de este tipo de atributo, o `null` cuando aún no ha sido
  /// persistido en el backend.
  final int? id;

  /// El nombre legible para humanos de este tipo de atributo (por ejemplo, "Director").
  final String name;

  /// El tipo de datos del valor del atributo (por ejemplo, `"text"`, `"number"`).
  /// Utilizado por la IU para determinar cómo renderizar y validar el campo de entrada.
  final String dataType;

  const AttributeTypeModel({
    this.id,
    required this.name,
    required this.dataType,
  });

  /// Crea un [AttributeTypeModel] a partir de un mapa JSON devuelto por la API,
  /// mapping `attributeTypeId` to [id].
  factory AttributeTypeModel.fromJson(Map<String, dynamic> json) {
    return AttributeTypeModel(
      id: json['attributeTypeId'] as int?,
      name: json['name'] as String,
      dataType: json['dataType'] as String,
    );
  }

  /// Convierte este modelo a un mapa JSON adecuado para enviar a la API.
  /// La clave `attributeTypeId` se omite cuando [id] es `null` (creación).
  Map<String, dynamic> toJson() => {
    if (id != null) 'attributeTypeId': id,
    'name': name,
    'dataType': dataType,
  };
}
