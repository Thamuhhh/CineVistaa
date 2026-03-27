import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../models/movie.dart';
import '../screens/movie_details_screen.dart';
import '../screens/trailer_screen.dart';

class HeroCarousel extends StatefulWidget {
  final List<Movie> movies;

  const HeroCarousel({Key? key, required this.movies}) : super(key: key);

  @override
  _HeroCarouselState createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<HeroCarousel> {
  late PageController _pageController;
  double _pageOffset = 0;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.9);
    _pageController.addListener(() {
      setState(() {
        _pageOffset = _pageController.page ?? 0;
      });
    });
    _startAutoPlay();
  }

  void _startAutoPlay() async {
    while (mounted) {
      await Future.delayed(const Duration(seconds: 5));
      if (mounted && widget.movies.isNotEmpty) {
        _currentPage = (_currentPage + 1) % widget.movies.length;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 1000),
          curve: Curves.fastOutSlowIn,
        );
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.movies.isEmpty) return const SizedBox();

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        // 🌌 Immersive Dynamic Background Glow
        Positioned.fill(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 800),
            child: CachedNetworkImage(
              key: ValueKey(widget.movies[_currentPage].id),
              imageUrl: widget.movies[_currentPage].backdropUrl,
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.6),
              colorBlendMode: BlendMode.darken,
            ),
          ),
        ),
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
            child: Container(color: Colors.transparent),
          ),
        ),

        // 🎢 The Carousel
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.62,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.movies.length,
            onPageChanged: (idx) => setState(() => _currentPage = idx),
            itemBuilder: (context, index) {
              final movie = widget.movies[index];
              
              // 🎢 Pro-Level 3D & Parallax Logic
              double scale = 1.0;
              double parallax = 0.0;
              double rotation = 0.0;
              
              if (_pageOffset >= index - 1 && _pageOffset <= index + 1) {
                double diff = (_pageOffset - index);
                scale = 1.0 - diff.abs() * 0.15;
                parallax = diff * 180;
                rotation = diff * 0.08;
              }

              return Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001) // Perspective
                  ..scale(scale)
                  ..rotateY(rotation),
                alignment: Alignment.center,
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (_) => MovieDetailsScreen(movie: movie))
                  ),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 30),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.6),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // 🖼️ Deep Parallax Background
                          Transform.translate(
                            offset: Offset(parallax, 0),
                            child: CachedNetworkImage(
                              imageUrl: movie.backdropUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Shimmer.fromColors(
                                baseColor: Colors.grey.shade900,
                                highlightColor: Colors.grey.shade800,
                                child: Container(color: Colors.black),
                              ),
                            ),
                          ),
                          // Ultra-Cinematic Gradient
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.2),
                                  Colors.black.withOpacity(0.95),
                                ],
                                stops: const [0.3, 0.6, 1.0],
                              ),
                            ),
                          ),
                          // Content Overlay
                          Positioned(
                            left: 20,
                            right: 20,
                            bottom: 30,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  movie.title.toUpperCase(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.5,
                                    color: Colors.white,
                                    shadows: [Shadow(color: Colors.black, blurRadius: 15)],
                                  ),
                                ),
                                const SizedBox(height: 14),
                                // Glassmorphic Premium Pill
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: Colors.white.withOpacity(0.15)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 18),
                                          const SizedBox(width: 5),
                                          Text(
                                            movie.rating.toStringAsFixed(1),
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                                          ),
                                          const SizedBox(width: 15),
                                          Text(
                                            movie.releaseDate.split('-')[0],
                                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                                          ),
                                          const SizedBox(width: 15),
                                          const Text("ULTRA HD", style: TextStyle(color: Color(0xFF7B2FFF), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 25),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildHeroButton(
                                      context,
                                      icon: Icons.play_arrow_rounded,
                                      label: 'PLAY',
                                      color: const Color(0xFF7B2FFF),
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => TrailerScreen(
                                            trailerId: movie.trailerId,
                                            movieTitle: movie.title,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 15),
                                    _buildHeroButton(
                                      context,
                                      icon: Icons.info_outline_rounded,
                                      label: 'INFO',
                                      color: Colors.white.withOpacity(0.1),
                                      onTap: () => Navigator.push(
                                        context, 
                                        MaterialPageRoute(builder: (_) => MovieDetailsScreen(movie: movie))
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeroButton(BuildContext context, {required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          if (color != Colors.white.withOpacity(0.15))
            BoxShadow(color: color.withOpacity(0.3), blurRadius: 10, spreadRadius: 1)
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Material(
            color: color,
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Row(
                  children: [
                    Icon(icon, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
