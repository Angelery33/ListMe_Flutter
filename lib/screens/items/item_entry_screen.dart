import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/items/item_model.dart';
import '../../data/lists/list_model.dart';
import '../../providers/items/items_provider.dart';
import '../../widgets/items/entry/entry_image_picker.dart';
import '../../widgets/items/entry/entry_main_info_section.dart';
import '../../widgets/items/entry/entry_status_progress_section.dart';
import '../../widgets/items/entry/entry_properties_section.dart';
import '../../widgets/items/entry/entry_dates_section.dart';
import '../../widgets/items/entry/entry_attributes_section.dart';

class ItemEntryScreen extends StatefulWidget {
  const ItemEntryScreen({super.key});

  @override
  State<ItemEntryScreen> createState() => _ItemEntryScreenState();
}

class _ItemEntryScreenState extends State<ItemEntryScreen> {
  late ListModel _list;
  ItemModel? _item;
  bool _initialized = false;
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  late TextEditingController _currentProgressController;
  late TextEditingController _totalProgressController;
  late TextEditingController _seasonController;
  late TextEditingController _totalSeasonController;
  late TextEditingController _chapterController;
  late TextEditingController _totalChapterController;

  // State
  String _status = "PENDING";
  bool _isCurrent = false;
  bool _wishlist = false;
  double _score = 0;
  String? _genre;
  int? _acquisitionDate;
  int? _startDate;
  int? _completionDate;
  
  final List<String> _newImages = [];
  final List<String> _existingImages = [];

  bool _isSaving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      _list = args['list'] as ListModel;
      _item = args['item'] as ItemModel?;
      _initValues();
      _initialized = true;
    }
  }

  void _initValues() {
    final item = _item;
    _nameController = TextEditingController(text: item?.name ?? "");
    _descController = TextEditingController(text: item?.description ?? "");
    _priceController = TextEditingController(text: item?.price?.toString() ?? "");
    _currentProgressController = TextEditingController(text: item?.currentProgress?.toString() ?? "");
    _totalProgressController = TextEditingController(text: item?.totalProgress?.toString() ?? "");
    _seasonController = TextEditingController(text: item?.season?.toString() ?? "");
    _totalSeasonController = TextEditingController(text: item?.totalSeason?.toString() ?? "");
    _chapterController = TextEditingController(text: item?.chapter?.toString() ?? "");
    _totalChapterController = TextEditingController(text: item?.totalChapter?.toString() ?? "");

    _status = item?.status ?? "PENDING";
    _isCurrent = item?.current ?? false;
    _wishlist = item?.wishlist ?? false;
    _score = item?.score ?? 0;
    _genre = item?.genre;
    _acquisitionDate = item?.acquisitionDate;
    _startDate = item?.startDate;
    _completionDate = item?.completionDate;
    
    // Simplificado: por ahora solo mostramos la imagen principal si existe
    if (item?.imagePath != null) {
      _existingImages.add(item!.imagePath!);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _currentProgressController.dispose();
    _totalProgressController.dispose();
    _seasonController.dispose();
    _totalSeasonController.dispose();
    _chapterController.dispose();
    _totalChapterController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSaving = true);

    try {
      final itemsProvider = context.read<ItemsProvider>();
      
      final newItem = ItemModel(
        id: _item?.id,
        idLibrary: _list.id!,
        name: _nameController.text.trim(),
        description: _descController.text.trim(),
        status: _status,
        genre: _genre,
        score: _score,
        wishlist: _wishlist,
        current: _isCurrent,
        price: double.tryParse(_priceController.text),
        imagePath: _newImages.isNotEmpty ? _newImages.first : (_item?.imagePath),
        currentProgress: int.tryParse(_currentProgressController.text),
        totalProgress: int.tryParse(_totalProgressController.text),
        season: int.tryParse(_seasonController.text),
        totalSeason: int.tryParse(_totalSeasonController.text),
        chapter: int.tryParse(_chapterController.text),
        totalChapter: int.tryParse(_totalChapterController.text),
        acquisitionDate: _acquisitionDate,
        startDate: _startDate,
        completionDate: _completionDate,
      );

      bool success;
      if (_item == null) {
        success = await itemsProvider.createItem(newItem);
        if (!success) {
          throw Exception(itemsProvider.errorMessage ?? "Error creando el artículo");
        }
      } else {
        success = await itemsProvider.updateItem(_item!.id!, newItem);
        if (!success) {
          throw Exception(itemsProvider.errorMessage ?? "Error actualizando el artículo");
        }
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al guardar: $e")),
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

    return Scaffold(
      appBar: AppBar(
        title: Text(_item == null ? "Nuevo Item" : "Editar Item"),
        actions: [
          if (_isSaving)
            const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()))
          else
            IconButton(onPressed: _save, icon: const Icon(Icons.check_rounded)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              EntryImagePicker(
                existingImages: _existingImages,
                newImages: _newImages,
                onPickImage: () {
                  // Simulación por ahora, en una app real usarías image_picker
                  setState(() => _newImages.add("https://placeholder.com/150"));
                },
                onRemoveExisting: (idx) => setState(() => _existingImages.removeAt(idx)),
                onRemoveNew: (idx) => setState(() => _newImages.removeAt(idx)),
              ),
              const SizedBox(height: 24),
              EntryMainInfoSection(
                nameController: _nameController,
                descController: _descController,
              ),
              const SizedBox(height: 24),
              EntryStatusProgressSection(
                status: _status,
                onStatusChanged: (val) => setState(() => _status = val),
                isCurrent: _isCurrent,
                onCurrentChanged: (val) => setState(() => _isCurrent = val),
                supportsProgress: _list.supportsProgress,
                progressType: _list.type,
                currentProgressController: _currentProgressController,
                totalProgressController: _totalProgressController,
                seasonController: _seasonController,
                totalSeasonController: _totalSeasonController,
                chapterController: _chapterController,
                totalChapterController: _totalChapterController,
              ),
              const SizedBox(height: 24),
              EntryPropertiesSection(
                genre: _genre,
                availableGenres: const ["Acción", "Aventura", "Comedia", "Drama", "Fantasía", "Terror", "Romance"],
                onGenreChanged: (val) => setState(() => _genre = val),
                priceController: _priceController,
                wishlist: _wishlist,
                onWishlistChanged: (val) => setState(() => _wishlist = val),
                score: _score,
                onScoreChanged: (val) => setState(() => _score = val),
                supportsPrice: _list.supportsPrice,
              ),
              const SizedBox(height: 24),
              EntryDatesSection(
                acquisitionDate: _acquisitionDate,
                startDate: _startDate,
                completionDate: _completionDate,
                onAcquisitionDateChanged: (val) => setState(() => _acquisitionDate = val),
                onStartDateChanged: (val) => setState(() => _startDate = val),
                onCompletionDateChanged: (val) => setState(() => _completionDate = val),
                tracksDates: _list.tracksDates,
              ),
              const SizedBox(height: 24),
              EntryAttributesSection(
                attributes: const [], // Por implementar carga real
                allTypes: const [],
                onRemove: (_) {},
                onAddRequest: () {},
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
