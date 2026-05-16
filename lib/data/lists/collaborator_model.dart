/// Representa un colaborador de una biblioteca con su rol de acceso.
class CollaboratorModel {
  /// Identificador único del usuario colaborador en el sistema.
  final int userId;

  /// Nombre de usuario visible del colaborador.
  final String username;

  /// Rol dentro de la biblioteca: `'editor'` (lectura/escritura) o `'viewer'` (solo lectura).
  final String role;

  const CollaboratorModel({
    required this.userId,
    required this.username,
    required this.role,
  });

  /// Deserializa un [CollaboratorModel] desde el JSON devuelto por el backend.
  factory CollaboratorModel.fromJson(Map<String, dynamic> json) {
    return CollaboratorModel(
      userId: json['userId'] as int,
      username: json['username'] as String,
      role: json['role'] as String,
    );
  }

  /// Indica si el colaborador tiene permiso de escritura.
  bool get isEditor => role == 'editor';
}
