class AttributeTypeModel {
  final int? id;
  final String name;
  final String dataType;

  const AttributeTypeModel({
    this.id,
    required this.name,
    required this.dataType,
  });

  factory AttributeTypeModel.fromJson(Map<String, dynamic> json) {
    return AttributeTypeModel(
      id: json['attributeTypeId'] as int?,
      name: json['name'] as String,
      dataType: json['dataType'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) 'attributeTypeId': id,
    'name': name,
    'dataType': dataType,
  };
}
