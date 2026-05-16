/// Representa una única imagen asociada con un elemento de lista.
///
/// Un elemento puede tener múltiples imágenes. Una imagen puede marcarse como favorita
/// a través de [isFavorite], que utiliza la IU para mostrarla como la imagen de portada
/// principal. Las imágenes se pueden almacenar localmente a través de [imageUri] o alojarse
/// de forma remota a través de [remoteImageUrl].
class ItemImageModel {
  /// El identificador único de este registro de imagen, o `null` cuando aún no se ha
  /// guardado en el backend.
  final int? id;

  /// El identificador del elemento al que pertenece esta imagen.
  final int idItem;

  /// La ruta del sistema de archivos local o URI a la imagen, o `null` si solo hay disponible
  /// una URL remota.
  final String? imageUri;

  /// La URL remota de la imagen (por ejemplo, devuelta por una API externa), o
  /// `null` si la imagen se almacena localmente.
  final String? remoteImageUrl;

  /// Indica si esta imagen es la imagen principal/favorita del elemento.
  /// La IU utiliza esto para determinar qué imagen mostrar como portada.
  final bool isFavorite;

  const ItemImageModel({
    this.id,
    required this.idItem,
    this.imageUri,
    this.remoteImageUrl,
    this.isFavorite = false,
  });

  /// Crea un [ItemImageModel] a partir del mapa JSON devuelto por la API,
  /// mapeando `idImage` al [id].
  factory ItemImageModel.fromJson(Map<String, dynamic> json) {
    return ItemImageModel(
      id: json['idImage'] as int?,
      idItem: json['idItem'] as int,
      imageUri: json['imageUri'] as String?,
      remoteImageUrl: json['remoteImageUrl'] as String?,
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }

  /// Devuelve una copia de este [ItemImageModel] con los campos indicados reemplazados.
  /// Los campos no proporcionados conservan sus valores actuales.
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

  /// Convierte este modelo a un mapa JSON adecuado para enviar a la API.
  /// La clave `idImage` se omite cuando el [id] es `null` (creación).
  Map<String, dynamic> toJson() => {
    if (id != null) 'idImage': id,
    'idItem': idItem,
    'imageUri': imageUri,
    'remoteImageUrl': remoteImageUrl,
    'isFavorite': isFavorite,
  };
}
