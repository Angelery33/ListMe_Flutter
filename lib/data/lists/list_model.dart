import 'package:hive/hive.dart';

part 'list_model.g.dart';

/// Modelo de una lista de usuario.
/// 
/// Representa las listas gestionadas por el usuario en la aplicación.
@HiveType(typeId: 0)
class ListModel {
  @HiveField(0)
  final int? id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String? type;
  @HiveField(3)
  final String? description;
  @HiveField(4)
  final bool supportsCompletion;
  @HiveField(5)
  final bool supportsWishlist;
  @HiveField(6)
  final bool tracksDates;
  @HiveField(7)
  final bool supportsPrice;
  @HiveField(8)
  final int? genreLayoutMode;
  @HiveField(9)
  final int? position;
  @HiveField(10)
  final bool supportsProgress;
  @HiveField(11)
  final String? progressType;
  @HiveField(12)
  final String? customProgressUnit;
  @HiveField(13)
  final String? defaultCategory;
  @HiveField(14)
  final int? ratingScale;
  @HiveField(15)
  final bool canEdit;
  @HiveField(16)
  final bool owner;
  @HiveField(17)
  final bool shared;
  @HiveField(18)
  final bool compact;
  @HiveField(19)
  final bool thematic;
  @HiveField(20)
  final bool gradeable;
  @HiveField(21)
  final String color;
  @HiveField(22)
  final String icon;
  @HiveField(23)
  final int itemCount;

  bool get isShared => shared;

  const ListModel({
    this.id,
    required this.name,
    this.type,
    this.description,
    this.supportsCompletion = false,
    this.supportsWishlist = false,
    this.tracksDates = false,
    this.supportsPrice = false,
    this.genreLayoutMode,
    this.position,
    this.supportsProgress = false,
    this.progressType,
    this.customProgressUnit,
    this.defaultCategory,
    this.ratingScale,
    this.canEdit = true,
    this.owner = true,
    this.shared = false,
    this.compact = false,
    this.thematic = false,
    this.gradeable = false,
    this.color = 'titanium',
    this.icon = 'list',
    this.itemCount = 0,
  });

  factory ListModel.fromJson(Map<String, dynamic> json) {
    return ListModel(
      id: json['idLibrary'] as int?,
      name: json['name'] as String,
      type: json['type'] as String?,
      description: json['description'] as String?,
      supportsCompletion: json['supportsCompletion'] as bool? ?? false,
      supportsWishlist: json['supportsWishlist'] as bool? ?? false,
      tracksDates: json['tracksDates'] as bool? ?? false,
      supportsPrice: json['supportsPrice'] as bool? ?? false,
      genreLayoutMode: json['genreLayoutMode'] as int?,
      position: json['position'] as int?,
      supportsProgress: json['supportsProgress'] as bool? ?? false,
      progressType: json['progressType'] as String?,
      customProgressUnit: json['customProgressUnit'] as String?,
      defaultCategory: json['defaultCategory'] as String?,
      ratingScale: json['ratingScale'] as int?,
      canEdit: json['canEdit'] as bool? ?? true,
      owner: json['owner'] as bool? ?? true,
      shared: json['shared'] as bool? ?? false,
      compact: json['compact'] as bool? ?? false,
      thematic: json['thematic'] as bool? ?? false,
      gradeable: json['gradeable'] as bool? ?? false,
      color: json['color'] as String? ?? 'titanium',
      icon: json['icon'] as String? ?? 'list',
      itemCount: (json['itemCount'] != null) 
          ? json['itemCount'] as int 
          : (json['itemsCount'] != null) 
              ? json['itemsCount'] as int 
              : 0,
    );
  }
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'name': name,
      'supportsCompletion': supportsCompletion,
      'supportsWishlist': supportsWishlist,
      'tracksDates': tracksDates,
      'supportsPrice': supportsPrice,
      'supportsProgress': supportsProgress,
      'canEdit': canEdit,
      'owner': owner,
      'shared': shared,
      'compact': compact,
      'thematic': thematic,
      'gradeable': gradeable,
      'color': color,
      'icon': icon,
    };
    if (id != null) map['idLibrary'] = id;
    if (type != null) map['type'] = type;
    if (description != null) map['description'] = description;
    if (genreLayoutMode != null) map['genreLayoutMode'] = genreLayoutMode;
    if (position != null) map['position'] = position;
    if (progressType != null) map['progressType'] = progressType;
    if (customProgressUnit != null) map['customProgressUnit'] = customProgressUnit;
    if (defaultCategory != null) map['defaultCategory'] = defaultCategory;
    if (ratingScale != null) map['ratingScale'] = ratingScale;
    
    return map;
  }

  ListModel copyWith({
    int? id,
    String? name,
    String? type,
    String? description,
    bool? supportsCompletion,
    bool? supportsWishlist,
    bool? tracksDates,
    bool? supportsPrice,
    int? genreLayoutMode,
    int? position,
    bool? supportsProgress,
    String? progressType,
    String? customProgressUnit,
    String? defaultCategory,
    int? ratingScale,
    bool? canEdit,
    bool? owner,
    bool? shared,
    bool? compact,
    bool? thematic,
    bool? gradeable,
    String? color,
    String? icon,
    int? itemCount,
  }) {
    return ListModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      supportsCompletion: supportsCompletion ?? this.supportsCompletion,
      supportsWishlist: supportsWishlist ?? this.supportsWishlist,
      tracksDates: tracksDates ?? this.tracksDates,
      supportsPrice: supportsPrice ?? this.supportsPrice,
      genreLayoutMode: genreLayoutMode ?? this.genreLayoutMode,
      position: position ?? this.position,
      supportsProgress: supportsProgress ?? this.supportsProgress,
      progressType: progressType ?? this.progressType,
      customProgressUnit: customProgressUnit ?? this.customProgressUnit,
      defaultCategory: defaultCategory ?? this.defaultCategory,
      ratingScale: ratingScale ?? this.ratingScale,
      canEdit: canEdit ?? this.canEdit,
      owner: owner ?? this.owner,
      shared: shared ?? this.shared,
      compact: compact ?? this.compact,
      thematic: thematic ?? this.thematic,
      gradeable: gradeable ?? this.gradeable,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      itemCount: itemCount ?? this.itemCount,
    );
  }
}
