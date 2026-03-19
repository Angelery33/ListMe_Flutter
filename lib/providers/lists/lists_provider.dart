import 'package:flutter/material.dart';
import '../../data/lists/lists_repository.dart';
import '../../data/lists/list_model.dart';

/// Proveedor de estado para la gestión de listas del usuario.
///
/// Gestiona la carga, creación, edición, eliminación y reordenación de listas.
class ListsProvider extends ChangeNotifier {
  // ignore: unused_field
  final ListsRepository _listsRepository;

  // ignore: prefer_final_fields
  bool _isLoading = false;
  final List<ListModel> _lists = [
    const ListModel(
      id: '1',
      name: 'Compra Semanal',
      description: 'Cosas para el súper',
      color: 'amethyst',
      icon: 'shopping_cart',
      isShared: false,
      order: 0,
    ),
    const ListModel(
      id: '2',
      name: 'Series Pendientes',
      description: 'Netflix, HBO, Disney+',
      color: 'ruby',
      icon: 'tv',
      isShared: true,
      order: 1,
    ),
    const ListModel(
      id: '3',
      name: 'Libros 2024',
      description: 'Lecturas para este año',
      color: 'sapphire',
      icon: 'book',
      isShared: false,
      order: 2,
    ),
  ];
  String? _errorMessage;

  ListsProvider(this._listsRepository);

  bool get isLoading => _isLoading;
  List<ListModel> get lists => _lists;
  String? get errorMessage => _errorMessage;

  void reorderLists(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final ListModel item = _lists.removeAt(oldIndex);
    _lists.insert(newIndex, item);
    notifyListeners();
  }

  // TODO: Implementar fetchLists, createList, updateList, deleteList y reorderLists.
}
