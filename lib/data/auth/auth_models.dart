/// Encapsula las credenciales necesarias para autenticar a un usuario existente.
///
/// Se serializa a JSON y se envía al endpoint `POST /auth/login`.
class LoginRequest {
  /// El nombre de usuario de la cuenta utilizado para identificar al usuario.
  final String username;

  /// La contraseña en texto plano de la cuenta.
  /// Se transmite a través de HTTPS y nunca se almacena localmente.
  final String password;

  const LoginRequest({
    required this.username,
    required this.password,
  });

  /// Convierte esta solicitud a un mapa JSON para el endpoint de la API de inicio de sesión.
  Map<String, dynamic> toJson() => {
    'username': username,
    'password': password,
  };
}

/// Encapsula los datos necesarios para crear una nueva cuenta de usuario.
///
/// Se serializa a JSON y se envía al endpoint `POST /auth/register`.
class RegisterRequest {
  /// El nombre de usuario deseado para la nueva cuenta.
  final String username;

  /// La contraseña en texto plano elegida por el usuario.
  final String password;

  /// La dirección de correo electrónico asociada con la nueva cuenta.
  final String email;

  const RegisterRequest({
    required this.username,
    required this.password,
    required this.email,
  });

  /// Convierte esta solicitud a un mapa JSON para el endpoint de la API de registro.
  Map<String, dynamic> toJson() => {
    'username': username,
    'password': password,
    'email': email,
  };
}

/// Representa el par de tokens devueltos por la API después de un inicio de sesión exitoso.
///
/// Tanto el [accessToken] como el [refreshToken] se persisten a través de [TokenStorage] para que
/// el usuario permanezca autenticado tras los reinicios de la aplicación.
class LoginResponse {
  /// JWT de corta duración utilizado para autorizar solicitudes a la API a través del encabezado
  /// `Authorization`.
  final String accessToken;

  /// Token de larga duración utilizado para obtener un nuevo [accessToken] sin volver a introducir
  /// las credenciales.
  final String refreshToken;

  const LoginResponse({
    required this.accessToken,
    required this.refreshToken,
  });

  /// Crea una [LoginResponse] a partir del mapa JSON devuelto por el endpoint de inicio
  /// de sesión.
  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
    );
  }
}

/// Encapsula el token de refresco necesario para obtener un nuevo par de tokens de acceso.
///
/// Se serializa a JSON y se envía al endpoint de refresco de tokens cuando el token de acceso
/// actual ha expirado.
class TokenRefreshRequest {
  /// El token de refresco de larga duración emitido previamente por el servidor.
  final String refreshToken;

  const TokenRefreshRequest({
    required this.refreshToken,
  });

  /// Convierte esta solicitud a un mapa JSON para el endpoint de la API de refresco de tokens.
  Map<String, dynamic> toJson() => {
    'refreshToken': refreshToken,
  };
}
