import 'package:flutter/material.dart';
import 'package:list_me/data/auth/user_model.dart';
import 'package:list_me/data/profile/profile_repository.dart';
import 'package:list_me/data/system/system_repository.dart';
import 'package:list_me/data/system/user_stats_model.dart';
import 'package:list_me/core/services/logger_service.dart';

/// Proveedor que gestiona los datos del perfil del usuario actual y la información del sistema.
///
/// Carga la cuenta de usuario, las estadísticas de uso y la versión de la API en la construcción,
/// y expone helpers de mutación para cambiar el nombre de usuario o la contraseña
/// y para eliminar la cuenta.
class ProfileProvider extends ChangeNotifier {
  final ProfileRepository _profileRepository;
  final SystemRepository _systemRepository;
  final LoggerService _logger = LoggerService.instance;

  /// El usuario autenticado actualmente, o `null` mientras se carga.
  UserModel? _user;

  /// Estadísticas de uso agregadas (listas totales, elementos totales, etc.), o `null`.
  UserStatsModel? _stats;

  /// Cadena de versión de la API del backend, p.ej. `"1.4.2"`, o `null` si no está disponible.
  String? _apiVersion;

  /// Indica si una operación asíncrona está en curso.
  bool _isLoading = false;

  /// Descripción del error de la operación fallida más reciente, o `null`.
  String? _errorMessage;

  /// Crea un [ProfileProvider] respaldado por [_profileRepository] y
  /// [_systemRepository] y dispara inmediatamente [loadProfile].
  ProfileProvider(this._profileRepository, this._systemRepository) {
    loadProfile();
  }

  /// Los datos del usuario autenticado, o `null` mientras se carga el perfil.
  UserModel? get user => _user;

  /// Estadísticas agregadas del usuario actual, o `null` antes de la primera carga.
  UserStatsModel? get stats => _stats;

  /// La versión de la API del servidor, útil para diagnósticos y la pantalla de perfil.
  String? get apiVersion => _apiVersion;

  /// Indica si una operación remota está en ejecución actualmente.
  bool get isLoading => _isLoading;

  /// Error de la última llamada fallida, o `null` cuando todo está correcto.
  String? get errorMessage => _errorMessage;

  /// Obtiene el perfil de usuario, las estadísticas de uso y la versión de la API del servidor.
  ///
  /// Establece [isLoading] mientras está en curso y rellena [errorMessage] en caso de fallo.
  Future<void> loadProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _profileRepository.getCurrentUser();
      _stats = await _systemRepository.getUserStats();
      _apiVersion = await _systemRepository.getApiVersion();
      _logger.info('ProfileProvider: Perfil, estadísticas y versión cargados');
    } catch (e) {
      _errorMessage = e.toString();
      _logger.error('ProfileProvider: Error al cargar datos', e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Envía una solicitud para cambiar el nombre de usuario a [newUsername].
  ///
  /// Actualiza [user] localmente en caso de éxito. Devuelve `true` en caso de éxito, `false`
  /// y establece [errorMessage] en caso de fallo.
  Future<bool> updateUsername(String newUsername) async {
    if (_user == null) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedUser = _user!.copyWith(username: newUsername);
      _user = await _profileRepository.updateProfile(updatedUser);
      _logger.info('ProfileProvider: Username actualizado');
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error al actualizar nombre de usuario';
      _logger.error('ProfileProvider: Error al actualizar username', e);
      notifyListeners();
      return false;
    }
  }

  /// Cambia la contraseña de la cuenta de [currentPassword] a [newPassword].
  ///
  /// Devuelve `true` en caso de éxito, `false` y establece [errorMessage] (con un
  /// mensaje en español para el usuario) en caso de fallo.
  Future<bool> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _profileRepository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      _logger.info('ProfileProvider: Contraseña cambiada');
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Contraseña actual incorrecta';
      _logger.error('ProfileProvider: Error al cambiar contraseña', e);
      notifyListeners();
      return false;
    }
  }

  /// Elimina permanentemente la cuenta del usuario autenticado.
  ///
  /// El caller es responsable de cerrar la sesión del usuario y navegar fuera
  /// tras una eliminación exitosa. Devuelve `true` en caso de éxito, `false` y
  /// establece [errorMessage] en caso de fallo.
  Future<bool> deleteAccount() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _profileRepository.deleteAccount();
      _logger.info('ProfileProvider: Cuenta eliminada');
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error al eliminar cuenta';
      _logger.error('ProfileProvider: Error al eliminar cuenta', e);
      notifyListeners();
      return false;
    }
  }

  /// Limpia [errorMessage] y notifica a los listeners para que los banners de error se oculten.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
