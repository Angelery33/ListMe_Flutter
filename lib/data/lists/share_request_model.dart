/// Encapsula los datos necesarios para compartir una biblioteca con otro usuario.
///
/// Se utiliza como el cuerpo de la solicitud para el endpoint de compartir biblioteca. [username]
/// identifica al destinatario y [readOnly] controla el nivel de acceso concedido.
class ShareRequestModel {
  /// El nombre de usuario del usuario que recibirá acceso a la biblioteca compartida.
  final String username;

  /// Indica si el destinatario recibe acceso de solo lectura (`true`, por defecto) o
  /// derechos de edición completos (`false`).
  final bool readOnly;

  const ShareRequestModel({
    required this.username,
    this.readOnly = true,
  });

  /// Convierte esta solicitud a un mapa JSON adecuado para enviar a la API.
  Map<String, dynamic> toJson() => {
    'username': username,
    'readOnly': readOnly,
  };
}
