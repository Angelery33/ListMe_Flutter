import 'package:flutter/material.dart';
import '../../data/lists/collaborator_model.dart';
import '../../data/lists/lists_repository.dart';
import '../../data/lists/list_model.dart';
import '../../data/lists/library_genre_model.dart';
import '../../data/items/items_repository.dart';
import '../../core/services/local_storage_service.dart';
import '../../core/services/logger_service.dart';
import '../../core/services/firebase_storage_service.dart';

/// Proveedor de estado para la gestión de listas del usuario.
///
/// Gestiona la carga, creación, edición, eliminación y reordenación de listas.
class ListsProvider extends ChangeNotifier {
  final ListsRepository _listsRepository;
  final ItemsRepository _itemsRepository;
  final LocalStorageService _localStorage = LocalStorageService.instance;
  final LoggerService _logger = LoggerService.instance;
  final FirebaseStorageService _firebaseStorage = FirebaseStorageService();

  /// Indica si hay una operación remota en ejecución actualmente.
  bool _isLoading = false;

  /// La lista ordenada actual de bibliotecas para el usuario autenticado.
  List<ListModel> _lists = [];

  /// Mensaje de error de la operación fallida más reciente, o `null`.
  String? _errorMessage;

  /// Crea un [ListsProvider] respaldado por [_listsRepository] e
  /// [_itemsRepository], cargando inmediatamente los datos en caché del disco y
  /// luego sincronizándolos desde el servidor.
  ListsProvider(this._listsRepository, this._itemsRepository) {
    _loadFromLocal();
    fetchLists();
  }

  /// Carga [_lists] desde el caché local de Hive para un primer renderizado instantáneo.
  void _loadFromLocal() {
    _logger.debug('ListsProvider: Cargando desde persistencia local');
    _lists = _localStorage.getLibraries();
    _lists.sort((a, b) => (a.position ?? 0).compareTo(b.position ?? 0));
    notifyListeners();
  }

  /// Indica si hay una operación remota en ejecución actualmente.
  bool get isLoading => _isLoading;

  /// La lista ordenada de bibliotecas para el usuario actual.
  List<ListModel> get lists => _lists;

  /// Mensaje de error de la última operación fallida, o `null`.
  String? get errorMessage => _errorMessage;

  /// Obtiene todas las bibliotecas del servidor y realiza una mezcla inteligente
  /// con las personalizaciones de icono/color/características almacenadas localmente para que las
  /// personalizaciones del usuario no se sobrescriban con los valores por defecto del servidor.
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

          return serverList.copyWith(
            icon: currentIcon,
            color: currentColor,
            compact: localMatch.compact,
            thematic: localMatch.thematic,
            gradeable: localMatch.gradeable,
            supportsWishlist: localMatch.supportsWishlist,
            supportsPrice: localMatch.supportsPrice,
            tracksDates: localMatch.tracksDates,
            supportsProgress: localMatch.supportsProgress,
            progressType: localMatch.progressType,
          );
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

  /// Crea [newList] en el servidor, la añade a [lists] y la persiste
  /// localmente. Devuelve `true` si tiene éxito, `false` y establece [errorMessage] en caso de
  /// fallo.
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

  /// Actualiza la biblioteca identificada por [id] con [updatedList].
  ///
  /// Guarda localmente primero (persistencia optimista), luego envía al servidor
  /// y combina la respuesta con los indicadores de características locales que el servidor puede no
  /// persistir. Devuelve `true` si tiene éxito, `false` y establece [errorMessage] en caso de
  /// fallo.
  Future<bool> updateList(int id, ListModel updatedList) async {
    try {
      // 1. Guardar preventivamente en local (Persistencia optimista del diseño)
      _localStorage.saveLibrary(updatedList);

      // 2. Intentar actualizar en servidor
      final serverResponse = await _listsRepository.updateLibrary(
        id,
        updatedList,
      );

      // 3. Mezclar respuesta del servidor con nuestra configuración local (por si el servidor no lo guarda)
      final finalLibrary = serverResponse.copyWith(
        icon: updatedList.icon,
        color: updatedList.color,
        compact: updatedList.compact,
        thematic: updatedList.thematic,
        gradeable: updatedList.gradeable,
        supportsWishlist: updatedList.supportsWishlist,
        supportsPrice: updatedList.supportsPrice,
        tracksDates: updatedList.tracksDates,
        supportsProgress: updatedList.supportsProgress,
        progressType: updatedList.progressType,
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

  /// Elimina la biblioteca identificada por [id] junto con todos sus elementos e
  /// imágenes asociadas en Firebase Storage.
  ///
  /// Elimina la biblioteca de [lists] y de la caché local si tiene éxito.
  /// Devuelve `true` si tiene éxito, `false` y establece [errorMessage] en caso de fallo.
  Future<bool> deleteList(int id) async {
    try {
      final libraryItems = await _itemsRepository.getAllItems(libraryId: id);

      for (final item in libraryItems) {
        if (item.id != null) {
          final images = await _itemsRepository.getItemImages(item.id!);
          for (final img in images) {
            if (img.imageUri?.isNotEmpty ?? false) {
              await _firebaseStorage.deleteImage(img.imageUri);
            }
          }
          if (item.imagePath?.isNotEmpty ?? false) {
            await _firebaseStorage.deleteImage(item.imagePath);
          }
          await _itemsRepository.deleteItem(item.id!);
        }
      }

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

  /// Mueve la lista en [oldIndex] a [newIndex] en el orden local, persiste
  /// el orden en Hive inmediatamente y luego sincroniza de forma asíncrona las nuevas posiciones con
  /// el servidor en segundo plano.
  void reorderLists(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) newIndex -= 1;
    final item = _lists.removeAt(oldIndex);
    _lists.insert(newIndex, item);
    _localStorage.saveLibraries(_lists);
    notifyListeners();

    // Persiste las nuevas posiciones en segundo plano
    _persistOrder();
  }

  /// Envía los valores de posición actualizados para todas las bibliotecas al servidor.
  ///
  /// Los errores de red se ignoran silenciosamente porque el orden ya está
  /// persistido localmente.
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
      // El orden ya está actualizado localmente; ignorar errores de red silenciosamente
    }
  }

  // Helpers de gestión de géneros

  /// Añade un género llamado [name] a la biblioteca identificada por [listId] y
  /// devuelve el [LibraryGenreModel] creado, o `null` en caso de fallo.
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

  /// Elimina el género identificado por [genreId] del servidor.
  ///
  /// Devuelve `true` si tiene éxito, `false` y establece [errorMessage] en caso de fallo.
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

  /// Devuelve todos los géneros asociados con la biblioteca identificada por [libraryId].
  Future<List<LibraryGenreModel>> getLibraryGenres(int libraryId) async {
    return await _listsRepository.getLibraryGenres(libraryId);
  }

  /// Crea y persiste un nuevo género llamado [name] para la biblioteca identificada
  /// por [libraryId] y devuelve el [LibraryGenreModel] resultante.
  Future<LibraryGenreModel> addLibraryGenre(int libraryId, String name) async {
    final genre = LibraryGenreModel(libraryId: libraryId, name: name);
    return await _listsRepository.addLibraryGenre(genre);
  }

  // ── Collaborator management ──────────────────────────────────────────────────

  /// Devuelve la lista de colaboradores de la biblioteca [libraryId].
  ///
  /// Lanza excepción si el servidor responde con error.
  Future<List<CollaboratorModel>> getCollaborators(int libraryId) async {
    return _listsRepository.getCollaborators(libraryId);
  }

  /// Elimina al colaborador con [userId] de la biblioteca [libraryId].
  ///
  /// Solo el propietario puede invocar esto. Devuelve `true` si tiene éxito,
  /// `false` y establece [errorMessage] en caso de fallo.
  Future<bool> removeCollaborator(int libraryId, int userId) async {
    try {
      await _listsRepository.removeCollaborator(libraryId, userId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Abandona la biblioteca compartida [libraryId].
  ///
  /// Elimina la lista de [lists] y de la caché local al completar con éxito.
  /// Devuelve `true` si tiene éxito, `false` y establece [errorMessage] en caso de fallo.
  Future<bool> leaveLibrary(int libraryId) async {
    try {
      await _listsRepository.leaveLibrary(libraryId);
      _lists.removeWhere((l) => l.id == libraryId);
      _localStorage.deleteLibrary(libraryId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
