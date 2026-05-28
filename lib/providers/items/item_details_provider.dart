import 'package:flutter/material.dart';
import '../../data/items/item_model.dart';
import '../../data/items/items_repository.dart';
import '../../data/items/item_image_model.dart';
import '../../data/attributes/attribute_item_model.dart';
import '../../data/attributes/attribute_type_model.dart';
import '../../data/attributes/attributes_repository.dart';
import 'package:image_picker/image_picker.dart';

/// Proveedor que gestiona el estado de la vista de detalle para un único [ItemModel].
///
/// Carga el elemento y todas sus relaciones (imágenes, sub-elementos, atributos)
/// desde la API y expone ayudantes de mutación detallados para que las secciones de
/// detalle individuales puedan actualizar el elemento sin recargar todo.
class ItemDetailsProvider extends ChangeNotifier {
  final ItemsRepository _itemsRepository;
  final AttributesRepository _attributesRepository;

  /// El elemento mostrado actualmente, o `null` mientras se carga por primera vez.
  ItemModel? _item;

  /// Elementos de sub-colección que pertenecen a [_item] cuando es una colección.
  List<ItemModel> _subItems = [];

  /// Imágenes de la galería asociadas con [_item], ordenadas para que la favorita sea la primera.
  List<ItemImageModel> _images = [];

  /// Pares clave/valor de atributos personalizados adjuntos a [_item].
  List<AttributeItemModel> _attributes = [];

  /// Definiciones de tipos de atributos, usadas para resolver nombres en la UI.
  List<AttributeTypeModel> _attributeTypes = [];

  /// Indica si hay alguna operación asíncrona en curso actualmente.
  bool _isLoading = false;

  /// Error legible por humanos de la operación fallida más reciente, o `null`.
  String? _errorMessage;

  /// Atributos expuestos para que la UI resuelva nombres de tipos.
  List<AttributeTypeModel> get attributeTypes => _attributeTypes;

  ItemDetailsProvider(this._itemsRepository, this._attributesRepository);

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

    // Renderizado inmediato con el item inicial solo si no hay datos frescos ya cargados
    // para este item (evita parpadeo de portada al volver a la pantalla).
    if (initialItem != null && _item?.id != initialItem.id) {
      _item = initialItem;
      notifyListeners();
    }

    try {
      // 1. Recargar datos del ítem completamente
      _item = await _itemsRepository.getItemById(itemId);

      if (_item != null) {
        final results = await Future.wait([
          _itemsRepository.getItemImages(itemId),
          _attributesRepository.getItemAttributes(itemId),
          _attributesRepository.getAllAttributeTypes(),
        ]);
        _images = results[0] as List<ItemImageModel>;
        _attributes = results[1] as List<AttributeItemModel>;
        _attributeTypes = results[2] as List<AttributeTypeModel>;
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
  /// Si [total] es `null` se conserva el valor total existente.
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
  /// Valores válidos de [field]: `'chapter'`, `'page'`, `'season'`, `'volume'`.
  /// Para nombres de campo desconocidos actualiza [ItemModel.currentProgress].
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
  /// No hace nada cuando [item] es `null` o no es una colección.
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
  /// Si el endpoint de sub-colecciones falla, filtra todos los ítems de la
  /// biblioteca por [ItemModel.parentId]. Los resultados se ordenan por número
  /// de volumen primero y luego alfabéticamente por nombre.
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
  /// Los nombres de volumen se rellenan con ceros para mantener el orden alfabético y numérico
  /// sincronizados. Omite la creación silenciosamente si el ítem no tiene `totalVolume` válido.
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
    final List<String> volumeErrors = [];
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
        } catch (e) {
          volumeErrors.add('Vol. $i: $e');
        }
      }
      if (volumeErrors.isNotEmpty) {
        _errorMessage = volumeErrors.join('\n');
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
  /// Si se omite [name], el ítem toma como nombre el siguiente número de volumen
  /// seguido del nombre del padre. Devuelve el [ItemModel] creado en caso de
  /// éxito, o `null` y establece [errorMessage] en caso de fallo.
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
  /// Actualiza la lista [images] de forma optimista para que la UI reordene
  /// al instante, luego sincroniza la URL remota de [item] mediante [_sortImagesAndSyncFavorite].
  /// Devuelve `true` en caso de éxito, `false` y establece [errorMessage] en caso de fallo.
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
  /// Devuelve el [ItemImageModel] creado en caso de éxito, o `null` en caso de fallo.
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
