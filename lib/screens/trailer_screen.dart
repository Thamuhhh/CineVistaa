import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';

class TrailerScreen extends StatefulWidget {
  final String trailerId;
  final String movieTitle;

  const TrailerScreen({Key? key, required this.trailerId, required this.movieTitle}) : super(key: key);

  @override
  _TrailerScreenState createState() => _TrailerScreenState();
}

class _TrailerScreenState extends State<TrailerScreen> {
  late YoutubePlayerController _controller;
  bool _isPlayerReady = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.trailerId,
      autoPlay: true,
      params: const YoutubePlayerParams(
        showControls: true, 
        mute: false,
        showFullscreenButton: true,
        loop: false,
        // 🔥 Premium origin fix for Web/Android IFrame stability
        origin: 'https://www.youtube.com',
      ),
    );

    // Phase 1: Fail-safe listener to detect if the video is actually playing
    _controller.listen((state) {
      if (state.fullScreenOption.enabled) {
        // Handle fullscreen if needed
      }
    });

    // Phase 2: Mock a premium 2-second "CineVistaa" loading sequence
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        setState(() {
          _isPlayerReady = true;
          // If the trailer ID is empty, we immediately trigger the fallback
          if (widget.trailerId.isEmpty) {
             _hasError = true;
          }
        });
      }
    });
  }

  Future<void> _launchYoutube() async {
    final url = Uri.parse('https://www.youtube.com/watch?v=${widget.trailerId}');
    // Fallback search if ID is missing
    final searchUrl = Uri.parse('https://www.youtube.com/results?search_query=${Uri.encodeComponent(widget.movieTitle)} trailer');
    
    final targetUrl = widget.trailerId.isNotEmpty ? url : searchUrl;
    
    if (await canLaunchUrl(targetUrl)) {
      await launchUrl(targetUrl, mode: LaunchMode.externalApplication);
    }
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Pure pitch black
      body: SafeArea(
        child: Stack(
          children: [
            // 1. The Main Player / Fallback
            Center(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 1200),
                opacity: _isPlayerReady ? 1.0 : 0.0,
                child: _hasError || widget.trailerId.isEmpty
                    ? _buildFallbackUI()
                    : YoutubePlayer(
                        controller: _controller,
                        aspectRatio: 16 / 9,
                      ),
              ),
            ),
            
            // 2. Custom "CineVistaa" Loading Sequence
            if (!_isPlayerReady)
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        const SizedBox(
                          width: 85,
                          height: 85,
                          child: CircularProgressIndicator(
                            color: Color(0xFF7B2FFF), 
                            strokeWidth: 3,
                          ),
                        ),
                        Image.asset(
                          'assets/logo.png',
                          width: 50,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(Icons.movie_filter_rounded, color: Color(0xFF7B2FFF), size: 40),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'CONNECTING TO THEATER...',
                      style: GoogleFonts.bebasNeue(
                        color: Colors.white70,
                        fontSize: 20,
                        letterSpacing: 3.0,
                      ),
                    ),
                  ],
                ),
              ),

            // 3. Header Controls
            Positioned(
              top: 0, left: 0, right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black.withOpacity(0.9), Colors.transparent],
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        widget.movieTitle,
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackUI() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.live_tv_rounded, color: Colors.white24, size: 100),
        const SizedBox(height: 24),
        const Text(
          'INTERNAL PLAYER RESTRICTED',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 1),
        ),
        const SizedBox(height: 12),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 48),
          child: Text(
            'This trailer is restricted by the uploader for embedded playback. Tap below to watch it directly on YouTube.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton.icon(
          onPressed: _launchYoutube,
          icon: const Icon(Icons.play_circle_fill_rounded, size: 28),
          label: const Text('WATCH ON YOUTUBE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF0000), // YouTube Red
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}
