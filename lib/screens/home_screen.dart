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
        if (provider.isLoading) {
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
                          const SizedBox(height: 24),

                          // 🕒 Continue Watching (Personal History)
                          if (provider.recentlyViewed.isNotEmpty)
                            HorizontalMovieList(
                              title: 'Continue Watching',
                              movies: provider.recentlyViewed,
                            ),
                          
                          // 🏷️ Dynamic Genre Filter Row
                          _buildGenreFilter(provider),
                          const SizedBox(height: 24),

                          if (provider.selectedGenreName != null) ...[
                            if (provider.isSorting)
                              const Padding(
                                padding: EdgeInsets.all(32.0),
                                child: Center(child: CircularProgressIndicator(color: Color(0xFF7B2FFF))),
                              )
                            else
                              HorizontalMovieList(
                                title: '${provider.selectedGenreName} Movies',
                                movies: provider.genreMovies,
                                category: 'genre', // Enables infinite scroll for this slice
                              ),
                            const SizedBox(height: 24),
                          ],

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

                          // 1. Sleek Notification Bell with 'New' Badge
                          PopupMenuButton<String>(
                            offset: const Offset(0, 50),
                            color: const Color(0xFF1E1E1E),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(color: Colors.white.withOpacity(0.1)),
                            ),
                            elevation: 10,
                            itemBuilder: (context) => [
                              PopupMenuItem<String>(
                                value: 'notif_1',
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: Image.network(
                                        'https://image.tmdb.org/t/p/w92/7I6VUdPj6tQECNHdviJkUHD2u89.jpg', // John Wick Poster mock
                                        width: 40, 
                                        height: 60, 
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(width: 40, height: 60, color: Colors.grey.shade900),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('New Arrival', style: TextStyle(color: Color(0xFF7B2FFF), fontSize: 12, fontWeight: FontWeight.bold)),
                                          const SizedBox(height: 4),
                                          const Text('John Wick: Chapter 4', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                                          const SizedBox(height: 4),
                                          Text('2 hours ago', style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 28),
                                Positioned(
                                  right: 2,
                                  top: 2,
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF7B2FFF), // Royal Purple Notification Dot
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.black, width: 2),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          
                          // 2. Ultra-Professional Minimalist Profile Dropdown
                          PopupMenuButton<String>(
                            offset: const Offset(0, 50), 
                            color: const Color(0xFF1E1E1E), 
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(color: Colors.white.withOpacity(0.1)),
                            ),
                            elevation: 10,
                            onSelected: (value) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Selected: $value'), behavior: SnackBarBehavior.floating),
                              );
                            },
                            itemBuilder: (context) => [
                              _buildPopupMenuItem('Account Settings', Icons.settings_rounded),
                              _buildPopupMenuItem('Downloads', Icons.download_rounded),
                              _buildPopupMenuItem('Switch Profiles', Icons.people_alt_rounded),
                              const PopupMenuDivider(height: 1),
                              _buildPopupMenuItem('Sign Out', Icons.exit_to_app_rounded, color: const Color(0xFF7B2FFF)),
                            ],
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey.shade900, // Clean architectural base
                                border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5), // Subtle premium stroke
                              ),
                              child: const Center(
                                child: Icon(Icons.person_outline_rounded, color: Colors.white, size: 20),
                              ),
                            ),
                          ),
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

  Widget _buildGenreFilter(MovieProvider provider) {
    final List<Map<String, dynamic>> genres = [
      {'name': 'Action', 'id': 28},
      {'name': 'Comedy', 'id': 35},
      {'name': 'Drama', 'id': 18},
      {'name': 'Thriller', 'id': 53},
      {'name': 'Horror', 'id': 27},
      {'name': 'Sci-Fi', 'id': 878},
    ];

    return SizedBox(
      height: 44,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: genres.length + 1,
        itemBuilder: (context, index) {
          final bool isAll = index == 0;
          final String name = isAll ? 'All Tamil' : genres[index - 1]['name'];
          final int? id = isAll ? null : genres[index - 1]['id'];
          final bool isSelected = provider.selectedGenreName == name || (isAll && provider.selectedGenreName == null);

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => provider.setGenre(id, isAll ? null : name),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF7B2FFF) : Colors.grey.shade900.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF7B2FFF) : Colors.white.withOpacity(0.1),
                    width: 1.5,
                  ),
                  boxShadow: isSelected ? [
                    BoxShadow(color: const Color(0xFF7B2FFF).withOpacity(0.3), blurRadius: 8, spreadRadius: 1)
                  ] : [],
                ),
                child: Center(
                  child: Text(
                    name,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey.shade400,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
