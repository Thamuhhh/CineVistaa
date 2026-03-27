import 'dart:async';
import 'package:flutter/material.dart';
import 'main_navigation.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // 1.5 second slow cinematic reveal
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    
    // Subtle premium zoom-in drift effect (0.8x to 1.0x scale)
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();

    // Hold screen perfectly still for a moment, then fade into the main app (3 seconds total)
    Timer(const Duration(milliseconds: 3000), () {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 1000), // Buttery smooth 1-second crossfade
          pageBuilder: (_, __, ___) => const MainNavigation(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Pure cinematic black
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Image.asset(
                  'assets/logo.png',
                  width: 250, // Massive beautiful branding
                  fit: BoxFit.contain,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
