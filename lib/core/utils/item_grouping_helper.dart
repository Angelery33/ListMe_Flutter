import '../../data/items/item_model.dart';
import '../../data/lists/list_model.dart';

/// Define las opciones de ordenación disponibles.
enum SortOption {
  dateNewest,
  dateOldest,
  nameAsc,
  nameDesc,
  scoreHighLow,
  scoreLowHigh,
}

/// Helper para gestionar la lógica de agrupación y filtrado de elementos.
class ItemGroupingHelper {
  /// Agrupa una lista de items basándose en la configuración de la biblioteca.
  /// [isSearching] indica si hay una búsqueda activa para mantener grouping.
  static Map<String, List<ItemModel>> groupItems({
    required List<ItemModel> items,
    required ListModel list,
    String? filterGenre,
    String searchQuery = '',
    SortOption sortOption = SortOption.dateNewest,
    bool isSearching = false,
  }) {
    // 1. Filtrado inicial (Búsqueda y Género)
    var filtered = items.where((item) {
      final matchesSearch =
          searchQuery.isEmpty ||
          item.name.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesGenre = filterGenre == null || item.genre == filterGenre;
      return matchesSearch && matchesGenre;
    }).toList();

    // 2. Ordenación
    _sortItems(filtered, sortOption);

    // 3. Agrupación
    Map<String, List<ItemModel>> grouped = {};

    // En modo búsqueda, mantener grouping si la lista lo soporta
    if (list.supportsCompletion) {
      _groupByStatus(filtered, grouped);
    } else if (list.supportsWishlist && !isSearching) {
      _groupByWishlist(filtered, grouped);
    } else if (list.thematic && list.genreLayoutMode == 1 && !isSearching) {
      _groupByGenre(filtered, grouped);
    } else {
      grouped['Todos'] = filtered;
    }

    return grouped;
  }

  static void _sortItems(List<ItemModel> items, SortOption option) {
    switch (option) {
      case SortOption.nameAsc:
        items.sort((a, b) => a.name.compareTo(b.name));
        break;
      case SortOption.nameDesc:
        items.sort((a, b) => b.name.compareTo(a.name));
        break;
      case SortOption.scoreHighLow:
        items.sort((a, b) => (b.score ?? 0).compareTo(a.score ?? 0));
        break;
      case SortOption.scoreLowHigh:
        items.sort((a, b) => (a.score ?? 0).compareTo(b.score ?? 0));
        break;
      case SortOption.dateNewest:
        items.sort((a, b) => (b.date ?? 0).compareTo(a.date ?? 0));
        break;
      case SortOption.dateOldest:
        items.sort((a, b) => (a.date ?? 0).compareTo(b.date ?? 0));
        break;
    }
  }

  static void _groupByStatus(
    List<ItemModel> items,
    Map<String, List<ItemModel>> grouped,
  ) {
    grouped['Pendientes'] = items.where((i) => i.status == 'PENDING').toList();
    grouped['En Progreso'] = items
        .where((i) => i.status == 'IN_PROGRESS')
        .toList();
    grouped['Completados'] = items
        .where((i) => i.status == 'COMPLETED')
        .toList();

    // Eliminar grupos vacíos
    grouped.removeWhere((key, value) => value.isEmpty);
  }

  static void _groupByWishlist(
    List<ItemModel> items,
    Map<String, List<ItemModel>> grouped,
  ) {
    grouped['Adquiridos'] = items.where((i) => !i.wishlist).toList();
    grouped['Lista de Deseos'] = items.where((i) => i.wishlist).toList();

    grouped.removeWhere((key, value) => value.isEmpty);
  }

  static void _groupByGenre(
    List<ItemModel> items,
    Map<String, List<ItemModel>> grouped,
  ) {
    for (var item in items) {
      final genre = item.genre ?? 'Otros';
      if (!grouped.containsKey(genre)) {
        grouped[genre] = [];
      }
      grouped[genre]!.add(item);
    }
  }

  /// Calcula el total acumulado de una lista de items.
  static double calculateTotal(List<ItemModel> items) {
    return items.fold(0.0, (sum, item) => sum + (item.price ?? 0.0));
  }
}
