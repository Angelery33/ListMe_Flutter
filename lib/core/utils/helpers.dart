/// Funciones de ayuda generales de la aplicación.
/// 
/// Centraliza utilidades reutilizables (formateadores, validadores, etc.)
/// para evitar código duplicado en distintas partes de la app.
class AppHelpers {
  AppHelpers._();

  /// Valida si un correo electrónico tiene formato correcto.
  static bool isValidEmail(String email) {
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(email);
  }

  /// Valida si una contraseña cumple los requisitos mínimos (mínimo 8 caracteres).
  static bool isValidPassword(String password) {
    return password.length >= 8;
  }
}
