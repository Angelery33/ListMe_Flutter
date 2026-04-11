import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/external_api_service.dart';
import '../../../providers/settings/settings_provider.dart';
import '../../../widgets/shared/custom_gradient_app_bar.dart';
import '../../../widgets/shared/universal_image.dart';

class SearchImportScreen extends StatefulWidget {
  final String category;

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
  Timer? _debounce;
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
        return await _apiService.searchBooks(query: query, page: page);
      case 'Anime':
        return await _apiService.searchAnime(query: query, page: page);
      case 'Manga':
      case 'Comic':
        if (source == 'Tomos') {
          return (await _apiService.searchBooks(
            query: query,
            page: page,
          )).map((b) => {...b, 'source': 'Manga (Tomos)'}).toList();
        } else if (source == 'MangaDex') {
          return await _apiService.searchMangaDex(query: query, page: page);
        } else if (source == 'MAL') {
          return await _apiService.searchMangaMAL(query: query, page: page);
        }
        return await _apiService.searchManga(query: query, page: page);
      case 'Movie':
      case 'Series':
        String? type;
        if (source == 'Cine') type = 'movie';
        if (source == 'Series') type = 'series';

        if (source == 'TMDb' || source == null) {
          final settings = Provider.of<SettingsProvider>(
            context,
            listen: false,
          );
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
          return await _apiService.searchBooks(query: query, page: page);
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

  String _getTitle() {
    switch (widget.category) {
      case 'Book':
        return 'Buscar Libros';
      case 'Anime':
        return 'Buscar Anime';
      case 'Manga':
        return 'Buscar Manga';
      case 'Comic':
        return 'Buscar Cómic';
      case 'Movie':
        return 'Buscar Películas';
      case 'Series':
        return 'Buscar Series';
      default:
        return 'Buscar ${widget.category}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomGradientAppBar(title: _getTitle(), showBackButton: true),
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
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
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
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    children: [
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
      if (result['author'] != null) data['author'] = result['author'];
      if (result['publisher'] != null) data['publisher'] = result['publisher'];
      if (result['publishedDate'] != null)
        data['publishedDate'] = result['publishedDate'];
      if (result['isbn'] != null) data['isbn'] = result['isbn'];
    } else if (widget.category == 'Anime') {
      data['totalChapter'] = result['totalEpisodes'];
      data['chapter'] = 0;
      if (result['durationMinutes'] != null) {
        data['durationMinutes'] = result['durationMinutes'];
      }
      if (result['studio'] != null) data['studio'] = result['studio'];
      if (result['statusRaw'] != null) data['statusRaw'] = result['statusRaw'];
      if (result['nameEnglish'] != null)
        data['nameEnglish'] = result['nameEnglish'];
      if (result['nameJapanese'] != null)
        data['nameJapanese'] = result['nameJapanese'];
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
