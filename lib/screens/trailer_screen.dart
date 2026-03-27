import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

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

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.trailerId,
      autoPlay: true,
      params: const YoutubePlayerParams(
        showControls: true, // Native YouTube controls for seamless skipping/pause interaction
        mute: false,
        showFullscreenButton: true,
        loop: false,
      ),
    );

    // Phase 2: Mock a premium 2-second "CineVistaa" loading sequence so the iframe buffer is totally masked
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        setState(() {
          _isPlayerReady = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. Cinematic Theater Immersive Blackout layout
    return Scaffold(
      backgroundColor: Colors.black, // Pure pitch black
      body: SafeArea(
        child: Stack(
          children: [
            // Center the massive video iframe seamlessly in the pure black space
            Center(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 1200), // Very slow gorgeous fade-in
                opacity: _isPlayerReady ? 1.0 : 0.0,
                child: YoutubePlayer(
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
                        // Massive spinning cinematic loading ring
                        const SizedBox(
                          width: 85,
                          height: 85,
                          child: CircularProgressIndicator(
                            color: Color(0xFF7B2FFF), // Royal Purple loading ring
                            strokeWidth: 3,
                          ),
                        ),
                        // CineVistaa App Logo inside the spinner!
                        Image.asset(
                          'assets/logo.png',
                          width: 50,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Optimizing 4K Stream...',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        letterSpacing: 2.0, // High-end kerning
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

            // 3. "Up Next" / Movie Title Overlay + Cinematic Close Button
            if (_isPlayerReady)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  // Allows clicks on the overlay but passes them down if strictly necessary
                  ignoring: false, 
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.95), // Deep shadow protects text visibility
                          Colors.black.withOpacity(0.0),
                        ],
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Interactive Cinematic 'Exit Theater' Button
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white24), // Premium UI ring
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 36),
                            onPressed: () => Navigator.pop(context), // Seamless slide down dismissal
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Movie Title cleanly embedded into the theater
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Text(
                              'Playing: ${widget.movieTitle}', // e.g. "Playing: Inception"
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(color: Colors.black, blurRadius: 10),
                                ],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
