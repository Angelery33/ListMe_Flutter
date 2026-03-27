/// Constantes globales de la aplicación.
class AppConstants {
  AppConstants._();

  // Nombre de la aplicación
  static const String appName = 'ListMe';

  // API Configuration
  // Use 10.0.2.2 for Android Emulator to access host's localhost
  static const String baseUrl = 'http://192.168.1.242:8089/api/v1';

  static const String authUrl = '$baseUrl/auth';
}
