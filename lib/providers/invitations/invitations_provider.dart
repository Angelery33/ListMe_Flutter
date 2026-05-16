import 'package:flutter/material.dart';
import '../../data/invitations/invitation_model.dart';
import '../../data/invitations/invitations_repository.dart';

/// Provider that manages collaboration invitations for the current user.
///
/// Loads pending invitations from the server with a short-lived cache
/// ([_staleDuration]) to avoid redundant network calls on every rebuild.
/// Exposes accept/reject/send operations that optimistically update local state.
class InvitationsProvider extends ChangeNotifier {
  final InvitationsRepository _repository;

  /// Currently loaded pending invitations.
  List<InvitationModel> _pendingInvitations = [];

  /// Whether an async operation is currently in progress.
  bool _isLoading = false;

  /// Timestamp of the most recent successful load, used to decide staleness.
  DateTime? _lastLoaded;

  /// Last error message, or `null` when the last operation succeeded.
  String? _error;

  /// How long cached invitations remain valid before a reload is required.
  static const _staleDuration = Duration(minutes: 2);

  /// Creates an [InvitationsProvider] backed by [_repository].
  InvitationsProvider(this._repository);

  /// The list of invitations that are still awaiting a response.
  List<InvitationModel> get pendingInvitations => _pendingInvitations;

  /// The number of pending invitations, useful for badge display.
  int get pendingCount => _pendingInvitations.length;

  /// Whether an async operation is currently running.
  bool get isLoading => _isLoading;

  /// The most recent error description, or `null` if no error occurred.
  String? get error => _error;

  /// Returns `true` when cached data is older than [_staleDuration] or
  /// has never been loaded, indicating a fresh fetch is needed.
  bool get isStale =>
      _lastLoaded == null ||
      DateTime.now().difference(_lastLoaded!) > _staleDuration;

  /// Fetches pending invitations from the server and replaces the local cache.
  ///
  /// Sets [isLoading] while the request is in flight and updates [error]
  /// if the request fails.
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

  /// Sends an invitation for [libraryId] to the user identified by [username].
  ///
  /// If [readOnly] is `true` the invitee will only be able to view the list.
  /// Returns `true` on success or `false` and sets [error] on failure.
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

  /// Accepts the invitation with the given [id] and removes it from the
  /// pending list so the UI updates immediately.
  ///
  /// Returns `true` on success or `false` and sets [error] on failure.
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

  /// Rejects the invitation with the given [id] and removes it from the
  /// pending list so the UI updates immediately.
  ///
  /// Returns `true` on success or `false` and sets [error] on failure.
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
