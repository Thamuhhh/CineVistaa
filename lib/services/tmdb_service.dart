import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';

class TmdbService {
  static const String _apiKey = 'cdef1e87093b92da3dcf8e7032daf61c';
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  static const String _imageBase = 'https://image.tmdb.org/t/p';

  // Fetch a list of movies from any TMDB endpoint with pagination
  Future<List<Movie>> _fetchMovies(String endpoint, List<String> categories, {int page = 1, String? language = 'ta'}) async {
    try {
      final connector = endpoint.contains('?') ? '&' : '?';
      final langParam = (language != null && language.isNotEmpty) ? '&with_original_language=$language' : '';
      
      final uri = Uri.parse(
        '$_baseUrl$endpoint${connector}api_key=$_apiKey$langParam&region=IN&page=$page',
      );
      final response = await http.get(uri);
      if (response.statusCode != 200) return [];

      final data = json.decode(response.body);
      final List results = data['results'] ?? [];

      // Fetch details and trailers in parallel
      final movies = await Future.wait(
        results.take(15).map((json) => _buildMovie(json, categories)),
      );
      return movies.whereType<Movie>().toList();
    } catch (e) {
      return [];
    }
  }

  // Build a single Movie object, fetching its trailer ID and providers
  Future<Movie?> _buildMovie(Map<String, dynamic> json, List<String> categories) async {
    final int? id = json['id'];
    if (id == null) return null;

    final String posterPath = json['poster_path'] ?? '';
    final String backdropPath = json['backdrop_path'] ?? '';

    if (posterPath.isEmpty || backdropPath.isEmpty) return null;

    // Fetch trailer and providers in parallel
    final results = await Future.wait([
      _fetchTrailerId(id),
      _fetchWatchProviders(id),
    ]);

    return Movie(
      id: id.toString(),
      title: json['title'] ?? json['original_title'] ?? 'Unknown',
      originalTitle: json['original_title'] ?? '',
      posterUrl: '$_imageBase/w500$posterPath',
      backdropUrl: '$_imageBase/original$backdropPath',
      overview: json['overview'] ?? 'No overview available.',
      rating: (json['vote_average'] ?? 0.0).toDouble(),
      releaseDate: json['release_date'] ?? '2024-01-01',
      trailerId: results[0] as String,
      categories: categories,
      watchProviders: results[1] as List<String>,
    );
  }

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

  // Get YouTube trailer ID for a specific movie
  Future<String> _fetchTrailerId(int movieId) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl/movie/$movieId/videos?api_key=$_apiKey&language=en-US',
      );
      final response = await http.get(uri);
      if (response.statusCode != 200) return '';

      final data = json.decode(response.body);
      final List results = data['results'] ?? [];

      // Prefer official Trailer on YouTube
      final trailer = results.firstWhere(
        (v) => v['type'] == 'Trailer' && v['site'] == 'YouTube',
        orElse: () => results.isNotEmpty ? results.first : null,
      );

      return trailer != null ? (trailer['key'] ?? '') : '';
    } catch (e) {
      return '';
    }
  }

  // --- Public API Methods (Tamil language priority with Pagination) ---

  // Fetches ALL Indian releases (Tamil, Hindi, etc.) but ENSURES Tamil appears first!
  Future<List<Movie>> fetchNowPlaying({int page = 1}) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl/movie/now_playing?api_key=$_apiKey&region=IN&page=$page',
      );
      final response = await http.get(uri);
      if (response.statusCode != 200) return [];

      final data = json.decode(response.body);
      final List results = data['results'] ?? [];

      // 🔥 Client-side priority sort: Move Tamil (ta) to the front of the line
      results.sort((a, b) {
        final aLang = a['original_language'] ?? '';
        final bLang = b['original_language'] ?? '';
        if (aLang == 'ta' && bLang != 'ta') return -1;
        if (aLang != 'ta' && bLang == 'ta') return 1;
        return 0;
      });

      final movies = await Future.wait(
        results.take(20).map((json) => _buildMovie(json, ['featured', 'new_release'])),
      );
      return movies.whereType<Movie>().toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Movie>> fetchTrending({int page = 1}) =>
      _fetchMovies('/discover/movie?sort_by=popularity.desc&primary_release_date.gte=2024-01-01', ['trending', 'featured'], page: page);

  Future<List<Movie>> fetchTopRated({int page = 1}) =>
      _fetchMovies('/discover/movie?sort_by=vote_average.desc&vote_count.gte=200&region=IN', ['top_rated'], page: page, language: null);

  Future<List<Movie>> fetchPopular({int page = 1}) =>
      _fetchMovies('/discover/movie?sort_by=popularity.desc&region=IN&with_genres=28', ['action'], page: page, language: null);

  Future<List<Movie>> fetchByGenre(int genreId, {int page = 1}) =>
      _fetchMovies('/discover/movie?with_genres=$genreId&region=IN', ['genre_filtered'], page: page, language: null);

  Future<List<Movie>> fetchRecommendations(String movieId) =>
      _fetchMovies('/movie/$movieId/recommendations', [], language: null);

  Future<List<Movie>> searchMovies(String query) async {
    if (query.isEmpty) return [];
    try {
      final uri = Uri.parse(
        '$_baseUrl/search/movie?api_key=$_apiKey&query=${Uri.encodeComponent(query)}&region=IN&page=1',
      );
      final response = await http.get(uri);
      if (response.statusCode != 200) return [];

      final data = json.decode(response.body);
      final List results = data['results'] ?? [];

      // Sort search results to keep Tamil first if multiple hits exist
      results.sort((a, b) {
        final aLang = a['original_language'] ?? '';
        final bLang = b['original_language'] ?? '';
        if (aLang == 'ta' && bLang != 'ta') return -1;
        if (aLang != 'ta' && bLang == 'ta') return 1;
        return 0;
      });

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
