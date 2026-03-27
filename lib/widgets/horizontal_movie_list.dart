import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/movie.dart';
import '../providers/movie_provider.dart';
import '../screens/movie_details_screen.dart';
import 'movie_card.dart';

class HorizontalMovieList extends StatefulWidget {
  final String title;
  final List<Movie> movies;
  final bool isTopTen; 
  final String? category; // Category ID for infinite scroll tracking

  const HorizontalMovieList({
    Key? key,
    required this.title,
    required this.movies,
    this.isTopTen = false,
    this.category,
  }) : super(key: key);

  @override
  State<HorizontalMovieList> createState() => _HorizontalMovieListState();
}

class _HorizontalMovieListState extends State<HorizontalMovieList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (widget.category == null) return;
    
    // Trigger load more when user is 200px from the end
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<MovieProvider>().loadMore(widget.category!);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.movies.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
          child: Text(
            widget.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(
          height: 180, 
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: widget.isTopTen ? 16 : 8),
            itemCount: widget.movies.length + (widget.category != null ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == widget.movies.length) {
                // Future-proof: Loading indicator at the end
                return Container(
                  width: 60,
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF7B2FFF)),
                );
              }

              final movie = widget.movies[index];
              Widget cardContent;
              
              if (widget.isTopTen) {
                cardContent = Container(
                  width: 175,
                  margin: const EdgeInsets.only(right: 20),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        right: 0,
                        top: 0,
                        bottom: 0,
                        width: 120,
                        child: MovieCard(movie: movie),
                      ),
                      Positioned(
                        left: -10,
                        bottom: -28,
                        child: ShaderMask(
                          shaderCallback: (Rect bounds) {
                            return const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0xFF9E9E9E), 
                                Color(0xFFFFFFFF), 
                                Color(0xFFBDBDBD), 
                                Color(0xFF757575), 
                              ],
                              stops: [0.0, 0.35, 0.65, 1.0],
                            ).createShader(bounds);
                          },
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              fontSize: 150,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -10,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                cardContent = Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: AspectRatio(
                    aspectRatio: 2 / 3,
                    child: MovieCard(movie: movie),
                  ),
                );
              }

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MovieDetailsScreen(movie: movie),
                    ),
                  );
                },
                child: cardContent,
              );
            },
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
