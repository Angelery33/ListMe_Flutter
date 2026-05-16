import 'dart:convert';
import 'package:http/http.dart' as http;
import 'logger_service.dart';

/// Servicio singleton que envuelve múltiples APIs de medios de terceros (Google Books,
/// MyAnimeList a través de Jikan, MangaDex, OMDb y TMDb).
///
/// Cada método de búsqueda devuelve una lista normalizada de registros `Map<String, dynamic>`
/// para que el resto de la aplicación pueda tratar los resultados de diferentes fuentes
/// de manera uniforme. Los nombres de los campos se mantienen consistentes en todas las fuentes (ej. `name`,
/// `description`, `imagePath`, `year`, `externalRating`).
class ExternalApiService {
  /// Instancia global singleton.
  static final ExternalApiService instance = ExternalApiService._();
  final LoggerService _logger = LoggerService.instance;
  ExternalApiService._();

  /// Traduce una cadena de estado cruda de MAL/MangaDex al español.
  ///
  /// Devuelve [status] sin cambios cuando la cadena no coincide con ningún valor conocido,
  /// y devuelve una cadena vacía cuando [status] es `null`.
  String _translateStatus(String? status) {
    if (status == null) return '';
    switch (status.toLowerCase()) {
      case 'finished':
        return 'Finalizado';
      case 'airing':
        return 'En emisión';
      case 'completed':
        return 'Completado';
      case 'publishing':
        return 'Publicando';
      case 'hiatus':
        return 'En pausa';
      case 'discontinued':
        return 'Descontinuado';
      case 'not yet aired':
        return 'Sin emitir';
      case 'currently publishing':
        return 'En publicación';
      default:
        return status;
    }
  }

  /// Busca volúmenes en Google Books que coincidan con [query] y devuelve hasta 10
  /// resultados normalizados para la [page] dada.
  ///
  /// [query] La cadena de búsqueda (título, autor, ISBN, etc.).
  /// [page] Número de página basado en 1; convertido internamente a un `startIndex`.
  Future<List<Map<String, dynamic>>> searchBooks({
    int page = 1,
    required String query,
  }) async {
    final int startIndex = (page - 1) * 10;
    final url = Uri.parse(
      'https://www.googleapis.com/books/v1/volumes?q=${Uri.encodeComponent(query)}&startIndex=$startIndex&maxResults=10&langRestrict=es',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['items'] as List? ?? [];
        final results = items.map((item) {
          final info = item['volumeInfo'];
          final industryIdentifiers =
              info['industryIdentifiers'] as List? ?? [];
          String? isbn;
          if (industryIdentifiers.isNotEmpty) {
            isbn = industryIdentifiers.first['identifier'];
          }

          // Extraer idioma
          String? language = info['language'];
          if (language == 'es')
            language = 'Español';
          else if (language == 'en')
            language = 'Inglés';
          else if (language == 'ja')
            language = 'Japonés';

          // Extraer fecha de publicación
          String? publishedDate = info['publishedDate'];
          String? year;
          if (publishedDate != null && publishedDate.length >= 4) {
            year = publishedDate.substring(0, 4);
          }

          return {
            'source': 'Google Books',
            'remoteId': item['id'],
            'name': info['title'] ?? 'Sin título',
            'description': info['description'] ?? '',
            'imagePath': info['imageLinks']?['thumbnail']?.replaceFirst(
              'http:',
              'https:',
            ),
            'imagePathLarge': info['imageLinks']?['large']?.replaceFirst(
              'http:',
              'https:',
            ),
            'genre': (info['categories'] as List?)?.first ?? '',
            'author': (info['authors'] as List?)?.join(', ') ?? '',
            'publisher': info['publisher'] ?? '',
            'publishedDate': publishedDate ?? '',
            'year': year ?? '',
            'pageCount': info['pageCount'],
            'isbn': isbn,
            'language': language,
            'externalRating': (info['averageRating'] as num?)?.toDouble(),
            'ratingsCount': info['ratingsCount'],
          };
        }).toList();

        _sortResults(results, query);
        return results;
      } else {
        throw Exception('Error de Google Books (${response.statusCode})');
      }
    } catch (e) {
      _logger.error('Error searching books: $e');
      if (e is Exception) rethrow;
      throw Exception('Error al buscar libros: $e');
    }
  }

  /// Busca anime en MyAnimeList (a través de la API Jikan v4) que coincida con [query].
  ///
  /// [query] El título del anime a buscar.
  /// [page] Número de página basado en 1.
  Future<List<Map<String, dynamic>>> searchAnime({
    required String query,
    int page = 1,
  }) async {
    return _searchJikan('anime', query, page: page);
  }

  /// Busca manga en MyAnimeList (a través de la API Jikan v4) que coincida con [query].
  ///
  /// [query] El título del manga a buscar.
  /// [page] Número de página basado en 1.
  Future<List<Map<String, dynamic>>> searchMangaMAL({
    required String query,
    int page = 1,
  }) async {
    return _searchJikan('manga', query, page: page);
  }

  /// Busca manga combinando Google Books (volúmenes físicos) y el
  /// catálogo de manga de MyAnimeList.
  ///
  /// Cuando [query] contiene un número (indicador de volumen), el método intenta primero con Google
  /// Books y devuelve los resultados pronto si los encuentra. De lo contrario, se consultan ambas fuentes
  /// en paralelo y se fusionan.
  ///
  /// [query] El título del manga/volumen a buscar.
  /// [page] Número de página basado en 1 reenviado a cada subfuente.
  Future<List<Map<String, dynamic>>> searchManga({
    required String query,
    int page = 1,
  }) async {
    final hasVolumeIndicator = RegExp(r'\d+').hasMatch(query);

    if (hasVolumeIndicator) {
      final booksResults = await searchBooks(query: query, page: page);
      if (booksResults.isNotEmpty) {
        return booksResults
            .map((b) => {...b, 'source': 'Manga (Tomos)'})
            .toList();
      }
    }

    final results = await Future.wait([
      searchBooks(query: query, page: page).then(
        (list) => list.map((b) => {...b, 'source': 'Manga (Tomos)'}).toList(),
      ),
      searchMangaMAL(query: query, page: page),
    ]);

    final combined = results.expand((x) => x).toList();
    _sortResults(combined, query);
    return combined;
  }

  Future<List<Map<String, dynamic>>> _searchJikan(
    String type,
    String query, {
    int page = 1,
  }) async {
    final url = Uri.parse(
      'https://api.jikan.moe/v4/$type?q=${Uri.encodeComponent(query)}&page=$page&limit=10',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['data'] as List? ?? [];
        return items.map((item) {
          final isAnime = type == 'anime';

          // Extraer año
          String? year;
          if (isAnime && item['aired']?['from'] != null) {
            year = item['aired']['from'].toString().substring(0, 4);
          } else if (!isAnime && item['published']?['from'] != null) {
            year = item['published']['from'].toString().substring(0, 4);
          }

          // Extraer episodios/capítulos/volúmenes
          final episodes = item['episodes'];
          final chapters = item['chapters'];
          final volumes = item['volumes'];

          // Extraer duración por episodio
          int? durationMinutes;
          if (item['duration'] != null) {
            final durationStr = item['duration'].toString();
            final match = RegExp(r'(\d+)').firstMatch(durationStr);
            if (match != null) {
              durationMinutes = int.tryParse(match.group(1)!);
            }
          }

          // Extraer estudio
          String? studio;
          if (item['studios'] != null && (item['studios'] as List).isNotEmpty) {
            studio = item['studios'][0]['name'];
          }

          // Extraer rating
          String? rating;
          if (item['rating'] != null) {
            rating = item['rating'].toString();
          }

          return {
            'source': isAnime ? 'MyAnimeList (Anime)' : 'MyAnimeList (Manga)',
            'remoteId': item['mal_id'].toString(),
            'name': item['title'] ?? 'Sin título',
            'nameEnglish': item['title_english'],
            'nameJapanese': item['title_japanese'],
            'description': item['synopsis'] ?? '',
            'imagePath': item['images']?['jpg']?['image_url'],
            'imagePathLarge': item['images']?['jpg']?['large_image_url'],
            'imagePathSmall': item['images']?['jpg']?['image_url'],
            'genre': (item['genres'] as List?)?.isNotEmpty == true
                ? item['genres'][0]['name']
                : '',
            'genres': (item['genres'] as List?)
                ?.map((g) => g['name'])
                .join(', '),
            'year': year ?? '',
            'score': (item['score'] as num?)?.toDouble() ?? 0.0,
            'episodes': episodes,
            'totalEpisodes': episodes,
            'chapters': chapters,
            'totalChapters': chapters,
            'volumes': volumes,
            'totalVolumes': volumes,
            'durationMinutes': durationMinutes,
            'status': _translateStatus(item['status']),
            'statusRaw': item['status'],
            'rating': rating,
            'studio': studio,
            'externalRating': (item['score'] as num?)?.toDouble(),
            'rank': item['rank'],
            'popularity': item['popularity'],
            'favorites': item['favorites'],
          };
        }).toList();
      }
    } catch (e) {
      _logger.error('Error searching Jikan $type: $e');
    }
    return [];
  }

  /// Busca manga en MangaDex que coincida con [query] y devuelve hasta 10 resultados
  /// para la [page] dada.
  ///
  /// Incluye arte de portada, autor y relaciones de artistas. Los títulos se devuelven
  /// con prioridad ES > EN > JA para adaptarse mejor a la audiencia principal de la aplicación.
  ///
  /// [query] El título del manga a buscar.
  /// [page] Número de página basado en 1.
  Future<List<Map<String, dynamic>>> searchMangaDex({
    required String query,
    int page = 1,
  }) async {
    final offset = (page - 1) * 10;
    final url = Uri.parse(
      'https://api.mangadex.org/manga?title=${Uri.encodeComponent(query)}&limit=10&offset=$offset&includes[]=cover_art&includes[]=author&includes[]=artist',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['data'] as List? ?? [];
        return items.map((item) {
          final attributes = item['attributes'];
          final relationships = item['relationships'] as List? ?? [];

          // Buscar cover art
          String? coverFileName;
          for (var rel in relationships) {
            if (rel['type'] == 'cover_art') {
              coverFileName = rel['attributes']?['fileName'];
              break;
            }
          }

          String? imageUrl;
          if (coverFileName != null) {
            imageUrl =
                'https://uploads.mangadex.org/covers/${item['id']}/$coverFileName.256.jpg';
          }

          // Título prioritario: ES > EN > JA
          final titleMap = attributes['title'] as Map? ?? {};
          final altTitles = attributes['altTitles'] as List? ?? [];

          String name = 'Sin título';
          if (titleMap['es'] != null) {
            name = titleMap['es'];
          } else if (titleMap['en'] != null) {
            name = titleMap['en'];
          } else if (titleMap['ja'] != null || titleMap['ja-ro'] != null) {
            name = titleMap['ja'] ?? titleMap['ja-ro'];
          } else {
            for (var alt in altTitles) {
              if (alt['es'] != null) {
                name = alt['es'];
                break;
              }
              if (alt['en'] != null) {
                name = alt['en'];
                break;
              }
            }
            if (name == 'Sin título')
              name = titleMap.values.firstOrNull ?? 'Sin título';
          }

          // Descripción
          final descMap = attributes['description'] as Map? ?? {};
          final description = descMap['es'] ?? descMap['en'] ?? '';

          // Año
          String? year;
          final pubDate = attributes['year'];
          if (pubDate != null) year = pubDate.toString();

          // Estado
          String status = _translateStatus(attributes['status']);

          // Autor
          String? author;
          for (var rel in relationships) {
            if (rel['type'] == 'author') {
              author = rel['attributes']?['name'];
              break;
            }
          }

          // Etiquetas (géneros)
          List<String> tagNames = [];
          final tagsList = attributes['tags'] as List?;
          if (tagsList != null) {
            for (var t in tagsList) {
              final tagGroup = t['attributes']?['group'];
              if (tagGroup == 'genre') {
                final tagName = t['attributes']?['name']?['en'];
                if (tagName != null) {
                  tagNames.add(tagName);
                  if (tagNames.length >= 3) break;
                }
              }
            }
          }
          final tags = tagNames.isNotEmpty ? tagNames.join(', ') : '';

          return {
            'source': 'MangaDex',
            'remoteId': item['id'],
            'name': name,
            'description': description,
            'imagePath': imageUrl,
            'imagePathLarge': imageUrl != null
                ? imageUrl.replaceAll('.256.jpg', '.512.jpg')
                : null,
            'genre': tags,
            'genres': tags,
            'year': year ?? '',
            'author': author ?? '',
            'status': status,
            'statusRaw': attributes['status'],
            'lastChapter': attributes['lastChapter'],
            'externalRating': null,
          };
        }).toList();
      }
    } catch (e) {
      _logger.error('Error searching MangaDex: $e');
    }
    return [];
  }

  /// Busca películas o series en OMDb que coincidan con [query].
  ///
  /// Lanza una [Exception] cuando [apiKey] está vacía, la clave de API es inválida,
  /// o el servidor devuelve un código de estado que no es 200.
  ///
  /// [query] El título a buscar.
  /// [apiKey] Una clave de API de OMDb válida.
  /// [page] Número de página basado en 1.
  /// [type] Filtro de tipo OMDb opcional (`'movie'`, `'series'`, `'episode'`).
  Future<List<Map<String, dynamic>>> searchMovies({
    required String query,
    required String apiKey,
    int page = 1,
    String? type,
  }) async {
    if (apiKey.isEmpty) {
      _logger.warning('OMDb API Key no configurada');
      throw Exception('API Key no configurada');
    }
    final typeParam = type != null ? "&type=$type" : "";
    final url = Uri.parse(
      'https://www.omdbapi.com/?s=${Uri.encodeComponent(query)}&page=$page&apikey=$apiKey$typeParam',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['Response'] == 'True') {
          final items = data['Search'] as List? ?? [];
          return items.map((item) {
            return {
              'source': 'OMDb',
              'remoteId': item['imdbID'],
              'name': item['Title'] ?? 'Sin título',
              'imagePath': item['Poster'] != 'N/A' ? item['Poster'] : null,
              'year': item['Year'],
              'type': item['Type'],
              'description': '',
              'genre': '',
              'externalRating': null,
            };
          }).toList();
        } else {
          final error = data['Error'] ?? 'Error desconocido de OMDb';
          if (error == 'Too many results.')
            throw Exception('Demasiados resultados. Sé más específico.');
          if (error == 'Movie not found!') return [];
          if (error == 'Invalid API key!')
            throw Exception('Clave de API inválida.');
          throw Exception(error);
        }
      } else {
        throw Exception('Error del servidor (${response.statusCode})');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Error inesperado al buscar películas: $e');
    }
  }

  /// Obtiene detalles completos de películas/series de OMDb para el [imdbId] dado.
  ///
  /// Devuelve un mapa normalizado con campos extendidos (trama, duración, director,
  /// actores, premios, etc.) o `null` si la solicitud falla.
  ///
  /// [imdbId] El identificador de IMDb (ej. `'tt0133093'`).
  /// [apiKey] Una clave de API de OMDb válida.
  Future<Map<String, dynamic>?> getMovieDetails(
    String imdbId,
    String apiKey,
  ) async {
    final url = Uri.parse(
      'https://www.omdbapi.com/?i=$imdbId&apikey=$apiKey&plot=full',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['Response'] == 'True') {
          // Extraer duración en minutos
          int? runtimeMinutes;
          if (data['Runtime'] != null && data['Runtime'] != 'N/A') {
            final runtimeStr = data['Runtime'].toString();
            final match = RegExp(r'(\d+)').firstMatch(runtimeStr);
            if (match != null) {
              runtimeMinutes = int.tryParse(match.group(1)!);
            }
          }

          // Extraer año
          String? year;
          if (data['Year'] != null) {
            final yearStr = data['Year'].toString();
            if (yearStr.length >= 4) {
              year = yearStr.substring(0, 4);
            }
          }

          return {
            'description': data['Plot'] ?? '',
            'fullDescription': data['Plot'] ?? '',
            'genre': (data['Genre'] as String?)?.split(',').first.trim() ?? '',
            'genres': data['Genre'] ?? '',
            'score': double.tryParse(data['imdbRating'] ?? '0') ?? 0.0,
            'runtime': runtimeMinutes,
            'runtimeRaw': data['Runtime'],
            'year': year ?? '',
            'director': data['Director'],
            'actors': data['Actors'],
            'writer': data['Writer'],
            'language': data['Language'],
            'country': data['Country'],
            'awards': data['Awards'],
            'imdbVotes': data['imdbVotes'],
            'externalRating': double.tryParse(data['imdbRating'] ?? '0') ?? 0.0,
          };
        }
      }
    } catch (e) {
      _logger.error('Error getting movie details', e);
      rethrow;
    }
    return null;
  }

  /// Busca películas o series de TV en TMDb que coincidan con [query].
  ///
  /// Los resultados se devuelven en español (`language=es-ES`). Lanza una [Exception]
  /// cuando [apiKey] está vacía o el servidor devuelve un error.
  ///
  /// [query] El título a buscar.
  /// [apiKey] Una clave de API de TMDb v3 válida.
  /// [page] Número de página basado en 1.
  /// [type] `'movie'` (por defecto) o `'tv'`.
  Future<List<Map<String, dynamic>>> searchTMDb({
    required String query,
    required String apiKey,
    int page = 1,
    String type = 'movie',
  }) async {
    if (apiKey.isEmpty) {
      _logger.warning('TMDb API Key no configurada');
      throw Exception('TMDb API Key no configurada');
    }

    final endpoint = type == 'movie' ? 'search/movie' : 'search/tv';
    final url = Uri.parse(
      'https://api.themoviedb.org/3/$endpoint?query=${Uri.encodeComponent(query)}&page=$page&api_key=$apiKey&language=es-ES',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List? ?? [];
        final isMovie = type == 'movie';
        return results.map((item) {
          return {
            'source': 'TMDb',
            'remoteId': item['id'].toString(),
            'name': item[isMovie ? 'title' : 'name'] ?? 'Sin título',
            'imagePath': item['poster_path'] != null
                ? 'https://image.tmdb.org/t/p/w500${item['poster_path']}'
                : null,
            'imagePathLarge': item['poster_path'] != null
                ? 'https://image.tmdb.org/t/p/original${item['poster_path']}'
                : null,
            'imagePathBackdrop': item['backdrop_path'] != null
                ? 'https://image.tmdb.org/t/p/w780${item['backdrop_path']}'
                : null,
            'year':
                (item[isMovie ? 'release_date' : 'first_air_date'] as String?)
                    ?.split('-')
                    .first ??
                '',
            'type': isMovie ? 'movie' : 'series',
            'description': item['overview'],
            'genreIds': item['genre_ids'],
            'externalRating': (item['vote_average'] as num?)?.toDouble(),
            'voteCount': item['vote_count'],
            'popularity': item['popularity'],
            'adult': item['adult'],
          };
        }).toList();
      } else {
        throw Exception('Error de TMDb (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error en búsqueda TMDb: $e');
    }
  }

  /// Obtiene detalles completos de películas o series de TV de TMDb para el [id] dado.
  ///
  /// Añade créditos e imágenes a la solicitud. Devuelve un mapa normalizado o
  /// `null` si la solicitud falla.
  ///
  /// [id] El identificador numérico de TMDb como cadena.
  /// [apiKey] Una clave de API de TMDb v3 válida.
  /// [type] `'movie'` (por defecto) o `'tv'`.
  Future<Map<String, dynamic>?> getTMDbDetails(
    String id,
    String apiKey, {
    String type = 'movie',
  }) async {
    final endpoint = type == 'movie' ? 'movie' : 'tv';
    final url = Uri.parse(
      'https://api.themoviedb.org/3/$endpoint/$id?api_key=$apiKey&language=es-ES&append_to_response=credits,images',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final isMovie = type == 'movie';

        // Extraer géneros
        final genres = (data['genres'] as List?)
            ?.map((g) => g['name'])
            .join(', ');

        // Extraer duración
        int? runtimeMinutes = data['runtime'];
        if (runtimeMinutes == null && data['episode_run_time'] != null) {
          final runTimes = data['episode_run_time'] as List;
          if (runTimes.isNotEmpty) {
            runtimeMinutes = runTimes[0];
          }
        }

        // Extraer temporadas y episodios
        int? seasons;
        int? episodes;
        if (!isMovie) {
          seasons = data['number_of_seasons'];
          episodes = data['number_of_episodes'];
        }

        // Extraer estudio/producción
        String? studio;
        if (data['production_companies'] != null &&
            (data['production_companies'] as List).isNotEmpty) {
          studio = data['production_companies'][0]['name'];
        }

        // Extraer año
        String? year;
        if (isMovie && data['release_date'] != null) {
          year = data['release_date'].toString().substring(0, 4);
        } else if (!isMovie && data['first_air_date'] != null) {
          year = data['first_air_date'].toString().substring(0, 4);
        }

        // Extraer tagline y información adicional
        String? tagline = data['tagline'];
        int? budget = data['budget'];
        int? revenue = data['revenue'];

        return {
          'description': data['overview'],
          'fullDescription': data['overview'],
          'genre': genres?.split(',').first ?? '',
          'genres': genres,
          'externalRating': (data['vote_average'] as num?)?.toDouble(),
          'voteCount': data['vote_count'],
          'runtime': runtimeMinutes,
          'runtimeRaw': isMovie ? data['runtime'] : data['episode_run_time'],
          'seasons': seasons,
          'totalSeasons': seasons,
          'episodes': episodes,
          'totalEpisodes': episodes,
          'year': year ?? '',
          'studio': studio,
          'tagline': tagline,
          'budget': budget,
          'revenue': revenue,
          'status': data['status'],
          'productionCountries': (data['production_countries'] as List?)
              ?.map((c) => c['name'])
              .join(', '),
          'originalLanguage': data['original_language'],
          'imdbId': data['imdb_id'],
        };
      }
    } catch (e) {
      _logger.error('Error fetching TMDb details', e);
    }
    return null;
  }

  /// Ordena [results] en el lugar priorizando los títulos que coinciden exactamente con [query],
  /// luego los que empiezan por él, luego los que lo contienen, y finalmente
  /// los demás alfabéticamente.
  ///
  /// Cuando dos resultados comparten el mismo prefijo de texto antes del primer número,
  /// se ordenan numéricamente por ese número (útil para listas de volúmenes).
  void _sortResults(List<Map<String, dynamic>> results, String query) {
    final lowerQuery = query.toLowerCase().trim();

    results.sort((a, b) {
      final nameA = (a['name'] as String).toLowerCase();
      final nameB = (b['name'] as String).toLowerCase();

      int priorityA = 3;
      int priorityB = 3;

      if (nameA == lowerQuery)
        priorityA = 0;
      else if (nameA.startsWith(lowerQuery))
        priorityA = 1;
      else if (nameA.contains(lowerQuery))
        priorityA = 2;

      if (nameB == lowerQuery)
        priorityB = 0;
      else if (nameB.startsWith(lowerQuery))
        priorityB = 1;
      else if (nameB.contains(lowerQuery))
        priorityB = 2;

      if (priorityA != priorityB) return priorityA.compareTo(priorityB);

      final regExp = RegExp(r'\d+');
      final matchA = regExp.firstMatch(nameA);
      final matchB = regExp.firstMatch(nameB);

      if (matchA != null && matchB != null) {
        final prefixA = nameA.substring(0, matchA.start);
        final prefixB = nameB.substring(0, matchB.start);

        if (prefixA == prefixB) {
          try {
            final numA = int.parse(matchA.group(1)!);
            final numB = int.parse(matchB.group(1)!);
            return numA.compareTo(numB);
          } catch (_) {}
        }
      }

      return nameA.compareTo(nameB);
    });
  }
}
