import 'package:flutter/material.dart';
import '../../data/items/item_model.dart';
import '../../data/items/items_repository.dart';
import '../../data/items/item_image_model.dart';
import '../../data/attributes/attribute_item_model.dart';
import 'package:image_picker/image_picker.dart';

/// Proveedor que gestiona el estado de la vista de detalle para un único [ItemModel].
///
/// Carga el elemento y todas sus relaciones (imágenes, sub-elementos, atributos)
/// desde la API y expone ayudantes de mutación detallados para que las secciones de
/// detalle individuales puedan actualizar el elemento sin recargar todo.
class ItemDetailsProvider extends ChangeNotifier {
  final ItemsRepository _itemsRepository;

  /// El elemento mostrado actualmente, o `null` mientras se carga por primera vez.
  ItemModel? _item;

  /// Elementos de sub-colección que pertenecen a [_item] cuando es una colección.
  List<ItemModel> _subItems = [];

  /// Imágenes de la galería asociadas con [_item], ordenadas para que la favorita sea la primera.
  List<ItemImageModel> _images = [];

  /// Pares clave/valor de atributos personalizados adjuntos a [_item].
  List<AttributeItemModel> _attributes = [];

  /// Indica si hay alguna operación asíncrona en curso actualmente.
  bool _isLoading = false;

  /// Error legible por humanos de la operación fallida más reciente, o `null`.
  String? _errorMessage;

  /// Crea un [ItemDetailsProvider] respaldado por [_itemsRepository].
  ItemDetailsProvider(this._itemsRepository);

  /// El elemento que se muestra actualmente en la pantalla de detalle.
  ItemModel? get item => _item;

  /// Sub-elementos cuando [item] es una colección; vacío en caso contrario.
  List<ItemModel> get subItems => _subItems;

  /// Galería de imágenes ordenada; la imagen favorita siempre está en el índice 0.
  List<ItemImageModel> get images => _images;

  /// Atributos personalizados para el elemento actual.
  List<AttributeItemModel> get attributes => _attributes;

  /// Indica si hay una operación remota pendiente.
  bool get isLoading => _isLoading;

  /// Descripción del error de la última llamada fallida, o `null` si tuvo éxito.
  String? get errorMessage => _errorMessage;

  /// Carga el elemento y sus relaciones desde la API.
  Future<void> loadItemDetails(int itemId, {ItemModel? initialItem}) async {
    _isLoading = true;
    _errorMessage = null;

    // Fast render with initial item only when we don't already have fresh data
    // for this item (avoids cover flicker when navigating back to the screen).
    if (initialItem != null && _item?.id != initialItem.id) {
      _item = initialItem;
      notifyListeners();
    }

    try {
      // 1. Refresh item data completely
      _item = await _itemsRepository.getItemById(itemId);

      if (_item != null) {
        _images = await _itemsRepository.getItemImages(itemId);
        _sortImagesAndSyncFavorite();

        if (_item!.collection) {
          await _fetchSubItems();
        }
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Actualiza el elemento a través de la API y actualiza el estado localmente.
  Future<bool> updateItem(ItemModel updatedItem) async {
    if (updatedItem.id == null) return false;

    try {
      final result = await _itemsRepository.updateItem(
        updatedItem.id!,
        updatedItem,
      );
      _item = result;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Actualiza la puntuación del elemento a [newScore] y guarda el cambio a través de la API.
  Future<void> updateScore(double newScore) async {
    if (_item != null) {
      final updatedItem = _item!.copyWith(score: newScore);
      await updateItem(updatedItem);
    }
  }

  /// Actualiza la descripción del elemento a [newDescription] y guarda el cambio.
  Future<void> updateDescription(String newDescription) async {
    if (_item != null) {
      final updatedItem = _item!.copyWith(description: newDescription);
      await updateItem(updatedItem);
    }
  }

  /// Actualiza los campos de progreso a [current] y [total] y guarda el cambio.
  ///
  /// If [total] is `null` the existing total value is preserved.
  Future<void> updateProgress(int current, int? total) async {
    if (_item != null) {
      final updatedItem = _item!.copyWith(
        currentProgress: current,
        totalProgress: total ?? _item!.totalProgress,
      );
      await updateItem(updatedItem);
    }
  }

  /// Incrementa el progreso actual en 1, limitado a [ItemModel.totalProgress]
  /// cuando se define un total para que nunca supere el 100 %.
  Future<void> incrementProgress() async {
    if (_item != null) {
      final current = _item!.currentProgress ?? 0;
      final total = _item!.totalProgress;

      if (total != null && total > 0 && current >= total) return;
      await updateProgress(current + 1, total);
    }
  }

  /// Decrementa el progreso actual en 1, con un mínimo de 0.
  Future<void> decrementProgress() async {
    if (_item != null) {
      final current = _item!.currentProgress ?? 0;
      final total = _item!.totalProgress;

      if (current <= 0) return;
      await updateProgress(current - 1, total);
    }
  }

  /// Actualiza un [field] de progreso con nombre específico a [value] y guarda el cambio.
  ///
  /// Supported [field] values: `'chapter'`, `'page'`, `'season'`, `'volume'`.
  /// Falls back to updating [ItemModel.currentProgress] for unknown field names.
  Future<void> updateProgressField(String field, int value) async {
    if (_item != null) {
      ItemModel updatedItem;
      switch (field) {
        case 'chapter':
          updatedItem = _item!.copyWith(chapter: value);
          break;
        case 'page':
          updatedItem = _item!.copyWith(page: value);
          break;
        case 'season':
          updatedItem = _item!.copyWith(season: value);
          break;
        case 'volume':
          updatedItem = _item!.copyWith(volume: value);
          break;
        default:
          updatedItem = _item!.copyWith(currentProgress: value);
      }
      await updateItem(updatedItem);
    }
  }

  /// Actualiza la lista [subItems] desde el servidor y notifica a los oyentes.
  ///
  /// No-op when [item] is `null` or is not a collection.
  Future<void> loadSubItems() async {
    if (_item != null && _item!.collection) {
      await _fetchSubItems();
      notifyListeners();
    }
  }

  /// Ordena [_images] para que la imagen favorita sea la primera y sincroniza la
  /// [ItemModel.remoteImageUrl] de [_item] con la URL de la favorita si está disponible.
  void _sortImagesAndSyncFavorite() {
    _images.sort((a, b) {
      if (a.isFavorite == b.isFavorite) return 0;
      return a.isFavorite ? -1 : 1;
    });
    final fav = _images.where((img) => img.isFavorite).firstOrNull;
    if (fav != null && fav.remoteImageUrl != null && _item != null) {
      _item = _item!.copyWith(remoteImageUrl: fav.remoteImageUrl);
    }
  }

  /// Obtiene los sub-elementos para el elemento de colección actual desde el servidor.
  ///
  /// Falls back to filtering all library items by [ItemModel.parentId] when
  /// the dedicated sub-collections endpoint throws. Results are sorted by
  /// volume number first, then alphabetically by name.
  Future<void> _fetchSubItems() async {
    if (_item?.id == null) return;
    try {
      _subItems = await _itemsRepository.getSubCollections(
        _item!.id!,
        _item!.idLibrary,
      );
    } catch (_) {
      final libraryItems = await _itemsRepository.getAllItems(
        libraryId: _item!.idLibrary,
      );
      _subItems = libraryItems.where((i) => i.parentId == _item!.id).toList();
    }
    _subItems.sort((a, b) {
      final av = a.volume ?? 0;
      final bv = b.volume ?? 0;
      if (av != bv) return av.compareTo(bv);
      return a.name.compareTo(b.name);
    });
  }

  /// Genera sub-elementos de volumen hasta [ItemModel.totalVolume] para el elemento
  /// de colección actual y devuelve el número de volúmenes creados con éxito.
  ///
  /// Volume names are zero-padded to keep alphabetical and numerical order
  /// in sync. Skips creation silently if the item has no valid `totalVolume`.
  Future<int> generateVolumes() async {
    if (_item == null ||
        _item!.id == null ||
        _item!.totalVolume == null ||
        _item!.totalVolume! <= 0) {
      return 0;
    }

    _isLoading = true;
    notifyListeners();

    int created = 0;
    try {
      final int count = _item!.totalVolume!;
      final parentId = _item!.id!;
      final libId = _item!.idLibrary;
      final padWidth = count.toString().length;

      for (int i = 1; i <= count; i++) {
        final padded = i.toString().padLeft(padWidth, '0');
        final newItem = ItemModel(
          idLibrary: libId,
          name: '$padded ${_item!.name}',
          description: _item!.description,
          status: 'PENDING',
          genre: _item!.genre,
          parentId: parentId,
          volume: i,
          totalVolume: count,
          collection: false,
          imagePath: _item!.imagePath,
          remoteImageUrl: _item!.remoteImageUrl,
        );
        try {
          await _itemsRepository.createItem(newItem);
          created++;
        } catch (_) {}
      }

      await _fetchSubItems();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return created;
  }

  /// Crea un único sub-elemento dentro de la colección actual.
  ///
  /// If [name] is omitted the item is named using the next volume number
  /// followed by the parent's name. Returns the newly created [ItemModel]
  /// on success, or `null` and sets [errorMessage] on failure.
  Future<ItemModel?> createSubItem({String? name}) async {
    if (_item?.id == null) return null;
    try {
      final nextVolume = (_subItems.map((s) => s.volume ?? 0).fold<int>(0,
              (max, v) => v > max ? v : max)) +
          1;
      final newItem = ItemModel(
        idLibrary: _item!.idLibrary,
        name: name ?? '$nextVolume ${_item!.name}',
        description: _item!.description,
        status: 'PENDING',
        genre: _item!.genre,
        parentId: _item!.id,
        volume: nextVolume,
        collection: false,
        imagePath: _item!.imagePath,
        remoteImageUrl: _item!.remoteImageUrl,
      );
      final created = await _itemsRepository.createItem(newItem);
      await _fetchSubItems();
      notifyListeners();
      return created;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Marca la imagen con [imageId] como la favorita para el elemento actual.
  ///
  /// Updates the local [images] list optimistically so the UI reorders
  /// instantly, then syncs [item]'s remote URL via [_sortImagesAndSyncFavorite].
  /// Returns `true` on success, `false` and sets [errorMessage] on failure.
  Future<bool> setFavoriteImage(int imageId) async {
    if (_item?.id == null) return false;

    try {
      await _itemsRepository.setFavoriteImage(_item!.id!, imageId);

      _images = _images
          .map((img) => img.id == imageId
              ? img.copyWith(isFavorite: true)
              : img.copyWith(isFavorite: false))
          .toList();
      _sortImagesAndSyncFavorite();

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Sube [imageFile] al servidor para el elemento actual y añade el
  /// [ItemImageModel] resultante a [images].
  ///
  /// Returns the created [ItemImageModel] on success, or `null` on failure.
  Future<ItemImageModel?> uploadImage(XFile imageFile) async {
    if (_item?.id == null) return null;

    try {
      final newImage = await _itemsRepository.uploadImage(_item!.id!, imageFile.path);
      _images.add(newImage);
      notifyListeners();
      return newImage;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }
}
