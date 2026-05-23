import 'package:flutter/material.dart';
import 'package:list_me/core/services/logger_service.dart';
import 'package:list_me/data/friends/friend_model.dart';
import 'package:list_me/data/friends/friends_repository.dart';
import 'package:list_me/data/friends/friendship_request_model.dart';

/// Proveedor de estado para la gestión de amistades del usuario autenticado.
///
/// Centraliza la lista de amigos con sus estadísticas, las solicitudes de amistad
/// pendientes y las operaciones de mutación (enviar, aceptar, rechazar, eliminar).
/// Notifica a los widgets suscritos tras cada cambio de estado.
class FriendsProvider extends ChangeNotifier {
  final FriendsRepository _repository;
  final LoggerService _logger = LoggerService.instance;

  /// Lista de amigos confirmados del usuario con sus estadísticas.
  List<FriendModel> _friends = [];

  /// Solicitudes de amistad pendientes recibidas por el usuario.
  List<FriendshipRequestModel> _pendingRequests = [];

  /// Indica si una operación asíncrona está en curso.
  bool _isLoading = false;

  /// Mensaje de error de la operación fallida más reciente, o `null`.
  String? _errorMessage;

  /// Crea un [FriendsProvider] respaldado por [_repository] y dispara la
  /// carga inicial de amigos y solicitudes.
  FriendsProvider(this._repository) {
    loadAll();
  }

  /// Lista de amigos confirmados con sus estadísticas.
  List<FriendModel> get friends => List.unmodifiable(_friends);

  /// Solicitudes de amistad pendientes recibidas por el usuario autenticado.
  List<FriendshipRequestModel> get pendingRequests =>
      List.unmodifiable(_pendingRequests);

  /// Número de solicitudes de amistad pendientes (usado para badges).
  int get pendingCount => _pendingRequests.length;

  /// Indica si una operación remota está en ejecución actualmente.
  bool get isLoading => _isLoading;

  /// Error de la última llamada fallida, o `null` cuando todo está correcto.
  String? get errorMessage => _errorMessage;

  /// Carga en paralelo la lista de amigos y las solicitudes pendientes.
  ///
  /// Establece [isLoading] mientras está en curso y rellena [errorMessage] en caso de fallo.
  Future<void> loadAll() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.getFriends(),
        _repository.getPendingRequests(),
      ]);
      _friends = results[0] as List<FriendModel>;
      _pendingRequests = results[1] as List<FriendshipRequestModel>;
      _logger.info('FriendsProvider: Amigos y solicitudes cargados');
    } catch (e) {
      _errorMessage = 'Error al cargar amigos';
      _logger.error('FriendsProvider: Error al cargar', e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Envía una solicitud de amistad al usuario con el nombre [username].
  ///
  /// Devuelve `true` en caso de éxito, `false` y establece [errorMessage] en caso de fallo.
  Future<bool> sendRequest(String username) async {
    try {
      await _repository.sendRequest(username);
      _logger.info('FriendsProvider: Solicitud enviada a $username');
      return true;
    } catch (e) {
      _errorMessage = _parseError(e, 'Error al enviar solicitud');
      _logger.error('FriendsProvider: Error al enviar solicitud', e);
      notifyListeners();
      return false;
    }
  }

  /// Acepta la solicitud de amistad con el identificador [id].
  ///
  /// Recarga la lista completa tras el éxito. Devuelve `true` en caso de éxito.
  Future<bool> acceptRequest(int id) async {
    try {
      await _repository.acceptRequest(id);
      _logger.info('FriendsProvider: Solicitud $id aceptada');
      await loadAll();
      return true;
    } catch (e) {
      _errorMessage = 'Error al aceptar solicitud';
      _logger.error('FriendsProvider: Error al aceptar', e);
      notifyListeners();
      return false;
    }
  }

  /// Rechaza la solicitud de amistad con el identificador [id].
  ///
  /// Elimina la solicitud de la lista local optimistamente. Devuelve `true` en caso de éxito.
  Future<bool> rejectRequest(int id) async {
    try {
      await _repository.rejectRequest(id);
      _pendingRequests.removeWhere((r) => r.id == id);
      _logger.info('FriendsProvider: Solicitud $id rechazada');
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error al rechazar solicitud';
      _logger.error('FriendsProvider: Error al rechazar', e);
      notifyListeners();
      return false;
    }
  }

  /// Elimina la amistad con el usuario cuyo nombre de usuario es [username].
  ///
  /// Elimina al amigo de la lista local optimistamente. Devuelve `true` en caso de éxito.
  Future<bool> removeFriend(String username) async {
    try {
      await _repository.removeFriend(username);
      _friends.removeWhere((f) => f.username == username);
      _logger.info('FriendsProvider: Amigo $username eliminado');
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error al eliminar amigo';
      _logger.error('FriendsProvider: Error al eliminar', e);
      notifyListeners();
      return false;
    }
  }

  /// Limpia [errorMessage] y notifica a los listeners.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Extrae el mensaje de error más útil de la excepción, con fallback a [fallback].
  String _parseError(Object e, String fallback) {
    final msg = e.toString();
    if (msg.contains('Ya existe')) return 'Ya existe una solicitud con este usuario';
    if (msg.contains('no encontrado')) return 'Usuario no encontrado';
    return fallback;
  }
}
