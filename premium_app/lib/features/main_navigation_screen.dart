import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import '../core/theme.dart';
import '../core/design_system.dart';
import 'home_screen.dart';
import 'naam_jap_screen.dart';
import 'library_screen.dart';
import 'journal_screen.dart';
import 'profile_screen.dart';
import '../core/providers.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  final List<Widget> _screens = [
    HomeScreen(),
    LibraryScreen(), 
    NaamJapScreen(),
    JournalScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    if (index == ref.read(navigationIndexProvider)) return;
    HapticFeedback.selectionClick();
    ref.read(navigationIndexProvider.notifier).state = index;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(navigationIndexProvider);
    final isVoidScreen = currentIndex == 1 || currentIndex == 2;
    final barBgColor = isVoidScreen 
        ? PremiumTokens.voidBlack.withValues(alpha: 0.9) 
        : Color(0x991A160F); 
    final accentColor = isVoidScreen ? const Color(0xFF256AF4) : PremiumTokens.saffronGlow;

    return Scaffold(
      backgroundColor: isVoidScreen ? PremiumTokens.voidBlack : PremiumTokens.charcoal,
      body: IndexedStack(index: currentIndex, children: _screens),
      extendBody: true,
      bottomNavigationBar: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Floating Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  height: 72,
                  decoration: BoxDecoration(
                    color: barBgColor,
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: accentColor.withValues(alpha: 0.1)),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.1),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildNavItem(0, Iconsax.home_1, "Home", accentColor, currentIndex),
                        _buildNavItem(1, Iconsax.book_1, "Library", accentColor, currentIndex),
                        const SizedBox(width: 56), // Space for FAB
                        _buildNavItem(3, Iconsax.book_5, "Journal", accentColor, currentIndex),
                        _buildNavItem(4, Iconsax.user, "Profile", accentColor, currentIndex),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Center FAB
          Positioned(
            bottom: 48,
            child: GestureDetector(
              onTap: () => _onItemTapped(2),
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: isVoidScreen ? PremiumTokens.voidBlack : PremiumTokens.charcoal, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  currentIndex == 2 ? Iconsax.music_play5 : Iconsax.refresh, 
                  color: isVoidScreen ? Colors.white : PremiumTokens.charcoal, 
                  size: 30
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, Color accentColor, int currentIndex) {
    final isActive = currentIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? accentColor : Colors.white38,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 10,
              color: isActive ? accentColor : Colors.white38,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
