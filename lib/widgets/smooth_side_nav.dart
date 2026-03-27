import 'dart:ui';
import 'package:flutter/material.dart';

class SmoothSideNav extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const SmoothSideNav({
    Key? key,
    required this.selectedIndex,
    required this.onItemSelected,
  }) : super(key: key);

  @override
  _SmoothSideNavState createState() => _SmoothSideNavState();
}

class _SmoothSideNavState extends State<SmoothSideNav> {
  bool _isExpanded = false;

  void _onHover(PointerEvent details) {
    setState(() => _isExpanded = true);
  }

  void _onExit(PointerEvent details) {
    setState(() => _isExpanded = false);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: _onHover,
      onExit: _onExit,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.fastOutSlowIn,
        width: _isExpanded ? 240 : 72,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.85),
          border: Border(
            right: BorderSide(
              color: Colors.white.withOpacity(0.05),
              width: 1,
            ),
          ),
        ),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 48),
                
                // Brand Logo exactly like JioHotstar
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: _isExpanded ? 24 : 16),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _isExpanded
                        ? Image.asset(
                            'assets/logo.png', 
                            height: 40, 
                            fit: BoxFit.contain,
                            alignment: Alignment.centerLeft,
                          )
                        // Collapsed state: just an icon or 'C'
                        : const Icon(Icons.movie_creation, color: Color(0xFFE50914), size: 36),
                  ),
                ),
                
                const SizedBox(height: 60),
                
                // Navigation Items
                _buildNavItem(icon: Icons.space_dashboard_rounded, label: 'Home', index: 0),
                _buildNavItem(icon: Icons.search_rounded, label: 'Search', index: 1),
                _buildNavItem(icon: Icons.bookmark_rounded, label: 'My Space', index: 2),
                
                const Spacer(),
                
                // User Profile at bottom
                _buildNavItem(icon: Icons.person_rounded, label: 'Profile Settings', index: 3),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required String label, required int index}) {
    final isSelected = widget.selectedIndex == index;

    return GestureDetector(
      onTap: () => widget.onItemSelected(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 22),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey.shade500,
              size: 28,
            ),
            const SizedBox(width: 24),
            if (_isExpanded)
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey.shade400,
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                  overflow: TextOverflow.clip,
                  maxLines: 1,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
