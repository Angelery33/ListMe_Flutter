/// Estados posibles de una solicitud de amistad.
enum FriendshipStatus { pending, accepted, rejected }

/// Modelo que representa una solicitud de amistad entre dos usuarios.
///
/// Se utiliza para mostrar las solicitudes entrantes pendientes en la pantalla de
/// solicitudes de amistad, permitiendo al usuario aceptarlas o rechazarlas.
class FriendshipRequestModel {
  /// Identificador único de la solicitud en el backend.
  final int id;

  /// Nombre de usuario del remitente de la solicitud.
  final String senderUsername;

  /// URL de la foto de perfil del remitente, o `null` si no tiene.
  final String? senderPhotoUrl;

  /// Nombre de usuario del destinatario de la solicitud.
  final String receiverUsername;

  /// URL de la foto de perfil del destinatario, o `null` si no tiene.
  final String? receiverPhotoUrl;

  /// Estado actual de la solicitud.
  final FriendshipStatus status;

  /// Fecha y hora en que se envió la solicitud.
  final DateTime createdAt;

  const FriendshipRequestModel({
    required this.id,
    required this.senderUsername,
    this.senderPhotoUrl,
    required this.receiverUsername,
    this.receiverPhotoUrl,
    required this.status,
    required this.createdAt,
  });

  /// Crea un [FriendshipRequestModel] a partir del mapa JSON devuelto por la API.
  factory FriendshipRequestModel.fromJson(Map<String, dynamic> json) {
    return FriendshipRequestModel(
      id: json['id'] as int,
      senderUsername: json['senderUsername'] as String,
      senderPhotoUrl: json['senderPhotoUrl'] as String?,
      receiverUsername: json['receiverUsername'] as String,
      receiverPhotoUrl: json['receiverPhotoUrl'] as String?,
      status: _parseStatus(json['status'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  static FriendshipStatus _parseStatus(String raw) {
    switch (raw.toUpperCase()) {
      case 'ACCEPTED':
        return FriendshipStatus.accepted;
      case 'REJECTED':
        return FriendshipStatus.rejected;
      default:
        return FriendshipStatus.pending;
    }
  }
}
