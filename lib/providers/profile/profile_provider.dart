import 'package:flutter/material.dart';
import 'package:list_me/data/auth/user_model.dart';
import 'package:list_me/data/profile/profile_repository.dart';
import 'package:list_me/data/system/system_repository.dart';
import 'package:list_me/data/system/user_stats_model.dart';
import 'package:list_me/core/services/logger_service.dart';

/// Provider that manages the current user's profile data and system information.
///
/// Loads the user account, usage statistics and API version on construction
/// and exposes mutation helpers for changing the username or password and for
/// deleting the account.
class ProfileProvider extends ChangeNotifier {
  final ProfileRepository _profileRepository;
  final SystemRepository _systemRepository;
  final LoggerService _logger = LoggerService.instance;

  /// The currently authenticated user, or `null` while loading.
  UserModel? _user;

  /// Aggregated usage stats (total lists, total items, etc.), or `null`.
  UserStatsModel? _stats;

  /// Backend API version string, e.g. `"1.4.2"`, or `null` if unavailable.
  String? _apiVersion;

  /// Whether an async operation is currently in progress.
  bool _isLoading = false;

  /// Error description from the most recent failed operation, or `null`.
  String? _errorMessage;

  /// Creates a [ProfileProvider] backed by [_profileRepository] and
  /// [_systemRepository] and immediately triggers [loadProfile].
  ProfileProvider(this._profileRepository, this._systemRepository) {
    loadProfile();
  }

  /// The authenticated user's data, or `null` while the profile is loading.
  UserModel? get user => _user;

  /// Aggregated statistics for the current user, or `null` before first load.
  UserStatsModel? get stats => _stats;

  /// The server's API version, useful for diagnostics and the profile screen.
  String? get apiVersion => _apiVersion;

  /// Whether a remote operation is currently running.
  bool get isLoading => _isLoading;

  /// Error from the last failed call, or `null` when everything is fine.
  String? get errorMessage => _errorMessage;

  /// Fetches the user profile, usage stats and API version from the server.
  ///
  /// Sets [isLoading] while in flight and populates [errorMessage] on failure.
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

  /// Sends a request to change the username to [newUsername].
  ///
  /// Updates [user] locally on success. Returns `true` on success, `false`
  /// and sets [errorMessage] on failure.
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

  /// Changes the account password from [currentPassword] to [newPassword].
  ///
  /// Returns `true` on success, `false` and sets [errorMessage] (with a
  /// user-friendly Spanish message) on failure.
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

  /// Permanently deletes the authenticated user's account.
  ///
  /// The caller is responsible for signing the user out and navigating away
  /// after a successful deletion. Returns `true` on success, `false` and
  /// sets [errorMessage] on failure.
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

  /// Clears [errorMessage] and notifies listeners so error banners are hidden.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
