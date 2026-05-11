import 'package:flutter/material.dart';
import '../../data/items/item_model.dart';
import '../../data/items/items_repository.dart';
import '../../data/items/item_image_model.dart';
import '../../data/attributes/attribute_item_model.dart';
import 'package:image_picker/image_picker.dart';

class ItemDetailsProvider extends ChangeNotifier {
  final ItemsRepository _itemsRepository;

  ItemModel? _item;
  List<ItemModel> _subItems = [];
  List<ItemImageModel> _images = [];
  List<AttributeItemModel> _attributes = [];
  bool _isLoading = false;
  String? _errorMessage;

  ItemDetailsProvider(this._itemsRepository);

  ItemModel? get item => _item;
  List<ItemModel> get subItems => _subItems;
  List<ItemImageModel> get images => _images;
  List<AttributeItemModel> get attributes => _attributes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Loads the item and its relationships from the API
  Future<void> loadItemDetails(int itemId, {ItemModel? initialItem}) async {
    _isLoading = true;
    _errorMessage = null;

    // Fast render with initial item if provided from the list
    if (initialItem != null) {
      _item = initialItem;
      notifyListeners();
    }

    try {
      // 1. Refresh item data completely
      _item = await _itemsRepository.getItemById(itemId);

      if (_item != null) {
        // 2. Fetch gallery
        _images = await _itemsRepository.getItemImages(itemId);

        // 3. Fetch sub-items if it's a collection
        if (_item!.collection) {
          // If the backend doesn't have a direct /items/parent/{id} endpoint yet,
          // we might just fetch library items and filter, or assume it's added.
          // For now we will await adding that endpoint, or filtering locally.
          final libraryItems = await _itemsRepository.getAllItems(
            libraryId: _item!.idLibrary,
          );
          _subItems = libraryItems
              .where((i) => i.parentId == _item!.id)
              .toList();
        }
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Updates the item via API and locally updates the state
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

  Future<void> updateScore(double newScore) async {
    if (_item != null) {
      final updatedItem = _item!.copyWith(score: newScore);
      await updateItem(updatedItem);
    }
  }

  Future<void> updateDescription(String newDescription) async {
    if (_item != null) {
      final updatedItem = _item!.copyWith(description: newDescription);
      await updateItem(updatedItem);
    }
  }

  Future<void> updateProgress(int current, int? total) async {
    if (_item != null) {
      final updatedItem = _item!.copyWith(
        currentProgress: current,
        totalProgress: total ?? _item!.totalProgress,
      );
      await updateItem(updatedItem);
    }
  }

  Future<void> incrementProgress() async {
    if (_item != null) {
      final current = _item!.currentProgress ?? 0;
      final total = _item!.totalProgress;

      if (total != null && total > 0 && current >= total) return;
      await updateProgress(current + 1, total);
    }
  }

  Future<void> decrementProgress() async {
    if (_item != null) {
      final current = _item!.currentProgress ?? 0;
      final total = _item!.totalProgress;

      if (current <= 0) return;
      await updateProgress(current - 1, total);
    }
  }

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

  Future<void> loadSubItems() async {
    if (_item != null && _item!.collection) {
      final libraryItems = await _itemsRepository.getAllItems(
        libraryId: _item!.idLibrary,
      );
      _subItems = libraryItems.where((i) => i.parentId == _item!.id).toList();
      notifyListeners();
    }
  }

  Future<bool> setFavoriteImage(int imageId) async {
    if (_item?.id == null) return false;

    try {
      await _itemsRepository.setFavoriteImage(_item!.id!, imageId);

      _images = _images.map((img) =>
        img.id == imageId
          ? img.copyWith(isFavorite: true)
          : img.copyWith(isFavorite: false)
      ).toList();

      final favImg = _images.firstWhere((img) => img.id == imageId);
      _item = _item!.copyWith(remoteImageUrl: favImg.remoteImageUrl);

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

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
