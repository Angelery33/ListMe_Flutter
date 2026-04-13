import 'package:flutter/material.dart';
import '../../data/items/items_repository.dart';
import '../../data/items/item_model.dart';
import '../../data/items/item_image_model.dart';
import '../../data/attributes/attribute_type_model.dart';
import '../../data/attributes/attribute_item_model.dart';
import '../../data/attributes/attributes_repository.dart';
import '../../core/utils/item_grouping_helper.dart';

class ItemsProvider extends ChangeNotifier {
  final ItemsRepository _itemsRepository;
  final AttributesRepository _attributesRepository;

  bool _isLoading = false;
  List<ItemModel> _items = [];
  String? _errorMessage;

  // Filtros y Ordenación
  String _searchQuery = '';
  String? _filterGenre;
  SortOption _sortOption = SortOption.dateNewest;

  // Estado actual
  int? _currentLibraryId;
  int? _currentParentId;
  String? _currentRemoteId;

  ItemsProvider(this._itemsRepository, this._attributesRepository);

  bool get isLoading => _isLoading;
  List<ItemModel> get items => _items;
  String? get errorMessage => _errorMessage;
  int? get currentLibraryId => _currentLibraryId;
  int? get currentParentId => _currentParentId;
  String? get currentRemoteId => _currentRemoteId;

  String get searchQuery => _searchQuery;
  String? get filterGenre => _filterGenre;
  SortOption get sortOption => _sortOption;

  List<String> get availableGenres =>
      _items.map((i) => i.genre).whereType<String>().toSet().toList();

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilterGenre(String? genre) {
    _filterGenre = genre;
    notifyListeners();
  }

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

  Future<void> _fetchSubCollections(int parentId, int libraryId) async {
    _isLoading = true;
    _errorMessage = null;
    _items = [];
    notifyListeners();

    try {
      _items = await _itemsRepository.getSubCollections(parentId, libraryId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> _fetchByRemoteId(String remoteId) async {
    _isLoading = true;
    _errorMessage = null;
    _items = [];
    notifyListeners();

    try {
      _items = await _itemsRepository.getItemsByRemoteId(remoteId);
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

  Future<void> fetchItemsByLibrary(int libraryId) async {
    _isLoading = true;
    _errorMessage = null;
    _items = []; // Limpia la lista (para carga inicial o cambio de lista)
    notifyListeners();

    try {
      _items = await _itemsRepository.getAllItems(libraryId: libraryId);
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
      _items = await _itemsRepository.getAllItems(libraryId: libraryId);
      notifyListeners();
    } catch (_) {
      // En caso de error silencioso, mantenemos lo que tenemos
    }
  }

  Future<bool> createItem(ItemModel newItem) async {
    try {
      final createdItem = await _itemsRepository.createItem(newItem);
      _items.add(createdItem);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

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

  Future<List<AttributeTypeModel>> getAttributeTypes() async {
    return await _attributesRepository.getAllAttributeTypes();
  }

  Future<AttributeTypeModel> createAttributeType(String name) async {
    final newType = AttributeTypeModel(name: name, dataType: "TEXT");
    return await _attributesRepository.createAttributeType(newType);
  }

  Future<List<AttributeItemModel>> getItemAttributes(int itemId) async {
    return await _attributesRepository.getItemAttributes(itemId);
  }

  Future<List<ItemImageModel>> getItemImages(int itemId) async {
    return await _itemsRepository.getItemImages(itemId);
  }

  List<ItemModel> getItemsByLibrary(int libraryId) {
    return _items.where((i) => i.idLibrary == libraryId).toList();
  }

  Future<bool> createItemImage(ItemImageModel image) async {
    try {
      await _itemsRepository.createItemImage(image);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

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
}
