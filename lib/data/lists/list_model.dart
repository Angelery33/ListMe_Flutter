/// Modelo de una lista de usuario.
/// 
/// Representa las listas gestionadas por el usuario en la aplicación.
class ListModel {
  final int? id;
  final String name;
  final String? type;
  final String? description;
  final bool supportsCompletion;
  final bool supportsWishlist;
  final bool tracksDates;
  final bool supportsPrice;
  final int? genreLayoutMode;
  final int? position;
  final bool supportsProgress;
  final String? progressType;
  final String? customProgressUnit;
  final String? defaultCategory;
  final int? ratingScale;
  final bool canEdit;
  final bool owner;
  final bool shared;
  final bool compact;
  final bool thematic;
  final bool gradeable;
  final String color;
  final String icon;

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
}
