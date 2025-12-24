import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme.dart';
import '../core/providers.dart';
import '../core/localization.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'library_screen.dart';
import 'profile_screen.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _currentIndex = 0;
  late PageController _pageController;

  final List<Widget> _screens = const [
    HomeScreen(),
    SearchScreen(),
    LibraryScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index == _currentIndex) return;

    // Haptic feedback for premium feel
    HapticFeedback.lightImpact();

    setState(() => _currentIndex = index);
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    final currentLanguage = ref.watch(languageProvider);
    final l = AppLocalization(currentLanguage);
    final isDark = AppTheme.isDark(context);

    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _screens,
      ),
      extendBody: true,
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              height: 72,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.08)
                    : Colors.white.withOpacity(0.85),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.white.withOpacity(0.5),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withOpacity(0.4)
                        : Colors.black.withOpacity(0.08),
                    blurRadius: 32,
                    offset: const Offset(0, 8),
                    spreadRadius: -8,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(
                    context,
                    0,
                    isActive: _currentIndex == 0,
                    inactiveIcon: LucideIcons.layoutGrid,
                    activeIcon: Icons.grid_view_rounded,
                    label: l.translate('home'),
                  ),
                  _buildNavItem(
                    context,
                    1,
                    isActive: _currentIndex == 1,
                    inactiveIcon: LucideIcons.compass,
                    activeIcon: Icons.explore_rounded,
                    label: l.translate('search'),
                  ),
                  _buildNavItem(
                    context,
                    2,
                    isActive: _currentIndex == 2,
                    inactiveIcon: LucideIcons.bookmark,
                    activeIcon: Icons.bookmark_rounded,
                    label: l.translate('library'),
                  ),
                  _buildNavItem(
                    context,
                    3,
                    isActive: _currentIndex == 3,
                    inactiveIcon: LucideIcons.user,
                    activeIcon: Icons.person_rounded,
                    label: l.translate('profile'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    int index, {
    required bool isActive,
    required IconData inactiveIcon,
    required IconData activeIcon,
    required String label,
  }) {
    final isDark = AppTheme.isDark(context);

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isActive
                  ? AppTheme.primaryColor.withOpacity(0.12)
                  : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isActive ? activeIcon : inactiveIcon,
              size: 22,
              color: isActive
                  ? AppTheme.primaryColor
                  : isDark
                  ? Colors.white.withOpacity(0.4)
                  : Colors.black.withOpacity(0.35),
            ),
          ),
        ],
      ),
    );
  }
}
