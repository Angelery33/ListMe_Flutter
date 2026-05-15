import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/i18n/l10n_extension.dart';
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
        if (source == 'TMDb') {
          final settings = Provider.of<SettingsProvider>(context, listen: false);
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
          final defaultSource = widget.category == 'Anime' ? 'MAL' : 'Auto';
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
                        return _buildResultCard(_results[index], colW);
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
                        child: _buildResultCard(_results[index], w),
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

  Widget _buildResultCard(Map<String, dynamic> item, double columnWidth) {
    final title = item['name'] ?? 'Sin título';
    final imageUrl = item['imagePath'];
    final year = item['year'];
    final rating = item['externalRating'];
    final author = item['author'];
    final description = item['description'] ?? '';
    final status = item['status'];
    final source = item['source'] ?? 'Unknown';

    String? secondaryInfo;
    if (author != null && (author as String).isNotEmpty) {
      secondaryInfo = author;
    } else if (year != null && (year as String).isNotEmpty) {
      secondaryInfo = year;
    }

    // All sizes scale proportionally to column width (base: 400px mobile)
    final scale = (columnWidth / 400).clamp(0.85, 1.4);
    final imgH = (145.0 * scale).clamp(100.0, 200.0);
    final imgW = imgH * 0.70;
    final titleSize = (15.0 * scale).clamp(14.0, 20.0);
    final bodySize = (13.0 * scale).clamp(12.0, 16.0);
    final tagSize = (11.0 * scale).clamp(10.0, 14.0);
    final ratingSize = (12.0 * scale).clamp(11.0, 16.0);
    final ratingIconSize = (16.0 * scale).clamp(14.0, 22.0);
    final descLimit = (100 * scale).toInt();
    final descLines = scale > 1.2 ? 4 : 3;
    final cardPadding = (12.0 * scale).clamp(10.0, 16.0);

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () => _selectItem(item),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(cardPadding),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: imageUrl != null && (imageUrl as String).isNotEmpty
                    ? UniversalImage(
                        '',
                        remoteImageUrl: imageUrl,
                        width: imgW,
                        height: imgH,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: imgW,
                        height: imgH,
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        child: const Icon(Icons.image, size: 30),
                      ),
              ),
              SizedBox(width: (12 * scale).clamp(8, 18)),
              Expanded(
                child: SizedBox(
                  height: imgH,
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: titleSize,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (secondaryInfo != null) ...[
                      SizedBox(height: (4 * scale).clamp(3, 8)),
                      Text(
                        secondaryInfo,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: bodySize,
                        ),
                      ),
                    ],
                    if (description.isNotEmpty) ...[
                      SizedBox(height: (4 * scale).clamp(3, 8)),
                      Text(
                        description.length > descLimit
                            ? '${description.substring(0, descLimit)}...'
                            : description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: bodySize,
                        ),
                        maxLines: descLines,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    SizedBox(height: (8 * scale).clamp(6, 14)),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _buildTag(source, Theme.of(context).colorScheme.primaryContainer,
                            Theme.of(context).colorScheme.onPrimaryContainer, tagSize),
                        if (year != null && (year as String).isNotEmpty && secondaryInfo != year)
                          _buildTag(year, Theme.of(context).colorScheme.secondaryContainer,
                              Theme.of(context).colorScheme.onSecondaryContainer, tagSize),
                        if (status != null && (status as String).isNotEmpty)
                          _buildTag(
                            status,
                            status.toLowerCase().contains('finish') ||
                                    status.toLowerCase().contains('complete')
                                ? Colors.green.withValues(alpha: 0.2)
                                : Colors.blue.withValues(alpha: 0.2),
                            status.toLowerCase().contains('finish') ||
                                    status.toLowerCase().contains('complete')
                                ? Colors.green.shade700
                                : Colors.blue.shade700,
                            tagSize,
                          ),
                      ],
                    ),
                  ],
                ),
                ),
              ),
              if (rating != null && (rating as num) > 0) ...[
                SizedBox(width: (8 * scale).clamp(6, 14)),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: (8 * scale).clamp(6, 14),
                    vertical: (4 * scale).clamp(3, 8),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, size: ratingIconSize, color: Colors.amber),
                      SizedBox(width: (4 * scale).clamp(3, 8)),
                      Text(
                        rating.toStringAsFixed(1),
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: ratingSize),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color bg, Color fg, [double fontSize = 10]) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: fg),
      ),
    );
  }

  String? _ratingSourceLabel(String? source) {
    if (source == null) return null;
    if (source.contains('MyAnimeList')) return 'MAL';
    if (source == 'TMDb') return 'TMDb';
    if (source == 'OMDb') return 'IMDb';
    if (source.contains('Google')) return 'Google';
    return null;
  }

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
