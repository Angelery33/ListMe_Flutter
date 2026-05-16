/// Representa una única entrada (elemento) dentro de una biblioteca de usuario.
///
/// Un [ItemModel] es el objeto de datos principal de la aplicación. Almacena todos los
/// metadatos sobre una entrada coleccionable o rastreable: información básica ([name],
/// [description], [genre]), seguimiento de progreso ([currentProgress],
/// [totalProgress], [season], [chapter], [page], [volume]), detalles de adquisición
/// ([acquisitionDate], [price]), puntuación del usuario ([score]), datos de valoración
/// externa ([externalRating], [ratingSource]), e indicaciones de visualización como
/// [imageAlignmentX] / [imageAlignmentY].
///
/// Los elementos se pueden agrupar en sub-colecciones estableciendo [parentId] con el
/// [id] de un elemento padre en la misma biblioteca.
class ItemModel {
  /// El identificador único de este elemento, o `null` si aún no se ha guardado.
  final int? id;

  /// El identificador de la biblioteca (lista) a la que pertenece este elemento.
  final int idLibrary;

  /// El nombre visible del elemento.
  final String name;

  /// Una descripción opcional más larga o sinopsis del elemento.
  final String? description;

  /// El año de lanzamiento o publicación del elemento, almacenado como un entero
  /// (por ejemplo, `2024`).
  final int? date;

  /// El estado de consumo o propiedad definido por el usuario
  /// (por ejemplo, `"Completado"`, `"Viendo"`).
  final String? status;

  /// La ruta del sistema de archivos local a la imagen de portada del elemento, o `null` si no hay ninguna.
  final String? imagePath;

  /// La puntuación personal del usuario para este elemento, en la escala definida por el
  /// `ratingScale` de la biblioteca padre.
  final double? score;

  /// La etiqueta de género o categoría para este elemento.
  final String? genre;

  /// La fecha en la que el usuario comenzó a consumir este elemento, como una marca de tiempo
  /// Unix en milisegundos.
  final int? startDate;

  /// La fecha en la que el usuario terminó de consumir este elemento, como una marca de tiempo
  /// Unix en milisegundos.
  final int? completionDate;

  /// La fecha en la que el usuario adquirió este elemento, como una marca de tiempo Unix
  /// en milisegundos.
  final int? acquisitionDate;

  /// El precio de compra o de mercado del elemento.
  final double? price;

  /// Una URL remota que apunta a la imagen de portada del elemento (por ejemplo, de una API
  /// de metadatos externa).
  final String? remoteImageUrl;

  /// La etiqueta para la unidad de seguimiento de progreso (por ejemplo, `"episodios"`,
  /// `"páginas"`). Se establece cuando la biblioteca padre tiene `supportsProgress` habilitado.
  final String? progressUnit;

  /// La cantidad de progreso actual del usuario, interpretada en [progressUnit].
  final int? currentProgress;

  /// La cantidad total de unidades de progreso para completar, interpretada en
  /// [progressUnit].
  final int? totalProgress;

  /// El número de temporada actual, utilizado para elementos de tipo serie.
  final int? season;

  /// El número de capítulo actual.
  final int? chapter;

  /// El número de página actual.
  final int? page;

  /// El número de volumen actual.
  final int? volume;

  /// El número total de temporadas para este elemento.
  final int? totalSeason;

  /// El número total de capítulos para este elemento.
  final int? totalChapter;

  /// El número total de páginas para este elemento.
  final int? totalPage;

  /// El número total de volúmenes para este elemento.
  final int? totalVolume;

  /// El [id] de un elemento padre cuando este elemento pertenece a una sub-colección,
  /// o `null` para elementos de nivel superior.
  final int? parentId;

  /// La valoración agregada de una fuente externa (por ejemplo, IMDb, MAL).
  final double? externalRating;

  /// El nombre de la fuente de valoración externa (por ejemplo, `"IMDb"`, `"MyAnimeList"`).
  final String? ratingSource;

  /// El desplazamiento de alineación horizontal para posicionar la imagen de portada dentro
  /// del widget de tarjeta, que va desde `-1.0` (izquierda) a `1.0` (derecha).
  final double? imageAlignmentX;

  /// El desplazamiento de alineación vertical para posicionar la imagen de portada dentro
  /// del widget de tarjeta, que va desde `-1.0` (superior) a `1.0` (inferior).
  final double? imageAlignmentY;

  /// Un número de catálogo o colección opcional para el elemento
  /// (por ejemplo, `"#042"`).
  final String? itemNumber;

  /// El descriptor del tipo de producto para coleccionables físicos
  /// (por ejemplo, `"Blu-ray"`, `"Tapa dura"`).
  final String? productType;

  /// La variante de edición o lanzamiento del elemento (por ejemplo, `"Edición de Coleccionista"`).
  final String? edition;

  /// Indica si este elemento forma parte de la colección activa del usuario.
  final bool collection;

  /// Indica si este elemento está en la lista de deseos del usuario en lugar de ser de su propiedad.
  final bool wishlist;

  /// Indica si este elemento se está consumiendo actualmente / está en progreso.
  final bool current;

  const ItemModel({
    this.id,
    required this.idLibrary,
    required this.name,
    this.description,
    this.date,
    this.status,
    this.imagePath,
    this.score,
    this.genre,
    this.startDate,
    this.completionDate,
    this.acquisitionDate,
    this.price,
    this.remoteImageUrl,
    this.progressUnit,
    this.currentProgress,
    this.totalProgress,
    this.season,
    this.chapter,
    this.page,
    this.volume,
    this.totalSeason,
    this.totalChapter,
    this.totalPage,
    this.totalVolume,
    this.parentId,
    this.externalRating,
    this.ratingSource,
    this.imageAlignmentX,
    this.imageAlignmentY,
    this.itemNumber,
    this.productType,
    this.edition,
    this.collection = false,
    this.wishlist = false,
    this.current = false,
  });

  /// Crea un [ItemModel] a partir del mapa JSON devuelto por la API, mapeando
  /// `idItem` a [id].
  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: json['idItem'] as int?,
      idLibrary: json['idLibrary'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      date: json['date'] as int?,
      status: json['status'] as String?,
      imagePath: json['imagePath'] as String?,
      score: (json['score'] as num?)?.toDouble(),
      genre: json['genre'] as String?,
      startDate: json['startDate'] as int?,
      completionDate: json['completionDate'] as int?,
      acquisitionDate: json['acquisitionDate'] as int?,
      price: (json['price'] as num?)?.toDouble(),
      remoteImageUrl: json['remoteImageUrl'] as String?,
      progressUnit: json['progressUnit'] as String?,
      currentProgress: json['currentProgress'] as int?,
      totalProgress: json['totalProgress'] as int?,
      season: json['season'] as int?,
      chapter: json['chapter'] as int?,
      page: json['page'] as int?,
      volume: json['volume'] as int?,
      totalSeason: json['totalSeason'] as int?,
      totalChapter: json['totalChapter'] as int?,
      totalPage: json['totalPage'] as int?,
      totalVolume: json['totalVolume'] as int?,
      parentId: json['parentId'] as int?,
      externalRating: (json['externalRating'] as num?)?.toDouble(),
      ratingSource: json['ratingSource'] as String?,
      imageAlignmentX: (json['imageAlignmentX'] as num?)?.toDouble(),
      imageAlignmentY: (json['imageAlignmentY'] as num?)?.toDouble(),
      itemNumber: json['itemNumber'] as String?,
      productType: json['productType'] as String?,
      edition: json['edition'] as String?,
      collection: json['collection'] as bool? ?? false,
      wishlist: json['wishlist'] as bool? ?? false,
      current: json['current'] as bool? ?? false,
    );
  }

  /// Devuelve una copia de este [ItemModel] con los campos especificados reemplazados.
  /// Cualquier campo no suministrado conserva su valor actual.
  ItemModel copyWith({
    int? id,
    int? idLibrary,
    String? name,
    String? description,
    int? date,
    String? status,
    String? imagePath,
    double? score,
    String? genre,
    int? startDate,
    int? completionDate,
    int? acquisitionDate,
    double? price,
    String? remoteImageUrl,
    String? progressUnit,
    int? currentProgress,
    int? totalProgress,
    int? season,
    int? chapter,
    int? page,
    int? volume,
    int? totalSeason,
    int? totalChapter,
    int? totalPage,
    int? totalVolume,
    int? parentId,
    double? externalRating,
    String? ratingSource,
    double? imageAlignmentX,
    double? imageAlignmentY,
    String? itemNumber,
    String? productType,
    String? edition,
    bool? collection,
    bool? wishlist,
    bool? current,
  }) {
    return ItemModel(
      id: id ?? this.id,
      idLibrary: idLibrary ?? this.idLibrary,
      name: name ?? this.name,
      description: description ?? this.description,
      date: date ?? this.date,
      status: status ?? this.status,
      imagePath: imagePath ?? this.imagePath,
      score: score ?? this.score,
      genre: genre ?? this.genre,
      startDate: startDate ?? this.startDate,
      completionDate: completionDate ?? this.completionDate,
      acquisitionDate: acquisitionDate ?? this.acquisitionDate,
      price: price ?? this.price,
      remoteImageUrl: remoteImageUrl ?? this.remoteImageUrl,
      progressUnit: progressUnit ?? this.progressUnit,
      currentProgress: currentProgress ?? this.currentProgress,
      totalProgress: totalProgress ?? this.totalProgress,
      season: season ?? this.season,
      chapter: chapter ?? this.chapter,
      page: page ?? this.page,
      volume: volume ?? this.volume,
      totalSeason: totalSeason ?? this.totalSeason,
      totalChapter: totalChapter ?? this.totalChapter,
      totalPage: totalPage ?? this.totalPage,
      totalVolume: totalVolume ?? this.totalVolume,
      parentId: parentId ?? this.parentId,
      externalRating: externalRating ?? this.externalRating,
      ratingSource: ratingSource ?? this.ratingSource,
      imageAlignmentX: imageAlignmentX ?? this.imageAlignmentX,
      imageAlignmentY: imageAlignmentY ?? this.imageAlignmentY,
      itemNumber: itemNumber ?? this.itemNumber,
      productType: productType ?? this.productType,
      edition: edition ?? this.edition,
      collection: collection ?? this.collection,
      wishlist: wishlist ?? this.wishlist,
      current: current ?? this.current,
    );
  }

  /// Convierte este modelo a un mapa JSON adecuado para enviar a la API.
  /// Solo se incluyen en la salida los campos opcionales no nulos para evitar
  /// sobrescribir los valores existentes con nulos.
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'idLibrary': idLibrary,
      'name': name,
      'collection': collection,
      'wishlist': wishlist,
      'current': current,
    };
    if (id != null) map['idItem'] = id;
    if (description != null) map['description'] = description;
    if (date != null) map['date'] = date;
    if (status != null) map['status'] = status;
    if (imagePath != null) map['imagePath'] = imagePath;
    if (score != null) map['score'] = score;
    if (genre != null) map['genre'] = genre;
    if (startDate != null) map['startDate'] = startDate;
    if (completionDate != null) map['completionDate'] = completionDate;
    if (acquisitionDate != null) map['acquisitionDate'] = acquisitionDate;
    if (price != null) map['price'] = price;
    if (remoteImageUrl != null) map['remoteImageUrl'] = remoteImageUrl;
    if (progressUnit != null) map['progressUnit'] = progressUnit;
    if (currentProgress != null) map['currentProgress'] = currentProgress;
    if (totalProgress != null) map['totalProgress'] = totalProgress;
    if (season != null) map['season'] = season;
    if (chapter != null) map['chapter'] = chapter;
    if (page != null) map['page'] = page;
    if (volume != null) map['volume'] = volume;
    if (totalSeason != null) map['totalSeason'] = totalSeason;
    if (totalChapter != null) map['totalChapter'] = totalChapter;
    if (totalPage != null) map['totalPage'] = totalPage;
    if (totalVolume != null) map['totalVolume'] = totalVolume;
    if (parentId != null) map['parentId'] = parentId;
    if (externalRating != null) map['externalRating'] = externalRating;
    if (ratingSource != null) map['ratingSource'] = ratingSource;
    if (imageAlignmentX != null) map['imageAlignmentX'] = imageAlignmentX;
    if (imageAlignmentY != null) map['imageAlignmentY'] = imageAlignmentY;
    if (itemNumber != null) map['itemNumber'] = itemNumber;
    if (productType != null) map['productType'] = productType;
    if (edition != null) map['edition'] = edition;

    return map;
  }
}
