import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/items/items_repository.dart';
import '../../data/items/item_model.dart';
import '../../data/items/item_image_model.dart';
import '../../data/attributes/attribute_type_model.dart';
import '../../data/attributes/attribute_item_model.dart';
import '../../data/attributes/attributes_repository.dart';
import '../../core/utils/item_grouping_helper.dart';

/// Provider that manages the list of [ItemModel]s shown in a library screen.
///
/// Handles loading, filtering, sorting and CRUD operations for items. Keeps
/// track of the current context (library, parent collection, or remote list)
/// so that [syncItems] knows how to re-fetch after a mutation.
class ItemsProvider extends ChangeNotifier {
  final ItemsRepository _itemsRepository;
  final AttributesRepository _attributesRepository;

  /// Whether a remote operation is currently running.
  bool _isLoading = false;

  /// The current in-memory item list, always filtered to top-level items only.
  List<ItemModel> _items = [];
  List<String> _cachedGenres = [];

  void _rebuildGenres() {
    _cachedGenres = _items.map((i) => i.genre).whereType<String>().toSet().toList();
  }

  /// Error message from the most recent failed operation, or `null`.
  String? _errorMessage;

  // Filtros y Ordenación

  /// Current text used to filter items by name.
  String _searchQuery = '';

  /// Current genre filter, or `null` when no genre filter is active.
  String? _filterGenre;

  /// Current sort order applied to the item list.
  SortOption _sortOption = SortOption.dateNewest;

  // Estado actual

  /// ID of the library currently being viewed, or `null` for remote/sub views.
  int? _currentLibraryId;

  /// Parent item ID when viewing a sub-collection, otherwise `null`.
  int? _currentParentId;

  /// Remote shared-list ID when viewing a public list, otherwise `null`.
  String? _currentRemoteId;

  /// Creates an [ItemsProvider] backed by [_itemsRepository] and
  /// [_attributesRepository].
  ItemsProvider(this._itemsRepository, this._attributesRepository);

  /// Whether a remote operation is currently running.
  bool get isLoading => _isLoading;

  /// The current (possibly filtered) item list.
  List<ItemModel> get items => _items;

  /// Error from the last failed call, or `null`.
  String? get errorMessage => _errorMessage;

  /// The library ID currently loaded, or `null`.
  int? get currentLibraryId => _currentLibraryId;

  /// The parent item ID when inside a sub-collection, or `null`.
  int? get currentParentId => _currentParentId;

  /// The remote list ID when viewing a shared list, or `null`.
  String? get currentRemoteId => _currentRemoteId;

  /// Current search text used to filter results in the UI.
  String get searchQuery => _searchQuery;

  /// Active genre filter, or `null` when all genres are shown.
  String? get filterGenre => _filterGenre;

  /// Active sort option applied to the displayed item list.
  SortOption get sortOption => _sortOption;

  /// Unique, non-null genre strings extracted from the current item list.
  /// Cached and rebuilt only when [_items] is replaced.
  List<String> get availableGenres => _cachedGenres;

  /// Updates [searchQuery] to [query] and notifies listeners so the UI
  /// can re-filter the list without a server round-trip.
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Sets the active genre filter to [genre] (or clears it if `null`) and
  /// notifies listeners.
  void setFilterGenre(String? genre) {
    _filterGenre = genre;
    notifyListeners();
  }

  /// Changes the active sort [option] and notifies listeners.
  void setSortOption(SortOption option) {
    _sortOption = option;
    notifyListeners();
  }

  /// Carga items de una lista normal.
  Future<void> loadData(int libraryId) async {
    _currentLibraryId = libraryId;
    _currentParentId = null;
    _currentRemoteId = null;
    await fetchItemsByLibrary(libraryId);
  }

  /// Carga subcollections (items con parentId).
  Future<void> loadSubCollections(int parentId, int libraryId) async {
    _currentLibraryId = libraryId;
    _currentParentId = parentId;
    _currentRemoteId = null;
    await _fetchSubCollections(parentId, libraryId);
  }

  /// Carga items de lista remota compartida.
  Future<void> loadByRemoteId(String remoteId, {String? libraryName}) async {
    _currentLibraryId = null;
    _currentParentId = null;
    _currentRemoteId = remoteId;
    await _fetchByRemoteId(remoteId);
  }

  /// Fetches sub-collection items (children of [parentId]) inside [libraryId]
  /// and replaces [items], showing a loading indicator while in flight.
  Future<void> _fetchSubCollections(int parentId, int libraryId) async {
    _isLoading = true;
    _errorMessage = null;
    _items = [];
    notifyListeners();

    try {
      _items = await _itemsRepository.getSubCollections(parentId, libraryId);
      _rebuildGenres();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Fetches items from a publicly shared list identified by [remoteId].
  Future<void> _fetchByRemoteId(String remoteId) async {
    _isLoading = true;
    _errorMessage = null;
    _items = [];
    notifyListeners();

    try {
      _items = await _itemsRepository.getItemsByRemoteId(remoteId);
      _rebuildGenres();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Sincroniza items con el servidor.
  Future<void> syncItems() async {
    if (_currentLibraryId != null) {
      await fetchItemsByLibrary(_currentLibraryId!);
    }
  }

  /// Loads all top-level items for [libraryId], clearing the list first to
  /// show a clean loading state when switching between libraries.
  Future<void> fetchItemsByLibrary(int libraryId) async {
    _isLoading = true;
    _errorMessage = null;
    _items = []; // Limpia la lista (para carga inicial o cambio de lista)
    notifyListeners();

    try {
      final all = await _itemsRepository.getAllItems(libraryId: libraryId);
      // Only top-level items show in the main library list. Sub-collection
      // items (parentId != null) are reachable from their parent's detail.
      _items = all.where((i) => i.parentId == null).toList();
      _rebuildGenres();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Actualiza los items desde el servidor SIN limpiar la lista actual primero.
  /// Úsalo al volver de crear/editar un item para evitar el flash de lista vacía.
  Future<void> refreshItems(int libraryId) async {
    try {
      final all = await _itemsRepository.getAllItems(libraryId: libraryId);
      _items = all.where((i) => i.parentId == null).toList();
      _rebuildGenres();
      notifyListeners();
    } catch (_) {
      // En caso de error silencioso, mantenemos lo que tenemos
    }
  }

  /// Creates [newItem] on the server and appends it to the local list when
  /// it has no parent (i.e. it is a top-level item).
  ///
  /// Returns the created [ItemModel] on success, or `null` and sets
  /// [errorMessage] on failure.
  Future<ItemModel?> createItem(ItemModel newItem) async {
    try {
      final createdItem = await _itemsRepository.createItem(newItem);
      // Sub-collection items don't belong in the main library list.
      if (createdItem.parentId == null) {
        _items.add(createdItem);
      }
      notifyListeners();
      return createdItem;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Sends [updatedItem] to the server for item with [id] and replaces the
  /// matching entry in the local list.
  ///
  /// Returns `true` on success, `false` and sets [errorMessage] on failure.
  Future<bool> updateItem(int id, ItemModel updatedItem) async {
    try {
      final item = await _itemsRepository.updateItem(id, updatedItem);
      final index = _items.indexWhere((i) => i.id == id);
      if (index != -1) {
        _items[index] = item;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Deletes the image record identified by [imageId] from the server.
  Future<void> deleteItemImage(int imageId) async {
    await _itemsRepository.deleteItemImage(imageId);
  }

  /// Deletes the item with [id] from the server and removes it from the
  /// local list so the UI updates immediately.
  ///
  /// Returns `true` on success, `false` and sets [errorMessage] on failure.
  Future<bool> deleteItem(int id) async {
    try {
      await _itemsRepository.deleteItem(id);
      _items.removeWhere((i) => i.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Incrementa el progreso de un item en 1 unidad y actualiza la API.
  Future<void> incrementProgress(ItemModel item) async {
    if (item.id == null) return;
    final current = item.currentProgress ?? 0;
    final total = item.totalProgress;

    // No incrementar si ya se llegó al total
    if (total != null && total > 0 && current >= total) return;

    final updated = item.copyWith(currentProgress: current + 1);
    await updateItem(item.id!, updated);
  }

  /// Returns all attribute types available for the current user, fetched from
  /// [AttributesRepository].
  Future<List<AttributeTypeModel>> getAttributeTypes() async {
    return await _attributesRepository.getAllAttributeTypes();
  }

  /// Creates a new text-type attribute type with the given [name] and returns
  /// the persisted [AttributeTypeModel].
  Future<AttributeTypeModel> createAttributeType(String name) async {
    final newType = AttributeTypeModel(name: name, dataType: "TEXT");
    return await _attributesRepository.createAttributeType(newType);
  }

  /// Returns all attribute key/value pairs attached to the item identified
  /// by [itemId].
  Future<List<AttributeItemModel>> getItemAttributes(int itemId) async {
    return await _attributesRepository.getItemAttributes(itemId);
  }

  /// Persists a new [attribute] entry linking an attribute type to an item.
  Future<AttributeItemModel> addAttributeToItem(AttributeItemModel attribute) async {
    return await _attributesRepository.addAttributeToItem(attribute);
  }

  /// Returns all images stored for the item identified by [itemId].
  Future<List<ItemImageModel>> getItemImages(int itemId) async {
    return await _itemsRepository.getItemImages(itemId);
  }

  /// Returns the subset of [items] that belong to [libraryId].
  List<ItemModel> getItemsByLibrary(int libraryId) {
    return _items.where((i) => i.idLibrary == libraryId).toList();
  }

  /// Persists [image] as a new gallery entry on the server and notifies
  /// listeners. Returns the created [ItemImageModel], or `null` on failure.
  Future<ItemImageModel?> createItemImage(ItemImageModel image) async {
    try {
      final created = await _itemsRepository.createItemImage(image);
      notifyListeners();
      return created;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Marks the image with [imageId] as the favourite for item [itemId] via
  /// the server. Returns `true` on success, `false` on failure.
  Future<bool> setFavoriteImage(int itemId, int imageId) async {
    try {
      await _itemsRepository.setFavoriteImage(itemId, imageId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }

  /// Updates an item in the local cache without an API call.
  /// Used to propagate changes from ItemDetailsProvider (e.g. new favorite image).
  void updateLocalItem(ItemModel updated) {
    final idx = _items.indexWhere((i) => i.id == updated.id);
    if (idx != -1 && _items[idx].remoteImageUrl != updated.remoteImageUrl) {
      _items[idx] = _items[idx].copyWith(remoteImageUrl: updated.remoteImageUrl);
      notifyListeners();
    }
  }

  /// Updates the remote image URL of item [itemId] to [remoteUrl] both locally
  /// and on the server, keeping the cover thumbnail in sync with the gallery.
  ///
  /// Returns `true` on success, `false` and sets [errorMessage] on failure.
  Future<bool> updateItemImageUrl(int itemId, String remoteUrl) async {
    try {
      final index = _items.indexWhere((i) => i.id == itemId);
      if (index != -1) {
        final updated = _items[index].copyWith(remoteImageUrl: remoteUrl);
        await updateItem(itemId, updated);
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Uploads [imageFile] to the server for item [itemId] and returns the
  /// resulting [ItemImageModel], or `null` on failure.
  Future<ItemImageModel?> uploadImage(int itemId, XFile imageFile) async {
    try {
      final image = await _itemsRepository.uploadImageFromFile(itemId, imageFile);
      notifyListeners();
      return image;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }
}
