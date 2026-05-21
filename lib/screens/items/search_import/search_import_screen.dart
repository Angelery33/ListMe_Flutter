import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/i18n/l10n_extension.dart';
import '../../../core/services/external_api_service.dart';
import '../../../providers/settings/settings_provider.dart';
import '../../../widgets/shared/custom_gradient_app_bar.dart';
import '../../../widgets/items/search/search_result_card.dart';

/// Pantalla que permite al usuario buscar en APIs externas e importar metadatos en
/// el formulario de entrada de elementos.
///
/// La fuente de búsqueda se determina automáticamente a partir de [category], pero el usuario
/// puede sobrescribirla con los chips selectores de fuente. Admite paginación de scroll infinito
/// a través de un campo de búsqueda con rebote (debounced).
class SearchImportScreen extends StatefulWidget {
  /// La categoría de la lista (ej. `'Book'`, `'Anime'`, `'Movie'`) que determina
  /// a qué API externa consultar por defecto.
  final String category;

  const SearchImportScreen({super.key, required this.category});

  @override
  State<SearchImportScreen> createState() => _SearchImportScreenState();
}

/// Estado para [SearchImportScreen].
///
/// Gestiona la búsqueda con rebote, la carga de resultados paginados, la selección de fuente y
/// las llamadas de enriquecimiento de detalles realizadas cuando el usuario selecciona un resultado.
class _SearchImportScreenState extends State<SearchImportScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ExternalApiService _apiService = ExternalApiService.instance;

  /// Filas de resultados de búsqueda de la consulta activa.
  List<Map<String, dynamic>> _results = [];

  /// Indica si se está cargando la primera página.
  bool _isLoading = false;

  /// Indica si se está añadiendo una página posterior.
  bool _isLoadingMore = false;

  /// Mensaje de error de la búsqueda fallida más reciente, o `null`.
  String? _error;

  /// El número de página del lote cargado más recientemente (basado en 1).
  int _currentPage = 1;

  /// Indica si hay páginas adicionales disponibles para la consulta actual.
  bool _hasMore = true;

  final ScrollController _scrollController = ScrollController();

  /// Temporizador de rebote (debounce) para que la búsqueda no se active en cada pulsación de tecla.
  Timer? _debounce;

  /// Fuente de API seleccionada manualmente, o `null` para usar el valor por defecto de la categoría.
  String? _selectedSource;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// Aplica rebote al cambio de [query] para que la búsqueda se dispare solo después de que el usuario deje
  /// de escribir durante 600 ms.
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () {
      if (mounted) _search();
    });
  }

  /// Activa [_loadMore] cuando la posición del scroll alcanza el 90% de la lista.
  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.9 &&
        !_isLoadingMore &&
        _hasMore) {
      _loadMore();
    }
  }

  /// Ejecuta una nueva búsqueda para la consulta actual, reiniciando la paginación y
  /// mostrando un indicador de carga. Muestra un mensaje de error en caso de fallo.
  void _search() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final String omdbApiKey = settings.omdbApiKey.trim().isNotEmpty
        ? settings.omdbApiKey.trim()
        : "900e2548";

    setState(() {
      _isLoading = true;
      _results = [];
      _error = null;
      _currentPage = 1;
      _hasMore = true;
    });

    try {
      final results = await _performSearch(query, 1, omdbApiKey);

      if (mounted) {
        setState(() {
          _results = results;
          _isLoading = false;
          if (results.length < 10) _hasMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          String msg = e.toString().contains('401')
              ? "Error 401: Key de OMDb inválida. Prueba a obtener una gratis en omdbapi.com e introducirla en Ajustes."
              : "Error al buscar: $e";
          _error = msg;
        });
      }
    }
  }

  /// Obtiene la siguiente página de resultados para la consulta actual y los añade
  /// a [_results].
  Future<void> _loadMore() async {
    final query = _searchController.text.trim();
    if (query.isEmpty || _isLoadingMore || !_hasMore) return;

    setState(() => _isLoadingMore = true);

    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final String omdbApiKey = settings.omdbApiKey.trim().isNotEmpty
        ? settings.omdbApiKey.trim()
        : "900e2548";

    try {
      final nextPage = _currentPage + 1;
      final results = await _performSearch(query, nextPage, omdbApiKey);

      if (mounted) {
        setState(() {
          _results.addAll(results);
          _currentPage = nextPage;
          _isLoadingMore = false;
          if (results.length < 10) _hasMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingMore = false);
      }
    }
  }

  /// Dirige la búsqueda de [query] para [page] al método correcto de [ExternalApiService]
  /// basado en [widget.category] y la [_selectedSource] activa.
  ///
  /// Devuelve la lista de resultados brutos de la API que luego se normaliza en [_selectItem].
  Future<List<Map<String, dynamic>>> _performSearch(
    String query,
    int page,
    String omdbApiKey,
  ) async {
    final source = _selectedSource;
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final booksApiKey = settings.googleBooksApiKey.trim().isNotEmpty
        ? settings.googleBooksApiKey.trim()
        : null;

    switch (widget.category) {
      case 'Book':
        return await _apiService.searchBooks(query: query, page: page, apiKey: booksApiKey);
      case 'Anime':
        if (source == 'TMDb') {
          return await _apiService.searchTMDb(
            query: query,
            page: page,
            apiKey: settings.tmdbApiKey,
            type: 'tv',
          );
        }
        return await _apiService.searchAnime(query: query, page: page);
      case 'Manga':
      case 'Comic':
        if (source == 'Tomos') {
          return (await _apiService.searchBooks(
            query: query,
            page: page,
            apiKey: booksApiKey,
            mangaMode: true,
          )).map((b) => {...b, 'source': 'Manga (Tomos)'}).toList();
        } else if (source == 'MangaDex') {
          return await _apiService.searchMangaDex(query: query, page: page);
        } else if (source == 'Auto') {
          return await _apiService.searchManga(query: query, page: page, googleBooksApiKey: booksApiKey);
        }
        // MAL por defecto (source == null || source == 'MAL')
        return await _apiService.searchMangaMAL(query: query, page: page);
      case 'Movie':
      case 'Series':
        String? type;
        if (source == 'Cine') type = 'movie';
        if (source == 'Series') type = 'series';

        if (source == 'TMDb' || source == null) {
          return await _apiService.searchTMDb(
            query: query,
            page: page,
            apiKey: settings.tmdbApiKey,
            type: widget.category == 'Movie' ? 'movie' : 'tv',
          );
        }

        return await _apiService.searchMovies(
          query: query,
          page: page,
          apiKey: omdbApiKey,
          type: type,
        );
      default:
        if (source == 'Books') {
          return await _apiService.searchBooks(query: query, page: page, apiKey: booksApiKey);
        } else if (source == 'MAL') {
          return await _apiService.searchAnime(query: query, page: page);
        } else if (source == 'MangaDex') {
          return await _apiService.searchMangaDex(query: query, page: page);
        } else if (source == 'OMDb') {
          return await _apiService.searchMovies(
            query: query,
            page: page,
            apiKey: omdbApiKey,
          );
        } else if (source == 'TMDb') {
          final settings = Provider.of<SettingsProvider>(
            context,
            listen: false,
          );
          return await _apiService.searchTMDb(
            query: query,
            page: page,
            apiKey: settings.tmdbApiKey,
            type: 'movie',
          );
        }
        return [];
    }
  }

  /// Construye una fila de [ChoiceChip]s que permiten al usuario sobrescribir la fuente de búsqueda
  /// por defecto para la [widget.category] actual.
  Widget _buildSourceSelector() {
    List<String> sources = [];
    if (widget.category == 'Manga' || widget.category == 'Comic') {
      sources = ['MAL', 'MangaDex', 'Tomos', 'Auto'];
    } else if (widget.category == 'Book') {
      sources = ['Auto (Books)'];
    } else if (widget.category == 'Anime') {
      sources = ['MAL', 'TMDb'];
    } else if (widget.category == 'Movie' || widget.category == 'Series') {
      sources = ['Auto'];
    } else {
      sources = ['Books', 'MAL', 'MangaDex', 'OMDb', 'TMDb'];
    }

    if (sources.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Wrap(
        spacing: 8.0,
        children: sources.map((s) {
          final defaultSource = (widget.category == 'Anime' || widget.category == 'Manga' || widget.category == 'Comic') ? 'MAL' : 'Auto';
          final isSelected =
              (_selectedSource == null && s == defaultSource) ||
              (_selectedSource == s);
          return ChoiceChip(
            label: Text(s),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) {
                setState(() {
                  _selectedSource = (s == 'Auto' ? null : s);
                  _search();
                });
              }
            },
          );
        }).toList(),
      ),
    );
  }

  /// Devuelve una cadena de título localizada que combina la etiqueta de búsqueda base con el
  /// nombre de [widget.category] legible por humanos.
  String _getTitle(BuildContext context) {
    final l = context.l10n;
    final base = l.searchImportTitle;
    switch (widget.category) {
      case 'Book':
        return '$base · ${l.categoryBook}';
      case 'Anime':
        return '$base · ${l.categoryAnime}';
      case 'Manga':
        return '$base · ${l.categoryManga}';
      case 'Comic':
        return '$base · ${l.categoryComic}';
      case 'Movie':
        return '$base · ${l.categoryMovie}';
      case 'Series':
        return '$base · ${l.categorySeries}';
      default:
        return '$base · ${widget.category}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomGradientAppBar(title: _getTitle(context), showBackButton: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: context.l10n.searchImportPlaceholder,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _search,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onSubmitted: (_) => _search(),
            ),
          ),
          _buildSourceSelector(),
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_error != null)
            Expanded(
              child: Center(
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
            )
          else if (_results.isEmpty)
            Expanded(child: Center(child: Text(context.l10n.searchImportNoResults)))
          else
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final w = constraints.maxWidth;
                  final isWide = w > 700;
                  if (isWide) {
                    final colW = (w - 8 - 24) / 2; // spacing + padding
                    final cardH = (colW * 0.38).clamp(140.0, 240.0);
                    return GridView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(12),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        mainAxisExtent: cardH,
                      ),
                      itemCount: _results.length + (_isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _results.length) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        return SearchResultCard(
                          item: _results[index],
                          columnWidth: colW,
                          onSelect: () => _selectItem(_results[index]),
                        );
                      },
                    );
                  }
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(8),
                    itemCount: _results.length + (_isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _results.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: SearchResultCard(
                          item: _results[index],
                          columnWidth: w,
                          onSelect: () => _selectItem(_results[index]),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  /// Asocia una cadena de [source] de API bruta con una etiqueta corta legible por humanos para la
  /// placa de calificación (ej. `'MyAnimeList'` → `'MAL'`).
  ///
  /// Devuelve `null` cuando la fuente no es reconocida.
  String? _ratingSourceLabel(String? source) {
    if (source == null) return null;
    if (source.contains('MyAnimeList')) return 'MAL';
    if (source == 'TMDb') return 'TMDb';
    if (source == 'OMDb') return 'IMDb';
    if (source.contains('Google')) return 'Google';
    return null;
  }

  /// Maneja un toque en una tarjeta de [result] obteniendo opcionalmente detalles más completos
  /// (ej. información extendida de TMDb para películas/series/anime) y luego cerrando la
  /// pantalla con un `Map<String, dynamic>` normalizado que el formulario de entrada de elementos
  /// puede consumir directamente.
  void _selectItem(Map<String, dynamic> result) async {
    Map<String, dynamic> data = {
      'name': result['name'],
      'description': result['description'],
      'remoteImageUrl': result['imagePath'],
      'genre': result['genre'],
      'externalRating': result['externalRating'],
      'ratingSource': _ratingSourceLabel(result['source'] as String?),
    };

    if (widget.category == 'Book') {
      data['totalPage'] = result['pageCount'];
      if (result['author'] != null) data['author'] = result['author'];
      if (result['publisher'] != null) data['publisher'] = result['publisher'];
      if (result['publishedDate'] != null)
        data['publishedDate'] = result['publishedDate'];
      if (result['isbn'] != null) data['isbn'] = result['isbn'];
    } else if (widget.category == 'Anime') {
      if (result['source'] == 'TMDb') {
        setState(() => _isLoading = true);
        try {
          final settings = Provider.of<SettingsProvider>(context, listen: false);
          final details = await _apiService.getTMDbDetails(
            result['remoteId'],
            settings.tmdbApiKey,
            type: 'tv',
          );
          if (details != null) {
            data['description'] = details['description'];
            data['genre'] = details['genre'];
            data['externalRating'] = details['externalRating'];
            data['totalChapter'] = details['totalEpisodes'];
            data['totalSeason'] = details['seasons'];
            data['year'] = details['year'];
            data['studio'] = details['studio'];
            data['runtime'] = details['runtime'];
          }
        } catch (e) {
          debugPrint("Error fetching TMDb anime details: $e");
        } finally {
          if (mounted) setState(() => _isLoading = false);
        }
      } else {
        data['totalChapter'] = result['totalEpisodes'];
        data['chapter'] = 0;
        if (result['durationMinutes'] != null)
          data['durationMinutes'] = result['durationMinutes'];
        if (result['studio'] != null) data['studio'] = result['studio'];
        if (result['statusRaw'] != null) data['statusRaw'] = result['statusRaw'];
        if (result['nameEnglish'] != null)
          data['nameEnglish'] = result['nameEnglish'];
        if (result['nameJapanese'] != null)
          data['nameJapanese'] = result['nameJapanese'];
      }
    } else if (widget.category == 'Manga' || widget.category == 'Comic') {
      data['totalChapter'] = result['totalChapters'] ?? result['chapters'];
      data['totalVolume'] = result['totalVolumes'] ?? result['volumes'];
      if (result['pageCount'] != null) {
        data['totalPage'] = result['pageCount'];
      }
      if (result['lastChapter'] != null) {
        data['lastChapter'] = result['lastChapter'];
      }
      if (result['author'] != null) data['author'] = result['author'];
    } else if (widget.category == 'Movie') {
      if (result['source'] == 'TMDb') {
        setState(() => _isLoading = true);
        try {
          final settings = Provider.of<SettingsProvider>(
            context,
            listen: false,
          );
          final details = await _apiService.getTMDbDetails(
            result['remoteId'],
            settings.tmdbApiKey,
            type: 'movie',
          );
          if (details != null) {
            data['description'] = details['description'];
            data['genre'] = details['genre'];
            data['genres'] = details['genres'];
            data['externalRating'] = details['externalRating'];
            data['runtime'] = details['runtime'];
            data['year'] = details['year'];
            data['studio'] = details['studio'];
            data['tagline'] = details['tagline'];
            data['imdbId'] = details['imdbId'];
          }
        } catch (e) {
          debugPrint("Error fetching TMDb details: $e");
        } finally {
          if (mounted) setState(() => _isLoading = false);
        }
      } else {
        setState(() => _isLoading = true);
        try {
          final settings = Provider.of<SettingsProvider>(
            context,
            listen: false,
          );
          final apiKey = settings.omdbApiKey.trim().isNotEmpty
              ? settings.omdbApiKey.trim()
              : "900e2548";
          final details = await _apiService.getMovieDetails(
            result['remoteId'],
            apiKey,
          );
          if (details != null) {
            data['description'] = details['description'];
            data['genre'] = details['genre'];
            data['genres'] = details['genres'];
            data['externalRating'] = details['externalRating'];
            data['runtime'] = details['runtime'];
            data['year'] = details['year'];
            data['director'] = details['director'];
            data['actors'] = details['actors'];
            data['writer'] = details['writer'];
            data['language'] = details['language'];
            data['country'] = details['country'];
          }
        } catch (e) {
          debugPrint("Error fetching movie details: $e");
        } finally {
          if (mounted) setState(() => _isLoading = false);
        }
      }
    } else if (widget.category == 'Series') {
      if (result['source'] == 'TMDb') {
        setState(() => _isLoading = true);
        try {
          final settings = Provider.of<SettingsProvider>(
            context,
            listen: false,
          );
          final details = await _apiService.getTMDbDetails(
            result['remoteId'],
            settings.tmdbApiKey,
            type: 'tv',
          );
          if (details != null) {
            data['description'] = details['description'];
            data['genre'] = details['genre'];
            data['genres'] = details['genres'];
            data['externalRating'] = details['externalRating'];
            data['totalSeason'] = details['seasons'];
            data['totalChapter'] = details['episodes'];
            data['year'] = details['year'];
            data['studio'] = details['studio'];
            data['runtime'] = details['runtime'];
          }
        } catch (e) {
          debugPrint("Error fetching TMDb details: $e");
        } finally {
          if (mounted) setState(() => _isLoading = false);
        }
      } else {
        setState(() => _isLoading = true);
        try {
          final settings = Provider.of<SettingsProvider>(
            context,
            listen: false,
          );
          final apiKey = settings.omdbApiKey.trim().isNotEmpty
              ? settings.omdbApiKey.trim()
              : "900e2548";
          final details = await _apiService.getMovieDetails(
            result['remoteId'],
            apiKey,
          );
          if (details != null) {
            data['description'] = details['description'];
            data['genre'] = details['genre'];
            data['genres'] = details['genres'];
            data['externalRating'] = details['externalRating'];
            data['runtime'] = details['runtime'];
            data['year'] = details['year'];
          }
        } catch (e) {
          debugPrint("Error fetching series details: $e");
        } finally {
          if (mounted) setState(() => _isLoading = false);
        }
      }
    }

    if (mounted) {
      Navigator.pop(context, data);
    }
  }
}
