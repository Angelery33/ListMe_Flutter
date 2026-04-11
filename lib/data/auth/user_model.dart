/// Modelo de usuario.
///
/// Debe coincidir con el Record de Java correspondiente en la API.
class UserModel {
  final int? id;
  final String username;
  final String? email;

  const UserModel({this.id, required this.username, this.email});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int?,
      username: json['username'] as String,
      email: json['email'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    if (email != null) 'email': email,
  };

  UserModel copyWith({int? id, String? username, String? email}) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
    );
  }
}
