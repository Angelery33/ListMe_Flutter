import 'package:flutter/material.dart';
import '../../data/items/items_repository.dart';
import '../../data/items/item_model.dart';

class ItemsProvider extends ChangeNotifier {
  final ItemsRepository _itemsRepository;

  bool _isLoading = false;
  List<ItemModel> _items = [];
  String? _errorMessage;

  ItemsProvider(this._itemsRepository);

  bool get isLoading => _isLoading;
  List<ItemModel> get items => _items;
  String? get errorMessage => _errorMessage;

  Future<void> fetchItemsByLibrary(int libraryId) async {
    _isLoading = true;
    _errorMessage = null;
    _items = []; // Clear current items while loading
    notifyListeners();

    try {
      _items = await _itemsRepository.getItemsByLibrary(libraryId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
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
}
