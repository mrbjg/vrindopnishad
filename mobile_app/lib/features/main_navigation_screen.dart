import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../core/theme.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'naam_jap_screen.dart';
import 'library_screen.dart';
import 'profile_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// MAIN NAVIGATION - Zen Navigation with floating bar
/// Modern icon-only navigation with smooth animations
/// ═══════════════════════════════════════════════════════════════════════════

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
    NaamJapScreen(),
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
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppTheme.space20,
          0,
          AppTheme.space20,
          AppTheme.space20,
        ),
        child: Container(
          height: 68,
          decoration: BoxDecoration(
            color: AppTheme.cardColor(context).withOpacity(0.95),
            borderRadius: BorderRadius.circular(AppTheme.radiusXL),
            border: Border.all(color: AppTheme.borderColor(context), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = constraints.maxWidth / 5;
              final indicatorLeft =
                  (_currentIndex * itemWidth) + (itemWidth - 52) / 2;

              return Stack(
                children: [
                  // Sliding indicator background
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    left: indicatorLeft,
                    top: (68 - 52) / 2,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusLarge,
                        ),
                      ),
                    ),
                  ),
                  // Navigation items
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavItem(
                        index: 0,
                        icon: Iconsax.home,
                        activeIcon: Iconsax.home_2, // Filled home
                        label: 'Home',
                        isDark: isDark,
                      ),
                      _buildNavItem(
                        index: 1,
                        icon: Iconsax.search_normal,
                        activeIcon:
                            Iconsax.search_favorite, // Search with heart
                        label: 'Search',
                        isDark: isDark,
                      ),
                      _buildNavItem(
                        index: 2,
                        icon: Iconsax.heart,
                        activeIcon: Iconsax.heart_tick, // Heart with tick
                        label: 'Jap',
                        isDark: isDark,
                      ),
                      _buildNavItem(
                        index: 3,
                        icon: Iconsax.book,
                        activeIcon: Iconsax.book_saved, // Open/saved book
                        label: 'Library',
                        isDark: isDark,
                      ),
                      _buildNavItem(
                        index: 4,
                        icon: Iconsax.user,
                        activeIcon: Iconsax.user_tick, // User with tick
                        label: 'Profile',
                        isDark: isDark,
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isDark,
  }) {
    final isActive = _currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTapped(index),
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          height: 68,
          child: Center(
            // Icon with smooth scale transition only (no rotation, no dot)
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeOutBack,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: Icon(
                isActive ? activeIcon : icon,
                key: ValueKey<bool>(isActive),
                size: isActive ? 26 : 24,
                color: isActive
                    ? AppTheme.primaryColor
                    : AppTheme.textMuted(context),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
