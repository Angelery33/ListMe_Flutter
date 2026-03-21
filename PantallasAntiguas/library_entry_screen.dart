import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models.dart';
import '../../data/database_helper.dart';
import '../../providers/library_provider.dart';
import '../app_theme.dart';
import '../components/responsive_container.dart';

class LibraryEntryScreen extends StatefulWidget {
  final Library? library; // If null, create new

  const LibraryEntryScreen({super.key, this.library});

  @override
  State<LibraryEntryScreen> createState() => _LibraryEntryScreenState();
}

class _LibraryEntryScreenState extends State<LibraryEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;
  final TextEditingController _genreController = TextEditingController();

  bool _supportsCompletion = false;
  bool _isGradeable = false;
  bool _isThematic = false;
  bool _supportsWishlist = false;
  bool _tracksDates = false;
  bool _supportsPrice = false;
  int _genreLayoutMode = 0; // 0: Normal, 1: Sections, 2: Grouped
  bool _isCompact = false;
  bool _supportsProgress = false;
  String? _progressType;
  late TextEditingController _customProgressUnitController;
  String? _defaultCategory; // 'Book', 'Anime', 'Manga', 'Movie'
  int _ratingScale = 10;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.library?.name ?? '');
    _descController = TextEditingController(
      text: widget.library?.description ?? '',
    );
    _supportsCompletion = widget.library?.supportsCompletion ?? false;
    _isGradeable = widget.library?.isGradeable ?? false;
    _isThematic = widget.library?.isThematic ?? false;
    _supportsWishlist = widget.library?.supportsWishlist ?? false;
    _tracksDates = widget.library?.tracksDates ?? false;
    _supportsPrice = widget.library?.supportsPrice ?? false;
    _genreLayoutMode = widget.library?.genreLayoutMode ?? 0;
    _isCompact = widget.library?.isCompact ?? false;
    _supportsProgress = widget.library?.supportsProgress ?? false;
    _progressType = widget.library?.progressType;
    _progressType = widget.library?.progressType;
    _defaultCategory = widget.library?.defaultCategory;
    _ratingScale = widget.library?.ratingScale ?? 10;

    // Fallback: If editing an old library without defaultCategory, try to infer it
    if (_defaultCategory == null && widget.library != null) {
      final t = (widget.library!.type ?? widget.library!.name).toLowerCase();
      if (t.contains('manga')) {
        _defaultCategory = 'Manga';
      } else if (t.contains('comic')) {
        _defaultCategory = 'Comic';
      } else if (t.contains('anime')) {
        _defaultCategory = 'Anime';
      } else if (t.contains('peli') ||
          t.contains('movie') ||
          t.contains('cine')) {
        _defaultCategory = 'Movie';
      } else if (t.contains('serie') || t.contains('tv')) {
        _defaultCategory = 'Series';
      } else if (t.contains('book') ||
          t.contains('libro') ||
          t.contains('lectura')) {
        _defaultCategory = 'Book';
      } else if (t.contains('figura')) {
        _defaultCategory = 'Figures';
      }
    }

    _customProgressUnitController = TextEditingController(
      text: widget.library?.customProgressUnit ?? '',
    );

    if (widget.library != null && widget.library!.isThematic) {
      // Load genres if editing and thematic
      Future.microtask(
        () => Provider.of<LibraryProvider>(
          context,
          listen: false,
        ).loadGenres(widget.library!.idLibrary!),
      );
    }
  }

  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _genreController.dispose();
    _customProgressUnitController.dispose();
    super.dispose();
  }

  void _saveLibrary() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final provider = Provider.of<LibraryProvider>(context, listen: false);

      final newLib = widget.library != null
          ? widget.library!.copyWith(
              name: _nameController.text.trim(),
              description: _descController.text.trim(),
              // Save type as well for compatibility
              type: _defaultCategory,
              supportsCompletion: _supportsCompletion,
              isGradeable: _isGradeable,
              isThematic: _isThematic,
              supportsWishlist: _supportsWishlist,
              tracksDates: _tracksDates,
              supportsPrice: _supportsPrice,
              genreLayoutMode: _genreLayoutMode,
              isCompact: _isCompact,
              supportsProgress: _supportsProgress,
              progressType: _progressType,
              customProgressUnit:
                  _customProgressUnitController.text.trim().isEmpty
                  ? null
                  : _customProgressUnitController.text.trim(),
              defaultCategory: _defaultCategory,
              ratingScale: _ratingScale,
            )
          : Library(
              name: _nameController.text.trim(),
              description: _descController.text.trim(),
              type: _defaultCategory, // Save type
              supportsCompletion: _supportsCompletion,
              isGradeable: _isGradeable,
              isThematic: _isThematic,
              supportsWishlist: _supportsWishlist,
              tracksDates: _tracksDates,
              supportsPrice: _supportsPrice,
              genreLayoutMode: _genreLayoutMode,
              isCompact: _isCompact,
              supportsProgress: _supportsProgress,
              progressType: _progressType,
              customProgressUnit:
                  _customProgressUnitController.text.trim().isEmpty
                  ? null
                  : _customProgressUnitController.text.trim(),
              defaultCategory: _defaultCategory,
              ratingScale: _ratingScale,
            );

      try {
        int libId;
        if (widget.library == null) {
          libId = await provider.addLibrary(newLib);
        } else {
          await provider.updateLibrary(newLib);
          libId = widget.library!.idLibrary!;
        }

        if (libId != -1) {
          // Handle Genres if Thematic
          // We can't really add genres if it's a NEW library until we get the ID,
          // which we handled via returning ID for addLibrary.
          // But for UI simplicity in this pass, user adds genres to a list in UI and we save them after library creation?
          // Or we enable adding genres only after creation?
          // The prompt implies instant parity. The provided kotlin code seems to do everything in one viewmodel state.
          // Provider state for genres is tied to a specific library ID.
          // For a NEW library, we might need to store genres locally and insert them after getting ID.

          // However, my `LibraryProvider` stores genres in `_genres` which is overwritten by `loadGenres`.
          // If I add genres locally here, I should loop and insert them using the new ID.
          // BUT, the interface for adding genres IS inside this screen.

          // Simplest approach for "Create New":
          // 1. User configures lib.
          // 2. User adds genres -> Store in local List<String>.
          // 3. On Save, insert Lib -> Get ID -> Insert Genres.

          // Simplest approach for "Edit":
          // 1. Load genres from DB.
          // 2. Add/Remove acts directly on DB (or batch save, but direct is easier to impl with current provider methods).

          // Let's implement the "Direct to DB" for Edit, and "Local list then Batch" for Create.

          if (widget.library == null && _isThematic) {
            // Batch insert local genres
            // Wait, I implemented `addGenre` taking `LibraryGenre` object with ID. I need ID.
            // So I definitely need to do it AFTER lib creation.
            for (var gName in _localNewGenres) {
              await provider.addGenre(
                LibraryGenre(libraryId: libId, name: gName),
              );
            }
          }
        }

        if (mounted) Navigator.pop(context);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Error: $e")));
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  // Local list for NEW libraries
  List<String> _localNewGenres = [];

  void _addGenre() {
    if (_genreController.text.trim().isEmpty) return;
    final name = _genreController.text.trim();

    if (widget.library != null) {
      // Direct add to DB
      Provider.of<LibraryProvider>(context, listen: false).addGenre(
        LibraryGenre(libraryId: widget.library!.idLibrary!, name: name),
      );
    } else {
      // Local list
      setState(() {
        _localNewGenres.add(name);
      });
    }
    _genreController.clear();
  }

  void _deleteGenre(LibraryGenre? dbGenre, int index) {
    if (widget.library != null && dbGenre != null) {
      Provider.of<LibraryProvider>(
        context,
        listen: false,
      ).deleteGenre(dbGenre.id!, widget.library!.idLibrary!);
    } else {
      setState(() {
        _localNewGenres.removeAt(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Genres list source
    final provider = Provider.of<LibraryProvider>(context);
    final displayedGenres = widget.library != null
        ? provider.genres
        : _localNewGenres
              .map((n) => LibraryGenre(libraryId: -1, name: n))
              .toList();

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: AppTheme.getAppBarGradient(context),
        title: Text(widget.library == null ? "Nueva Lista" : "Editar Lista"),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveLibrary,
            tooltip: "Guardar",
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ResponsiveContainer(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _nameController,
                                decoration: const InputDecoration(
                                  labelText: "Nombre *",
                                  prefixIcon: Icon(Icons.list_alt),
                                  border: OutlineInputBorder(),
                                ),
                                validator: (v) =>
                                    v!.isEmpty ? "Requerido" : null,
                                textCapitalization:
                                    TextCapitalization.sentences,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _descController,
                                decoration: const InputDecoration(
                                  labelText: "Descripción (Opcional)",
                                  prefixIcon: Icon(Icons.description),
                                  border: OutlineInputBorder(),
                                ),
                                maxLines: 3,
                                textCapitalization:
                                    TextCapitalization.sentences,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Tipo de Lista",
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                              ),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<String>(
                                value: _defaultCategory,
                                decoration: const InputDecoration(
                                  labelText: 'Categoría para Importar',
                                  prefixIcon: Icon(Icons.import_contacts),
                                  border: OutlineInputBorder(),
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: null,
                                    child: Text("General / Otros"),
                                  ),
                                  DropdownMenuItem(
                                    value: "Book",
                                    child: Text("Libros"),
                                  ),
                                  DropdownMenuItem(
                                    value: "Manga",
                                    child: Text("Manga"),
                                  ),
                                  DropdownMenuItem(
                                    value: "Comic",
                                    child: Text("Cómic"),
                                  ),
                                  DropdownMenuItem(
                                    value: "Anime",
                                    child: Text("Anime"),
                                  ),
                                  DropdownMenuItem(
                                    value: "Movie",
                                    child: Text("Películas"),
                                  ),
                                  DropdownMenuItem(
                                    value: "Series",
                                    child: Text("Series / TV"),
                                  ),
                                  DropdownMenuItem(
                                    value: "Figures",
                                    child: Text("Figuras"),
                                  ),
                                  DropdownMenuItem(
                                    value: "Funko",
                                    child: Text("Funko Pop"),
                                  ),
                                ],
                                onChanged: (val) {
                                  setState(() {
                                    // Auto-populate name if empty or matches a previous auto-suggestion
                                    final currentName = _nameController.text
                                        .trim();
                                    final categoryNames = [
                                      "Libros",
                                      "Manga",
                                      "Cómic",
                                      "Anime",
                                      "Cine / Series",
                                      "Figuras",
                                      "Colección Funko",
                                      "Nueva Lista",
                                      "",
                                    ];

                                    if (categoryNames.contains(currentName)) {
                                      if (val == "Book") {
                                        _nameController.text = "Libros";
                                      } else if (val == "Manga") {
                                        _nameController.text = "Manga";
                                      } else if (val == "Comic") {
                                        _nameController.text = "Cómic";
                                      } else if (val == "Anime") {
                                        _nameController.text = "Anime";
                                      } else if (val == "Movie") {
                                        _nameController.text = "Películas";
                                      } else if (val == "Series") {
                                        _nameController.text = "Series / TV";
                                      } else if (val == "Figures") {
                                        _nameController.text = "Figuras";
                                      } else if (val == "Funko") {
                                        _nameController.text =
                                            "Colección Funko";
                                      }
                                    }

                                    _defaultCategory =
                                        val; // RESTORED ASSIGNMENT

                                    // Auto-populate genres if category selected
                                    if (val != null) {
                                      final defaults =
                                          DatabaseHelper.defaultGenres[val];
                                      if (defaults != null) {
                                        _localNewGenres.addAll(
                                          defaults.where(
                                            (g) => !_localNewGenres.contains(g),
                                          ),
                                        );
                                      }
                                    }
                                    if (val == "Book" ||
                                        val == "Manga" ||
                                        val == "Comic") {
                                      _supportsCompletion = true;
                                      _isGradeable = true;
                                      _isThematic = true;
                                      _supportsWishlist = true;
                                      _tracksDates = true;
                                      _isCompact = true;
                                      _supportsProgress = true;
                                      _supportsPrice = false;
                                      if (val == "Book")
                                        _progressType = "Libro";
                                      if (val == "Manga" || val == "Comic") {
                                        _progressType = "Manga";
                                      }
                                    } else if (val == "Anime" ||
                                        val == "Movie" ||
                                        val == "Series") {
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
                                        _supportsProgress =
                                            false; // Movies don't track progress by default
                                        _progressType = "Manual";
                                      }
                                      if (val == "Series") {
                                        _supportsProgress =
                                            true; // Series track progress by default
                                        _progressType = "Serie";
                                      }
                                    } else if (val == "Figures" ||
                                        val == "Funko") {
                                      _supportsCompletion = true;
                                      _isGradeable = true;
                                      _isThematic = true;
                                      _supportsWishlist = true;
                                      _supportsPrice = true;
                                      _tracksDates = true;
                                      _isCompact = true;
                                      _supportsProgress = false;
                                      _progressType = "Manual";
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Column(
                            children: [
                              _buildFeatureSwitch(
                                "Ítems Completables",
                                "Permitir marcar ítems como completados",
                                _supportsCompletion,
                                (v) => setState(() => _supportsCompletion = v),
                                Icons.check_circle_outline,
                              ),
                              _buildFeatureSwitch(
                                "Es Calificable",
                                "Permitir puntuar los ítems",
                                _isGradeable,
                                (v) => setState(() => _isGradeable = v),
                                Icons.star_border,
                              ),
                              if (_isGradeable) ...[
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 8.0,
                                  ),
                                  child: DropdownButtonFormField<int>(
                                    value: _ratingScale,
                                    isExpanded: true,
                                    decoration: const InputDecoration(
                                      labelText: 'Escala de Puntuación',
                                      prefixIcon: Icon(Icons.score),
                                      border: OutlineInputBorder(),
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                        value: 5,
                                        child: Text("Sobre 5 Estrellas (1-5)"),
                                      ),
                                      DropdownMenuItem(
                                        value: 10,
                                        child: Text(
                                          "Sobre 10 (Estándar, 5 estrellas)",
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: 100,
                                        child: Text("Sobre 100 (Porcentaje)"),
                                      ),
                                    ],
                                    onChanged: (val) =>
                                        setState(() => _ratingScale = val!),
                                  ),
                                ),
                              ],
                              _buildFeatureSwitch(
                                "Es Temática",
                                "Organizar ítems por géneros personalizados",
                                _isThematic,
                                (v) => setState(() => _isThematic = v),
                                Icons.category_outlined,
                              ),
                              _buildFeatureSwitch(
                                "Lista de Deseos",
                                "Soportar ítems deseados vs adquiridos",
                                _supportsWishlist,
                                (v) => setState(() => _supportsWishlist = v),
                                Icons.card_giftcard,
                              ),
                              _buildFeatureSwitch(
                                "Seguimiento de Fechas",
                                "Registrar fechas de inicio y fin",
                                _tracksDates,
                                (v) => setState(() => _tracksDates = v),
                                Icons.date_range,
                              ),
                              _buildFeatureSwitch(
                                "Habilitar Precios",
                                "Seguimiento de costes y presupuestos",
                                _supportsPrice,
                                (v) => setState(() => _supportsPrice = v),
                                Icons.attach_money,
                              ),
                              _buildFeatureSwitch(
                                "Vista Compacta",
                                "Mostrar tarjetas más pequeñas en la lista",
                                _isCompact,
                                (v) => setState(() => _isCompact = v),
                                Icons.view_comfy_alt_outlined,
                              ),
                              _buildFeatureSwitch(
                                "Seguimiento de Progreso",
                                "Contabilizar páginas, capítulos, niveles...",
                                _supportsProgress,
                                (v) => setState(() => _supportsProgress = v),
                                Icons.trending_up,
                              ),
                            ],
                          ),
                        ),
                      ),

                      if (_supportsProgress) ...[
                        const SizedBox(height: 16),
                        Card(
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Configuración de Progreso",
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                ),
                                const SizedBox(height: 16),
                                DropdownButtonFormField<String>(
                                  value: _progressType,
                                  decoration: const InputDecoration(
                                    labelText: 'Tipo de seguimiento',
                                    prefixIcon: Icon(Icons.settings_overscan),
                                    border: OutlineInputBorder(),
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                      value: null,
                                      child: Text("Ninguno"),
                                    ),
                                    DropdownMenuItem(
                                      value: "Manual",
                                      child: Text("Manual"),
                                    ),
                                    DropdownMenuItem(
                                      value: "Libro",
                                      child: Text("Libro"),
                                    ),
                                    DropdownMenuItem(
                                      value: "Serie",
                                      child: Text("Serie"),
                                    ),
                                    DropdownMenuItem(
                                      value: "Anime",
                                      child: Text("Anime"),
                                    ),
                                    DropdownMenuItem(
                                      value: "Manga",
                                      child: Text("Manga"),
                                    ),
                                  ],
                                  onChanged: (val) =>
                                      setState(() => _progressType = val),
                                ),
                                if (_progressType == "Manual") ...[
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _customProgressUnitController,
                                    decoration: const InputDecoration(
                                      labelText: 'Unidad personalizada',
                                      hintText:
                                          'ej: Artículo, Nivel, Misión...',
                                      prefixIcon: Icon(Icons.edit),
                                      border: OutlineInputBorder(),
                                    ),
                                    textCapitalization:
                                        TextCapitalization.sentences,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],

                      if (_isThematic) ...[
                        const SizedBox(height: 16),
                        Card(
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Personalizar Géneros",
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _genreController,
                                        decoration: const InputDecoration(
                                          hintText: "Nuevo Género",
                                          prefixIcon: Icon(Icons.label_outline),
                                          border: OutlineInputBorder(),
                                        ),
                                        textCapitalization:
                                            TextCapitalization.sentences,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    FilledButton.icon(
                                      onPressed: _addGenre,
                                      icon: const Icon(Icons.add),
                                      label: const Text("Añadir"),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                if (displayedGenres.isEmpty)
                                  const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        "Sin géneros definidos.",
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ),
                                  ),
                                ...displayedGenres.asMap().entries.map((entry) {
                                  final idx = entry.key;
                                  final g = entry.value;
                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 4,
                                    ),
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerHighest
                                        .withValues(alpha: 0.5),
                                    child: ListTile(
                                      leading: const Icon(Icons.label),
                                      title: Text(g.name),
                                      trailing: IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.redAccent,
                                        ),
                                        onPressed: () => _deleteGenre(
                                          g.id == null ? null : g,
                                          idx,
                                        ),
                                      ),
                                      dense: true,
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                      ],

                      if (_isThematic) ...[
                        const SizedBox(height: 16),

                        // ... Genre List (Keeping existing code) ...
                        const SizedBox(height: 16),
                        Card(
                          elevation: 2,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  "Configuración de Visualización",
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                ),
                              ),
                              RadioListTile<int>(
                                title: const Text("Ignorar Temáticas"),
                                subtitle: const Text("Estándar"),
                                value: 0,
                                groupValue: _genreLayoutMode,
                                onChanged: (v) =>
                                    setState(() => _genreLayoutMode = v!),
                              ),
                              RadioListTile<int>(
                                title: const Text("Secciones con Cabeceras"),
                                subtitle: const Text("Agrupar por tema"),
                                value: 1,
                                groupValue: _genreLayoutMode,
                                onChanged: (v) =>
                                    setState(() => _genreLayoutMode = v!),
                              ),
                              RadioListTile<int>(
                                title: const Text("Agrupado sin Cabeceras"),
                                subtitle: const Text("Agrupar por tema"),
                                value: 2,
                                groupValue: _genreLayoutMode,
                                onChanged: (v) =>
                                    setState(() => _genreLayoutMode = v!),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildFeatureSwitch(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
    IconData icon,
  ) {
    return SwitchListTile(
      secondary: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      value: value,
      onChanged: onChanged,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
