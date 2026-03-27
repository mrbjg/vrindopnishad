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
import '../core/providers.dart';
import '../core/dynamic_icon_service.dart';
import '../widgets/mini_player.dart';
import 'rituals_screen.dart';
import '../core/stats_provider.dart';

import '../core/notification_manager.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  // Pinterest-style Menu State
  final ValueNotifier<Offset?> _menuPointerPosition = ValueNotifier<Offset?>(null);
  final GlobalKey<SacredActionMenuState> _menuKey = GlobalKey<SacredActionMenuState>();

  // Optimized screen instances to prevent recreation on every rebuild
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    PremiumUI.setSacredStatus();
    
    _screens = [
      const HomeScreen(),
      const LibraryScreen(),
      const NaamJapScreen(),
      const EternalReflectionScreen(),
      const ProfileScreen(),
      const RitualsScreen(),
    ];

    // Initialize notifications and sync reminders
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(notificationServiceProvider).init();
      await ref.read(notificationManagerProvider).syncAllReminders();
      _checkGoalSetting();
    });
  }

  void _checkGoalSetting() {
    final statsAsync = ref.read(userStatsProvider);
    statsAsync.whenData((stats) {
      // Temporarily disabled due to database schema mismatch with 'daily_mala_goal'
      /*
      if (stats != null && stats.dailyMalaGoal == 0) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SacredGoalScreen(isOnboarding: true)),
        );
      }
      */
    });
  }

  @override
  Widget build(BuildContext context) {
    // Activate Dynamic Icon Service
    ref.watch(dynamicIconServiceProvider);

    return Scaffold(
      backgroundColor: PremiumTokens.voidBlack,
      body: Stack(
        children: [
          Positioned.fill(
            child: Consumer(
              builder: (context, ref, child) {
                final currentIndex = ref.watch(navigationIndexProvider);
                return RepaintBoundary(
                  child: PremiumUI.masterBackground(index: currentIndex),
                );
              },
            ),
          ),
          Positioned.fill(
            child: Consumer(
              builder: (context, ref, child) {
                final currentIndex = ref.watch(navigationIndexProvider);
                return RepaintBoundary(
                  child: IndexedStack(index: currentIndex, children: _screens),
                );
              },
            ),
          ),
          
          // Persistent Mini Player (Restored & Improved)
          const Positioned(
            left: 0,
            right: 0,
            bottom: 102, // Tightened from 120 to clear the Nav Button while feeling more compact
            child: MiniPlayer(),
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
                      bottom: 22, // Tightened from 26 for a more compact look
                      child: Consumer(
                        builder: (context, ref, child) {
                          final count = ref.watch(naamJapStateProvider);
                          return PremiumUI.sacredVoidButton(
                            isActive: currentIndex == 2,
                            count: count.total,
                            onTap: () {
                              HapticFeedback.heavyImpact();
                              // Only increment count (Naam Jap) as requested
                              ref.read(naamJapStateProvider.notifier).increment(context);
                            },
                            onLongPressStart: (details) {
                              _menuPointerPosition.value = details.globalPosition;
                              showSacredMenu(
                                context,
                                details.globalPosition,
                                [
                                  SacredMenuItem(
                                    icon: Iconsax.heart, 
                                    label: "Naam Jap",
                                    color: PremiumTokens.saffronGlow,
                                    onTap: () {
                                      ref.read(navigationIndexProvider.notifier).state = 2;
                                    },
                                  ),
                                  SacredMenuItem(
                                    icon: Iconsax.sun_1, 
                                    label: "Rituals",
                                    color: PremiumTokens.nebulaBlue,
                                    onTap: () {
                                      ref.read(navigationIndexProvider.notifier).state = 5;
                                    },
                                  ),
                                  SacredMenuItem(
                                    icon: Iconsax.rotate_left,
                                    label: "Reset",
                                    color: Colors.redAccent,
                                    onTap: () {
                                      ref.read(naamJapStateProvider.notifier).reset();
                                      PremiumUI.showNotification(
                                        context, 
                                        "Naam Jap counter reset",
                                        icon: Iconsax.rotate_left,
                                        color: Colors.redAccent,
                                      );
                                    },
                                  ),
                                  SacredMenuItem(
                                    icon: Icons.vibration,
                                    label: "Haptics",
                                    color: PremiumTokens.nebulaBlue,
                                    onTap: () {
                                      HapticFeedback.vibrate();
                                      PremiumUI.showNotification(
                                        context, 
                                        "Haptic Feedback: Heavy",
                                        icon: Icons.vibration,
                                        color: PremiumTokens.nebulaBlue,
                                      );
                                    },
                                  ),
                                  SacredMenuItem(
                                    icon: Iconsax.send_2,
                                    label: "Share",
                                    color: Colors.greenAccent,
                                    onTap: () {
                                      PremiumUI.showNotification(
                                        context, 
                                        "Sharing Sant-Vaani...",
                                        icon: Iconsax.send_2,
                                        color: Colors.greenAccent,
                                      );
                                    },
                                  ),
                                ],
                                _menuPointerPosition,
                                key: _menuKey,
                              );
                            },
                            onLongPressMoveUpdate: (details) {
                              _menuPointerPosition.value = details.globalPosition;
                            },
                            onLongPressEnd: (details) {
                              // Notify the menu to trigger the highlighted action and close
                              _menuKey.currentState?.handleRelease();
                              _menuPointerPosition.value = null;
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
