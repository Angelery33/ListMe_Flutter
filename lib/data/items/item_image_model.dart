class ItemImageModel {
  final int? id;
  final int idItem;
  final String? imageUri;
  final String? remoteImageUrl;
  final bool isFavorite;

  const ItemImageModel({
    this.id,
    required this.idItem,
    this.imageUri,
    this.remoteImageUrl,
    this.isFavorite = false,
  });

  factory ItemImageModel.fromJson(Map<String, dynamic> json) {
    return ItemImageModel(
      id: json['idImage'] as int?,
      idItem: json['idItem'] as int,
      imageUri: json['imageUri'] as String?,
      remoteImageUrl: json['remoteImageUrl'] as String?,
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }

  ItemImageModel copyWith({
    int? id,
    int? idItem,
    String? imageUri,
    String? remoteImageUrl,
    bool? isFavorite,
  }) {
    return ItemImageModel(
      id: id ?? this.id,
      idItem: idItem ?? this.idItem,
      imageUri: imageUri ?? this.imageUri,
      remoteImageUrl: remoteImageUrl ?? this.remoteImageUrl,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) 'idImage': id,
    'idItem': idItem,
    'imageUri': imageUri,
    'remoteImageUrl': remoteImageUrl,
    'isFavorite': isFavorite,
  };
}
