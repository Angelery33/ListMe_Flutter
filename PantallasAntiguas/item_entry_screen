import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:provider/provider.dart';
import '../../data/models.dart';
import '../../data/database_helper.dart';
import '../../providers/item_provider.dart';
import '../../services/file_service.dart';
import '../../services/cloud_sync_service.dart';
import '../app_theme.dart';
import '../components/responsive_container.dart';
import 'search_import_screen.dart';

// Import New Components
import '../widgets/entry/attribute_item_local.dart';
import '../widgets/entry/item_entry_image_picker.dart';
import '../widgets/entry/item_entry_main_info_section.dart';
import '../widgets/entry/item_entry_properties_section.dart';
import '../widgets/entry/item_entry_progress_section.dart';
import '../widgets/entry/item_entry_dates_section.dart';
import '../widgets/entry/item_entry_attributes_section.dart';

class ItemEntryScreen extends StatefulWidget {
  final int libraryId;
  final Item? item; // If null, creating new
  final int? parentId; // If provided, creating sub-item

  const ItemEntryScreen({
    super.key,
    required this.libraryId,
    this.item,
    this.parentId,
  });

  @override
  State<ItemEntryScreen> createState() => _ItemEntryScreenState();
}

class _ItemEntryScreenState extends State<ItemEntryScreen>
    with WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  late TextEditingController _currentProgressController;
  late TextEditingController _totalProgressController;

  // Progress controllers
  late TextEditingController _seasonController;
  late TextEditingController _chapterController;
  late TextEditingController _pageController;
  late TextEditingController _volumeController;
  late TextEditingController _totalSeasonController;
  late TextEditingController _totalChapterController;
  late TextEditingController _totalPageController;
  late TextEditingController _totalPageController;
  late TextEditingController _totalVolumeController;
  late TextEditingController _scoreController;

  // Funko Controllers
  late TextEditingController _itemNumberController;

  // State Variables
  String _progressUnit = "Página";
  String? _selectedProductType;
  String? _selectedEdition;
  double _score = 0;
  String _status = "PENDING";
  String? _genre;
  int? _startDate;
  int? _completionDate;
  int? _acquisitionDate;
  bool _isWishlist = false;
  bool _isCurrent = false;
  bool _isCollection = false;
  double? _externalRating;
  String? _importedRemoteImageUrl;

  final List<String> _newImagePaths = [];
  List<ItemImage> _existingImages = [];
  final Set<int> _deletedImageIds = {};
  final ImagePicker _picker = ImagePicker();

  List<AttributeItemLocal> _attributes = [];
  List<AttributeType> _allAttributeTypes = [];
  Library? _library;
  List<LibraryGenre> _libraryGenres = [];

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeData();
    _initControllers();
  }

  void _initControllers() {
    _nameController = TextEditingController(text: widget.item?.name ?? '');
    _descController = TextEditingController(
      text: widget.item?.description ?? '',
    );
    _priceController = TextEditingController(
      text: widget.item?.price?.toString() ?? '',
    );
    _currentProgressController = TextEditingController(
      text: widget.item?.currentProgress?.toString() ?? '',
    );
    _totalProgressController = TextEditingController(
      text: widget.item?.totalProgress?.toString() ?? '',
    );
    _itemNumberController = TextEditingController(
      text: widget.item?.itemNumber ?? '',
    );

    _seasonController = TextEditingController(
      text: widget.item?.season?.toString() ?? '',
    );
    _chapterController = TextEditingController(
      text: widget.item?.chapter?.toString() ?? '',
    );
    _pageController = TextEditingController(
      text: widget.item?.page?.toString() ?? '',
    );
    _volumeController = TextEditingController(
      text: widget.item?.volume?.toString() ?? '',
    );
    _totalSeasonController = TextEditingController(
      text: widget.item?.totalSeason?.toString() ?? '',
    );
    _totalChapterController = TextEditingController(
      text: widget.item?.totalChapter?.toString() ?? '',
    );
    _totalPageController = TextEditingController(
      text: widget.item?.totalPage?.toString() ?? '',
    );
    _totalVolumeController = TextEditingController(
      text: widget.item?.totalVolume?.toString() ?? '',
    );

    // Init state from item
    double initialScore = widget.item?.score ?? 0;
    // We cannot easily determine scale here properly without library loaded,
    // but we can try defaults or update it later in _initializeData.
    // For now, rawString.
    _scoreController = TextEditingController(
      text: initialScore > 0 ? initialScore.toStringAsFixed(2) : "",
    );

    // Init state from item
    _progressUnit = widget.item?.progressUnit ?? "Página"; // Default
    _selectedProductType = widget.item?.productType;
    _selectedEdition = widget.item?.edition;
    _score = widget.item?.score ?? 0;
    _status = widget.item?.status ?? "PENDING";
    _genre = widget.item?.genre;
    _startDate = widget.item?.startDate ?? widget.item?.date;
    _completionDate = widget.item?.completionDate;
    _acquisitionDate = widget.item?.acquisitionDate;
    _isWishlist = widget.item?.isWishlist ?? false;
    _isCurrent = widget.item?.isCurrent ?? false;
    _isCollection = widget.item?.isCollection ?? false;
    _externalRating = widget.item?.externalRating;
  }

  Future<void> _initializeData() async {
    await _reloadLibrary();
    _allAttributeTypes = await DatabaseHelper.instance.getAllAttributeTypes();

    if (_library != null) {
      await _loadGenres();
    } else {
      _libraryGenres = await DatabaseHelper.instance.getGenresForLibrary(
        widget.libraryId,
      );
    }

    if (widget.item != null) {
      final images = await DatabaseHelper.instance.getItemImages(
        widget.item!.idItem!,
      );
      final attrs = await DatabaseHelper.instance.getAttributesForItem(
        widget.item!.idItem!,
      );

      // Deduplicate logic omitted for brevity, assuming standard fetch
      // But keeping dedup logic is safer:
      final uniqueImages = <ItemImage>[];
      final seenUris = <String>{};
      for (var img in images) {
        final key = img.remoteImageUrl ?? img.imageUri;
        if (!seenUris.contains(key)) {
          seenUris.add(key);
          uniqueImages.add(img);
        }
      }

      // Ensure main image is in list if not already
      // Ensure main image is in list if not already
      if (widget.item!.imagePath != null ||
          widget.item!.remoteImageUrl != null) {
        bool mainInGallery = false;

        // Check main path existence
        String? validMainPath;
        if (widget.item!.imagePath != null &&
            widget.item!.imagePath!.isNotEmpty) {
          final path = widget.item!.imagePath!;
          final lower = path.toLowerCase();
          bool exists = false;
          if (lower.startsWith('http') ||
              lower.startsWith('https') ||
              lower.startsWith('blob')) {
            exists = true;
          } else if (!kIsWeb) {
            String cleanPath = path;
            if (path.startsWith('file://')) cleanPath = path.substring(7);
            if (await FileService().fileExists(cleanPath)) {
              exists = true;
            }
          }

          if (exists) validMainPath = path;
        }

        // Fallback to remote if local is invalid/missing
        if (validMainPath == null &&
            widget.item!.remoteImageUrl != null &&
            widget.item!.remoteImageUrl!.isNotEmpty) {
          validMainPath = widget.item!.remoteImageUrl;
        }

        if (validMainPath != null) {
          for (var img in uniqueImages) {
            if (img.imageUri == validMainPath ||
                (img.remoteImageUrl != null &&
                    img.remoteImageUrl == validMainPath)) {
              mainInGallery = true;
              break;
            }
          }

          if (!mainInGallery) {
            uniqueImages.insert(
              0,
              ItemImage(
                idItem: widget.item!.idItem!,
                imageUri:
                    validMainPath, // Use the validated path (local or remote)
                remoteImageUrl: widget.item!.remoteImageUrl,
              ),
            );
          }
        }
      }

      setState(() {
        _existingImages = uniqueImages;
        _attributes = attrs
            .map(
              (a) => AttributeItemLocal(
                attributeItemId: a.attributeItemId,
                attributeTypeId: a.attributeTypeId,
                name: a.name,
                dataType: "TEXT",
                value: a.value,
              ),
            )
            .toList();
      });
    }

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _reloadLibrary() async {
    final lib = await DatabaseHelper.instance.getLibraryById(widget.libraryId);
    if (!mounted) return;
    if (lib != null) setState(() => _library = lib);
  }

  Future<void> _loadGenres() async {
    var genres = await DatabaseHelper.instance.getGenresForLibrary(
      widget.libraryId,
    );
    // Lazy seed
    if (genres.isEmpty && _library != null) {
      await DatabaseHelper.instance.seedLibraryGenres(
        widget.libraryId,
        _library!.type ?? "",
      );
      genres = await DatabaseHelper.instance.getGenresForLibrary(
        widget.libraryId,
      );
    }
    if (mounted) setState(() => _libraryGenres = genres);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _currentProgressController.dispose();
    _totalProgressController.dispose();
    _itemNumberController.dispose();
    _seasonController.dispose();
    _chapterController.dispose();
    _pageController.dispose();
    _volumeController.dispose();
    _totalSeasonController.dispose();
    _totalChapterController.dispose();
    _totalPageController.dispose();
    _totalVolumeController.dispose();
    _scoreController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _reloadLibrary();
  }

  // --- Logic Methods ---

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (!mounted || image == null) return;

    bool? shouldCrop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("¿Recortar imagen?"),
        content: const Text(
          "¿Deseas recortar la imagen para que sea cuadrada?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Sí, recortar"),
          ),
        ],
      ),
    );

    if (!mounted) return;

    if (shouldCrop == true) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: image.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Recortar Portada',
            toolbarColor: Theme.of(context).colorScheme.primary,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: 'Recortar Portada',
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
          ),
        ],
      );
      if (mounted && croppedFile != null) {
        setState(() => _newImagePaths.add(croppedFile.path));
        return;
      }
    }
    setState(() => _newImagePaths.add(image.path));
  }

  Future<void> _openSearchImport() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            SearchImportScreen(category: _library?.type ?? "Generico"),
      ),
    );

    if (result != null && result is Map<String, dynamic> && mounted) {
      if (result.containsKey('name'))
        _nameController.text = result['name'];
      else if (result.containsKey('title'))
        _nameController.text = result['title'];

      if (result.containsKey('description'))
        _descController.text = result['description'];

      // Handle Image
      if (result.containsKey('remoteImageUrl')) {
        // It handles "remoteImageUrl" from SearchImportScreen selectItem, or "imageUrl" from generic?
        // selectItem sends: 'remoteImageUrl': result['imagePath']
        // Let's check keys again.
        final url = result['remoteImageUrl'] ?? result['imageUrl'];
        if (url != null && url.isNotEmpty) {
          setState(() {
            _importedRemoteImageUrl = url;
            // Add to existing images so it shows up in the picker
            _existingImages.insert(
              0,
              ItemImage(
                idItem: widget.item?.idItem ?? -1, // Temporary ID
                imageUri: url,
                remoteImageUrl: url,
              ),
            );
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Imagen importada añadida")),
          );
        }
      }

      // Handle extra mappings based on library type
      if (_library?.type == 'Funko') {
        if (result.containsKey('attributes')) {
          final Map<String, String> attrs = result['attributes'];
          // Map known funko attrs
          if (attrs.containsKey('Item Number'))
            _itemNumberController.text = attrs['Item Number']!;
          if (attrs.containsKey('Year')) {
            // Maybe add to attributes list or date?
          }
        }
      }
    }
  }

  Future<String?> _handleCreateAttributeType() async {
    TextEditingController typeNameController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Nuevo Tipo de Atributo"),
          content: TextField(
            controller: typeNameController,
            decoration: const InputDecoration(labelText: "Nombre del tipo"),
            textCapitalization: TextCapitalization.sentences,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () async {
                if (typeNameController.text.isNotEmpty) {
                  await DatabaseHelper.instance.insertAttributeType(
                    AttributeType(
                      name: typeNameController.text.trim(),
                      dataType: "TEXT",
                    ),
                  );
                  if (mounted)
                    Navigator.pop(context, typeNameController.text.trim());
                }
              },
              child: const Text("Crear"),
            ),
          ],
        );
      },
    ).then((value) async {
      if (value != null && mounted) {
        // Allow parent to refresh list?
        // The widget might need a nudge but we passed the callback.
        // We need to refresh internal list ' _allAttributeTypes' so we can pass it down next build.
        final newTypes = await DatabaseHelper.instance.getAllAttributeTypes();
        setState(() {
          _allAttributeTypes = newTypes;
        });
        return value;
      }
      return null;
    });
  }

  void _showAddGenreDialog() {
    final genreDialogController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Añadir Género/Temática'),
        content: TextField(
          controller: genreDialogController,
          decoration: const InputDecoration(labelText: 'Nombre del género'),
          textCapitalization: TextCapitalization.sentences,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
          ),
          TextButton(
            onPressed: () async {
              final name = genreDialogController.text.trim();
              if (name.isNotEmpty) {
                await DatabaseHelper.instance.insertLibraryGenre(
                  LibraryGenre(libraryId: widget.libraryId, name: name),
                );
                if (!mounted) return;

                if (_library?.isCloud == true && _library?.remoteId != null) {
                  await CloudSyncService.instance.syncGenresToCloud(
                    widget.libraryId,
                    _library!.remoteId!,
                  );
                }

                await _loadGenres();
                if (mounted) {
                  setState(() => _genre = name);
                  Navigator.pop(context);
                }
              }
            },
            child: const Text('AÑADIR'),
          ),
        ],
      ),
    );
  }

  // --- SAVE LOGIC ---
  Future<void> _saveItem() async {
    if (_isSaving) return;
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isSaving = true);

      // 1. Save Images Permanently
      List<String> permanentNewPaths = [];
      for (var tempPath in _newImagePaths) {
        try {
          final perm = await FileService().saveImagePermanently(tempPath);
          permanentNewPaths.add(perm);
        } catch (e) {
          debugPrint("Error saving image: $e");
        }
      }

      // 2. Determine Main Image
      String? mainImagePath = widget.item?.imagePath;
      String? mainRemoteImageUrl = widget.item?.remoteImageUrl;

      if (_importedRemoteImageUrl != null)
        mainRemoteImageUrl = _importedRemoteImageUrl;

      if (mainImagePath == null) {
        if (permanentNewPaths.isNotEmpty)
          mainImagePath = permanentNewPaths.first;
        else if (_existingImages.isNotEmpty)
          mainImagePath = _existingImages.first.imageUri;
      }

      // 3. Progress Logic
      int? finalCurrent;
      int? finalTotal;
      final progressType = _library?.progressType ?? "Manual";

      // Helper to reuse controllers
      final season = int.tryParse(_seasonController.text);
      final chapter = int.tryParse(_chapterController.text);
      final page = int.tryParse(_pageController.text);
      final volume = int.tryParse(_volumeController.text);
      final totalSeason = int.tryParse(_totalSeasonController.text);
      final totalChapter = int.tryParse(_totalChapterController.text);
      final totalPage = int.tryParse(_totalPageController.text);
      final totalVolume = int.tryParse(_totalVolumeController.text);

      if (progressType == "Libro" || progressType == "Manga") {
        finalCurrent = page;
        finalTotal = totalPage;
        _progressUnit = "Página";
      } else if (progressType == "Serie" || progressType == "Anime") {
        finalCurrent = chapter;
        finalTotal = totalChapter;
        _progressUnit = "Episodio";
      } else {
        finalCurrent = int.tryParse(_currentProgressController.text);
        finalTotal = int.tryParse(_totalProgressController.text);
        _progressUnit = _library?.customProgressUnit ?? "Progreso";
      }

      // Reconstructing properly:
      Item itemToSave;
      if (widget.item != null) {
        itemToSave = widget.item!.copyWith(
          name: _nameController.text.trim(),
          description: _descController.text.trim(),
          score: _score,
          status: _status,
          genre: _genre?.trim().isEmpty == true ? null : _genre?.trim(),
          startDate: _startDate,
          completionDate: _completionDate,
          acquisitionDate: _acquisitionDate,
          isWishlist: _isWishlist,
          price: double.tryParse(_priceController.text.replaceAll(',', '.')),
          isCurrent: _isCurrent,
          imagePath: mainImagePath,
          progressUnit: _progressUnit,
          currentProgress: finalCurrent,
          totalProgress: finalTotal,
          season: season,
          chapter: chapter,
          page: page,
          volume: volume,
          totalSeason: totalSeason,
          totalChapter: totalChapter,
          totalPage: totalPage,
          totalVolume: totalVolume,
          isCollection: _isCollection,
          externalRating: _externalRating,
          remoteImageUrl: mainRemoteImageUrl,
          itemNumber: _itemNumberController.text.trim(),
          productType: _selectedProductType,
          edition: _selectedEdition,
        );
      } else {
        itemToSave = Item(
          idLibrary: widget.libraryId,
          parentId: widget.parentId,
          name: _nameController.text.trim(),
          description: _descController.text.trim(),
          score: _score,
          status: _status,
          genre: _genre?.trim().isEmpty == true ? null : _genre?.trim(),
          date: _startDate ?? DateTime.now().millisecondsSinceEpoch,
          startDate: _startDate,
          completionDate: _completionDate,
          acquisitionDate: _acquisitionDate,
          isWishlist: _isWishlist,
          price: double.tryParse(_priceController.text.replaceAll(',', '.')),
          isCurrent: _isCurrent,
          imagePath: mainImagePath,
          progressUnit: _progressUnit,
          currentProgress: finalCurrent,
          totalProgress: finalTotal,
          season: season,
          chapter: chapter,
          page: page,
          volume: volume,
          totalSeason: totalSeason,
          totalChapter: totalChapter,
          totalPage: totalPage,
          totalVolume: totalVolume,
          isCollection: _isCollection,
          externalRating: _externalRating,
          remoteImageUrl: mainRemoteImageUrl ?? _importedRemoteImageUrl,
          itemNumber: _itemNumberController.text.trim(),
          productType: _selectedProductType,
          edition: _selectedEdition,
        );
      }

      // 5. Provider Call
      final provider = Provider.of<ItemProvider>(context, listen: false);
      int itemId;
      try {
        if (widget.item == null) {
          itemId = await provider.addItem(itemToSave);
        } else {
          await provider.updateItem(itemToSave);
          itemId = widget.item!.idItem!;
        }

        if (itemId == -1) throw Exception("Failed to save item ID returned -1");

        // 6. Save Side Entities
        for (var id in _deletedImageIds) {
          await DatabaseHelper.instance.deleteItemImage(id);
        }
        for (var path in permanentNewPaths) {
          await DatabaseHelper.instance.insertItemImage(
            ItemImage(idItem: itemId, imageUri: path),
          );
        }

        await DatabaseHelper.instance.deleteAttributesByItemId(itemId);
        for (var attr in _attributes) {
          await DatabaseHelper.instance.upsertAttributeItem(
            AttributeItem(
              idItem: itemId,
              attributeTypeId: attr.attributeTypeId,
              value: attr.value,
            ),
          );
        }

        if (mounted) Navigator.pop(context, true);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Error: $e")));
          setState(() => _isSaving = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Derived Props
    final isGradeable = _library?.isGradeable ?? false;
    final tracksDates = _library?.tracksDates ?? false;
    final supportsWishlist = _library?.supportsWishlist ?? false;
    final supportsCompletion = _library?.supportsCompletion ?? false;
    final supportsPrice = _library?.supportsPrice ?? false;
    final isThematic = _library?.isThematic ?? false;
    final supportsProgress = _library?.supportsProgress ?? false;

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: AppTheme.getAppBarGradient(context),
        title: Text(widget.item == null ? 'Nuevo Elemento' : 'Editar Elemento'),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(color: Colors.white),
            ),
          if (!_isSaving)
            IconButton(onPressed: _saveItem, icon: const Icon(Icons.check)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: ResponsiveContainer(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Images
                ItemEntryImagePicker(
                  existingImages: _existingImages,
                  newImagePaths: _newImagePaths,
                  onPickImage: _pickImage,
                  onRemoveExisting: (idx) {
                    setState(() {
                      final img = _existingImages.removeAt(idx);
                      if (img.idImage != null)
                        _deletedImageIds.add(img.idImage!);
                    });
                  },
                  onRemoveNew: (idx) =>
                      setState(() => _newImagePaths.removeAt(idx)),
                ),
                const SizedBox(height: 16),

                // 2. Main Info
                ItemEntryMainInfoSection(
                  nameController: _nameController,
                  descController: _descController,
                  itemNumberController: _itemNumberController,
                  selectedProductType: _selectedProductType,
                  selectedEdition: _selectedEdition,
                  onProductTypeChanged: (val) =>
                      setState(() => _selectedProductType = val),
                  onEditionChanged: (val) =>
                      setState(() => _selectedEdition = val),
                  onImportPressed: _openSearchImport,
                  libraryType: _library?.type,
                  showImportButton: true,
                  hasRemoteImage: _importedRemoteImageUrl != null,
                ),
                const SizedBox(height: 16),

                // 3. Properties (Score, Status, Genre, Price)
                ItemEntryPropertiesSection(
                  isGradeable: isGradeable,
                  supportsCompletion: supportsCompletion,
                  supportsPrice: supportsPrice,
                  isThematic: isThematic,
                  score: _score,
                  status: _status,
                  isCurrent: _isCurrent,
                  genre: _genre,
                  libraryGenres: _libraryGenres,
                  libraryType: _library?.type,
                  ratingScale: _library?.ratingScale ?? 10,
                  priceController: _priceController,
                  scoreController: _scoreController,
                  onScoreChanged: (val) {
                    setState(() {
                      if (val.isNotEmpty)
                        _score = double.tryParse(val.replaceAll(',', '.')) ?? 0;
                      else
                        _score = 0;
                    });
                  },
                  onStarTap: (val) {
                    setState(() {
                      _score = val;
                      // Format text based on scale
                      final scale = _library?.ratingScale ?? 10;
                      if (scale == 100) {
                        _scoreController.text = val.toStringAsFixed(0);
                      } else if (scale == 5) {
                        _scoreController.text = val.toStringAsFixed(1);
                      } else {
                        _scoreController.text = val.toStringAsFixed(2);
                      }
                    });
                  },
                  onScoreSaved: (val) {
                    if (val != null && val.isNotEmpty)
                      _score = double.tryParse(val.replaceAll(',', '.')) ?? 0;
                  },
                  onStatusChanged: (val) => setState(() {
                    _status = val!;
                    if (_status == "PENDING" || _status == "COMPLETED")
                      _isCurrent = false;
                  }),
                  onCurrentChanged: (val) => setState(() => _isCurrent = val),
                  onGenreChanged: (val) => setState(() => _genre = val),
                  onGenreSaved: (val) => _genre = val,
                  onAddGenrePressed: _showAddGenreDialog,
                ),
                const SizedBox(height: 16),

                // 4. Progress (Optional)
                if (supportsProgress) ...[
                  ItemEntryProgressSection(
                    library: _library,
                    pageController: _pageController,
                    totalPageController: _totalPageController,
                    chapterController: _chapterController,
                    totalChapterController: _totalChapterController,
                    seasonController: _seasonController,
                    totalSeasonController: _totalSeasonController,
                    volumeController: _volumeController,
                    totalVolumeController: _totalVolumeController,
                    currentProgressController: _currentProgressController,
                    totalProgressController: _totalProgressController,
                  ),
                  const SizedBox(height: 16),
                ],

                // 5. Dates & Meta
                ItemEntryDatesSection(
                  tracksDates: tracksDates,
                  supportsWishlist: supportsWishlist,
                  startDate: _startDate,
                  completionDate: _completionDate,
                  acquisitionDate: _acquisitionDate,
                  isWishlist: _isWishlist,
                  isCollection: _isCollection,
                  onDateChanged: (type, ts) {
                    setState(() {
                      if (type == 'start') _startDate = ts;
                      if (type == 'completion') _completionDate = ts;
                      if (type == 'acquisition') _acquisitionDate = ts;
                    });
                  },
                  onWishlistChanged: (val) => setState(() => _isWishlist = val),
                  onCollectionChanged: (val) =>
                      setState(() => _isCollection = val),
                ),
                const SizedBox(height: 16),

                // 6. Attributes
                ItemEntryAttributesSection(
                  attributes: _attributes,
                  allAttributeTypes: _allAttributeTypes,
                  onAttributeAdded: (attr) =>
                      setState(() => _attributes.add(attr)),
                  onRemoveAttribute: (idx) =>
                      setState(() => _attributes.removeAt(idx)),
                  onCreateAttributeType: _handleCreateAttributeType,
                ),
                // Bottom spacing
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
