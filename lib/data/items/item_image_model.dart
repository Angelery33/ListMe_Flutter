class ItemImageModel {
  final int? id;
  final int idItem;
  final String? imageUri;
  final String? remoteImageUrl;

  const ItemImageModel({
    this.id,
    required this.idItem,
    this.imageUri,
    this.remoteImageUrl,
  });

  factory ItemImageModel.fromJson(Map<String, dynamic> json) {
    return ItemImageModel(
      id: json['idImage'] as int?,
      idItem: json['idItem'] as int,
      imageUri: json['imageUri'] as String?,
      remoteImageUrl: json['remoteImageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) 'idImage': id,
    'idItem': idItem,
    'imageUri': imageUri,
    'remoteImageUrl': remoteImageUrl,
  };
}
