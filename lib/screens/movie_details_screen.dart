import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../models/movie.dart';
import '../providers/movie_provider.dart';
import '../widgets/horizontal_movie_list.dart';
import 'trailer_screen.dart';
import '../services/tmdb_service.dart';

class MovieDetailsScreen extends StatelessWidget {
  final Movie movie;
  final TmdbService _api = TmdbService();

  MovieDetailsScreen({Key? key, required this.movie}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final provider = Provider.of<MovieProvider>(context, listen: false);
    final isSaved = provider.isInWatchlist(movie.id);

    // Track this visit for "Continue Watching" history
    WidgetsBinding.instance.addPostFrameCallback((_) {
      provider.addToRecentlyViewed(movie);
    });

    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            // Increased height specifically to show off the cinematic glass effect
            expandedHeight: size.height * 0.45, 
            pinned: true,
            backgroundColor: Colors.black,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: movie.backdropUrl,
                    fit: BoxFit.cover,
                  ),
                  // Dark gradient fading down globally for main legibility
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.4),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.5],
                      ),
                    ),
                  ),
                  // Clean cinematic black bottom fade (No blur)
                  Positioned(
                    bottom: -1,
                    left: 0,
                    right: 0,
                    height: 200,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.8),
                            Colors.black,
                          ],
                          stops: const [0.0, 0.6, 1.0],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        movie.releaseDate.length >= 4 ? movie.releaseDate.substring(0, 4) : '', 
                        style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade900,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('UA', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text('${movie.rating}'),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade700),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('4K Ultra HD', style: TextStyle(fontSize: 10, color: Colors.grey)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Action Buttons Row (Prime Video style)
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TrailerScreen(
                                  trailerId: movie.trailerId,
                                  movieTitle: movie.title, 
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.play_arrow, size: 28),
                          label: const Text(
                            'Watch Trailer',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        children: [
                          IconButton(
                            onPressed: () => provider.toggleWatchlist(movie),
                            icon: Icon(
                              isSaved ? Icons.check : Icons.add,
                              size: 32,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            isSaved ? 'Saved' : 'Watchlist',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      Column(
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.file_download_outlined, size: 28, color: Colors.white),
                          ),
                          Text(
                            'Download',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  // 🎭 Real Star Cast & Global Crew
                  const SizedBox(height: 36),
                  const Text('Top Cast & Stars', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 16),
                  _buildRealCastRow(),

                  // Synopsis Text
                  const SizedBox(height: 36),
                  const Text(
                    'Synopsis',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    movie.overview,
                    style: TextStyle(
                      color: Colors.grey.shade300,
                      height: 1.5,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (movie.watchProviders.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Available On',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildWatchProvidersRow(movie.watchProviders),
                    const SizedBox(height: 32),
                  ],

                  const Divider(color: Colors.white24),
                  const SizedBox(height: 16),
                  
                  // 🎬 Deep Recommendations Engine (Real API)
                  FutureBuilder<List<Movie>>(
                    future: _api.fetchRecommendations(movie.id),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data!.isEmpty) return const SizedBox();
                      return HorizontalMovieList(
                        title: 'More Like This',
                        movies: snapshot.data!,
                      );
                    },
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🎨 Real Star Cast Fetcher (Kollywood, Hollywood, or Global)
  Widget _buildRealCastRow() {
    return FutureBuilder<List<Map<String, String>>>(
      future: _api.fetchCredits(movie.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              itemBuilder: (_, __) => Padding(
                padding: const EdgeInsets.only(right: 24),
                child: Column(
                  children: [
                    Container(
                      width: 70, height: 70,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey.shade900),
                    ),
                    const SizedBox(height: 8),
                    Container(width: 50, height: 10, color: Colors.grey.shade900),
                  ],
                ),
              ),
            ),
          );
        }

        final cast = snapshot.data!;
        if (cast.isEmpty) return const Text('Cast information not available', style: TextStyle(color: Colors.grey));

        return SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: cast.length,
            itemBuilder: (context, index) {
              final actor = cast[index];
              return Padding(
                padding: const EdgeInsets.only(right: 24),
                child: Column(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF7B2FFF).withOpacity(0.3), width: 1.5),
                        image: DecorationImage(
                          image: CachedNetworkImageProvider(actor['img']!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 80,
                      child: Text(
                        actor['name']!,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  // Builder for premium glowing platform chips
  Widget _buildWatchProvidersRow(List<String> providers) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: providers.map((platform) {
        Color bgColor;
        Color textColor = Colors.white;
        if (platform.toLowerCase().contains('netflix')) {
          bgColor = const Color(0xFFE50914).withOpacity(0.15);
          textColor = const Color(0xFFE50914);
        } else if (platform.toLowerCase().contains('amazon') || platform.toLowerCase().contains('prime')) {
          bgColor = const Color(0xFF00A8E1).withOpacity(0.15);
          textColor = const Color(0xFF00A8E1);
        } else if (platform.toLowerCase().contains('hotstar') || platform.toLowerCase().contains('disney')) {
          bgColor = const Color(0xFF113CCF).withOpacity(0.2);
          textColor = const Color(0xFF4A90E2);
        } else if (platform.toLowerCase().contains('zee5')) {
          bgColor = const Color(0xFF8230C6).withOpacity(0.15);
          textColor = const Color(0xFFAD5AFF);
        } else if (platform.toLowerCase().contains('sony')) {
          bgColor = const Color(0xFFC7A148).withOpacity(0.15);
          textColor = const Color(0xFFFFD700);
        } else if (platform.toLowerCase().contains('sun')) {
          bgColor = const Color(0xFFFF4500).withOpacity(0.15);
          textColor = const Color(0xFFFF4500);
        } else {
          bgColor = Colors.grey.shade900;
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(30), // Matching the pill-button aesthetics
            border: Border.all(color: textColor.withOpacity(0.3), width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.tv_rounded, color: textColor, size: 16),
              const SizedBox(width: 8),
              Text(
                platform,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
