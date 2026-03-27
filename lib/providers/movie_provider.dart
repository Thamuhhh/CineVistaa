import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/movie.dart';
import '../services/tmdb_service.dart';

class MovieProvider with ChangeNotifier {
  final TmdbService _api = TmdbService();
  List<Movie> _allMovies = [];
  List<Movie> _watchlist = [];
  List<Movie> _recentlyViewed = [];
  bool _isLoading = true;
  bool _isSorting = false;
  
  // Pagination tracking
  final Map<String, int> _pageTracker = {
    'featured': 1,
    'trending': 1,
    'new_release': 1,
    'top_rated': 1,
    'action': 1,
    'genre': 1,
  };

  int? _selectedGenreId;
  String? _selectedGenreName;

  bool get isLoading => _isLoading;
  bool get isSorting => _isSorting;
  List<Movie> get allMovies => _allMovies;
  List<Movie> get watchlist => _watchlist;
  List<Movie> get recentlyViewed => _recentlyViewed;
  String? get selectedGenreName => _selectedGenreName;

  // Real-time categorized getters
  List<Movie> get featuredMovies => _allMovies.where((m) => m.categories.contains('featured')).toList();
  List<Movie> get trendingMovies => _allMovies.where((m) => m.categories.contains('trending')).toList();
  List<Movie> get actionMovies => _allMovies.where((m) => m.categories.contains('action')).toList();
  List<Movie> get topRatedMovies => _allMovies.where((m) => m.categories.contains('top_rated')).toList();
  List<Movie> get newReleases => _allMovies.where((m) => m.categories.contains('new_release')).toList();
  List<Movie> get genreMovies => _allMovies.where((m) => m.categories.contains('genre_filtered')).toList();

  MovieProvider() {
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    _isLoading = true;
    _allMovies = [];
    notifyListeners();

    try {
      // Reset page tracking
      _pageTracker.updateAll((key, value) => 1);

      await _loadHomeCategory(() => _api.fetchNowPlaying(page: 1));
      await _loadHomeCategory(() => _api.fetchTrending(page: 1));
      await _loadHomeCategory(() => _api.fetchTopRated(page: 1));
      await _loadHomeCategory(() => _api.fetchPopular(page: 1));
      
      // Load persistent state
      await Future.wait([
        _loadWatchlist(),
        _loadRecentlyViewed(),
      ]);
    } catch (e) {
      debugPrint('API Error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadHomeCategory(Future<List<Movie>> Function() loader) async {
    try {
      final results = await loader();
      if (results.isNotEmpty) {
        _mergeMovies(results);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Home category load error: $e');
    }
  }

  // --- Recently Viewed (History) Engine ---

  Future<void> addToRecentlyViewed(Movie movie) async {
    // Remove if exists to move to front
    _recentlyViewed.removeWhere((m) => m.id == movie.id);
    
    // Insert at front
    _recentlyViewed.insert(0, movie);
    
    // Limit to 10 most recent
    if (_recentlyViewed.length > 10) {
      _recentlyViewed = _recentlyViewed.sublist(0, 10);
    }
    
    notifyListeners();
    await _saveRecentlyViewed();
  }

  Future<void> _loadRecentlyViewed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? data = prefs.getString('recently_viewed');
      if (data != null) {
        final List<dynamic> decoded = json.decode(data);
        _recentlyViewed = decoded.map((i) => Movie.fromJson(i)).toList();
      }
    } catch (e) {
      debugPrint('Load History Error: $e');
    }
  }

  Future<void> _saveRecentlyViewed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = json.encode(_recentlyViewed.map((m) => m.toJson()).toList());
      await prefs.setString('recently_viewed', encoded);
    } catch (e) {
      debugPrint('Save History Error: $e');
    }
  }

  // --- Infinite Scroll Logic ---
  
  Future<void> loadMore(String category) async {
    final int nextPage = (_pageTracker[category] ?? 1) + 1;
    List<Movie> newResults = [];

    try {
      switch (category) {
        case 'trending':
          newResults = await _api.fetchTrending(page: nextPage);
          break;
        case 'new_release':
          newResults = await _api.fetchNowPlaying(page: nextPage);
          break;
        case 'top_rated':
          newResults = await _api.fetchTopRated(page: nextPage);
          break;
        case 'action':
          newResults = await _api.fetchPopular(page: nextPage);
          break;
        case 'genre':
          if (_selectedGenreId != null) {
            newResults = await _api.fetchByGenre(_selectedGenreId!, page: nextPage);
          }
          break;
      }

      if (newResults.isNotEmpty) {
        _pageTracker[category] = nextPage;
        _mergeMovies(newResults);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Load More Error: $e');
    }
  }

  // --- Genre Filtering Engine ---

  Future<void> setGenre(int? id, String? name) async {
    if (_selectedGenreId == id) return;

    _selectedGenreId = id;
    _selectedGenreName = name;
    _isSorting = true;
    notifyListeners();

    // Clear old genre filter results from master list
    _allMovies.removeWhere((m) => m.categories.contains('genre_filtered'));

    if (id != null) {
      _pageTracker['genre'] = 1;
      final results = await _api.fetchByGenre(id, page: 1);
      _mergeMovies(results);
    }

    _isSorting = false;
    notifyListeners();
  }

  void _mergeMovies(List<Movie> newMovies) {
    final Map<String, Movie> unifiedMap = {for (var m in _allMovies) m.id: m};

    for (var movie in newMovies) {
      if (unifiedMap.containsKey(movie.id)) {
        final existing = unifiedMap[movie.id]!;
        final updatedCategories = {...existing.categories, ...movie.categories}.toList();
        unifiedMap[movie.id] = Movie(
          id: existing.id,
          title: _preferNonEmpty(existing.title, movie.title),
          originalTitle: _preferNonEmpty(existing.originalTitle, movie.originalTitle),
          posterUrl: _preferNonEmpty(existing.posterUrl, movie.posterUrl),
          backdropUrl: _preferNonEmpty(existing.backdropUrl, movie.backdropUrl),
          logoUrl: _preferOptional(existing.logoUrl, movie.logoUrl),
          overview: _preferNonEmpty(existing.overview, movie.overview),
          rating: existing.rating > 0 ? existing.rating : movie.rating,
          releaseDate: _preferNonEmpty(existing.releaseDate, movie.releaseDate),
          trailerId: _preferNonEmpty(existing.trailerId, movie.trailerId),
          categories: updatedCategories,
          watchProviders: existing.watchProviders.isNotEmpty
              ? existing.watchProviders
              : movie.watchProviders,
        );
      } else {
        unifiedMap[movie.id] = movie;
      }
    }
    _allMovies = unifiedMap.values.toList();
  }

  String _preferNonEmpty(String primary, String fallback) {
    return primary.trim().isNotEmpty ? primary : fallback;
  }

  String? _preferOptional(String? primary, String? fallback) {
    if (primary != null && primary.trim().isNotEmpty) return primary;
    if (fallback != null && fallback.trim().isNotEmpty) return fallback;
    return null;
  }

  // --- Watchlist Engine ---
  
  bool isInWatchlist(String movieId) {
    return _watchlist.any((m) => m.id == movieId);
  }

  Future<void> toggleWatchlist(Movie movie) async {
    if (isInWatchlist(movie.id)) {
      _watchlist.removeWhere((m) => m.id == movie.id);
    } else {
      _watchlist.add(movie);
    }
    notifyListeners();
    await _saveWatchlist();
  }

  Future<void> _loadWatchlist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? data = prefs.getString('my_watchlist');
      if (data != null) {
        final List<dynamic> decoded = json.decode(data);
        _watchlist = decoded.map((i) => Movie.fromJson(i)).toList();
      }
    } catch (e) {
      debugPrint('Load Watchlist Error: $e');
    }
  }

  Future<void> _saveWatchlist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = json.encode(_watchlist.map((m) => m.toJson()).toList());
      await prefs.setString('my_watchlist', encoded);
    } catch (e) {
      debugPrint('Save Watchlist Error: $e');
    }
  }
}
