import 'dart:ui';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'watchlist_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({Key? key}) : super(key: key);

  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const SearchScreen(),
    const WatchlistScreen(),
  ];

  final List<Map<String, dynamic>> _navItems = [
    {'icon': Icons.home_rounded, 'label': 'Home'},
    {'icon': Icons.search_rounded, 'label': 'Search'},
    {'icon': Icons.bookmark_rounded, 'label': 'My Space'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
          
          // 💎 Floating Glassmorphic 'Expanding' Navbar
          Positioned(
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).padding.bottom + 20,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(35),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  height: 70,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(35),
                    border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: _navItems.asMap().entries.map((entry) {
                      int index = entry.key;
                      bool isSelected = _currentIndex == index;

                      return GestureDetector(
                        onTap: () => setState(() => _currentIndex = index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.fastOutSlowIn,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF7B2FFF) : Colors.transparent,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: isSelected ? [
                              BoxShadow(color: const Color(0xFF7B2FFF).withOpacity(0.3), blurRadius: 10, spreadRadius: 1)
                            ] : [],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                entry.value['icon'],
                                size: 24,
                                color: isSelected ? Colors.white : Colors.white.withOpacity(0.4),
                              ),
                              if (isSelected) ...[
                                const SizedBox(width: 10),
                                Text(
                                  entry.value['label'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 14,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
