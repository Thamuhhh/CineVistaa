import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import '../models/movie.dart';
import '../screens/movie_details_screen.dart';
import '../screens/trailer_screen.dart';
import '../services/logo_generation_service.dart';

class HeroCarousel extends StatefulWidget {
  final List<Movie> movies;

  const HeroCarousel({Key? key, required this.movies}) : super(key: key);

  @override
  State<HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<HeroCarousel> {
  late final PageController _pageController;
  double _pageOffset = 0;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.94)
      ..addListener(() {
        if (!mounted) return;
        setState(() {
          _pageOffset = _pageController.page ?? 0;
        });
      });
    _startAutoPlay();
  }

  void _startAutoPlay() async {
    while (mounted) {
      await Future.delayed(const Duration(seconds: 5));
      if (!mounted || widget.movies.isEmpty || !_pageController.hasClients) {
        continue;
      }

      _currentPage = (_currentPage + 1) % widget.movies.length;
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeOutCubic,
      );
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
    final activeMovie = widget.movies[_currentPage];

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.72,
      child: Stack(
        children: [
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 900),
              child: CachedNetworkImage(
                key: ValueKey(activeMovie.id),
                imageUrl: activeMovie.backdropUrl,
                fit: BoxFit.cover,
                color: Colors.black.withOpacity(0.74),
                colorBlendMode: BlendMode.darken,
              ),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 36, sigmaY: 36),
              child: Container(color: Colors.black.withOpacity(0.14)),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF160D20).withOpacity(0.30),
                    Colors.black.withOpacity(0.18),
                    Colors.black.withOpacity(0.90),
                  ],
                ),
              ),
            ),
          ),
          PageView.builder(
            controller: _pageController,
            itemCount: widget.movies.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              return _buildCarouselSlide(context, widget.movies[index], index);
            },
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 10,
            child: Row(
              children: [
                Text(
                  'Swipe through featured picks',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.72),
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                Row(
                  children: List.generate(
                    widget.movies.length.clamp(0, 6),
                    (index) => GestureDetector(
                      onTap: () => _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 420),
                        curve: Curves.easeOutCubic,
                      ),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 280),
                        margin: const EdgeInsets.only(left: 8),
                        height: 6,
                        width: _currentPage == index ? 28 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? Colors.white
                              : Colors.white.withOpacity(0.28),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarouselSlide(BuildContext context, Movie movie, int index) {
    final delta = (_pageOffset - index).clamp(-1.0, 1.0);
    final scale = 1.0 - (delta.abs() * 0.05);

    return Transform.translate(
      offset: Offset(delta * 20, 0),
      child: Transform.scale(
        scale: scale,
        child: GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => MovieDetailsScreen(movie: movie)),
          ),
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 28, 16, 42),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(34),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.46),
                  blurRadius: 34,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(34),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isCompact = constraints.maxWidth < 360;
                  final posterWidth = (constraints.maxWidth * (isCompact ? 0.28 : 0.24))
                      .clamp(92.0, 150.0)
                      .toDouble();
                  final contentRight = isCompact ? 22.0 : posterWidth + 42.0;

                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      Transform.translate(
                        offset: Offset(delta * 44, 0),
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
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.black.withOpacity(0.14),
                                Colors.transparent,
                                const Color(0xFF130B1F).withOpacity(0.30),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.18),
                                Colors.black.withOpacity(0.30),
                                Colors.black.withOpacity(0.96),
                              ],
                              stops: const [0.0, 0.45, 1.0],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 20,
                        left: 20,
                        child: _buildHeaderBadge(movie),
                      ),
                      Positioned(
                        top: 20,
                        right: 20,
                        child: _buildPageBadge(index),
                      ),
                      if (!isCompact)
                        Positioned(
                          right: 18,
                          bottom: 26,
                          child: _buildPosterPreview(movie, posterWidth, delta),
                        ),
                      Positioned(
                        left: 22,
                        right: contentRight,
                        bottom: 28,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'FEATURED TONIGHT',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.78),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.8,
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 90,
                              child: _buildMovieBranding(movie),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              movie.overview,
                              maxLines: isCompact ? 2 : 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.82),
                                height: 1.45,
                                fontSize: isCompact ? 13 : 14,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                _buildMetaChip(
                                  icon: Icons.star_rounded,
                                  label: movie.rating.toStringAsFixed(1),
                                  accent: const Color(0xFFFFC83D),
                                ),
                                _buildMetaChip(
                                  icon: Icons.calendar_today_rounded,
                                  label: movie.releaseDate.split('-')[0],
                                ),
                                _buildMetaChip(
                                  icon: Icons.theaters_rounded,
                                  label: movie.watchProviders.isNotEmpty
                                      ? movie.watchProviders.first
                                      : 'Cine Pick',
                                ),
                              ],
                            ),
                            const SizedBox(height: 22),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                _buildHeroButton(
                                  context,
                                  icon: Icons.play_arrow_rounded,
                                  label: movie.trailerId.isNotEmpty
                                      ? 'WATCH TRAILER'
                                      : 'OPEN DETAILS',
                                  color: const Color(0xFFE33E57),
                                  onTap: () => movie.trailerId.isNotEmpty
                                      ? Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => TrailerScreen(
                                              trailerId: movie.trailerId,
                                              movieTitle: movie.title,
                                            ),
                                          ),
                                        )
                                      : Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => MovieDetailsScreen(movie: movie),
                                          ),
                                        ),
                                ),
                                _buildHeroButton(
                                  context,
                                  icon: Icons.info_outline_rounded,
                                  label: 'MORE INFO',
                                  color: Colors.white.withOpacity(0.10),
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => MovieDetailsScreen(movie: movie),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingLogo() {
    return Shimmer.fromColors(
      baseColor: Colors.white.withOpacity(0.05),
      highlightColor: Colors.white.withOpacity(0.12),
      child: Container(
        width: 180,
        height: 82,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  Widget _buildMovieBranding(Movie movie) {
    return Align(
      alignment: Alignment.centerLeft,
      child: _AiMovieBranding(
        movie: movie,
        loadingLogo: _buildLoadingLogo(),
        textLogo: _buildTextLogo(movie.title),
      ),
    );
  }

  Widget _buildTextLogo(String title) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 300),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.08),
            Colors.white.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.14)),
      ),
      child: Text(
        title.toUpperCase(),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.left,
        style: GoogleFonts.bebasNeue(
          color: Colors.white,
          fontSize: 34,
          height: 0.95,
          letterSpacing: 1.6,
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(0.55),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderBadge(Movie movie) {
    final provider = movie.watchProviders.isNotEmpty
        ? movie.watchProviders.first.toUpperCase()
        : 'EDITOR PICK';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.30),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Text(
        provider,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildPageBadge(int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.28),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
      ),
      child: Text(
        '${index + 1}/${widget.movies.length}',
        style: TextStyle(
          color: Colors.white.withOpacity(0.84),
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildPosterPreview(Movie movie, double width, double delta) {
    return Transform.translate(
      offset: Offset(delta * -12, delta.abs() * 10),
      child: Transform.rotate(
        angle: delta * 0.03,
        child: Container(
          width: width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.42),
                blurRadius: 22,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                AspectRatio(
                  aspectRatio: 0.68,
                  child: CachedNetworkImage(
                    imageUrl: movie.posterUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey.shade900,
                    ),
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.05),
                          Colors.black.withOpacity(0.72),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetaChip({
    required IconData icon,
    required String label,
    Color accent = Colors.white,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: accent, size: 15),
          const SizedBox(width: 7),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.90),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          if (color != Colors.white.withOpacity(0.15))
            BoxShadow(
              color: color.withOpacity(0.24),
              blurRadius: 18,
              spreadRadius: 1,
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Material(
            color: color,
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        letterSpacing: 0.9,
                      ),
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

class _AiMovieBranding extends StatefulWidget {
  final Movie movie;
  final Widget loadingLogo;
  final Widget textLogo;

  const _AiMovieBranding({
    required this.movie,
    required this.loadingLogo,
    required this.textLogo,
  });

  @override
  State<_AiMovieBranding> createState() => _AiMovieBrandingState();
}

class _AiMovieBrandingState extends State<_AiMovieBranding> {
  Future<File?>? _generatedLogoFuture;

  @override
  void initState() {
    super.initState();
    _resetFuture();
  }

  @override
  void didUpdateWidget(covariant _AiMovieBranding oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.movie.id != widget.movie.id ||
        oldWidget.movie.logoUrl != widget.movie.logoUrl ||
        oldWidget.movie.posterUrl != widget.movie.posterUrl ||
        oldWidget.movie.backdropUrl != widget.movie.backdropUrl) {
      _resetFuture();
    }
  }

  void _resetFuture() {
    _generatedLogoFuture = LogoGenerationService.getOrGenerateLogo(widget.movie);
  }

  Widget _buildImage(String imageUrl) {
    return Hero(
      tag: 'logo_${widget.movie.id}',
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.contain,
        alignment: Alignment.centerLeft,
        placeholder: (context, url) => widget.loadingLogo,
        errorWidget: (context, url, error) => _buildGeneratedLogo(),
      ),
    );
  }

  Widget _buildGeneratedLogo() {
    if (!LogoGenerationService.isConfigured) {
      return widget.textLogo;
    }

    return FutureBuilder<File?>(
      future: _generatedLogoFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return widget.loadingLogo;
        }

        final file = snapshot.data;
        if (file == null) {
          return widget.textLogo;
        }

        return Hero(
          tag: 'logo_${widget.movie.id}',
          child: Image.file(
            file,
            fit: BoxFit.contain,
            alignment: Alignment.centerLeft,
            errorBuilder: (context, error, stackTrace) => widget.textLogo,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final logoUrl = widget.movie.logoUrl;
    if (logoUrl != null && logoUrl.trim().isNotEmpty) {
      return _buildImage(logoUrl);
    }

    return _buildGeneratedLogo();
  }
}
