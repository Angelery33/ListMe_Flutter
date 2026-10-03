/// Constantes globales de la aplicación.
class AppConstants {
  AppConstants._();

  /// Nombre visible de la aplicación, usado en títulos y encabezados.
  static const String appName = 'ListMe';

  /// Versión semántica actual de la aplicación Flutter.
  static const String appVersion = '1.0.3';

  /// Número de compilación (build number) actual.
  static const int buildNumber = 6;

  /// Cadena formateada para mostrar en la interfaz.
  static const String appVersionDisplay = 'v$appVersion+$buildNumber';

  /// URL base de la API REST de producción.
  /// En Android Emulator usar 10.0.2.2 para acceder al localhost del host.
  static const String baseUrl = 'https://api.angelcantero.store/api/v1';

  /// URL base del módulo de autenticación, derivada de [baseUrl].
  static const String authUrl = '$baseUrl/auth';
}
