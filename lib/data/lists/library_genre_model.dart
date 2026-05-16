/// Representa una etiqueta de género asociada con una biblioteca específica.
///
/// Las bibliotecas pueden tener un conjunto personalizable de etiquetas de género que los usuarios asignan a
/// los elementos. [LibraryGenreModel] almacena una de esas etiquetas, vinculada a una única
/// biblioteca a través de [libraryId].
class LibraryGenreModel {
  /// El identificador único de este registro de género, o `null` cuando aún no se ha
  /// guardado en el backend.
  final int? id;

  /// El identificador de la biblioteca a la que pertenece este género.
  final int libraryId;

  /// El nombre visible del género (por ejemplo, `"Acción"`, `"Romance"`).
  final String name;

  const LibraryGenreModel({
    this.id,
    required this.libraryId,
    required this.name,
  });

  /// Crea un [LibraryGenreModel] a partir del mapa JSON devuelto por la API.
  factory LibraryGenreModel.fromJson(Map<String, dynamic> json) {
    return LibraryGenreModel(
      id: json['id'] as int?,
      libraryId: json['libraryId'] as int,
      name: json['name'] as String,
    );
  }

  /// Convierte este modelo a un mapa JSON adecuado para enviar a la API.
  /// La clave `id` se omite cuando [id] es `null` (creación).
  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'libraryId': libraryId,
    'name': name,
  };
}
