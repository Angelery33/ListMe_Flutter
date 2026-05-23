import 'package:hive/hive.dart';

part 'list_model.g.dart';

/// Modelo de una lista de usuario.
///
/// Representa las listas gestionadas por el usuario en la aplicación.
///
/// Un [ListModel] encapsula todos los indicadores de configuración que controlan qué
/// funciones están activas para una biblioteca: seguimiento de finalización
/// ([supportsCompletion]), soporte para lista de deseos ([supportsWishlist]), seguimiento
/// de fechas ([tracksDates]), seguimiento de precios ([supportsPrice]), seguimiento de
/// progreso ([supportsProgress]) y calificación ([gradeable]). Las preferencias de
/// visualización como [compact], [thematic], [color] e [icon] también se
/// almacenan aquí.
@HiveType(typeId: 0)
class ListModel {
  /// El identificador único de esta biblioteca, o `null` si aún no se ha guardado.
  @HiveField(0)
  final int? id;

  /// El nombre visible de la biblioteca definido por el usuario.
  @HiveField(1)
  final String name;

  /// El tipo de contenido de la biblioteca (por ejemplo, `"películas"`, `"libros"`), utilizado para
  /// determinar qué campos de metadatos y plantillas de IU se muestran.
  @HiveField(2)
  final String? type;

  /// Una descripción opcional que proporciona contexto sobre el propósito de la biblioteca.
  @HiveField(3)
  final String? description;

  /// Indica si los elementos de esta biblioteca se pueden marcar como completados.
  @HiveField(4)
  final bool supportsCompletion;

  /// Indica si esta biblioteca soporta una sección de lista de deseos para elementos que no son propiedad del usuario.
  @HiveField(5)
  final bool supportsWishlist;

  /// Indica si los elementos de esta biblioteca rastrean las fechas de inicio y finalización.
  @HiveField(6)
  final bool tracksDates;

  /// Indica si los elementos de esta biblioteca pueden almacenar un precio de compra.
  @HiveField(7)
  final bool supportsPrice;

  /// Controla cómo se disponen los géneros en la IU (por ejemplo, lista vs. cuadrícula).
  @HiveField(8)
  final int? genreLayoutMode;

  /// La posición de ordenación de esta biblioteca en la lista de bibliotecas del usuario.
  @HiveField(9)
  final int? position;

  /// Indica si los elementos de esta biblioteca soportan el seguimiento del progreso
  /// (por ejemplo, episodios vistos, páginas leídas).
  @HiveField(10)
  final bool supportsProgress;

  /// El tipo de seguimiento de progreso utilizado (por ejemplo, `"capítulos"`, `"episodios"`).
  @HiveField(11)
  final String? progressType;

  /// Una etiqueta personalizada para la unidad de progreso cuando [progressType] se establece en un
  /// valor personalizado.
  @HiveField(12)
  final String? customProgressUnit;

  /// La categoría de estado predeterminada aplicada a los elementos recién creados en esta
  /// biblioteca.
  @HiveField(13)
  final String? defaultCategory;

  /// El valor máximo de la escala de valoración del usuario para esta biblioteca
  /// (por ejemplo, `10` para una escala 0–10).
  @HiveField(14)
  final int? ratingScale;

  /// Indica si el usuario autenticado tiene derechos de edición sobre esta biblioteca. `false`
  /// cuando la biblioteca se comparte con el usuario en modo de solo lectura.
  @HiveField(15)
  final bool canEdit;

  /// Indica si el usuario autenticado es el propietario de esta biblioteca.
  @HiveField(16)
  final bool owner;

  /// Indica si esta biblioteca se ha compartido con otros usuarios.
  @HiveField(17)
  final bool shared;

  /// Indica si la biblioteca se muestra en modo compacto (lista condensada).
  @HiveField(18)
  final bool compact;

  /// Indica si la biblioteca utiliza un diseño temático (agrupado por género).
  @HiveField(19)
  final bool thematic;

  /// Indica si a los elementos de esta biblioteca se les puede dar una nota/puntuación numérica.
  @HiveField(20)
  final bool gradeable;

  /// El identificador del color de acento utilizado para la tarjeta de la biblioteca y el tinte del icono.
  @HiveField(21)
  final String color;

  /// El identificador del icono utilizado para representar visualmente esta biblioteca en la IU.
  @HiveField(22)
  final String icon;

  /// El número total de elementos almacenados actualmente en esta biblioteca, utilizado para
  /// mostrar una insignia de recuento sin una llamada a la API por separado.
  @HiveField(23)
  final int itemCount;

  /// Nombre de usuario del propietario de la biblioteca. Solo presente en listas
  /// compartidas donde el usuario autenticado es colaborador.
  @HiveField(25)
  final String? ownerUsername;

  /// La lista ordenada de valores de estado que se muestran como pestañas de filtro para esta biblioteca.
  /// Se almacena como una cadena separada por comas en la API y se divide al deserializar.
  @HiveField(24)
  final List<String>? statusOrder;

  /// Devuelve `true` si esta biblioteca se ha compartido con otros usuarios.
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
    this.statusOrder,
    this.ownerUsername,
  });

  /// Crea un [ListModel] a partir del mapa JSON devuelto por la API, mapeando
  /// `idLibrary` a [id] y dividiendo la cadena `statusOrder` separada por comas
  /// en una lista.
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
      statusOrder: (json['statusOrder'] as String?)
          ?.split(',')
          .where((s) => s.isNotEmpty)
          .toList(),
      ownerUsername: json['ownerUsername'] as String?,
    );
  }

  /// Convierte este modelo a un mapa JSON adecuado para enviar a la API.
  /// Los campos opcionales solo se incluyen cuando no son nulos; [statusOrder]
  /// se vuelve a unir en una cadena separada por comas.
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
    if (statusOrder != null && statusOrder!.isNotEmpty) {
      map['statusOrder'] = statusOrder!.join(',');
    }

    return map;
  }

  /// Devuelve una copia de este [ListModel] con los campos especificados reemplazados.
  /// Cualquier campo no suministrado conserva su valor actual.
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
    List<String>? statusOrder,
    String? ownerUsername,
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
      statusOrder: statusOrder ?? this.statusOrder,
      ownerUsername: ownerUsername ?? this.ownerUsername,
    );
  }
}
