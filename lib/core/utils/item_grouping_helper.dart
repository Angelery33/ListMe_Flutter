import 'package:flutter/widgets.dart';
import '../i18n/l10n_extension.dart';
import '../../data/items/item_model.dart';
import '../../data/lists/list_model.dart';

/// Claves de grupo estables (no visibles para el usuario). La traducción ocurre en el momento de la visualización
/// a través de `groupLabelFor(context, key)`.
const String kGroupKeyPending = '@group/pending';

/// Clave estable para el grupo "En Progreso".
const String kGroupKeyInProgress = '@group/inProgress';

/// Clave estable para el grupo "Pausado".
const String kGroupKeyPaused = '@group/paused';

/// Clave estable para el grupo "Abandonado".
const String kGroupKeyDropped = '@group/dropped';

/// Clave estable para el grupo "Completado".
const String kGroupKeyCompleted = '@group/completed';

/// Clave estable para el grupo "Adquirido" (en propiedad) usado en listas de tipo deseos.
const String kGroupKeyAcquired = '@group/acquired';

/// Clave estable para el grupo "Lista de deseos" usado en listas de tipo deseos.
const String kGroupKeyWishlist = '@group/wishlist';

/// Resuelve una clave de grupo estable en una etiqueta localizada.
/// Para claves desconocidas (ej. géneros definidos por el usuario), devuelve la clave tal cual.
///
/// [context] Se utiliza para acceder a las [AppLocalizations] actuales.
/// [key] Una constante de clave de grupo estable (ej. [kGroupKeyPending]) o una cadena
/// de género para listas temáticas.
String groupLabelFor(BuildContext context, String key) {
  final l = context.l10n;
  switch (key) {
    case kGroupKeyPending:
      return l.groupPending;
    case kGroupKeyInProgress:
      return l.groupInProgress;
    case kGroupKeyPaused:
      return l.groupPaused;
    case kGroupKeyDropped:
      return l.groupDropped;
    case kGroupKeyCompleted:
      return l.groupCompleted;
    case kGroupKeyAcquired:
      return l.groupAcquired;
    case kGroupKeyWishlist:
      return l.groupWishlist;
    default:
      return key;
  }
}

/// Criterios de ordenación disponibles para las listas de elementos.
enum SortOption {
  /// Los elementos más nuevos primero, basados en el campo de fecha del elemento.
  dateNewest,

  /// Los elementos más antiguos primero, basados en el campo de fecha del elemento.
  dateOldest,

  /// Orden alfabético ascendente por nombre.
  nameAsc,

  /// Orden alfabético descendente por nombre.
  nameDesc,

  /// Elementos con la puntuación más alta primero.
  scoreHighLow,

  /// Elementos con la puntuación más baja primero.
  scoreLowHigh,
}

/// Helper para gestionar la lógica de agrupación y filtrado de elementos.
///
/// Todos los métodos son estáticos; esta clase no está diseñada para ser instanciada.
class ItemGroupingHelper {
  /// Agrupa una lista de items basándose en la configuración de la biblioteca.
  ///
  /// El método aplica tres pasos secuenciales:
  /// 1. **Filtrar** — elimina elementos que no coinciden con [searchQuery] o [filterGenre].
  /// 2. **Ordenar** — ordena la lista filtrada según [sortOption].
  /// 3. **Agrupar** — divide los elementos en secciones con nombre cuyas claves son
  ///    constantes de clave de grupo estables (para estado/deseos) o cadenas de género (para
  ///    listas temáticas).
  ///
  /// [items] La lista completa de elementos a procesar.
  /// [list] El [ListModel] padre cuya configuración impulsa la estrategia de agrupación.
  /// [filterGenre] Cuando no es nulo, solo se incluyen los elementos con este género.
  /// [searchQuery] Filtro de subcadena que no distingue entre mayúsculas y minúsculas aplicado a los nombres de los elementos.
  /// [sortOption] Determina el orden de los elementos dentro de cada grupo.
  /// [isSearching] Cuando es `true`, se suprime la agrupación por deseos y temática para
  /// que los resultados de búsqueda aparezcan como una lista plana y sin agrupar.
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

    final hasNonDefaultStatus = filtered.any(
      (i) => i.status != null && i.status != 'PENDING',
    );

    if (list.supportsCompletion || hasNonDefaultStatus) {
      _groupByStatus(filtered, grouped, statusOrder: list.statusOrder);
    } else if (list.supportsWishlist && !isSearching) {
      _groupByWishlist(filtered, grouped);
    } else if (list.thematic && !isSearching) {
      if (list.genreLayoutMode == 1) {
        // Secciones con cabeceras de género
        _groupByGenre(filtered, grouped);
      } else if (list.genreLayoutMode == 2) {
        // Agrupado sin cabeceras: un único grupo pero ordenado por género
        filtered.sort((a, b) => (a.genre ?? '').compareTo(b.genre ?? ''));
        grouped['Todos'] = filtered;
      } else {
        grouped['Todos'] = filtered;
      }
    } else {
      grouped['Todos'] = filtered;
    }

    return grouped;
  }

  /// Agrupa elementos por género para su uso como segundo nivel dentro de una sección
  /// de estado o lista de deseos. Mantiene el orden en que aparecen los géneros.
  ///
  /// [items] Los elementos a reagrupar; ya deberían estar ordenados/filtrados.
  static Map<String, List<ItemModel>> subGroupByGenre(List<ItemModel> items) {
    final Map<String, List<ItemModel>> grouped = {};
    for (final item in items) {
      final genre = item.genre ?? 'Otros';
      grouped.putIfAbsent(genre, () => []).add(item);
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

  static const _statusToGroupKey = {
    'PENDING': kGroupKeyPending,
    'IN_PROGRESS': kGroupKeyInProgress,
    'PAUSED': kGroupKeyPaused,
    'DROPPED': kGroupKeyDropped,
    'COMPLETED': kGroupKeyCompleted,
  };

  static const _defaultStatusOrder = [
    'PENDING',
    'IN_PROGRESS',
    'PAUSED',
    'DROPPED',
    'COMPLETED',
  ];

  static void _groupByStatus(
    List<ItemModel> items,
    Map<String, List<ItemModel>> grouped, {
    List<String>? statusOrder,
  }) {
    final order =
        (statusOrder != null && statusOrder.isNotEmpty)
            ? statusOrder
            : _defaultStatusOrder;

    for (final status in order) {
      final key = _statusToGroupKey[status];
      if (key == null) continue;
      final group = items.where((i) => i.status == status).toList();
      if (group.isNotEmpty) grouped[key] = group;
    }

    // Items with statuses not in the configured order fall into their natural group
  }

  static void _groupByWishlist(
    List<ItemModel> items,
    Map<String, List<ItemModel>> grouped,
  ) {
    grouped[kGroupKeyAcquired] = items.where((i) => !i.wishlist).toList();
    grouped[kGroupKeyWishlist] = items.where((i) => i.wishlist).toList();

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

  /// Calcula el total acumulado de una lista de elementos sumando sus precios.
  ///
  /// Los elementos sin precio (`null`) se tratan como cero. Devuelve la suma como un
  /// `double`.
  ///
  /// [items] Los elementos cuyos precios deben ser sumados.
  static double calculateTotal(List<ItemModel> items) {
    return items.fold(0.0, (sum, item) => sum + (item.price ?? 0.0));
  }
}
