import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../core/design_system.dart';
import 'home_screen.dart';
import 'naam_jap_screen.dart';
import 'library_screen.dart';
import 'journal_screen.dart';
import 'profile_screen.dart';
import 'package:flutter/services.dart';
import '../core/audio_provider.dart';
import '../core/content_provider.dart';
import '../core/providers.dart';
import '../widgets/mini_player.dart';

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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PremiumTokens.voidBlack,
      body: Stack(
        children: [
          Positioned.fill(
            child: Consumer(
              builder: (context, ref, child) {
                final currentIndex = ref.watch(navigationIndexProvider);
                return PremiumUI.masterBackground(index: currentIndex);
              },
            ),
          ),
          Positioned.fill(
            child: Consumer(
              builder: (context, ref, child) {
                final currentIndex = ref.watch(navigationIndexProvider);
                return IndexedStack(index: currentIndex, children: _screens);
              },
            ),
          ),
          
          // Persistent Mini Player (Restored & Improved)
          Positioned(
            left: 0,
            right: 0,
            bottom: 120, // Increased more to clear the Nav Button's glow (101px)
            child: const MiniPlayer(),
          ),

          // Mind-Blowing Ethereal NavBar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Consumer(
              builder: (context, ref, child) {
                final currentIndex = ref.watch(navigationIndexProvider);
                return Stack(
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
                      bottom: 26, 
                      child: Consumer(
                        builder: (context, ref, child) {
                          final count = ref.watch(naamJapStateProvider);
                          return PremiumUI.sacredVoidButton(
                            isActive: currentIndex == 2,
                            count: count,
                            onTap: () {
                              HapticFeedback.heavyImpact();
                              // Only increment count (Naam Jap) as requested
                              ref.read(naamJapStateProvider.notifier).increment();
                            },
                            onLongPressStart: (details) {
                              showSacredMenu(
                                context,
                                details.globalPosition,
                                [
                                  SacredMenuItem(
                                    icon: Iconsax.heart, // Or Iconsax.book
                                    label: "Naam Jap",
                                    color: PremiumTokens.saffronGlow,
                                    onTap: () {
                                      ref.read(navigationIndexProvider.notifier).state = 2;
                                    },
                                  ),
                                  SacredMenuItem(
                                    icon: Iconsax.rotate_left,
                                    label: "Reset",
                                    color: Colors.redAccent,
                                    onTap: () {
                                      ref.read(naamJapStateProvider.notifier).reset();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text("Naam Jap counter reset")),
                                      );
                                    },
                                  ),
                                  SacredMenuItem(
                                    icon: Icons.vibration,
                                    label: "Haptics",
                                    color: PremiumTokens.nebulaBlue,
                                    onTap: () => HapticFeedback.vibrate(),
                                  ),
                                  SacredMenuItem(
                                    icon: Iconsax.send_2,
                                    label: "Share",
                                    color: Colors.greenAccent,
                                    onTap: () {},
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
