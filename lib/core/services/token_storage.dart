import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Clase de utilidad para persistir y recuperar tokens JWT en el almacén de claves seguro
/// del dispositivo a través de [FlutterSecureStorage].
///
/// Todos los métodos son estáticos para que los llamadores no necesiten mantener una instancia.
class TokenStorage {
  static const _storage = FlutterSecureStorage();

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  /// Persiste tanto el [accessToken] como el [refreshToken] en el almacenamiento seguro,
  /// sobrescribiendo cualquier valor almacenado previamente.
  ///
  /// [accessToken] JWT de corta duración utilizado para autenticar solicitudes a la API.
  /// [refreshToken] Token de larga duración utilizado para obtener un nuevo token de acceso.
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  /// Devuelve el token de acceso almacenado, o `null` si no se ha guardado ninguno.
  static Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  /// Devuelve el token de refresco almacenado, o `null` si no se ha guardado ninguno.
  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  /// Elimina tanto el token de acceso como el token de refresco del almacenamiento seguro,
  /// cerrando efectivamente la sesión del usuario a nivel de token.
  static Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }
}
