class ItemModel {
  final int? id;
  final int idLibrary;
  final String name;
  final String? description;
  final int? date;
  final String? status;
  final String? imagePath;
  final double? score;
  final String? genre;
  final int? startDate;
  final int? completionDate;
  final int? acquisitionDate;
  final double? price;
  final String? remoteImageUrl;
  final String? progressUnit;
  final int? currentProgress;
  final int? totalProgress;
  final int? season;
  final int? chapter;
  final int? page;
  final int? volume;
  final int? totalSeason;
  final int? totalChapter;
  final int? totalPage;
  final int? totalVolume;
  final int? parentId;
  final double? externalRating;
  final double? imageAlignmentX;
  final double? imageAlignmentY;
  final String? itemNumber;
  final String? productType;
  final String? edition;
  final bool collection;
  final bool wishlist;
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
    this.imageAlignmentX,
    this.imageAlignmentY,
    this.itemNumber,
    this.productType,
    this.edition,
    this.collection = false,
    this.wishlist = false,
    this.current = false,
  });

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

  Map<String, dynamic> toJson() => {
    if (id != null) 'idItem': id,
    'idLibrary': idLibrary,
    'name': name,
    'description': description,
    'date': date,
    'status': status,
    'imagePath': imagePath,
    'score': score,
    'genre': genre,
    'startDate': startDate,
    'completionDate': completionDate,
    'acquisitionDate': acquisitionDate,
    'price': price,
    'remoteImageUrl': remoteImageUrl,
    'progressUnit': progressUnit,
    'currentProgress': currentProgress,
    'totalProgress': totalProgress,
    'season': season,
    'chapter': chapter,
    'page': page,
    'volume': volume,
    'totalSeason': totalSeason,
    'totalChapter': totalChapter,
    'totalPage': totalPage,
    'totalVolume': totalVolume,
    'parentId': parentId,
    'externalRating': externalRating,
    'imageAlignmentX': imageAlignmentX,
    'imageAlignmentY': imageAlignmentY,
    'itemNumber': itemNumber,
    'productType': productType,
    'edition': edition,
    'collection': collection,
    'wishlist': wishlist,
    'current': current,
  };
}
