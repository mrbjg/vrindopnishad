// Removed unused dart:ui import
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
import '../core/color_theme_provider.dart';
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

  // PageView controller for WhatsApp-like swipe navigation
  late final PageController _pageController;
  
  // Track if we're programmatically animating (to avoid feedback loops)
  bool _isAnimatingToPage = false;

  // Dynamic page scroll physics to prevent vertical scrolling gesture interruption
  ScrollPhysics _pagePhysics = const ClampingScrollPhysics();
  Offset _startOffset = Offset.zero;
  bool _decidedDirection = false;

  // The 5 swipeable main screens (Rituals at index 5 is overlay-only)
  static const int _swipeablePageCount = 5;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: ref.read(navigationIndexProvider));
    PremiumUI.setSacredStatus();

    // Initialize notifications and sync reminders
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(notificationServiceProvider).init();
      await ref.read(notificationManagerProvider).syncAllReminders();
      _checkGoalSetting();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _checkGoalSetting() {
    final statsAsync = ref.read(userStatsProvider);
    statsAsync.whenData((stats) {
      // Temporarily disabled due to database schema mismatch with 'daily_mala_goal'
    });
  }

  /// Called when user swipes to a new page
  void _onPageChanged(int index) {
    if (_isAnimatingToPage) return; // Ignore during programmatic animation
    if (index < _swipeablePageCount) {
      ref.read(navigationIndexProvider.notifier).state = index;
    }
  }

  /// Animate PageView to a tab (called from bottom nav taps)
  void _animateToPage(int index) {
    if (index >= _swipeablePageCount) return; // Rituals not in PageView
    if (_pageController.hasClients && _pageController.page?.round() != index) {
      _isAnimatingToPage = true;
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      ).then((_) {
        _isAnimatingToPage = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // CRITICAL: Watch themeProvider and colorPaletteProvider to force rebuild on theme change.
    final themeMode = ref.watch(themeProvider);
    final colorPalette = ref.watch(colorPaletteProvider);
    // Activate Dynamic Icon Service
    ref.watch(dynamicIconServiceProvider);
    
    // Sync system status and navigation bar overlay style
    PremiumUI.setSacredStatus();

    // Listen to navigation index changes from bottom nav taps
    ref.listen<int>(navigationIndexProvider, (prev, next) {
      if (next < _swipeablePageCount) {
        _animateToPage(next);
      }
    });

    final currentIndex = ref.watch(navigationIndexProvider);
    final isRitualsActive = currentIndex == 5;

    // The 5 swipeable screens
    final screens = [
      const HomeScreen(),
      const LibraryScreen(),
      const NaamJapScreen(),
      const EternalReflectionScreen(),
      const ProfileScreen(),
    ];

    final viewInsets = MediaQuery.of(context).viewInsets;
    final isKeyboardOpen = viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: PremiumTokens.surfaceMain,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: RepaintBoundary(
              child: PremiumUI.masterBackground(
                index: isRitualsActive ? 5 : currentIndex,
                context: context,
              ),
            ),
          ),

          // Main content: PageView for swipeable tabs
          Positioned.fill(
            child: RepaintBoundary(
              key: ValueKey('${themeMode.name}_${colorPalette.name}'),
              child: Stack(
                children: [
                  // Swipeable PageView (always present, hidden behind rituals when active)
                  Listener(
                    onPointerDown: (event) {
                      _startOffset = event.position;
                      _decidedDirection = false;
                    },
                    onPointerMove: (event) {
                      if (_decidedDirection) return;
                      
                      final double dx = (event.position.dx - _startOffset.dx).abs();
                      final double dy = (event.position.dy - _startOffset.dy).abs();
                      
                      // Check for a small movement before deciding primary direction
                      if (dx > 8 || dy > 8) {
                        _decidedDirection = true;
                        if (dy > dx) {
                          // Drag is primarily vertical: disable page swipe to let inner list scroll
                          if (_pagePhysics is! NeverScrollableScrollPhysics) {
                            setState(() {
                              _pagePhysics = const NeverScrollableScrollPhysics();
                            });
                          }
                        } else {
                          // Drag is primarily horizontal: keep page swiping active
                          if (_pagePhysics is! ClampingScrollPhysics) {
                            setState(() {
                              _pagePhysics = const ClampingScrollPhysics();
                            });
                          }
                        }
                      }
                    },
                    onPointerUp: (event) {
                      if (_pagePhysics is! ClampingScrollPhysics) {
                        setState(() {
                          _pagePhysics = const ClampingScrollPhysics();
                        });
                      }
                    },
                    onPointerCancel: (event) {
                      if (_pagePhysics is! ClampingScrollPhysics) {
                        setState(() {
                          _pagePhysics = const ClampingScrollPhysics();
                        });
                      }
                    },
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: _onPageChanged,
                      physics: _pagePhysics,
                      children: screens,
                    ),
                  ),

                  // Rituals overlay (shown on top when index == 5)
                  if (isRitualsActive)
                    const Positioned.fill(
                      child: RitualsScreen(),
                    ),
                ],
              ),
            ),
          ),
          
          // Persistent Mini Player
          if (!isKeyboardOpen)
            const Positioned(
              left: 0,
              right: 0,
              bottom: 102,
              child: MiniPlayer(),
            ),

          // Liquid Glass NavBar with Backdrop Blur
          if (!isKeyboardOpen)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  PremiumUI.floatingNavBar(
                    selectedIndex: currentIndex == 5 ? 2 : currentIndex,
                    onTap: (index) {
                      // If switching away from rituals, go back to the PageView page
                      if (isRitualsActive && index != 2) {
                        ref.read(navigationIndexProvider.notifier).state = index;
                      } else {
                        ref.read(navigationIndexProvider.notifier).state = index;
                      }
                    },
                    items: const [
                      (iconSvg: 'iconsax-ai-housing-jbqdn4s3-.svg', activeIconSvg: 'iconsax-ai-housing-1etziexn-.svg', label: "Home"),
                      (iconSvg: 'iconsax-book-saved-cf2vpsqx-.svg', activeIconSvg: 'iconsax-book-saved-bg1ra9cv-.svg', label: "Library"),
                      (iconSvg: 'iconsax-archive-27ilzneb-.svg', activeIconSvg: 'iconsax-archive-27ilzneb-.svg', label: ""), // Placeholder for center
                      (iconSvg: 'iconsax-chat-outline.svg', activeIconSvg: 'iconsax-chat-bold.svg', label: "Journal"),
                      (iconSvg: 'iconsax-ai-users-rcrm13gd-.svg', activeIconSvg: 'iconsax-ai-users-uj3awqug-.svg', label: "Profile"),
                    ],
                  ),
                  Positioned(
                    bottom: 22,
                    child: Consumer(
                      builder: (context, ref, child) {
                        final count = ref.watch(naamJapStateProvider);
                        return PremiumUI.sacredVoidButton(
                          isActive: currentIndex == 2 || currentIndex == 5,
                          count: count.total,
                          onTap: () {
                            HapticFeedback.heavyImpact();
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
                                    color: PremiumTokens.activeAccent,
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
                                    color: PremiumTokens.activeAccent,
                                    onTap: () {
                                      HapticFeedback.vibrate();
                                      PremiumUI.showNotification(
                                        context, 
                                        "Haptic Feedback: Heavy",
                                        icon: Icons.vibration,
                                        color: PremiumTokens.activeAccent,
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
                                pointerPosition: _menuPointerPosition,
                                key: _menuKey,
                              );
                           },
                          onLongPressMoveUpdate: (details) {
                            _menuPointerPosition.value = details.globalPosition;
                          },
                          onLongPressEnd: (details) {
                            _menuKey.currentState?.handleRelease();
                            _menuPointerPosition.value = null;
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
