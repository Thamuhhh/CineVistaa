import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';
import '../utils/branding_registry.dart';

class TmdbService {
  static const String _apiKey = 'cdef1e87093b92da3dcf8e7032daf61c';
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  static const String _imageBase = 'https://image.tmdb.org/t/p';
  static const Duration _requestTimeout = Duration(seconds: 12);
  static const int _maxMovieResults = 16;
  static const int _movieBuildBatchSize = 4;

  // Fetch a list of movies from any TMDB endpoint with pagination
  Future<List<Movie>> _fetchMovies(String endpoint, List<String> categories, {int page = 1, String? language}) async {
    try {
      final connector = endpoint.contains('?') ? '&' : '?';
      
      // 🔥 THE INDIAN PRIDE FILTER: Strictly include only Indian languages if no specific one is asked
      // ta: Tamil, hi: Hindi, te: Telugu, ml: Malayalam, kn: Kannada
      final String indianLanguages = 'ta|hi|te|ml|kn';
      final langParam = (language != null && language.isNotEmpty) 
          ? '&with_original_language=$language' 
          : '&with_original_language=$indianLanguages';
      
      final uri = Uri.parse(
        '$_baseUrl$endpoint${connector}api_key=$_apiKey$langParam&region=IN&page=$page',
      );
      final response = await _getWithRetry(uri);
      if (response.statusCode != 200) return [];

      final data = json.decode(response.body);
      final List results = data['results'] ?? [];

      // Always prioritize Tamil in the results for this specific app
      _sortResultsTamilFirst(results);

      return _buildMoviesSafely(results, categories);
    } catch (e) {
      return [];
    }
  }

  // Reusable sorting engine to ensure Tamil movies stay at the top of the list
  void _sortResultsTamilFirst(List results) {
    results.sort((a, b) {
      final aLang = a['original_language'] ?? '';
      final bLang = b['original_language'] ?? '';
      if (aLang == 'ta' && bLang != 'ta') return -1;
      if (aLang != 'ta' && bLang == 'ta') return 1;
      return 0;
    });
  }

  // Build a single Movie object, fetching its trailer ID and providers
  Future<Movie?> _buildMovie(Map<String, dynamic> json, List<String> categories) async {
    final int? id = json['id'];
    if (id == null) return null;

    final String posterPath = json['poster_path'] ?? '';
    final String backdropPath = json['backdrop_path'] ?? '';

    // Only include movies with posters for a premium look
    if (posterPath.isEmpty || backdropPath.isEmpty) return null;

    final String originalLanguage = json['original_language'] ?? '';

    // Fetch trailer, providers, and LOGO in parallel
    final results = await Future.wait([
      _fetchTrailerId(id),
      _fetchWatchProviders(id),
      _fetchLogoPath(id, preferredLanguage: originalLanguage),
    ]);

    return Movie(
      id: id.toString(),
      title: json['title'] ?? json['original_title'] ?? 'Unknown',
      originalTitle: json['original_title'] ?? '',
      posterUrl: '$_imageBase/w500$posterPath',
      backdropUrl: '$_imageBase/original$backdropPath',
      logoUrl: results[2] as String?,
      overview: json['overview'] ?? 'No overview available.',
      rating: (json['vote_average'] ?? 0.0).toDouble(),
      releaseDate: json['release_date'] ?? '2024-01-01',
      trailerId: results[0] as String,
      categories: categories,
      watchProviders: results[1] as List<String>,
    );
  }

  // Fetch official transparent logo PNG for a movie
  Future<String?> _fetchLogoPath(int movieId, {String? preferredLanguage}) async {
    try {
      // 🕵️ SOURCE 1: Branding Registry (Agentic Internet Search Overrides)
      // We check this curated registry first to catch perfect internet-sourced logos
      // that are missing from TMDB (e.g., Youth 2002 Vijay Classic).
      final customLogo = BrandingRegistry.getReservedLogo(movieId);
      if (customLogo != null) return customLogo;

      // 🌍 SOURCE 2: Aggressive Logo Scan (Official TMDB)
      final uri = Uri.parse(
        '$_baseUrl/movie/$movieId/images?api_key=$_apiKey',
      );
      final response = await http.get(uri);
      if (response.statusCode != 200) return null;

      final data = json.decode(response.body);
      final List logos = data['logos'] ?? [];
      
      if (logos.isNotEmpty) {
        // 1. Match the movie's actual original language if TMDB has it
        final preferredLogo = _findLogoByLanguage(logos, preferredLanguage);
        if (preferredLogo != null) return preferredLogo;

        // 2. Tamil branding if available
        final tamilLogo = _findLogoByLanguage(logos, 'ta');
        if (tamilLogo != null) return tamilLogo;

        // 3. English / studio standard
        final englishLogo = _findLogoByLanguage(logos, 'en');
        if (englishLogo != null) return englishLogo;

        // 4. Untagged standard logos
        final untaggedLogo = logos.cast<Map<String, dynamic>>().firstWhere(
          (l) => (l['iso_639_1'] == null || l['iso_639_1'] == 'xx') &&
              (l['file_path'] as String?)?.isNotEmpty == true,
          orElse: () => <String, dynamic>{},
        );
        if (untaggedLogo.isNotEmpty) return '$_imageBase/original${untaggedLogo['file_path']}';

        // 5. Absolute fallback: use any available logo instead of leaving it blank
        final anyLogo = logos.cast<Map<String, dynamic>>().firstWhere(
          (l) => (l['file_path'] as String?)?.isNotEmpty == true,
          orElse: () => <String, dynamic>{},
        );
        if (anyLogo.isNotEmpty) return '$_imageBase/original${anyLogo['file_path']}';
      }

      // OpenAI fallback generation is handled at the UI/service layer when TMDB has no logo.
      return null;
    } catch (e) {
      return null;
    }
  }

  String? _findLogoByLanguage(List logos, String? languageCode) {
    if (languageCode == null || languageCode.isEmpty) return null;

    final logo = logos.cast<Map<String, dynamic>>().firstWhere(
      (l) => l['iso_639_1'] == languageCode &&
          (l['file_path'] as String?)?.isNotEmpty == true,
      orElse: () => <String, dynamic>{},
    );

    if (logo.isEmpty) return null;
    return '$_imageBase/original${logo['file_path']}';
  }

  // Fetch watch providers for a movie
  Future<List<String>> _fetchWatchProviders(int movieId) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl/movie/$movieId/watch/providers?api_key=$_apiKey',
      );
      final response = await http.get(uri);
      if (response.statusCode != 200) return [];

      final data = json.decode(response.body);
      final results = data['results'] ?? {};
      
      // Focus on India (IN) stream providers
      final india = results['IN'] ?? {};
      final flatrate = india['flatrate'] ?? [];
      
      return List<String>.from(flatrate.map((p) => p['provider_name']));
    } catch (e) {
      return [];
    }
  }

  Future<List<Movie>> _buildMoviesSafely(List results, List<String> categories) async {
    final builtMovies = <Movie>[];
    final limitedResults = results.take(_maxMovieResults).cast<Map<String, dynamic>>().toList();

    for (int i = 0; i < limitedResults.length; i += _movieBuildBatchSize) {
      final batch = limitedResults.skip(i).take(_movieBuildBatchSize);
      final batchResults = await Future.wait(
        batch.map((json) => _buildMovieSafely(json, categories)),
      );
      builtMovies.addAll(batchResults.whereType<Movie>());
    }

    return builtMovies;
  }

  Future<Movie?> _buildMovieSafely(Map<String, dynamic> json, List<String> categories) async {
    try {
      return await _buildMovie(json, categories);
    } catch (e) {
      return null;
    }
  }

  Future<http.Response> _getWithRetry(Uri uri, {int maxAttempts = 3}) async {
    http.Response? lastResponse;

    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        final response = await http.get(uri).timeout(_requestTimeout);
        if (response.statusCode == 429 || response.statusCode >= 500) {
          lastResponse = response;
        } else {
          return response;
        }
      } catch (e) {
        if (attempt == maxAttempts) rethrow;
      }

      if (attempt < maxAttempts) {
        await Future.delayed(Duration(milliseconds: 450 * attempt));
      }
    }

    return lastResponse ?? http.Response('', 500);
  }

  // Get YouTube trailer ID for a specific movie
  Future<String> _fetchTrailerId(int movieId) async {
    try {
      // 🌍 We remove '&language=en-US' to ensure we capture regional Tamil/Indian trailers
      final uri = Uri.parse(
        '$_baseUrl/movie/$movieId/videos?api_key=$_apiKey',
      );
      final response = await http.get(uri);
      if (response.statusCode != 200) return '';

      final data = json.decode(response.body);
      final List results = data['results'] ?? [];

      if (results.isEmpty) return '';

      // 🔥 Premium Priority Logic: Search for the best video in order
      final trailer = results.firstWhere(
        (v) => v['type'] == 'Trailer' && v['site'] == 'YouTube',
        orElse: () => null,
      );
      if (trailer != null) return (trailer['key'] ?? '');

      final teaser = results.firstWhere(
        (v) => v['type'] == 'Teaser' && v['site'] == 'YouTube',
        orElse: () => null,
      );
      if (teaser != null) return (teaser['key'] ?? '');

      final clip = results.firstWhere(
        (v) => (v['type'] == 'Clip' || v['type'] == 'Featurette') && v['site'] == 'YouTube',
        orElse: () => null,
      );
      if (clip != null) return (clip['key'] ?? '');

      final fallback = results.firstWhere(
        (v) => v['site'] == 'YouTube',
        orElse: () => null,
      );

      return fallback != null ? (fallback['key'] ?? '') : '';
    } catch (e) {
      return '';
    }
  }

  // --- Public API Methods (Strict Indian Focus with Tamil Priority) ---

  // Fetches ALL Indian releases but ENSURES Tamil appears first!
  Future<List<Movie>> fetchNowPlaying({int page = 1}) =>
      _fetchMovies('/movie/now_playing', ['featured', 'new_release'], page: page);

  Future<List<Movie>> fetchTrending({int page = 1}) =>
      _fetchMovies('/discover/movie?sort_by=popularity.desc&primary_release_date.gte=2023-01-01', ['trending', 'featured'], page: page);

  Future<List<Movie>> fetchTopRated({int page = 1}) =>
      _fetchMovies('/discover/movie?sort_by=vote_average.desc&vote_count.gte=50', ['top_rated'], page: page);

  Future<List<Movie>> fetchPopular({int page = 1}) =>
      _fetchMovies('/discover/movie?sort_by=popularity.desc&with_genres=28', ['action'], page: page);

  Future<List<Movie>> fetchByGenre(int genreId, {int page = 1}) =>
      _fetchMovies('/discover/movie?with_genres=$genreId', ['genre_filtered'], page: page);

  Future<List<Movie>> fetchRecommendations(String movieId) =>
      _fetchMovies('/movie/$movieId/recommendations', []);

  Future<List<Movie>> searchMovies(String query) async {
    if (query.isEmpty) return [];
    try {
      final String indianLanguages = 'ta|hi|te|ml|kn';
      final uri = Uri.parse(
        '$_baseUrl/search/movie?api_key=$_apiKey&query=${Uri.encodeComponent(query)}&region=IN&with_original_language=$indianLanguages&page=1',
      );
      final response = await http.get(uri);
      if (response.statusCode != 200) return [];

      final data = json.decode(response.body);
      final List results = data['results'] ?? [];

      _sortResultsTamilFirst(results);

      final movies = await Future.wait(
        results.take(10).map((json) => _buildMovie(json, [])),
      );
      return movies.whereType<Movie>().toList();
    } catch (e) {
      return [];
    }
  }

  // Fetch real Cast and Crew for a movie
  Future<List<Map<String, String>>> fetchCredits(String movieId) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl/movie/$movieId/credits?api_key=$_apiKey',
      );
      final response = await http.get(uri);
      if (response.statusCode != 200) return [];

      final data = json.decode(response.body);
      final List cast = data['cast'] ?? [];

      return cast.take(10).map((c) => {
        'name': (c['name'] as String? ?? 'Unknown'),
        'img': (c['profile_path'] != null 
                ? '$_imageBase/w200${c['profile_path']}' 
                : 'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png'),
      }).toList();
    } catch (e) {
      return [];
    }
  }
}
