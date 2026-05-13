import 'package:flutter/material.dart';
import 'package:list_me/data/auth/user_model.dart';
import 'package:list_me/data/profile/profile_repository.dart';
import 'package:list_me/data/system/system_repository.dart';
import 'package:list_me/data/system/user_stats_model.dart';
import 'package:list_me/core/services/logger_service.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileRepository _profileRepository;
  final SystemRepository _systemRepository;
  final LoggerService _logger = LoggerService.instance;

  UserModel? _user;
  UserStatsModel? _stats;
  String? _apiVersion;
  bool _isLoading = false;
  String? _errorMessage;

  ProfileProvider(this._profileRepository, this._systemRepository) {
    loadProfile();
  }

  UserModel? get user => _user;
  UserStatsModel? get stats => _stats;
  String? get apiVersion => _apiVersion;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

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

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
