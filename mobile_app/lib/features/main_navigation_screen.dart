import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/theme.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'library_screen.dart';
import 'profile_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    SearchScreen(),
    LibraryScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    if (index == _currentIndex) return;
    HapticFeedback.lightImpact();
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      extendBody: true,
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        height: 70,
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF1A1A2E).withOpacity(0.95)
              : Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Sliding Background Highlight
            AnimatedAlign(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutBack,
              alignment: Alignment(
                -1.0 +
                    (_currentIndex *
                        (2.0 / 3.0)), // Distribute -1 to 1 across 4 items
                0,
              ),
              child: FractionallySizedBox(
                widthFactor: 1 / 4,
                child: Center(
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ),
            // Icons Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  context,
                  index: 0,
                  icon: LucideIcons.home,
                  activeIcon: Icons.home_rounded,
                  isDark: isDark,
                ),
                _buildNavItem(
                  context,
                  index: 1,
                  icon: LucideIcons.search,
                  activeIcon: Icons.search_rounded,
                  isDark: isDark,
                ),
                _buildNavItem(
                  context,
                  index: 2,
                  icon: LucideIcons.bookmark,
                  activeIcon: Icons.bookmark_rounded,
                  isDark: isDark,
                ),
                _buildNavItem(
                  context,
                  index: 3,
                  icon: LucideIcons.user,
                  activeIcon: Icons.person_rounded,
                  isDark: isDark,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required bool isDark,
  }) {
    final isActive = _currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTapped(index),
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: Icon(
            isActive ? activeIcon : icon,
            size: isActive ? 28 : 24,
            color: isActive
                ? AppTheme.primaryColor
                : (isDark ? Colors.white54 : Colors.black45),
          )
          .animate(target: isActive ? 1 : 0)
          .scale(
            begin: const Offset(1, 1),
            end: const Offset(1.15, 1.15),
            duration: 400.ms,
            curve: Curves.elasticOut,
          )
          .shake(
            hz: isActive ? 3 : 0,
            duration: 500.ms,
            curve: Curves.easeInOut,
          ),
        ),
      ),
    );
  }
}
