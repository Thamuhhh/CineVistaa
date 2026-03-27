import 'dart:async';
import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/tmdb_service.dart';
import '../widgets/movie_card.dart';
import 'movie_details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TmdbService _api = TmdbService();
  final TextEditingController _searchController = TextEditingController();
  List<Movie> _searchResults = [];
  bool _isSearching = false;
  Timer? _debounce;

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isNotEmpty) {
        _performSearch(query);
      } else {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
      }
    });
  }

  Future<void> _performSearch(String query) async {
    setState(() => _isSearching = true);
    final results = await _api.searchMovies(query);
    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Premium Cinematic Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                style: const TextStyle(color: Colors.white, fontSize: 18),
                cursorColor: const Color(0xFF7B2FFF), // Royal Purple Cursor
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade900,
                  hintText: 'Search any movie (e.g. Leo, Jailer)...',
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade400, size: 28),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, color: Colors.white54),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchResults = [];
                              _isSearching = false;
                            });
                          },
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(vertical: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Color(0xFF7B2FFF).withOpacity(0.4), width: 1.5),
                  ),
                ),
              ),
            ),
            
            // Search Results Heading
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                _searchController.text.isEmpty 
                  ? 'Explore Global Cinema' 
                  : (_isSearching ? 'Searching...' : (_searchResults.isEmpty ? 'No results found' : 'Top Results')),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                  color: Colors.white,
                ),
              ),
            ),

            // Results Grid / Loading / Empty
            Expanded(
              child: _isSearching
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF7B2FFF)))
                  : _searchResults.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_rounded, size: 80, color: Colors.grey.shade800),
                              const SizedBox(height: 16),
                              Text(
                                _searchController.text.isEmpty 
                                  ? 'Enter a movie name to search' 
                                  : 'No matches found in the universe',
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                              ),
                            ],
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 100, top: 8),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 2 / 3,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final movie = _searchResults[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => MovieDetailsScreen(movie: movie),
                                  ),
                                );
                              },
                              child: MovieCard(movie: movie),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
