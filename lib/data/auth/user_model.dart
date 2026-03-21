/// Modelo de usuario.
/// 
/// Debe coincidir con el Record de Java correspondiente en la API.
class UserModel {
  final int? id;
  final String username;

  const UserModel({
    this.id,
    required this.username,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int?,
      username: json['username'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
  };
}
