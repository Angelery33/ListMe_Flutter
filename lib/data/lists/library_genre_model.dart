class LibraryGenreModel {
  final int? id;
  final int libraryId;
  final String name;

  const LibraryGenreModel({
    this.id,
    required this.libraryId,
    required this.name,
  });

  factory LibraryGenreModel.fromJson(Map<String, dynamic> json) {
    return LibraryGenreModel(
      id: json['id'] as int?,
      libraryId: json['libraryId'] as int,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'libraryId': libraryId,
    'name': name,
  };
}
