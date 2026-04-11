import 'package:flutter/material.dart';
import '../../data/lists/lists_repository.dart';
import '../../data/lists/list_model.dart';
import '../../data/lists/library_genre_model.dart';
import '../../core/services/local_storage_service.dart';
import '../../core/services/logger_service.dart';

/// Proveedor de estado para la gestión de listas del usuario.
///
/// Gestiona la carga, creación, edición, eliminación y reordenación de listas.
class ListsProvider extends ChangeNotifier {
  final ListsRepository _listsRepository;
  final LocalStorageService _localStorage = LocalStorageService.instance;
  final LoggerService _logger = LoggerService.instance;

  bool _isLoading = false;
  List<ListModel> _lists = [];
  String? _errorMessage;

  ListsProvider(this._listsRepository) {
    _loadFromLocal();
    fetchLists();
  }

  void _loadFromLocal() {
    _logger.debug('ListsProvider: Cargando desde persistencia local');
    _lists = _localStorage.getLibraries();
    _lists.sort((a, b) => (a.position ?? 0).compareTo(b.position ?? 0));
    notifyListeners();
  }

  bool get isLoading => _isLoading;
  List<ListModel> get lists => _lists;
  String? get errorMessage => _errorMessage;

  Future<void> fetchLists() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final serverLists = await _listsRepository.getAllLibraries();
      final localLibraries = _localStorage.getLibraries();

      // MEZCLA INTELIGENTE: Preservar iconos/colores locales si el servidor manda valores por defecto
      _lists = serverLists.map((serverList) {
        final localMatch = localLibraries
            .where((l) => l.id == serverList.id)
            .firstOrNull;

        if (localMatch != null) {
          // Si el servidor manda los valores por defecto, pero nosotros tenemos algo personalizado localmente, lo mantenemos.
          String currentIcon = serverList.icon;
          String currentColor = serverList.color;

          if (serverList.icon == 'list' && localMatch.icon != 'list') {
            currentIcon = localMatch.icon;
          }
          if (serverList.color == 'titanium' &&
              localMatch.color != 'titanium') {
            currentColor = localMatch.color;
          }

          return serverList.copyWith(icon: currentIcon, color: currentColor);
        }
        return serverList;
      }).toList();

      _lists.sort((a, b) => (a.position ?? 0).compareTo(b.position ?? 0));

      // Persistir lo mezclado en local
      _localStorage.saveLibraries(_lists);

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
      _localStorage.saveLibrary(createdList);
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
      // 1. Guardar preventivamente en local (Persistencia optimista del diseño)
      _localStorage.saveLibrary(updatedList);

      // 2. Intentar actualizar en servidor
      final serverResponse = await _listsRepository.updateLibrary(
        id,
        updatedList,
      );

      // 3. Mezclar respuesta del servidor con nuestro diseño local (por si el servidor no lo guarda)
      final finalLibrary = serverResponse.copyWith(
        icon: updatedList.icon,
        color: updatedList.color,
      );

      final index = _lists.indexWhere((l) => l.id == id);
      if (index != -1) {
        _lists[index] = finalLibrary;
        _localStorage.saveLibrary(finalLibrary);
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
      _localStorage.deleteLibrary(id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void reorderLists(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) newIndex -= 1;
    final item = _lists.removeAt(oldIndex);
    _lists.insert(newIndex, item);
    _localStorage.saveLibraries(_lists);
    notifyListeners();

    // Persist new positions in the background
    _persistOrder();
  }

  Future<void> _persistOrder() async {
    final items = _lists
        .asMap()
        .entries
        .where((e) => e.value.id != null)
        .map((e) => {'id': e.value.id!, 'position': e.key})
        .toList();
    try {
      await _listsRepository.reorderLibraries(items);
    } catch (_) {
      // Order is already updated locally; silently ignore network errors
    }
  }

  // Genre Management Helpers
  Future<LibraryGenreModel?> addGenreToList(int listId, String name) async {
    try {
      final newGenre = LibraryGenreModel(libraryId: listId, name: name);
      return await _listsRepository.addLibraryGenre(newGenre);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> deleteGenreFromList(int genreId) async {
    try {
      await _listsRepository.deleteLibraryGenre(genreId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<List<LibraryGenreModel>> getLibraryGenres(int libraryId) async {
    return await _listsRepository.getLibraryGenres(libraryId);
  }

  Future<LibraryGenreModel> addLibraryGenre(int libraryId, String name) async {
    final genre = LibraryGenreModel(libraryId: libraryId, name: name);
    return await _listsRepository.addLibraryGenre(genre);
  }
}
