import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/external_api_service.dart';
import '../app_theme.dart';
import '../components/universal_image.dart';

class SearchImportScreen extends StatefulWidget {
  final String category; // 'Book', 'Anime', 'Manga', 'Movie'

  const SearchImportScreen({super.key, required this.category});

  @override
  State<SearchImportScreen> createState() => _SearchImportScreenState();
}

class _SearchImportScreenState extends State<SearchImportScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ExternalApiService _apiService = ExternalApiService.instance;
  List<Map<String, dynamic>> _results = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();

  // Real-time search
  Timer? _debounce;
  String? _selectedSource; // 'MAL', 'Books', 'MangaDex', 'OMDb'

  // For Movies, we need an API Key from settings.

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

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 600), () {
      if (mounted) _search();
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.9 &&
        !_isLoadingMore &&
        _hasMore) {
      _loadMore();
    }
  }

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

  Future<List<Map<String, dynamic>>> _performSearch(
    String query,
    int page,
    String omdbApiKey,
  ) async {
    final source = _selectedSource;

    switch (widget.category) {
      case 'Book':
        return await _apiService.searchBooks(query, page: page);
      case 'Anime':
        return await _apiService.searchAnime(query, page: page);
      case 'Manga':
      case 'Comic':
        if (source == 'Tomos') {
          return (await _apiService.searchBooks(
            query,
            page: page,
          )).map((b) => {...b, 'source': 'Manga (Tomos)'}).toList();
        } else if (source == 'MangaDex') {
          return await _apiService.searchMangaDex(query, page: page);
        } else if (source == 'MAL') {
          return await _apiService.searchMangaMAL(query, page: page);
        }
        // Default smart search
        return await _apiService.searchManga(query, page: page);
      case 'Movie':
      case 'Series':
        String? type;
        if (source == 'Cine') type = 'movie';
        if (source == 'Series') type = 'series';

        // Auto (null) or explicitly TMDb - FORCE TMDB for Auto
        if (source == 'TMDb' || source == null) {
          final settings = Provider.of<SettingsProvider>(
            context,
            listen: false,
          );
          return await _apiService.searchTMDb(
            query,
            page: page,
            apiKey: settings.tmdbApiKey,
            type: widget.category == 'Movie' ? 'movie' : 'tv',
          );
        }

        return await _apiService.searchMovies(
          query,
          page: page,
          apiKey: omdbApiKey,
          type: type,
        );
      default:
        // Generic/General library support - dispatch by selected source
        if (source == 'Books') {
          return await _apiService.searchBooks(query, page: page);
        } else if (source == 'MAL') {
          return await _apiService.searchAnime(query, page: page);
        } else if (source == 'MangaDex') {
          return await _apiService.searchMangaDex(query, page: page);
        } else if (source == 'OMDb') {
          return await _apiService.searchMovies(
            query,
            page: page,
            apiKey: omdbApiKey,
          );
        } else if (source == 'TMDb') {
          final settings = Provider.of<SettingsProvider>(
            context,
            listen: false,
          );
          return await _apiService.searchTMDb(
            query,
            page: page,
            apiKey: settings.tmdbApiKey,
            type: 'movie', // Default to movie for general
          );
        }
        return [];
    }
  }

  Widget _buildSourceSelector() {
    List<String> sources = [];
    if (widget.category == 'Manga' || widget.category == 'Comic') {
      sources = ['Auto', 'MAL', 'Tomos', 'MangaDex'];
    } else if (widget.category == 'Book') {
      sources = ['Auto (Books)'];
    } else if (widget.category == 'Anime') {
      sources = ['Auto (MAL)'];
    } else if (widget.category == 'Movie' || widget.category == 'Series') {
      sources = ['Auto'];
    } else {
      // General libraries (or Figures, etc.) can access all APIs
      sources = ['Books', 'MAL', 'MangaDex', 'OMDb', 'TMDb'];
    }

    if (sources.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Wrap(
        spacing: 8.0,
        children: sources.map((s) {
          final isSelected =
              (_selectedSource == null && s == 'Auto') ||
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

  @override
  Widget build(BuildContext context) {
    String title = "Buscar ${widget.category}";
    switch (widget.category) {
      case 'Book':
        title = "Buscar Libros";
        break;
      case 'Anime':
        title = "Buscar Anime";
        break;
      case 'Manga':
        title = "Buscar Manga";
        break;
      case 'Comic':
        title = "Buscar Cómic";
        break;
      case 'Movie':
        title = "Buscar Películas";
        break;
      case 'Series':
        title = "Buscar Series";
        break;
    }

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: AppTheme.getAppBarGradient(context),
        title: Text(title),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: "Título, autor...",
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
            const Expanded(child: Center(child: Text("Sin resultados")))
          else
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _results.length + (_isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _results.length) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final item = _results[index];
                  final title = item['name'] ?? "Sin título";
                  final imageUrl = item['imagePath'];
                  final year = item['year'];
                  final rating = item['externalRating'];
                  final author = item['author'];
                  final description = item['description'] ?? '';
                  final status = item['status'];
                  final source = item['source'] ?? "Unknown";

                  // Determine what to show as secondary info
                  String? secondaryInfo;
                  if (author != null && author.isNotEmpty) {
                    secondaryInfo = author;
                  } else if (year != null && year.isNotEmpty) {
                    secondaryInfo = year;
                  }

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: InkWell(
                      onTap: () => _selectItem(item),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Larger thumbnail
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: imageUrl != null && imageUrl.isNotEmpty
                                  ? UniversalImage(
                                      imageUrl,
                                      width: 60,
                                      height: 90,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      width: 60,
                                      height: 90,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.surfaceContainerHighest,
                                      child: const Icon(Icons.image, size: 30),
                                    ),
                            ),
                            const SizedBox(width: 12),
                            // Content
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Title
                                  Text(
                                    title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (secondaryInfo != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      secondaryInfo,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                  if (description.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      description.length > 80
                                          ? '${description.substring(0, 80)}...'
                                          : description,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                  const SizedBox(height: 8),
                                  // Badges row
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    children: [
                                      // Source badge
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primaryContainer
                                              .withValues(alpha: 0.5),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          source,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onPrimaryContainer,
                                          ),
                                        ),
                                      ),
                                      // Year badge (if not already shown as secondary info)
                                      if (year != null &&
                                          year.isNotEmpty &&
                                          secondaryInfo != year)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondaryContainer
                                                .withValues(alpha: 0.5),
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: Text(
                                            year,
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSecondaryContainer,
                                            ),
                                          ),
                                        ),
                                      // Status badge
                                      if (status != null && status.isNotEmpty)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                status.toLowerCase().contains(
                                                      'finish',
                                                    ) ||
                                                    status
                                                        .toLowerCase()
                                                        .contains('complete')
                                                ? Colors.green.withValues(
                                                    alpha: 0.2,
                                                  )
                                                : Colors.blue.withValues(
                                                    alpha: 0.2,
                                                  ),
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: Text(
                                            status,
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  status.toLowerCase().contains(
                                                        'finish',
                                                      ) ||
                                                      status
                                                          .toLowerCase()
                                                          .contains('complete')
                                                  ? Colors.green.shade700
                                                  : Colors.blue.shade700,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Rating badge (trailing)
                            if (rating != null && rating > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.amber.withValues(alpha: 0.5),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      size: 16,
                                      color: Colors.amber,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      rating.toStringAsFixed(1),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  void _selectItem(Map<String, dynamic> result) async {
    Map<String, dynamic> data = {
      'name': result['name'],
      'description': result['description'],
      'remoteImageUrl': result['imagePath'],
      'genre': result['genre'],
      'externalRating': result['externalRating'],
    };

    if (widget.category == 'Book') {
      data['totalPage'] = result['pageCount'];
    } else if (widget.category == 'Anime' ||
        widget.category == 'Manga' ||
        widget.category == 'Comic') {
      data['totalChapter'] = result['chapters'] ?? result['episodes'];
      data['totalVolume'] = result['volumes'];
      // Also capture pageCount if it's coming from Books (Tomos)
      if (result['pageCount'] != null) {
        data['totalPage'] = result['pageCount'];
      }
    } else if (widget.category == 'Movie' || widget.category == 'Series') {
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
            type: widget.category == 'Movie' ? 'movie' : 'tv',
          );
          if (details != null) {
            data['description'] = details['description'];
            data['genre'] = details['genre'];
            data['externalRating'] = details['externalRating'];
            if (widget.category == 'Series') {
              data['totalSeason'] = details['seasons'];
              data['totalChapter'] = details['episodes'];
            }
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
            data['externalRating'] = details['externalRating'];
          }
        } catch (e) {
          debugPrint("Error fetching movie details: $e");
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
