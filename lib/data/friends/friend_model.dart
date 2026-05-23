/// Modelo que representa un amigo del usuario autenticado junto con sus estadísticas de uso.
///
/// Se utiliza en la pantalla social para mostrar una tarjeta de resumen por cada amigo:
/// avatar, nombre de usuario, número de listas y número de ítems.
class FriendModel {
  /// Identificador único del amigo en el backend.
  final int id;

  /// Nombre de usuario del amigo.
  final String username;

  /// URL de la foto de perfil almacenada en Firebase Storage, o `null` si no tiene.
  final String? photoUrl;

  /// Número total de bibliotecas (listas) que posee el amigo.
  final int totalLibraries;

  /// Número total de ítems registrados en todas las bibliotecas del amigo.
  final int totalItems;

  const FriendModel({
    required this.id,
    required this.username,
    this.photoUrl,
    required this.totalLibraries,
    required this.totalItems,
  });

  /// Crea un [FriendModel] a partir del mapa JSON devuelto por la API.
  factory FriendModel.fromJson(Map<String, dynamic> json) {
    return FriendModel(
      id: json['id'] as int,
      username: json['username'] as String,
      photoUrl: json['photoUrl'] as String?,
      totalLibraries: (json['totalLibraries'] as num).toInt(),
      totalItems: (json['totalItems'] as num).toInt(),
    );
  }
}
