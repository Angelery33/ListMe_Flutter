import 'package:flutter/material.dart';
import '../../data/invitations/invitation_model.dart';
import '../../data/invitations/invitations_repository.dart';

/// Proveedor que gestiona las invitaciones de colaboración del usuario actual.
///
/// Carga las invitaciones pendientes del servidor con una caché de corta duración
/// ([_staleDuration]) para evitar llamadas de red redundantes en cada reconstrucción.
/// Expone operaciones de aceptar/rechazar/enviar que actualizan el estado local de forma optimista.
class InvitationsProvider extends ChangeNotifier {
  final InvitationsRepository _repository;

  /// Invitaciones pendientes cargadas actualmente.
  List<InvitationModel> _pendingInvitations = [];

  /// Indica si una operación asíncrona está en curso.
  bool _isLoading = false;

  /// Marca de tiempo de la carga exitosa más reciente, usada para determinar la obsolescencia.
  DateTime? _lastLoaded;

  /// Último mensaje de error, o `null` cuando la última operación fue exitosa.
  String? _error;

  /// Tiempo durante el cual las invitaciones en caché permanecen válidas antes de requerir una recarga.
  static const _staleDuration = Duration(minutes: 2);

  /// Crea un [InvitationsProvider] respaldado por [_repository].
  InvitationsProvider(this._repository);

  /// La lista de invitaciones que aún están esperando respuesta.
  List<InvitationModel> get pendingInvitations => _pendingInvitations;

  /// El número de invitaciones pendientes, útil para mostrar insignias.
  int get pendingCount => _pendingInvitations.length;

  /// Indica si una operación asíncrona está en ejecución actualmente.
  bool get isLoading => _isLoading;

  /// La descripción del error más reciente, o `null` si no ocurrió ningún error.
  String? get error => _error;

  /// Devuelve `true` cuando los datos en caché son más antiguos que [_staleDuration] o
  /// nunca se han cargado, indicando que se necesita una nueva solicitud.
  bool get isStale =>
      _lastLoaded == null ||
      DateTime.now().difference(_lastLoaded!) > _staleDuration;

  /// Obtiene las invitaciones pendientes del servidor y reemplaza la caché local.
  ///
  /// Establece [isLoading] mientras la solicitud está en curso y actualiza [error]
  /// si la solicitud falla.
  Future<void> loadPendingInvitations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _pendingInvitations = await _repository.getPendingInvitations();
      _lastLoaded = DateTime.now();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Envía una invitación para [libraryId] al usuario identificado por [username].
  ///
  /// Si [readOnly] es `true`, el invitado solo podrá ver la lista.
  /// Devuelve `true` en caso de éxito o `false` y establece [error] en caso de fallo.
  Future<bool> sendInvitation(int libraryId, String username, bool readOnly) async {
    try {
      await _repository.sendInvitation(libraryId, username, readOnly);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Acepta la invitación con el [id] dado y la elimina de la lista
  /// pendiente para que la UI se actualice de inmediato.
  ///
  /// Devuelve `true` en caso de éxito o `false` y establece [error] en caso de fallo.
  Future<bool> acceptInvitation(int id) async {
    try {
      await _repository.acceptInvitation(id);
      _pendingInvitations.removeWhere((i) => i.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Rechaza la invitación con el [id] dado y la elimina de la lista
  /// pendiente para que la UI se actualice de inmediato.
  ///
  /// Devuelve `true` en caso de éxito o `false` y establece [error] en caso de fallo.
  Future<bool> rejectInvitation(int id) async {
    try {
      await _repository.rejectInvitation(id);
      _pendingInvitations.removeWhere((i) => i.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
