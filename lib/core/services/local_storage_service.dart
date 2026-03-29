import 'package:hive_flutter/hive_flutter.dart';
import '../../data/lists/list_model.dart';
import 'logger_service.dart';

class LocalStorageService {
  static final LocalStorageService instance = LocalStorageService._();
  final LoggerService _logger = LoggerService.instance;
  
  static const String _librariesBoxName = 'libraries';

  LocalStorageService._();

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

  Future<void> saveLibraries(List<ListModel> libraries) async {
    _logger.debug('LocalStorageService: Guardando ${libraries.length} listas en local');
    final Map<int, ListModel> map = {};
    for (var lib in libraries) {
      if (lib.id != null) map[lib.id!] = lib;
    }
    await _librariesBox.clear();
    await _librariesBox.putAll(map);
  }

  Future<void> saveLibrary(ListModel library) async {
    if (library.id == null) return;
    _logger.debug('LocalStorageService: Guardando lista ${library.id} en local');
    await _librariesBox.put(library.id!, library);
  }

  List<ListModel> getLibraries() {
    return _librariesBox.values.toList();
  }

  Future<void> deleteLibrary(int id) async {
    _logger.debug('LocalStorageService: Eliminando lista $id de local');
    await _librariesBox.delete(id);
  }

  Future<void> clearAll() async {
    await _librariesBox.clear();
  }
}
