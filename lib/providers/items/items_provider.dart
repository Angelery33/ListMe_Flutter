import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/items/items_repository.dart';
import '../../data/items/item_model.dart';
import '../../data/items/item_image_model.dart';
import '../../data/attributes/attribute_type_model.dart';
import '../../data/attributes/attribute_item_model.dart';
import '../../data/attributes/attributes_repository.dart';
import '../../core/utils/item_grouping_helper.dart';

/// Proveedor que gestiona la lista de [ItemModel]s mostrados en la pantalla de una biblioteca.
///
/// Controla la carga, filtrado, ordenación y operaciones CRUD sobre elementos.
/// Mantiene el contexto actual (biblioteca, colección padre o lista remota)
/// para que [syncItems] sepa cómo volver a obtener datos tras una mutación.
class ItemsProvider extends ChangeNotifier {
  final ItemsRepository _itemsRepository;
  final AttributesRepository _attributesRepository;

  /// Indica si hay una operación remota en curso.
  bool _isLoading = false;

  /// Lista de elementos en memoria, siempre filtrada a elementos raíz.
  List<ItemModel> _items = [];
  List<String> _cachedGenres = [];

  void _rebuildGenres() {
    _cachedGenres = _items.map((i) => i.genre).whereType<String>().toSet().toList();
  }

  /// Mensaje de error de la última operación fallida, o `null`.
  String? _errorMessage;

  // Filtros y Ordenación

  /// Texto de búsqueda actual para filtrar elementos por nombre.
  String _searchQuery = '';

  /// Filtro de género activo, o `null` cuando no hay ninguno activo.
  String? _filterGenre;

  /// Orden de clasificación aplicado actualmente a la lista de elementos.
  SortOption _sortOption = SortOption.dateNewest;

  // Estado actual

  /// ID de la biblioteca que se está visualizando, o `null` en vistas remotas o de subcolección.
  int? _currentLibraryId;

  /// ID del elemento padre al ver una subcolección, o `null` en otro caso.
  int? _currentParentId;

  /// ID de lista compartida remota al ver una lista pública, o `null` en otro caso.
  String? _currentRemoteId;

  /// Crea un [ItemsProvider] respaldado por [_itemsRepository] y [_attributesRepository].
  ItemsProvider(this._itemsRepository, this._attributesRepository);

  /// Indica si hay una operación remota en curso.
  bool get isLoading => _isLoading;

  /// Lista de elementos actual (posiblemente filtrada).
  List<ItemModel> get items => _items;

  /// Error de la última llamada fallida, o `null`.
  String? get errorMessage => _errorMessage;

  /// ID de la biblioteca cargada actualmente, o `null`.
  int? get currentLibraryId => _currentLibraryId;

  /// ID del elemento padre al estar dentro de una subcolección, o `null`.
  int? get currentParentId => _currentParentId;

  /// ID de la lista remota al visualizar una lista compartida, o `null`.
  String? get currentRemoteId => _currentRemoteId;

  /// Texto de búsqueda actual usado para filtrar resultados en la UI.
  String get searchQuery => _searchQuery;

  /// Filtro de género activo, o `null` cuando se muestran todos los géneros.
  String? get filterGenre => _filterGenre;

  /// Opción de ordenación activa aplicada a la lista de elementos mostrada.
  SortOption get sortOption => _sortOption;

  /// Cadenas de género únicas y no nulas extraídas de la lista actual.
  /// Se cachean y reconstruyen solo cuando se reemplaza [_items].
  List<String> get availableGenres => _cachedGenres;

  /// Actualiza [searchQuery] a [query] y notifica a los listeners para que la UI
  /// pueda refiltrar la lista sin un viaje de ida y vuelta al servidor.
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Establece el filtro de género activo a [genre] (o lo borra si es `null`)
  /// y notifica a los listeners.
  void setFilterGenre(String? genre) {
    _filterGenre = genre;
    notifyListeners();
  }

  /// Cambia la opción de ordenación activa a [option] y notifica a los listeners.
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

  /// Obtiene los elementos de la subcolección (hijos de [parentId]) dentro de [libraryId]
  /// y reemplaza [items], mostrando un indicador de carga mientras está en vuelo.
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

  /// Obtiene los elementos de una lista pública compartida identificada por [remoteId].
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

  /// Carga todos los elementos raíz de [libraryId], borrando la lista primero para
  /// mostrar un estado de carga limpio al cambiar entre bibliotecas.
  Future<void> fetchItemsByLibrary(int libraryId) async {
    _isLoading = true;
    _errorMessage = null;
    _items = []; // Limpia la lista (para carga inicial o cambio de lista)
    notifyListeners();

    try {
      final all = await _itemsRepository.getAllItems(libraryId: libraryId);
      // Solo los elementos raíz aparecen en la lista principal; los subelementos
      // (parentId != null) son accesibles desde el detalle de su padre.
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

  /// Crea [newItem] en el servidor y lo añade a la lista local cuando
  /// no tiene padre (es decir, es un elemento raíz).
  ///
  /// Devuelve el [ItemModel] creado en caso de éxito, o `null` y establece
  /// [errorMessage] en caso de fallo.
  Future<ItemModel?> createItem(ItemModel newItem) async {
    try {
      final createdItem = await _itemsRepository.createItem(newItem);
      // Los subelementos no pertenecen a la lista principal de la biblioteca.
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

  /// Envía [updatedItem] al servidor para el elemento con [id] y reemplaza
  /// la entrada correspondiente en la lista local.
  ///
  /// Devuelve `true` en caso de éxito, `false` y establece [errorMessage] en caso de fallo.
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

  /// Elimina el registro de imagen identificado por [imageId] del servidor.
  Future<void> deleteItemImage(int imageId) async {
    await _itemsRepository.deleteItemImage(imageId);
  }

  /// Elimina el elemento con [id] del servidor y lo quita de la lista local
  /// para que la UI se actualice inmediatamente.
  ///
  /// Devuelve `true` en caso de éxito, `false` y establece [errorMessage] en caso de fallo.
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

  /// Devuelve todos los tipos de atributo disponibles para el usuario actual,
  /// obtenidos desde [AttributesRepository].
  Future<List<AttributeTypeModel>> getAttributeTypes() async {
    return await _attributesRepository.getAllAttributeTypes();
  }

  /// Crea un nuevo tipo de atributo de texto con el [name] dado y devuelve
  /// el [AttributeTypeModel] persistido.
  Future<AttributeTypeModel> createAttributeType(String name) async {
    final newType = AttributeTypeModel(name: name, dataType: "TEXT");
    return await _attributesRepository.createAttributeType(newType);
  }

  /// Devuelve todos los pares clave/valor de atributos asociados al elemento
  /// identificado por [itemId].
  Future<List<AttributeItemModel>> getItemAttributes(int itemId) async {
    return await _attributesRepository.getItemAttributes(itemId);
  }

  /// Persiste una nueva entrada [attribute] que vincula un tipo de atributo con un elemento.
  Future<AttributeItemModel> addAttributeToItem(AttributeItemModel attribute) async {
    return await _attributesRepository.addAttributeToItem(attribute);
  }

  /// Devuelve todas las imágenes almacenadas para el elemento identificado por [itemId].
  Future<List<ItemImageModel>> getItemImages(int itemId) async {
    return await _itemsRepository.getItemImages(itemId);
  }

  /// Devuelve el subconjunto de [items] que pertenecen a [libraryId].
  List<ItemModel> getItemsByLibrary(int libraryId) {
    return _items.where((i) => i.idLibrary == libraryId).toList();
  }

  /// Persiste [image] como una nueva entrada de galería en el servidor y notifica
  /// a los listeners. Devuelve el [ItemImageModel] creado, o `null` en caso de fallo.
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

  /// Marca la imagen con [imageId] como favorita para el elemento [itemId] en el
  /// servidor. Devuelve `true` en caso de éxito, `false` en caso de fallo.
  Future<bool> setFavoriteImage(int itemId, int imageId) async {
    try {
      await _itemsRepository.setFavoriteImage(itemId, imageId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }

  /// Actualiza un elemento en la caché local sin llamada a la API.
  /// Usado para propagar cambios desde ItemDetailsProvider (p. ej. nueva imagen favorita).
  void updateLocalItem(ItemModel updated) {
    final idx = _items.indexWhere((i) => i.id == updated.id);
    if (idx != -1 && _items[idx].remoteImageUrl != updated.remoteImageUrl) {
      _items[idx] = _items[idx].copyWith(remoteImageUrl: updated.remoteImageUrl);
      notifyListeners();
    }
  }

  /// Actualiza la URL de imagen remota del elemento [itemId] a [remoteUrl] tanto
  /// localmente como en el servidor, manteniendo la miniatura de portada sincronizada con la galería.
  ///
  /// Devuelve `true` en caso de éxito, `false` y establece [errorMessage] en caso de fallo.
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

  /// Sube [imageFile] al servidor para el elemento [itemId] y devuelve el
  /// [ItemImageModel] resultante, o `null` en caso de fallo.
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
