/// Modelo de usuario.
///
/// Debe coincidir con el Record de Java correspondiente en la API.
class UserModel {
  /// El identificador único del usuario en el backend, o `null` cuando el
  /// modelo aún no ha sido persistido.
  final int? id;

  /// El nombre de usuario único elegido por el usuario durante el registro.
  final String username;

  /// La dirección de correo electrónico asociada con la cuenta, o `null` si no se proporciona.
  final String? email;

  const UserModel({this.id, required this.username, this.email});

  /// Crea un [UserModel] a partir del mapa JSON devuelto por la API.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int?,
      username: json['username'] as String,
      email: json['email'] as String?,
    );
  }

  /// Convierte este modelo a un mapa JSON adecuado para enviar a la API.
  /// La clave `email` se omite cuando [email] es `null`.
  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    if (email != null) 'email': email,
  };

  /// Devuelve una copia de este [UserModel] con los campos indicados reemplazados.
  /// Los campos no proporcionados conservan sus valores actuales.
  UserModel copyWith({int? id, String? username, String? email}) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
    );
  }
}
