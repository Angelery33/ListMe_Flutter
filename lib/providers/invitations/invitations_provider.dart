import 'package:flutter/material.dart';
import '../../data/invitations/invitation_model.dart';
import '../../data/invitations/invitations_repository.dart';

class InvitationsProvider extends ChangeNotifier {
  final InvitationsRepository _repository;

  List<InvitationModel> _pendingInvitations = [];
  bool _isLoading = false;
  DateTime? _lastLoaded;
  String? _error;

  static const _staleDuration = Duration(minutes: 2);

  InvitationsProvider(this._repository);

  List<InvitationModel> get pendingInvitations => _pendingInvitations;
  int get pendingCount => _pendingInvitations.length;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool get isStale =>
      _lastLoaded == null ||
      DateTime.now().difference(_lastLoaded!) > _staleDuration;

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
