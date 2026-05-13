import 'package:flutter/material.dart';
import '../../core/i18n/l10n_extension.dart';
import 'package:provider/provider.dart';
import '../../data/lists/list_model.dart';
import '../../data/lists/library_genre_model.dart';
import '../../providers/lists/lists_provider.dart';
import '../../data/lists/lists_repository.dart';
import '../../widgets/lists/config/config_main_info_section.dart';
import '../../widgets/lists/config/config_type_section.dart';
import '../../widgets/lists/config/config_features_section.dart';
import '../../widgets/lists/config/config_rating_progress_section.dart';
import '../../widgets/lists/config/config_genres_section.dart';
import '../../widgets/lists/config/config_display_section.dart';
import '../../widgets/lists/config/config_icon_color_section.dart';
import '../../widgets/shared/custom_gradient_app_bar.dart';
import '../../widgets/shared/app_shell.dart';

/// Géneros por defecto por tipo de lista (igual que la versión legacy)
const Map<String, List<String>> kDefaultGenres = {
  'Book': [
    'Fantasía',
    'Ciencia Ficción',
    'Romance',
    'Misterio',
    'Terror',
    'Historia',
    'Aventura',
    'Otros',
  ],
  'Manga': [
    'Shounen',
    'Shoujo',
    'Seinen',
    'Josei',
    'Isekai',
    'Mecha',
    'Slice of Life',
    'Otros',
  ],
  'Comic': ['Superhéroes', 'Sci-Fi', 'Horror', 'Fantasía', 'Acción', 'Otros'],
  'Anime': [
    'Shounen',
    'Shoujo',
    'Seinen',
    'Mecha',
    'Isekai',
    'Slice of Life',
    'Deportes',
    'Otros',
  ],
  'Movie': [
    'Acción',
    'Comedia',
    'Drama',
    'Terror',
    'Sci-Fi',
    'Animación',
    'Documental',
    'Otros',
  ],
  'Series': [
    'Acción',
    'Comedia',
    'Drama',
    'Thriller',
    'Sci-Fi',
    'Animación',
    'Documental',
    'Otros',
  ],
  'Figures': [
    'Anime',
    'Videojuegos',
    'Películas',
    'Cómics',
    'Vocaloid',
    'Original',
    'Otros',
  ],
  'Funko': [
    'Marvel',
    'DC',
    'Anime',
    'Star Wars',
    'Harry Potter',
    'Disney',
    'Películas',
    'Otros',
  ],
};

/// Nombre sugerido a mostrar según categoría
const Map<String, String> kCategoryDefaultNames = {
  'Book': 'Libros',
  'Manga': 'Manga',
  'Comic': 'Cómic',
  'Anime': 'Anime',
  'Movie': 'Películas',
  'Series': 'Series / TV',
  'Figures': 'Figuras',
  'Funko': 'Colección Funko',
};

class ListConfigScreen extends StatefulWidget {
  final ListModel? library;

  const ListConfigScreen({super.key, this.library});

  @override
  State<ListConfigScreen> createState() => _ListConfigScreenState();
}

class _ListConfigScreenState extends State<ListConfigScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;
  final TextEditingController _genreController = TextEditingController();
  late TextEditingController _customProgressUnitController;

  bool _supportsCompletion = false;
  bool _isGradeable = false;
  bool _isThematic = false;
  bool _supportsWishlist = false;
  bool _tracksDates = false;
  bool _supportsPrice = false;
  int _genreLayoutMode = 0;
  bool _isCompact = false;
  bool _supportsProgress = false;
  String? _progressType;
  String? _defaultCategory;
  int _ratingScale = 10;

  bool _isLoading = false;
  List<LibraryGenreModel> _displayedGenres = [];
  late String _selectedColor;
  late String _selectedIcon;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.library?.name ?? '');
    _descController = TextEditingController(
      text: widget.library?.description ?? '',
    );
    _customProgressUnitController = TextEditingController(
      text: widget.library?.customProgressUnit ?? '',
    );

    _supportsCompletion = widget.library?.supportsCompletion ?? false;
    _isGradeable = widget.library?.gradeable ?? false;
    _isThematic = widget.library?.thematic ?? false;
    _supportsWishlist = widget.library?.supportsWishlist ?? false;
    _tracksDates = widget.library?.tracksDates ?? false;
    _supportsPrice = widget.library?.supportsPrice ?? false;
    _genreLayoutMode = widget.library?.genreLayoutMode ?? 0;
    _isCompact = widget.library?.compact ?? false;
    _supportsProgress = widget.library?.supportsProgress ?? false;
    _progressType = widget.library?.progressType;
    _ratingScale = widget.library?.ratingScale ?? 10;
    _selectedColor = widget.library?.color ?? 'titanium';
    _selectedIcon = widget.library?.icon ?? 'list';

    // Preferir defaultCategory, si no type (compatibilidad con datos legacy)
    _defaultCategory = widget.library?.defaultCategory ?? widget.library?.type;

    // Cargar géneros en el siguiente frame para que Provider esté disponible
    if (widget.library != null && _isThematic) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _loadGenresIfEditing(),
      );
    }
  }

  Future<void> _loadGenresIfEditing() async {
    if (widget.library == null || widget.library!.id == null) return;
    try {
      final repo = Provider.of<ListsRepository>(context, listen: false);
      final genres = await repo.getLibraryGenres(widget.library!.id!);
      if (mounted) {
        setState(() {
          _displayedGenres = genres;
        });
      }
    } catch (_) {
      // Si no se pueden cargar los géneros, dejamos la lista vacía
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _genreController.dispose();
    _customProgressUnitController.dispose();
    super.dispose();
  }

  void _onCategoryChanged(String? val) {
    setState(() {
      _defaultCategory = val;

      // --- Auto-fill de nombre ---
      final autoNames = kCategoryDefaultNames.values.toList()..add('');
      final currentName = _nameController.text.trim();
      if (autoNames.contains(currentName) && val != null) {
        _nameController.text = kCategoryDefaultNames[val] ?? currentName;
      }

      // --- Auto-populate géneros por defecto (solo si no hay géneros ya) ---
      if (val != null && _displayedGenres.isEmpty) {
        final defaults = kDefaultGenres[val] ?? [];
        _displayedGenres = defaults
            .map((name) => LibraryGenreModel(libraryId: -1, name: name))
            .toList();
      }

      // --- Configuración de flags según categoría ---
      if (val == "Book" || val == "Manga" || val == "Comic") {
        _supportsCompletion = true;
        _isGradeable = true;
        _isThematic = true;
        _supportsWishlist = true;
        _tracksDates = true;
        _isCompact = true;
        _supportsProgress = true;
        _supportsPrice = false;
        if (val == "Book") _progressType = "Libro";
        if (val == "Manga" || val == "Comic") _progressType = "Manga";
      } else if (val == "Anime" || val == "Movie" || val == "Series") {
        _supportsCompletion = true;
        _isGradeable = true;
        _isThematic = true;
        _tracksDates = true;
        _isCompact = true;
        _supportsWishlist = false;
        _supportsPrice = false;
        if (val == "Anime") {
          _supportsProgress = true;
          _progressType = "Anime";
        }
        if (val == "Movie") {
          _supportsProgress = false;
          _progressType = "Manual";
        }
        if (val == "Series") {
          _supportsProgress = true;
          _progressType = "Serie";
        }
      } else if (val == "Figures" || val == "Funko") {
        _supportsCompletion = true;
        _isGradeable = true;
        _isThematic = true;
        _supportsWishlist = true;
        _supportsPrice = true;
        _tracksDates = true;
        _isCompact = true;
        _supportsProgress = true;
        _progressType = "Funko";
      }

      // --- Auto-fill de Icono según categoría ---
      if (val == "Book") _selectedIcon = "book";
      if (val == "Manga" || val == "Comic") _selectedIcon = "book";
      if (val == "Anime" || val == "Series" || val == "Movie")
        _selectedIcon = "tv";
      if (val == "Figures" || val == "Funko") _selectedIcon = "fitness";
    });
  }

  void _addGenre() async {
    if (_genreController.text.trim().isEmpty) return;
    final name = _genreController.text.trim();

    if (widget.library != null) {
      // Editing existing list, save directly to backend
      final provider = Provider.of<ListsProvider>(context, listen: false);
      final newGenre = await provider.addGenreToList(widget.library!.id!, name);
      if (newGenre != null && mounted) {
        setState(() {
          _displayedGenres.add(newGenre);
        });
      }
    } else {
      // Creating new list, keep locally
      setState(() {
        _displayedGenres.add(LibraryGenreModel(libraryId: -1, name: name));
      });
    }
    _genreController.clear();
  }

  void _deleteGenre(LibraryGenreModel dbGenre, int index) async {
    if (widget.library != null && dbGenre.id != null) {
      final provider = Provider.of<ListsProvider>(context, listen: false);
      final success = await provider.deleteGenreFromList(dbGenre.id!);
      if (success && mounted) {
        setState(() {
          _displayedGenres.removeAt(index);
        });
      }
    } else {
      setState(() {
        _displayedGenres.removeAt(index);
      });
    }
  }

  void _saveLibrary() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final provider = Provider.of<ListsProvider>(context, listen: false);

    final isNew = widget.library == null;

    final listObj = ListModel(
      id: widget.library?.id,
      name: _nameController.text.trim(),
      description: _descController.text.trim(),
      type: _defaultCategory,
      supportsCompletion: _supportsCompletion,
      gradeable: _isGradeable,
      thematic: _isThematic,
      supportsWishlist: _supportsWishlist,
      tracksDates: _tracksDates,
      supportsPrice: _supportsPrice,
      genreLayoutMode: _genreLayoutMode,
      compact: _isCompact,
      supportsProgress: _supportsProgress,
      progressType: _progressType,
      customProgressUnit: _customProgressUnitController.text.trim().isEmpty
          ? null
          : _customProgressUnitController.text.trim(),
      defaultCategory: _defaultCategory,
      ratingScale: _ratingScale,
      color: _selectedColor,
      icon: _selectedIcon,
    );

    try {
      if (isNew) {
        final success = await provider.createList(listObj);
        if (!success) {
          throw Exception(provider.errorMessage ?? "Error creando la lista");
        }
        if (_isThematic) {
          // If a new list was created successfully, the provider adds it to the list.
          // Getting the newly created list from the provider (assume it's the last one).
          final createdList = provider.lists.lastWhere(
            (l) => l.name == listObj.name,
          );
          // Insert queued genres
          for (var genre in _displayedGenres) {
            await provider.addGenreToList(createdList.id!, genre.name);
          }
        }
      } else {
        final success = await provider.updateList(widget.library!.id!, listObj);
        if (!success) {
          throw Exception(
            provider.errorMessage ?? "Error actualizando la lista",
          );
        }
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("${context.l10n.errorPrefix}: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentIndex: 0,
      appBar: CustomGradientAppBar(
        title: widget.library == null
            ? context.l10n.listConfigTitleCreate
            : context.l10n.listConfigTitleEdit,
        actions: [
          IconButton(
            icon: const Icon(Icons.check_rounded),
            onPressed: _saveLibrary,
            tooltip: context.l10n.commonSave,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ConfigTypeSection(
                      selectedCategory: _defaultCategory,
                      onChanged: _onCategoryChanged,
                    ),
                    const SizedBox(height: 16),
                    ConfigMainInfoSection(
                      nameController: _nameController,
                      descController: _descController,
                    ),
                    const SizedBox(height: 16),
                    ConfigIconColorSection(
                      selectedIcon: _selectedIcon,
                      selectedColor: _selectedColor,
                      onIconChanged: (v) => setState(() => _selectedIcon = v),
                      onColorChanged: (v) => setState(() => _selectedColor = v),
                    ),
                    const SizedBox(height: 16),
                    ConfigFeaturesSection(
                      supportsCompletion: _supportsCompletion,
                      onSupportsCompletionChanged: (v) =>
                          setState(() => _supportsCompletion = v),
                      isGradeable: _isGradeable,
                      onIsGradeableChanged: (v) =>
                          setState(() => _isGradeable = v),
                      isThematic: _isThematic,
                      onIsThematicChanged: (v) =>
                          setState(() => _isThematic = v),
                      supportsWishlist: _supportsWishlist,
                      onSupportsWishlistChanged: (v) =>
                          setState(() => _supportsWishlist = v),
                      tracksDates: _tracksDates,
                      onTracksDatesChanged: (v) =>
                          setState(() => _tracksDates = v),
                      supportsPrice: _supportsPrice,
                      onSupportsPriceChanged: (v) =>
                          setState(() => _supportsPrice = v),
                      isCompact: _isCompact,
                      onIsCompactChanged: (v) => setState(() => _isCompact = v),
                      supportsProgress: _supportsProgress,
                      onSupportsProgressChanged: (v) =>
                          setState(() => _supportsProgress = v),
                    ),
                    const SizedBox(height: 16),
                    ConfigRatingProgressSection(
                      isGradeable: _isGradeable,
                      ratingScale: _ratingScale,
                      onRatingScaleChanged: (v) =>
                          setState(() => _ratingScale = v),
                      supportsProgress: _supportsProgress,
                      progressType: _progressType,
                      onProgressTypeChanged: (v) =>
                          setState(() => _progressType = v),
                      customProgressUnitController:
                          _customProgressUnitController,
                    ),
                    const SizedBox(height: 16),
                    ConfigGenresSection(
                      isThematic: _isThematic,
                      displayedGenres: _displayedGenres,
                      genreController: _genreController,
                      onAddGenre: _addGenre,
                      onDeleteGenre: _deleteGenre,
                    ),
                    const SizedBox(height: 16),
                    ConfigDisplaySection(
                      isThematic: _isThematic,
                      genreLayoutMode: _genreLayoutMode,
                      onGenreLayoutModeChanged: (v) {
                        if (v != null) {
                          setState(() => _genreLayoutMode = v);
                        }
                      },
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }
}
