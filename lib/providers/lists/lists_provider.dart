import 'package:flutter/material.dart';
import '../../data/lists/lists_repository.dart';
import '../../data/lists/list_model.dart';

/// Proveedor de estado para la gestión de listas del usuario.
///
/// Gestiona la carga, creación, edición, eliminación y reordenación de listas.
class ListsProvider extends ChangeNotifier {
  final ListsRepository _listsRepository;

  bool _isLoading = false;
  List<ListModel> _lists = [];
  String? _errorMessage;

  ListsProvider(this._listsRepository) {
    fetchLists();
  }

  bool get isLoading => _isLoading;
  List<ListModel> get lists => _lists;
  String? get errorMessage => _errorMessage;

  Future<void> fetchLists() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _lists = await _listsRepository.getAllLibraries();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<bool> createList(ListModel newList) async {
    try {
      final createdList = await _listsRepository.createLibrary(newList);
      _lists.add(createdList);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateList(int id, ListModel updatedList) async {
    try {
      final list = await _listsRepository.updateLibrary(id, updatedList);
      final index = _lists.indexWhere((l) => l.id == id);
      if (index != -1) {
        _lists[index] = list;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteList(int id) async {
    try {
      await _listsRepository.deleteLibrary(id);
      _lists.removeWhere((l) => l.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void reorderLists(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final ListModel item = _lists.removeAt(oldIndex);
    _lists.insert(newIndex, item);
    // TODO: Persistence of order in DB if needed (using position field)
    notifyListeners();
  }
}
