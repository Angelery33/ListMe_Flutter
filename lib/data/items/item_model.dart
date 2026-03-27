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
    if (imageAlignmentX != null) map['imageAlignmentX'] = imageAlignmentX;
    if (imageAlignmentY != null) map['imageAlignmentY'] = imageAlignmentY;
    if (itemNumber != null) map['itemNumber'] = itemNumber;
    if (productType != null) map['productType'] = productType;
    if (edition != null) map['edition'] = edition;
    
    return map;
  }
}
