/// Constantes globales de la aplicación.
class AppConstants {
  AppConstants._();

  /// Nombre visible de la aplicación, usado en títulos y encabezados.
  // Nombre de la aplicación
  static const String appName = 'ListMe';

  /// URL base de la API REST de producción.
  /// En Android Emulator usar 10.0.2.2 para acceder al localhost del host.
  static const String baseUrl = 'https://api.angelcantero.store/api/v1';

  /// URL base del módulo de autenticación, derivada de [baseUrl].
  static const String authUrl = '$baseUrl/auth';
}
