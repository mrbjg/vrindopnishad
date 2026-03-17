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
      body: Stack(
        children: [
          Positioned.fill(child: PremiumUI.masterBackground(index: currentIndex)),
          IndexedStack(index: currentIndex, children: _screens),
          // Mind-Blowing Ethereal NavBar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                PremiumUI.floatingNavBar(
                  selectedIndex: currentIndex,
                  onTap: (index) => ref.read(navigationIndexProvider.notifier).state = index,
                  items: const [
                    (iconSvg: 'iconsax-ai-housing-jbqdn4s3-.svg', activeIconSvg: 'iconsax-ai-housing-1etziexn-.svg', label: "Home"),
                    (iconSvg: 'iconsax-book-saved-cf2vpsqx-.svg', activeIconSvg: 'iconsax-book-saved-bg1ra9cv-.svg', label: "Library"),
                    (iconSvg: 'iconsax-archive-27ilzneb-.svg', activeIconSvg: 'iconsax-archive-27ilzneb-.svg', label: ""), // Placeholder for center
                    (iconSvg: 'iconsax-ai-send-message-m26q6m1j-.svg', activeIconSvg: 'iconsax-ai-send-message-2njcmr24-.svg', label: "Journal"),
                    (iconSvg: 'iconsax-ai-users-rcrm13gd-.svg', activeIconSvg: 'iconsax-ai-users-uj3awqug-.svg', label: "Profile"),
                  ],
                ),
                Positioned(
                  bottom: 26, // Locked to navbar midline
                  child: PremiumUI.sacredVoidButton(
                    isActive: currentIndex == 2,
                    onTap: () => ref.read(navigationIndexProvider.notifier).state = 2,
                  ),
                ),
              ],
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
