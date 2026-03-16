import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import '../core/design_system.dart';
import 'home_screen.dart';
import 'naam_jap_screen.dart';
import 'library_screen.dart';
import 'journal_screen.dart';
import 'profile_screen.dart';
import '../core/providers.dart';
import 'package:flutter/services.dart';

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
    final barBgColor = PremiumTokens.voidBlack.withValues(alpha: 0.9);
    final accentColor = PremiumTokens.nebulaBlue;

    return Scaffold(
      backgroundColor: PremiumTokens.voidBlack,
      body: IndexedStack(index: currentIndex, children: _screens),
      extendBody: true,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(top: 24),
        child: GestureDetector(
          onTap: () => _onItemTapped(2),
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: PremiumTokens.nebulaGradient,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white10, width: 2),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.5),
                  blurRadius: 25,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              currentIndex == 2 ? Iconsax.music_play5 : Iconsax.refresh, 
              color: Colors.white, 
              size: 32
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 100,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: BottomAppBar(
              height: 72,
              color: barBgColor,
              shape: const CircularNotchedRectangle(),
              notchMargin: 8,
              padding: EdgeInsets.zero,
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildNavItem(0, Iconsax.home_1, "Home", accentColor, currentIndex),
                    _buildNavItem(1, Iconsax.book_1, "Library", accentColor, currentIndex),
                    const SizedBox(width: 56), // Notch space
                    _buildNavItem(3, Iconsax.book, "Journal", accentColor, currentIndex),
                    _buildNavItem(4, Iconsax.user, "Profile", accentColor, currentIndex),
                  ],
                ),
              ),
            ),
          ),
        ),
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
