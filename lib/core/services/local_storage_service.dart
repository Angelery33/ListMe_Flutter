import 'package:hive_flutter/hive_flutter.dart';
import '../../data/lists/list_model.dart';
import 'logger_service.dart';

/// Servicio singleton que persiste los datos de la aplicación localmente usando Hive.
///
/// Proporciona una interfaz CRUD simple para objetos [ListModel] para que la aplicación pueda
/// mostrar listas en caché cuando está fuera de línea. Debe inicializarse llamando a [init]
/// antes de que se utilice cualquier otro método (normalmente en `main.dart` antes de
/// `runApp`).
class LocalStorageService {
  /// Instancia global singleton.
  static final LocalStorageService instance = LocalStorageService._();
  final LoggerService _logger = LoggerService.instance;

  static const String _librariesBoxName = 'libraries';

  LocalStorageService._();

  /// Inicializa Hive, registra los adaptadores de modelos y abre las cajas requeridas.
  ///
  /// Debe esperarse antes de que se realice cualquier operación de lectura/escritura. Es seguro llamarlo
  /// varias veces; las llamadas posteriores son nulas porque Hive deduplica la apertura de
  /// cajas.
  Future<void> init() async {
    _logger.debug('LocalStorageService: Inicializando Hive');
    await Hive.initFlutter();

    // Registrar Adaptadores
    Hive.registerAdapter(ListModelAdapter());

    // Abrir Boxes
    await Hive.openBox<ListModel>(_librariesBoxName);
    _logger.info('LocalStorageService: Hive inicializado correctamente');
  }

  // --- Operaciones de Listas (Libraries) ---

  Box<ListModel> get _librariesBox => Hive.box<ListModel>(_librariesBoxName);

  /// Reemplaza toda la caché de bibliotecas locales con [libraries].
  ///
  /// La caja se borra primero, luego se escriben todos los elementos con un [ListModel.id] no nulo.
  /// Los elementos sin un id se omiten silenciosamente.
  ///
  /// [libraries] La lista completa y actualizada de bibliotecas a persistir.
  Future<void> saveLibraries(List<ListModel> libraries) async {
    _logger.debug('LocalStorageService: Guardando ${libraries.length} listas en local');
    final Map<int, ListModel> map = {};
    for (var lib in libraries) {
      if (lib.id != null) map[lib.id!] = lib;
    }
    await _librariesBox.clear();
    await _librariesBox.putAll(map);
  }

  /// Persiste o actualiza una sola entrada de [library] en la caché local.
  ///
  /// No hace nada si [library] tiene un id nulo. Esto evita sobrescribir la caja
  /// con un registro sin clave.
  ///
  /// [library] La biblioteca para guardar o actualizar.
  Future<void> saveLibrary(ListModel library) async {
    if (library.id == null) return;
    _logger.debug('LocalStorageService: Guardando lista ${library.id} en local');
    await _librariesBox.put(library.id!, library);
  }

  /// Devuelve todos los objetos [ListModel] almacenados localmente en caché como una lista.
  List<ListModel> getLibraries() {
    return _librariesBox.values.toList();
  }

  /// Elimina la biblioteca con el [id] dado de la caché local.
  ///
  /// [id] El identificador numérico de la biblioteca a eliminar.
  Future<void> deleteLibrary(int id) async {
    _logger.debug('LocalStorageService: Eliminando lista $id de local');
    await _librariesBox.delete(id);
  }

  /// Elimina todos los datos almacenados localmente en caché en todas las cajas.
  Future<void> clearAll() async {
    await _librariesBox.clear();
  }
}
