import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/movie_provider.dart';
import '../widgets/hero_carousel.dart';
import '../widgets/horizontal_movie_list.dart';
import 'package:shimmer/shimmer.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ScrollController _scrollController;
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          _scrollOffset = _scrollController.offset;
        });
      });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MovieProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.allMovies.isEmpty) {
          // Extremely premium geometric shimmer sequence rendering precisely over the ultimate movie layout spots
          return Scaffold(
            backgroundColor: Colors.black,
            body: Shimmer.fromColors(
              baseColor: Colors.grey.shade900,
              highlightColor: Colors.grey.shade800,
              child: ListView(
                physics: const NeverScrollableScrollPhysics(), // Don't scroll while loading
                padding: EdgeInsets.zero,
                children: [
                  // Hero Poster Massive Skeleton Container
                  Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.55,
                    color: Colors.black,
                  ),
                  const SizedBox(height: 32),
                  
                  // Horizontal Category Ribbon 1 Mock Skeleton
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(width: 150, height: 26, color: Colors.black),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 180,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: 4,
                      itemBuilder: (_, __) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Container(
                          width: 120, 
                          height: 180, 
                          decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ),

                  // Horizontal Category Ribbon 2 Mock Skeleton
                  const SizedBox(height: 48),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(width: 200, height: 26, color: Colors.black),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 180,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: 4,
                      itemBuilder: (_, __) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Container(
                          width: 120, 
                          height: 180, 
                          decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              // Scrollable Core Content
              CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 120),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          HeroCarousel(movies: provider.featuredMovies),
                          const SizedBox(height: 32),

                          // ❤️ My Watchlist — only shows up if you have saved movies
                          if (provider.watchlist.isNotEmpty)
                            HorizontalMovieList(
                               title: '❤️ My List', 
                               movies: provider.watchlist,
                            ),
                          // 🆕 New Releases — placed just above Trending Now
                          HorizontalMovieList(
                            title: 'New Releases',
                            movies: provider.newReleases,
                            category: 'new_release',
                          ),
                          HorizontalMovieList(
                            title: 'Trending Now',
                            movies: provider.trendingMovies.take(10).toList(),
                            isTopTen: true,
                            // Category removed to disable infinite scroll for Top 10
                          ),
                          HorizontalMovieList(
                            title: 'Top Rated Masterpieces',
                            movies: provider.topRatedMovies,
                            category: 'top_rated',
                          ),
                          HorizontalMovieList(
                            title: 'Action & Adventure',
                            movies: provider.actionMovies,
                            category: 'action',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Premium "Netflix Transparent to Solid" AppBar Overlay
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: ClipRect(
                  child: BackdropFilter(
                    // Dynamically increase blur only when user starts scrolling down
                    filter: ImageFilter.blur(
                      sigmaX: (_scrollOffset / 20).clamp(0.0, 15.0),
                      sigmaY: (_scrollOffset / 20).clamp(0.0, 15.0),
                    ),
                    child: Container(
                      // Dynamically fade to black based on scroll offset (350 pixels to achieve solid 85%)
                      color: Colors.black.withOpacity((_scrollOffset / 350).clamp(0.0, 0.85)),
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top + 16,
                        bottom: 16,
                        left: 20,
                        right: 20,
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              _scrollController.animateTo(
                                0, 
                                duration: const Duration(milliseconds: 700), 
                                curve: Curves.easeInOutQuart
                              );
                            },
                            child: Hero(
                              tag: 'app_logo',
                              child: Image.asset(
                                'assets/logo.png',
                                height: 48, // Upgraded for better mobile presence
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => Text(
                                  'CINEVISTAA',
                                  style: GoogleFonts.bebasNeue(
                                    fontSize: 28,
                                    color: const Color(0xFF7B2FFF),
                                    letterSpacing: 2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Builder for sleek Dropdown menu list items
  PopupMenuItem<String> _buildPopupMenuItem(String label, IconData icon, {Color color = Colors.white}) {
    return PopupMenuItem<String>(
      value: label,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 14),
          Text(
            label, 
            style: TextStyle(
              color: color, 
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
