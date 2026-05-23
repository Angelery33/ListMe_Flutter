import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/i18n/l10n_extension.dart';
import '../../core/services/image_picker_service.dart';
import '../../data/items/item_model.dart';
import '../../data/items/item_image_model.dart';
import '../../data/lists/list_model.dart';
import '../../data/lists/library_genre_model.dart';
import '../../data/attributes/attribute_item_model.dart';
import '../../data/attributes/attribute_type_model.dart';
import '../../providers/items/items_provider.dart';
import '../../providers/lists/lists_provider.dart';
import '../../widgets/items/entry/entry_image_picker.dart';
import '../../widgets/items/entry/entry_main_info_section.dart';
import '../../widgets/items/entry/entry_status_progress_section.dart';
import '../../widgets/items/entry/entry_properties_section.dart';
import '../../widgets/items/entry/entry_dates_section.dart';
import '../../widgets/items/entry/entry_attributes_section.dart';
import '../../core/providers/responsive_provider.dart';
import '../../widgets/shared/custom_gradient_app_bar.dart';
import '../../widgets/shared/app_shell.dart';
import 'search_import/search_import_screen.dart';

/// Pantalla para crear un nuevo elemento o editar uno existente dentro de una biblioteca.
///
/// Recibe sus argumentos a través de [ModalRoute.settings]: un `Map<String, dynamic>`
/// que contiene las claves requeridas `'list'` ([ListModel]) y las opcionales `'item'`
/// ([ItemModel]) y `'parentId'` (`int`). Devuelve `true` al cerrar tras guardar.
class ItemEntryScreen extends StatefulWidget {
  const ItemEntryScreen({super.key});

  @override
  State<ItemEntryScreen> createState() => _ItemEntryScreenState();
}

/// Estado para [ItemEntryScreen].
///
/// Gestiona un gran conjunto de [TextEditingController]s para cada campo editable,
/// una galería de imágenes pendientes, colas de atributos y la lógica de guardado que
/// orquesta las llamadas a la API de creación/actualización junto con la carga de imágenes y
/// la persistencia de atributos.
class _ItemEntryScreenState extends State<ItemEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePickerService();

  /// La biblioteca a la que pertenece este elemento.
  late ListModel _list;

  /// El elemento que se está editando, o `null` cuando se crea un nuevo elemento.
  ItemModel? _item;

  /// ID del elemento padre cuando se crea un sub-elemento dentro de una colección.
  int? _parentId;

  /// Guardia para asegurar que [didChangeDependencies] solo inicialice los controladores una vez.
  bool _initialized = false;

  /// Indica si la operación de guardado se está ejecutando actualmente.
  bool _isSaving = false;

  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  late TextEditingController _itemNumberController;
  late TextEditingController _productTypeController;
  late TextEditingController _editionController;

  late TextEditingController _currentProgressController;
  late TextEditingController _totalProgressController;
  late TextEditingController _seasonController;
  late TextEditingController _totalSeasonController;
  late TextEditingController _chapterController;
  late TextEditingController _totalChapterController;
  late TextEditingController _pageController;
  late TextEditingController _totalPageController;
  late TextEditingController _volumeController;
  late TextEditingController _totalVolumeController;

  /// Código de estado del elemento, uno de los valores definidos por el backend (ej. `'PENDING'`).
  String _status = "PENDING";

  /// Indica si el elemento está marcado como actualmente en progreso.
  bool _isCurrent = false;

  /// Indica si este elemento pertenece a la lista de deseos.
  bool _wishlist = false;

  /// Indica si este elemento es una colección padre.
  bool _isCollection = false;

  /// Puntuación del usuario de 0 a la escala de calificación de la lista.
  double _score = 0;

  /// Cadena del género seleccionado, o `null` cuando no se elige ningún género.
  String? _genre;

  /// Marca de tiempo Unix (ms) para la fecha de adquisición, o `null`.
  int? _acquisitionDate;

  /// Marca de tiempo Unix (ms) para la fecha de inicio, o `null`.
  int? _startDate;

  /// Marca de tiempo Unix (ms) para la fecha de finalización, o `null`.
  int? _completionDate;

  /// URL de imagen remota importada de un resultado de búsqueda, o `null`.
  String? _importedRemoteImageUrl;

  /// Valor de calificación externa importado de un resultado de búsqueda, o `null`.
  double? _importedExternalRating;

  /// Rutas de archivos locales de las imágenes recién elegidas que aún no se han cargado.
  final List<String> _newImages = [];

  /// Objetos [XFile] para las imágenes recién elegidas, emparejados 1 a 1 con [_newImages].
  final List<XFile> _newImageFiles = [];

  /// Imágenes ya persistidas en el servidor para el elemento que se está editando.
  List<ItemImageModel> _existingImages = [];

  /// Imágenes eliminadas por el usuario que deben ser borradas del servidor al guardar.
  final List<ItemImageModel> _deletedImages = [];

  /// Índice en la lista combinada de imágenes existentes+nuevas que el usuario marcó como favorita.
  int? _favoriteImageIndex;

  /// Géneros disponibles en la biblioteca actual para el selector de géneros.
  List<LibraryGenreModel> _libraryGenres = [];

  /// Todas las definiciones de tipos de atributos disponibles para el usuario.
  List<AttributeTypeModel> _attributeTypes = [];

  /// Pares clave/valor de atributos ya adjuntos al elemento que se está editando.
  List<AttributeItemModel> _attributes = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is! Map<String, dynamic>) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pop();
        });
        return;
      }
      _list = args['list'] as ListModel;
      _item = args['item'] as ItemModel?;
      _parentId = args['parentId'] as int? ?? _item?.parentId;
      _initControllers();
      _loadData();
      _initialized = true;
    }
  }

  /// Inicializa todos los [TextEditingController]s y campos de estado desde [_item]
  /// cuando se edita, o con valores vacíos/por defecto cuando se crea.
  void _initControllers() {
    final item = _item;
    _nameController = TextEditingController(text: item?.name ?? "");
    _descController = TextEditingController(text: item?.description ?? "");
    _priceController = TextEditingController(
      text: item?.price?.toString() ?? "",
    );
    _itemNumberController = TextEditingController(text: item?.itemNumber ?? "");
    _productTypeController = TextEditingController(
      text: item?.productType ?? "",
    );
    _editionController = TextEditingController(text: item?.edition ?? "");

    _currentProgressController = TextEditingController(
      text: item?.currentProgress?.toString() ?? "",
    );
    _totalProgressController = TextEditingController(
      text: item?.totalProgress?.toString() ?? "",
    );
    _seasonController = TextEditingController(
      text: item?.season?.toString() ?? "",
    );
    _totalSeasonController = TextEditingController(
      text: item?.totalSeason?.toString() ?? "",
    );
    _chapterController = TextEditingController(
      text: item?.chapter?.toString() ?? "",
    );
    _totalChapterController = TextEditingController(
      text: item?.totalChapter?.toString() ?? "",
    );
    _pageController = TextEditingController(text: item?.page?.toString() ?? "");
    _totalPageController = TextEditingController(
      text: item?.totalPage?.toString() ?? "",
    );
    _volumeController = TextEditingController(
      text: item?.volume?.toString() ?? "",
    );
    _totalVolumeController = TextEditingController(
      text: item?.totalVolume?.toString() ?? "",
    );

    _status = item?.status ?? "PENDING";
    _isCurrent = item?.current ?? false;
    _wishlist = item?.wishlist ?? false;
    _isCollection = item?.collection ?? false;
    _score = item?.score ?? 0;
    _genre = item?.genre;
    _acquisitionDate = item?.acquisitionDate;
    _startDate = item?.startDate;
    _completionDate = item?.completionDate;

    if (item?.imagePath != null || item?.remoteImageUrl != null) {
      _existingImages.add(
        ItemImageModel(
          idItem: item!.id ?? 0,
          imageUri: item.imagePath ?? "",
          remoteImageUrl: item.remoteImageUrl,
        ),
      );
    }
  }

  /// Carga los géneros de la biblioteca, los tipos de atributos, los atributos del elemento y las imágenes de la galería
  /// desde el servidor para que se rellenen los selectores del formulario.
  Future<void> _loadData() async {
    if (_list.id != null) {
      final listsProvider = context.read<ListsProvider>();
      final itemsProvider = context.read<ItemsProvider>();

      try {
        final genres = await listsProvider.getLibraryGenres(_list.id!);
        if (mounted) setState(() => _libraryGenres = genres);
      } catch (_) {}

      try {
        final attrs = await itemsProvider.getAttributeTypes();
        if (mounted) setState(() => _attributeTypes = attrs);
      } catch (_) {}

      if (_item?.id != null) {
        try {
          final itemAttrs = await itemsProvider.getItemAttributes(_item!.id!);
          if (mounted) setState(() => _attributes = itemAttrs);
        } catch (_) {}

        try {
          final images = await itemsProvider.getItemImages(_item!.id!);
          if (mounted) {
            setState(() {
              // Only replace if gallery has records; otherwise keep the initial
              // entry from _initControllers (item's remoteImageUrl as fallback)
              if (images.isNotEmpty) _existingImages = images;
              final favIdx = _existingImages.indexWhere((img) => img.isFavorite);
              _favoriteImageIndex = favIdx >= 0 ? favIdx : null;
            });
          }
        } catch (_) {}
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _itemNumberController.dispose();
    _productTypeController.dispose();
    _editionController.dispose();
    _currentProgressController.dispose();
    _totalProgressController.dispose();
    _seasonController.dispose();
    _totalSeasonController.dispose();
    _chapterController.dispose();
    _totalChapterController.dispose();
    _pageController.dispose();
    _totalPageController.dispose();
    _volumeController.dispose();
    _totalVolumeController.dispose();
    super.dispose();
  }

  /// Envía solicitudes de eliminación al servidor para todas las imágenes en [_deletedImages].
  Future<void> _deleteOldImages(ItemsProvider itemsProvider) async {
    for (final img in _deletedImages) {
      // Delete from database (server handles Firebase Storage deletion)
      if (img.id != null) {
        try { await itemsProvider.deleteItemImage(img.id!); } catch (_) {}
      }
    }
  }

  /// Carga todos los archivos en [_newImageFiles] al servidor bajo [itemDbId] y
  /// devuelve la lista resultante de [ItemImageModel]s (nulls para cargas fallidas).
  Future<List<ItemImageModel?>> _uploadImagesToCloud(int itemDbId) async {
    if (_newImageFiles.isEmpty) return [];

    final List<ItemImageModel?> uploaded = [];
    for (int i = 0; i < _newImageFiles.length; i++) {
      final image = await context.read<ItemsProvider>().uploadImage(
            itemDbId,
            _newImageFiles[i],
          );
      uploaded.add(image);
    }
    return uploaded;
  }

  /// Abre la cámara o la galería del dispositivo (basado en [source]: `'camera'` o
  /// `'gallery'`) y añade la imagen seleccionada a la cola de carga pendiente.
  Future<void> _pickImage(String source) async {
    final image = await _imagePicker.pickImage(
      source: source == 'camera' ? ImageSource.camera : ImageSource.gallery,
    );
    if (image != null && mounted) {
      setState(() {
        _newImages.add(image.path);
        _newImageFiles.add(image);
      });
    }
  }

  /// Pares nombre/valor de atributos a persistir después de que se guarde el elemento.
  final Map<String, String> _pendingAttributes = {};

  /// Abre [SearchImportScreen] para la categoría de la lista actual y rellena los
  /// campos del formulario con los metadatos devueltos.
  Future<void> _openSearchImport() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SearchImportScreen(category: _list.type ?? "Generico"),
      ),
    );

    if (result != null && result is Map<String, dynamic> && mounted) {
      if (result.containsKey('name')) {
        _nameController.text = result['name'];
      } else if (result.containsKey('title')) {
        _nameController.text = result['title'];
      }

      if (result.containsKey('description')) {
        _descController.text = result['description'];
      }

      if (result.containsKey('remoteImageUrl')) {
        final url = result['remoteImageUrl'] ?? result['imageUrl'];
        if (url != null && url.isNotEmpty) {
          setState(() {
            _importedRemoteImageUrl = url;
            _existingImages.insert(
              0,
              ItemImageModel(
                idItem: _item?.id ?? 0,
                imageUri: url,
                remoteImageUrl: url,
              ),
            );
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.itemImportAdded)),
          );
        }
      }

      if (result.containsKey('externalRating')) {
        final rating = result['externalRating'];
        if (rating != null && rating is double) {
          setState(() => _importedExternalRating = rating);
        }
      }

      if (result.containsKey('genre') && _genre == null) {
        setState(() => _genre = result['genre']);
      }

      _applyImportedProgressFields(result);
      _collectImportedAttributes(result);

      if (mounted) setState(() {});
    }
  }

  /// Rellena los controladores relacionados con el progreso (páginas, capítulos, volúmenes, temporadas)
  /// desde el mapa [result] devuelto por [SearchImportScreen], solo cuando esos
  /// controladores están todavía vacíos para evitar sobrescribir la entrada manual.
  void _applyImportedProgressFields(Map<String, dynamic> result) {
    int? toInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString());
    }

    final totalPage = toInt(result['totalPage']);
    if (totalPage != null && totalPage > 0 && _totalPageController.text.isEmpty) {
      _totalPageController.text = totalPage.toString();
    }

    final totalChapter = toInt(result['totalChapter']) ??
        toInt(result['totalChapters']) ??
        toInt(result['lastChapter']) ??
        toInt(result['chapters']) ??
        toInt(result['episodes']) ??
        toInt(result['totalEpisodes']);
    if (totalChapter != null && totalChapter > 0 && _totalChapterController.text.isEmpty) {
      _totalChapterController.text = totalChapter.toString();
    }

    final totalVolume = toInt(result['totalVolume']) ??
        toInt(result['totalVolumes']) ??
        toInt(result['volumes']);
    if (totalVolume != null && totalVolume > 0 && _totalVolumeController.text.isEmpty) {
      _totalVolumeController.text = totalVolume.toString();
    }

    final totalSeason = toInt(result['totalSeason']) ?? toInt(result['seasons']);
    if (totalSeason != null && totalSeason > 0 && _totalSeasonController.text.isEmpty) {
      _totalSeasonController.text = totalSeason.toString();
    }
  }

  /// Recopila campos de metadatos conocidos de [result] en [_pendingAttributes]
  /// para que puedan guardarse como atributos de elemento personalizados después de que el elemento sea persistido.
  ///
  /// Los valores que son `null`, vacíos, `'N/A'` o `'0'` se omiten silenciosamente.
  void _collectImportedAttributes(Map<String, dynamic> result) {
    void addAttr(String name, dynamic value) {
      if (value == null) return;
      final str = value.toString().trim();
      if (str.isEmpty || str == 'N/A' || str == '0') return;
      _pendingAttributes[name] = str;
    }

    addAttr('Autor', result['author']);
    addAttr('Director', result['director']);
    addAttr('Reparto', result['actors']);
    addAttr('Guionista', result['writer']);
    addAttr('Estudio', result['studio']);
    addAttr('Editorial', result['publisher']);
    addAttr('Año', result['year']);
    addAttr('Idioma', result['language']);
    addAttr('País', result['country']);
    addAttr('ISBN', result['isbn']);
    addAttr('IMDb ID', result['imdbId']);
    addAttr('Eslogan', result['tagline']);

    final runtime = result['runtime'];
    if (runtime != null) {
      final r = runtime is int ? runtime : int.tryParse(runtime.toString());
      if (r != null && r > 0) {
        _pendingAttributes['Duración'] = '$r min';
      }
    }

    final duration = result['durationMinutes'];
    if (duration != null) {
      final d = duration is int ? duration : int.tryParse(duration.toString());
      if (d != null && d > 0) {
        _pendingAttributes['Duración/Episodio'] = '$d min';
      }
    }

    final nameJa = result['nameJapanese'];
    if (nameJa != null && nameJa.toString().trim().isNotEmpty) {
      _pendingAttributes['Título Japonés'] = nameJa.toString();
    }
    final nameEn = result['nameEnglish'];
    if (nameEn != null && nameEn.toString().trim().isNotEmpty) {
      _pendingAttributes['Título Inglés'] = nameEn.toString();
    }
  }

  /// Guarda [_pendingAttributes] como registros de atributos vinculados a [itemId].
  ///
  /// Crea sobre la marcha los tipos de atributos que faltan y omite los atributos que
  /// ya existen para el elemento para evitar duplicados.
  Future<void> _persistPendingAttributes(int itemId) async {
    if (_pendingAttributes.isEmpty) return;
    final itemsProvider = context.read<ItemsProvider>();

    List<AttributeTypeModel> types = _attributeTypes;
    try {
      types = await itemsProvider.getAttributeTypes();
    } catch (_) {}

    final existingNames = {
      for (final a in _attributes)
        types
                .firstWhere(
                  (t) => t.id == a.attributeTypeId,
                  orElse: () =>
                      const AttributeTypeModel(name: '', dataType: 'TEXT'),
                )
                .name
                .toLowerCase():
            true,
    };

    for (final entry in _pendingAttributes.entries) {
      try {
        if (existingNames[entry.key.toLowerCase()] == true) continue;

        AttributeTypeModel? type;
        for (final t in types) {
          if (t.name.toLowerCase() == entry.key.toLowerCase()) {
            type = t;
            break;
          }
        }
        type ??= await itemsProvider.createAttributeType(entry.key);
        if (type.id == null) continue;

        await itemsProvider.addAttributeToItem(
          AttributeItemModel(
            value: entry.value,
            idItem: itemId,
            attributeTypeId: type.id!,
          ),
        );
        types = [...types, type];
      } catch (_) {}
    }
    _pendingAttributes.clear();
  }

  /// Muestra un [AlertDialog] con un campo de texto para que el usuario escriba un nuevo nombre
  /// de género. Lo guarda en el backend si se edita una lista existente, o lo mantiene
  /// localmente si se crea una lista nueva.
  void _showAddGenreDialog() {
    final controller = TextEditingController();

    Future<void> submit(BuildContext ctx) async {
      final name = controller.text.trim();
      if (name.isNotEmpty && _list.id != null) {
        final listsProvider = ctx.read<ListsProvider>();
        await listsProvider.addLibraryGenre(_list.id!, name);
        if (mounted) {
          final genres = await listsProvider.getLibraryGenres(_list.id!);
          setState(() { _libraryGenres = genres; _genre = name; });
          Navigator.pop(ctx);
        }
      }
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ctx.l10n.genreAddTitle),
        content: TextField(
          controller: controller,
          autofocus: true,
          textInputAction: TextInputAction.done,
          textCapitalization: TextCapitalization.sentences,
          onSubmitted: (_) => submit(ctx),
          decoration: InputDecoration(labelText: ctx.l10n.genreName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(ctx.l10n.commonCancel.toUpperCase()),
          ),
          TextButton(
            onPressed: () => submit(ctx),
            child: Text(ctx.l10n.commonAdd.toUpperCase()),
          ),
        ],
      ),
    ).then((_) => controller.dispose());
  }

  /// Muestra un [AlertDialog] con un campo de texto para introducir un nuevo nombre de tipo
  /// de atributo y devuelve el nombre introducido, o `null` si se cancela.
  Future<String?> _showCreateAttributeTypeDialog() async {
    final controller = TextEditingController();
    try {
      return await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(ctx.l10n.attributeNewType),
          content: TextField(
            controller: controller,
            autofocus: true,
            textInputAction: TextInputAction.done,
            textCapitalization: TextCapitalization.sentences,
            onSubmitted: (_) {
              final name = controller.text.trim();
              if (name.isNotEmpty) Navigator.pop(ctx, name);
            },
            decoration: InputDecoration(
              labelText: ctx.l10n.attributesNewTypeName,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(ctx.l10n.commonCancel),
            ),
            TextButton(
              onPressed: () {
                final name = controller.text.trim();
                if (name.isNotEmpty) Navigator.pop(ctx, name);
              },
              child: Text(ctx.l10n.commonCreate),
            ),
          ],
        ),
      );
    } finally {
      controller.dispose();
    }
  }

  /// Determina la unidad de progreso y los valores actual/total según [_list.progressType].
  ({String unit, int? current, int? total}) _resolveProgress() {
    final progressType = _list.progressType;
    if (progressType == "Libro" || progressType == "Manga") {
      return (
        unit: "Página",
        current: int.tryParse(_pageController.text),
        total: int.tryParse(_totalPageController.text),
      );
    } else if (progressType == "Serie" || progressType == "Anime") {
      return (
        unit: "Episodio",
        current: int.tryParse(_chapterController.text),
        total: int.tryParse(_totalChapterController.text),
      );
    }
    return (
      unit: _list.customProgressUnit ?? "Progreso",
      current: int.tryParse(_currentProgressController.text),
      total: int.tryParse(_totalProgressController.text),
    );
  }

  /// Construye el [ItemModel] a persistir a partir del estado actual de los controladores.
  ItemModel _buildItemModel({
    required String progressUnit,
    required int? finalCurrent,
    required int? finalTotal,
    required String finalImagePath,
    required String itemRemoteImageUrl,
  }) {
    return ItemModel(
      id: _item?.id,
      idLibrary: _list.id!,
      name: _nameController.text.trim(),
      description: _descController.text.trim().isEmpty
          ? null
          : _descController.text.trim(),
      status: _status,
      genre: _genre,
      score: _score,
      wishlist: _wishlist,
      current: _isCurrent,
      collection: _isCollection,
      price: double.tryParse(_priceController.text.replaceAll(',', '.')),
      imagePath: finalImagePath,
      remoteImageUrl: itemRemoteImageUrl,
      progressUnit: progressUnit,
      currentProgress: finalCurrent,
      totalProgress: finalTotal,
      season: int.tryParse(_seasonController.text),
      totalSeason: int.tryParse(_totalSeasonController.text),
      chapter: int.tryParse(_chapterController.text),
      totalChapter: int.tryParse(_totalChapterController.text),
      page: int.tryParse(_pageController.text),
      totalPage: int.tryParse(_totalPageController.text),
      volume: int.tryParse(_volumeController.text),
      totalVolume: int.tryParse(_totalVolumeController.text),
      itemNumber: _itemNumberController.text.trim().isEmpty
          ? null
          : _itemNumberController.text.trim(),
      productType: _productTypeController.text.trim().isEmpty
          ? null
          : _productTypeController.text.trim(),
      edition: _editionController.text.trim().isEmpty
          ? null
          : _editionController.text.trim(),
      acquisitionDate: _acquisitionDate,
      startDate: _startDate,
      completionDate: _completionDate,
      externalRating: _importedExternalRating,
      parentId: _parentId,
    );
  }

  /// Persiste o actualiza [newItem] en el servidor y devuelve el ID resultante.
  ///
  /// Lanza una [Exception] si el backend responde con error.
  Future<int> _createOrUpdate(
    ItemsProvider itemsProvider,
    ItemModel newItem,
  ) async {
    if (_item == null) {
      final created = await itemsProvider.createItem(newItem);
      if (created == null) {
        throw Exception(itemsProvider.errorMessage ?? "Error creando el artículo");
      }
      return created.id!;
    } else {
      final success = await itemsProvider.updateItem(_item!.id!, newItem);
      if (!success) {
        throw Exception(itemsProvider.errorMessage ?? "Error actualizando el artículo");
      }
      return _item!.id!;
    }
  }

  /// Persiste imágenes existentes sin ID, sube las nuevas y marca la favorita.
  ///
  /// Devuelve la URL remota de la imagen favorita resultante, o `null` si no hay imágenes.
  Future<String?> _persistImages(
    ItemsProvider itemsProvider,
    int savedItemId,
    String fallbackRemoteUrl,
  ) async {
    // Persist existing images that don't have a server id yet (e.g. imported from API).
    final List<ItemImageModel?> resolvedExisting =
        List<ItemImageModel?>.filled(_existingImages.length, null);
    bool persistedNew = false;
    for (int i = 0; i < _existingImages.length; i++) {
      final img = _existingImages[i];
      if (img.id != null) {
        resolvedExisting[i] = img;
        continue;
      }
      final url = img.remoteImageUrl?.isNotEmpty == true
          ? img.remoteImageUrl!
          : (img.imageUri?.isNotEmpty == true ? img.imageUri! : '');
      if (url.isEmpty) continue;
      try {
        final created = await itemsProvider.createItemImage(ItemImageModel(
          idItem: savedItemId,
          imageUri: url,
          remoteImageUrl: img.remoteImageUrl,
          isFavorite: false,
        ));
        if (created != null) {
          resolvedExisting[i] = created;
          persistedNew = true;
        }
      } catch (_) {}
    }

    // Upload brand-new images from device.
    List<ItemImageModel?> uploaded = const [];
    if (_newImageFiles.isNotEmpty) {
      uploaded = await _uploadImagesToCloud(savedItemId);
    }

    // Determine the persisted image matching the selected favorite position.
    final int favIdx = _favoriteImageIndex ?? 0;
    ItemImageModel? favImage;
    if (favIdx < _existingImages.length) {
      favImage = resolvedExisting[favIdx];
    } else {
      final newIdx = favIdx - _existingImages.length;
      if (newIdx >= 0 && newIdx < uploaded.length) favImage = uploaded[newIdx];
    }
    favImage ??= resolvedExisting.firstWhere((m) => m != null, orElse: () => null);
    favImage ??= uploaded.firstWhere((m) => m != null, orElse: () => null);

    if (favImage?.id != null) {
      await itemsProvider.setFavoriteImage(savedItemId, favImage!.id!);
    }

    // Return the remote URL to sync on the item only when something actually changed.
    if (uploaded.isNotEmpty || persistedNew) {
      final url = favImage?.remoteImageUrl?.isNotEmpty == true
          ? favImage!.remoteImageUrl!
          : fallbackRemoteUrl;
      return url.isNotEmpty ? url : null;
    }
    return null;
  }

  /// Valida el formulario, persiste el [ItemModel], sube imágenes, marca la favorita,
  /// guarda atributos importados y cierra la pantalla con `true`.
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isSaving) return;

    setState(() => _isSaving = true);

    try {
      final itemsProvider = context.read<ItemsProvider>();

      final (:unit, :current, :total) = _resolveProgress();
      final finalImagePath = _newImages.isNotEmpty
          ? _newImages.first
          : (_item?.imagePath ?? '');
      final itemRemoteImageUrl = _item?.remoteImageUrl ?? _importedRemoteImageUrl ?? '';

      await _deleteOldImages(itemsProvider);

      final newItem = _buildItemModel(
        progressUnit: unit,
        finalCurrent: current,
        finalTotal: total,
        finalImagePath: finalImagePath,
        itemRemoteImageUrl: itemRemoteImageUrl,
      );

      final savedItemId = await _createOrUpdate(itemsProvider, newItem);

      await _persistPendingAttributes(savedItemId);

      final updatedRemoteUrl = await _persistImages(
        itemsProvider,
        savedItemId,
        itemRemoteImageUrl,
      );

      if (updatedRemoteUrl != null && mounted) {
        try {
          await itemsProvider.updateItem(
            savedItemId,
            newItem.copyWith(id: savedItemId, remoteImageUrl: updatedRemoteUrl),
          );
        } catch (_) {}
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${context.l10n.itemSaveError}: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final responsive = context.watch<ResponsiveProvider>();

    return AppShell(
      currentIndex: 0,
      appBar: CustomGradientAppBar(
        title: _item == null ? context.l10n.itemNew : context.l10n.itemEdit,
        showBackButton: true,
        actions: [
          if (_isSaving)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            )
          else
            IconButton(onPressed: _save, icon: const Icon(Icons.check_rounded)),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: responsive.formMaxWidth),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: responsive.horizontalPadding,
              vertical: 16,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
              EntryImagePicker(
                existingImages: _existingImages
                    .map((e) => e.imageUri ?? '')
                    .toList(),
                existingRemoteUrls: _existingImages
                    .map((e) => e.remoteImageUrl ?? '')
                    .toList(),
                newImages: _newImages,
                favoriteIndex: _favoriteImageIndex,
                onPickImage: _pickImage,
                onRemoveExisting: (idx) {
                  setState(() {
                    if (idx < 0 || idx >= _existingImages.length) return;
                    final img = _existingImages.removeAt(idx);
                    _deletedImages.add(img);
                    if (_favoriteImageIndex == idx) _favoriteImageIndex = null;
                  });
                },
                onRemoveNew: (idx) {
                  setState(() {
                    _newImages.removeAt(idx);
                    if (idx < _newImageFiles.length) _newImageFiles.removeAt(idx);
                    final totalExisting = _existingImages.length;
                    if (_favoriteImageIndex != null &&
                        _favoriteImageIndex! >= totalExisting &&
                        _favoriteImageIndex! - totalExisting == idx) {
                      _favoriteImageIndex = null;
                    }
                  });
                },
                onSetFavorite: (idx) =>
                    setState(() => _favoriteImageIndex = idx),
              ),
              const SizedBox(height: 16),
              EntryMainInfoSection(
                nameController: _nameController,
                descController: _descController,
                itemNumberController: _list.type == "Funko"
                    ? _itemNumberController
                    : null,
                productTypeController: _list.type == "Funko"
                    ? _productTypeController
                    : null,
                editionController: _list.type == "Funko"
                    ? _editionController
                    : null,
                showImportButton: true,
                onImportPressed: _openSearchImport,
                showItemNumber: _list.type == "Funko",
                showProductType: _list.type == "Funko",
                showEdition: _list.type == "Funko",
              ),
              const SizedBox(height: 16),
              EntryStatusProgressSection(
                status: _status,
                onStatusChanged: (val) => setState(() => _status = val),
                isCurrent: _isCurrent,
                onCurrentChanged: (val) => setState(() => _isCurrent = val),
                supportsProgress: _list.supportsProgress,
                progressType: _list.progressType,
                currentProgressController: _currentProgressController,
                totalProgressController: _totalProgressController,
                seasonController: _seasonController,
                totalSeasonController: _totalSeasonController,
                chapterController: _chapterController,
                totalChapterController: _totalChapterController,
                pageController: _pageController,
                totalPageController: _totalPageController,
                volumeController: _volumeController,
                totalVolumeController: _totalVolumeController,
              ),
              const SizedBox(height: 16),
              EntryPropertiesSection(
                genre: _genre,
                availableGenres: _libraryGenres,
                onGenreChanged: (val) => setState(() => _genre = val),
                onGenreSaved: (val) => _genre = val,
                onAddGenrePressed: _showAddGenreDialog,
                priceController: _priceController,
                score: _score,
                onScoreChanged: (val) =>
                    setState(() => _score = double.tryParse(val) ?? 0),
                onStarTap: (val) => setState(() => _score = val),
                supportsPrice: _list.supportsPrice,
                isGradeable: _list.gradeable,
                isThematic: _list.thematic,
                ratingScale: _list.ratingScale ?? 10,
              ),
              const SizedBox(height: 16),
              EntryDatesSection(
                acquisitionDate: _acquisitionDate,
                startDate: _startDate,
                completionDate: _completionDate,
                onAcquisitionDateChanged: (val) =>
                    setState(() => _acquisitionDate = val),
                onStartDateChanged: (val) => setState(() => _startDate = val),
                onCompletionDateChanged: (val) =>
                    setState(() => _completionDate = val),
                tracksDates: _list.tracksDates,
                supportsWishlist: _list.supportsWishlist,
                isWishlist: _wishlist,
                isCollection: _isCollection,
                onWishlistChanged: (val) => setState(() => _wishlist = val),
                onCollectionChanged: (val) =>
                    setState(() => _isCollection = val),
              ),
              const SizedBox(height: 16),
              EntryAttributesSection(
                attributes: _attributes,
                allTypes: _attributeTypes,
                onAdd: (attr) => setState(() => _attributes.add(attr)),
                onRemove: (idx) => setState(() => _attributes.removeAt(idx)),
                onCreateAttributeType: () async {
                  final result = await _showCreateAttributeTypeDialog();
                  if (result != null) {
                    final itemsProvider = context.read<ItemsProvider>();
                    final newType = await itemsProvider.createAttributeType(
                      result,
                    );
                    setState(() => _attributeTypes.add(newType));
                    return result;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
        ),
      ),
    );
  }
}
