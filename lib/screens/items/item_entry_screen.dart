import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/services/image_picker_service.dart';
import '../../core/services/firebase_storage_service.dart';
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

class ItemEntryScreen extends StatefulWidget {
  const ItemEntryScreen({super.key});

  @override
  State<ItemEntryScreen> createState() => _ItemEntryScreenState();
}

class _ItemEntryScreenState extends State<ItemEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePickerService();
  final _firebaseStorage = FirebaseStorageService();

  late ListModel _list;
  ItemModel? _item;
  bool _initialized = false;
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

  String _status = "PENDING";
  bool _isCurrent = false;
  bool _wishlist = false;
  bool _isCollection = false;
  double _score = 0;
  String? _genre;
  int? _acquisitionDate;
  int? _startDate;
  int? _completionDate;
  String? _importedRemoteImageUrl;
  double? _importedExternalRating;

  final List<String> _newImages = [];
  final List<XFile> _newImageFiles = [];
  List<ItemImageModel> _existingImages = [];
  final List<ItemImageModel> _deletedImages = [];
  int? _favoriteImageIndex;

  List<LibraryGenreModel> _libraryGenres = [];
  List<AttributeTypeModel> _attributeTypes = [];
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
      _initControllers();
      _loadData();
      _initialized = true;
    }
  }

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

  Future<void> _deleteOldImages(ItemsProvider itemsProvider) async {
    for (final img in _deletedImages) {
      // Delete from database
      if (img.id != null) {
        try { await itemsProvider.deleteItemImage(img.id!); } catch (_) {}
      }
      // Delete from Firebase Storage
      await _firebaseStorage.deleteImage(img.remoteImageUrl);
    }
  }

  Future<String?> _uploadImagesToCloud(int itemDbId) async {
    if (_newImageFiles.isEmpty) return null;

    String? favoriteRemoteUrl;

    for (int i = 0; i < _newImageFiles.length; i++) {
      final remoteUrl = await _firebaseStorage.uploadImage(
        _newImageFiles[i],
        '${itemDbId}_$i',
      );

      if (remoteUrl == null) continue;

      final isFavorite = _favoriteImageIndex == _existingImages.length + i;
      if (isFavorite || favoriteRemoteUrl == null) favoriteRemoteUrl = remoteUrl;

      if (mounted) {
        final newImage = ItemImageModel(
          idItem: itemDbId,
          imageUri: _newImages[i],
          remoteImageUrl: remoteUrl,
          isFavorite: isFavorite,
        );
        await context.read<ItemsProvider>().createItemImage(newImage);
      }
    }

    return favoriteRemoteUrl;
  }

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
            const SnackBar(content: Text("Imagen importada añadida")),
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
    }
  }

  void _showAddGenreDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Añadir Género/Temática'),
        content: TextField(
          controller: controller,
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
              final name = controller.text.trim();
              if (name.isNotEmpty && _list.id != null) {
                final listsProvider = context.read<ListsProvider>();
                await listsProvider.addLibraryGenre(_list.id!, name);
                if (mounted) {
                  final genres = await listsProvider.getLibraryGenres(
                    _list.id!,
                  );
                  setState(() {
                    _libraryGenres = genres;
                    _genre = name;
                  });
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

  Future<String?> _showCreateAttributeTypeDialog() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Nuevo Tipo de Atributo"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: "Nombre del tipo"),
          textCapitalization: TextCapitalization.sentences,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                Navigator.pop(dialogContext, name);
              }
            },
            child: const Text("Crear"),
          ),
        ],
      ),
    );
    return result;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isSaving) return;

    setState(() => _isSaving = true);

    try {
      final itemsProvider = context.read<ItemsProvider>();

      String? progressUnit;
      int? finalCurrent;
      int? finalTotal;

      final progressType = _list.progressType;

      if (progressType == "Libro" || progressType == "Manga") {
        progressUnit = "Página";
        finalCurrent = int.tryParse(_pageController.text);
        finalTotal = int.tryParse(_totalPageController.text);
      } else if (progressType == "Serie" || progressType == "Anime") {
        progressUnit = "Episodio";
        finalCurrent = int.tryParse(_chapterController.text);
        finalTotal = int.tryParse(_totalChapterController.text);
      } else {
        progressUnit = _list.customProgressUnit ?? "Progreso";
        finalCurrent = int.tryParse(_currentProgressController.text);
        finalTotal = int.tryParse(_totalProgressController.text);
      }

      String finalImagePath = _newImages.isNotEmpty
          ? _newImages.first
          : (_item?.imagePath != null ? _item?.imagePath ?? '' : '');
      String itemRemoteImageUrl =
          _item?.remoteImageUrl ?? _importedRemoteImageUrl ?? '';

      setState(() => _isSaving = true);

      await _deleteOldImages(itemsProvider);

      final newItem = ItemModel(
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
      );

      int? savedItemId;
      if (_item == null) {
        final createdItem = await itemsProvider.createItem(newItem);
        if (createdItem == null)
          throw Exception(
            itemsProvider.errorMessage ?? "Error creando el artículo",
          );
        savedItemId = createdItem.id;
      } else {
        final success = await itemsProvider.updateItem(_item!.id!, newItem);
        if (!success)
          throw Exception(
            itemsProvider.errorMessage ?? "Error actualizando el artículo",
          );
        savedItemId = _item!.id;
      }

      if (savedItemId != null) {
        // Persist existing images that have no gallery record yet
        // (e.g. imported IMDB images stored only in ItemModel, not in ItemImageModel)
        bool persistedNewGalleryEntries = false;
        for (int i = 0; i < _existingImages.length; i++) {
          final img = _existingImages[i];
          if (img.id != null) continue;
          final url = img.remoteImageUrl?.isNotEmpty == true
              ? img.remoteImageUrl!
              : (img.imageUri?.isNotEmpty == true ? img.imageUri! : '');
          if (url.isEmpty) continue;
          try {
            await itemsProvider.createItemImage(ItemImageModel(
              idItem: savedItemId,
              imageUri: url,
              remoteImageUrl: img.remoteImageUrl,
              isFavorite: (_favoriteImageIndex ?? 0) == i,
            ));
            persistedNewGalleryEntries = true;
          } catch (_) {}
        }

        // Upload new images and collect the favorite remote URL
        String? uploadedFavoriteUrl;
        if (_newImageFiles.isNotEmpty) {
          uploadedFavoriteUrl = await _uploadImagesToCloud(savedItemId);
        }

        // Only sync ItemModel.remoteImageUrl when something actually changed:
        // new images were uploaded, or an unregistered image was just persisted.
        final bool remoteUrlChanged =
            uploadedFavoriteUrl != null || persistedNewGalleryEntries;

        if (remoteUrlChanged && mounted) {
          final int favIdx = _favoriteImageIndex ?? 0;
          String? bestRemoteUrl;
          if (favIdx < _existingImages.length) {
            final favImg = _existingImages[favIdx];
            bestRemoteUrl = favImg.remoteImageUrl?.isNotEmpty == true
                ? favImg.remoteImageUrl
                : favImg.imageUri;
          }
          bestRemoteUrl ??= uploadedFavoriteUrl ?? itemRemoteImageUrl;

          if (bestRemoteUrl.isNotEmpty) {
            try {
              await itemsProvider.updateItem(
                savedItemId,
                newItem.copyWith(id: savedItemId, remoteImageUrl: bestRemoteUrl),
              );
            } catch (_) {}
          }
        }
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error al guardar: $e")));
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
        title: _item == null ? "Nuevo Item" : "Editar Item",
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
