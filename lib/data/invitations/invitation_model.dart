/// Representa una invitación para compartir una biblioteca enviada de un usuario a otro.
///
/// Se crea una invitación cuando el propietario de una biblioteca quiere compartirla
/// con otro usuario. El destinatario puede aceptar o rechazar la invitación;
/// [status] refleja el estado actual de ese ciclo de vida.
class InvitationModel {
  /// El identificador único de esta invitación en el backend.
  final int id;

  /// El nombre de usuario del usuario que envió la invitación.
  final String senderUsername;

  /// El nombre de usuario del usuario que recibió la invitación.
  final String receiverUsername;

  /// El identificador de la biblioteca que se está compartiendo.
  final int libraryId;

  /// El nombre visible de la biblioteca que se está compartiendo, almacenado aquí en caché para que la IU pueda
  /// mostrarlo sin una llamada adicional a la API.
  final String libraryName;

  /// Indica si el destinatario, si acepta, tendrá acceso de solo lectura a la
  /// biblioteca compartida (`true`) o derechos de edición completos (`false`).
  final bool readOnly;

  /// El estado actual del ciclo de vida de la invitación, normalmente uno de
  /// `"PENDING"`, `"ACCEPTED"` o `"REJECTED"`.
  final String status;

  /// La marca de tiempo UTC en la que se creó esta invitación.
  final DateTime createdAt;

  InvitationModel({
    required this.id,
    required this.senderUsername,
    required this.receiverUsername,
    required this.libraryId,
    required this.libraryName,
    required this.readOnly,
    required this.status,
    required this.createdAt,
  });

  /// Crea un [InvitationModel] a partir del mapa JSON devuelto por la API,
  /// analizando [createdAt] a partir de una cadena ISO-8601.
  factory InvitationModel.fromJson(Map<String, dynamic> json) {
    return InvitationModel(
      id: json['id'],
      senderUsername: json['senderUsername'],
      receiverUsername: json['receiverUsername'],
      libraryId: json['libraryId'],
      libraryName: json['libraryName'],
      readOnly: json['readOnly'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
