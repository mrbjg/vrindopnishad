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
          child: Stack(
            children: [
              // Sliding indicator background
              AnimatedAlign(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                alignment: Alignment(-1.0 + (_currentIndex * (2.0 / 3.0)), 0),
                child: FractionallySizedBox(
                  widthFactor: 1 / 4,
                  child: Center(
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
                ),
              ),
              // Navigation items
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    index: 0,
                    icon: LucideIcons.home,
                    label: 'Home',
                    isDark: isDark,
                  ),
                  _buildNavItem(
                    index: 1,
                    icon: LucideIcons.search,
                    label: 'Search',
                    isDark: isDark,
                  ),
                  _buildNavItem(
                    index: 2,
                    icon: LucideIcons.bookOpen,
                    label: 'Library',
                    isDark: isDark,
                  ),
                  _buildNavItem(
                    index: 3,
                    icon: LucideIcons.user,
                    label: 'Profile',
                    isDark: isDark,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required bool isDark,
  }) {
    final isActive = _currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTapped(index),
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                    icon,
                    size: isActive ? 24 : 22,
                    color: isActive
                        ? AppTheme.primaryColor
                        : AppTheme.textMuted(context),
                  )
                  .animate(target: isActive ? 1 : 0)
                  .scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.1, 1.1),
                    duration: 250.ms,
                    curve: Curves.easeOutBack,
                  ),
              const SizedBox(height: 4),
              // Dot indicator
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: isActive ? 4 : 0,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
