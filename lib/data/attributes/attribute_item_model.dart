class AttributeItemModel {
  final int? id;
  final String value;
  final int idItem;
  final int attributeTypeId;

  const AttributeItemModel({
    this.id,
    required this.value,
    required this.idItem,
    required this.attributeTypeId,
  });

  factory AttributeItemModel.fromJson(Map<String, dynamic> json) {
    return AttributeItemModel(
      id: json['attributeItemId'] as int?,
      value: json['value'] as String,
      idItem: json['idItem'] as int,
      attributeTypeId: json['attributeTypeId'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) 'attributeItemId': id,
    'value': value,
    'idItem': idItem,
    'attributeTypeId': attributeTypeId,
  };
}
