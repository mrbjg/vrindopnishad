import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/design_system.dart';
import '../core/providers.dart';
import '../core/color_theme_provider.dart';
import '../core/spirituality_provider.dart';
import '../core/stats_provider.dart';
import '../core/auth_provider.dart';
import '../core/content_provider.dart';
import 'search_screen.dart';
import 'daily_motivation_screen.dart';
import 'daily_gyaan_screen.dart';
import 'sacred_calendar_screen.dart';
import 'category_list_screen.dart';
import 'rituals_screen.dart';
import 'profile/find_friends_screen.dart';

import '../core/personalized_feed_provider.dart';
import 'content_detail_screen.dart';
import '../widgets/animated_effects.dart';
import '../core/ambient_audio_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 250) {
      ref.read(personalizedDiscoveryProvider.notifier).loadMore();
    }
  }

  String _getEffectiveImageUrl(SacredContent item) {
    return item.displayImageUrl;
  }

  Widget _buildHorizontalShelf({
    required String title,
    required List<SacredContent> items,
    required WidgetRef ref,
    required BuildContext context,
  }) {
    if (items.isEmpty) return const SizedBox.shrink();

    // Ensure at least 2 items are present for a full visual shelf
    final List<SacredContent> displayItems = List.from(items);
    if (displayItems.length < 2) {
      final allContent = ref.watch(sacredContentProvider);
      for (final fallbackItem in allContent) {
        if (!displayItems.any((x) => x.id == fallbackItem.id)) {
          displayItems.add(fallbackItem);
          if (displayItems.length >= 2) break;
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text(
            title.toUpperCase(),
            style: PremiumTokens.sansStyle(
              color: PremiumTokens.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
        ),
        SizedBox(
          height: 200, // Increased height to prevent vertical clipping of Hindi titles/authors
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: displayItems.length,
            itemBuilder: (context, index) {
              final item = displayItems[index];
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: PressableScale(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ContentDetailScreen(content: item),
                      ),
                    );
                  },
                  child: SizedBox(
                    width: 160, // YouTube block width
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image Thumbnail with border-radius and top badges
                        Container(
                          height: 90, // Aspect ratio roughly 16:9
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: PremiumTokens.borderSubtle),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                PremiumUI.networkImage(
                                  url: _getEffectiveImageUrl(item),
                                  fit: BoxFit.cover,
                                ),
                                // Bottom subtle vignette
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withValues(alpha: 0.45),
                                      ],
                                    ),
                                  ),
                                ),
                                // Category badge top-left
                                Positioned(
                                  left: 6,
                                  top: 6,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.65),
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: Text(
                                      item.category.toUpperCase(),
                                      style: PremiumTokens.sansStyle(
                                        color: PremiumTokens.activeAccentLight,
                                        fontSize: 7,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                // Resonance match badge top-right
                                Consumer(
                                  builder: (context, ref, child) {
                                    final match = ref.watch(matchPercentageProvider(item));
                                    return Positioned(
                                      right: 6,
                                      top: 6,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(alpha: 0.65),
                                          borderRadius: BorderRadius.circular(100),
                                        ),
                                        child: Text(
                                          "$match%",
                                          style: PremiumTokens.sansStyle(
                                            color: PremiumTokens.saffronGlow,
                                            fontSize: 7,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Title below the image
                        Text(
                          item.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: PremiumTokens.hindiAwareStyle(
                            item.title,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: PremiumTokens.textPrimary,
                          ),
                        ),
                        if (item.author != null && item.author!.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            item.author!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: PremiumTokens.sansStyle(
                              color: PremiumTokens.textMuted,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    PremiumTokens.of(context);
    // Watch themes to rebuild
    ref.watch(themeProvider);
    ref.watch(colorPaletteProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async {
              HapticFeedback.mediumImpact();
              await ref.read(sacredContentProvider.notifier).refresh();
              ref.read(personalizedDiscoveryProvider.notifier).refresh();
            },
            color: PremiumTokens.activeAccent,
            backgroundColor: PremiumTokens.surfaceMain,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
              // Sticky Header
              SliverAppBar(
                expandedHeight: 0,
                collapsedHeight: 72,
                pinned: true,
                floating: false,
                elevation: 0,
                scrolledUnderElevation: 0,
                backgroundColor: Colors.transparent,
                titleSpacing: 20,
                title: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          PremiumUI.showNotification(
                            context, 
                            "Welcome to Divine Path", 
                            icon: Iconsax.sun_15
                          );
                        },
                        child: PremiumUI.logo(height: 28, color: PremiumTokens.textPrimary)
                      ),
                    ),
                    const Spacer(),
                    const Row(
                      children: [
                        _CompactSearchButton(),
                        SizedBox(width: 16),
                        _CompactNotificationButton(),
                        SizedBox(width: 16),
                        _CompactProfileButton(),
                      ],
                    ),
                  ],
                ),
                automaticallyImplyLeading: false,
              ),

              // 0. Daily Check-in (REMOVED)

              // Consolodated Lite Section
              const SliverToBoxAdapter(
                child: Column(
                  children: [
                    _DailyMotivationSection(),
                    RepaintBoundary(child: _PeaceBreathingSection()),
                    RepaintBoundary(child: _PremiumNaamJapSection()),
                    _QuickActionsGrid(),
                  ],
                ),
              ),

              // 7-9. Consolidated Legacy Content (Performance Optimization)
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _CategoriesHeader(),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: _CategoriesGridLite(),
                    ),
                    const SizedBox(height: 20),
                    
                    // Netflix-style Continue Journey
                    Consumer(
                      builder: (context, ref, child) {
                        final list = ref.watch(continueReadingProvider);
                        return _buildHorizontalShelf(
                          title: 'Continue Your Journey',
                          items: list,
                          ref: ref,
                          context: context,
                        );
                      },
                    ),

                    // Dynamic Categories shelves (Distribute by multiple categories)
                    Consumer(
                      builder: (context, ref, child) {
                        final categories = ref.watch(personalizedCategoriesProvider);
                        if (categories.isEmpty) return const SizedBox.shrink();
                        
                        return Column(
                          children: categories.map((catInfo) {
                            final list = ref.watch(personalizedFilteredContentProvider(catInfo.name));
                            if (list.isEmpty) return const SizedBox.shrink();
                            
                            return _buildHorizontalShelf(
                              title: 'More in ${catInfo.name}',
                              items: list,
                              ref: ref,
                              context: context,
                            );
                          }).toList(),
                        );
                      },
                    ),

                    // YouTube-style Trending
                    Consumer(
                      builder: (context, ref, child) {
                        final list = ref.watch(trendingContentProvider);
                        return _buildHorizontalShelf(
                          title: 'Trending Wisdom',
                          items: list,
                          ref: ref,
                          context: context,
                        );
                      },
                    ),

                    const _RecentReflectionPreviewLite(),
                    
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      child: Text(
                        'RECOMMENDED FOR YOU',
                        style: PremiumTokens.sansStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                          color: PremiumTokens.textMuted,
                        ),
                      ),
                    ),

                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 12, 20, 180),
                      child: _PremiumContentListLite(),
                    ),
                  ],
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

// ─── Daily Motivation Section ──────────────────────────────

class _DailyMotivationSection extends ConsumerStatefulWidget {
  const _DailyMotivationSection();

  @override
  ConsumerState<_DailyMotivationSection> createState() => _DailyMotivationSectionState();
}

class _DailyMotivationSectionState extends ConsumerState<_DailyMotivationSection> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final contextMotivation = ref.watch(contextualMotivationProvider);
    final colorPalette = ref.watch(colorPaletteProvider);

    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _isPressed = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          _isPressed = false;
        });
      },
      onTapCancel: () {
        setState(() {
          _isPressed = false;
        });
      },
      onTap: () {
        HapticFeedback.mediumImpact();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DailyMotivationScreen()),
        );
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
        child: AnimatedScale(
          scale: _isPressed ? 0.96 : 1.0,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOutCubic,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: PremiumTokens.surfaceMain.withValues(alpha: 0.5),
              border: Border.all(
                color: colorPalette.accent.withValues(alpha: 0.15),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: colorPalette.accent.withValues(alpha: 0.08),
                  blurRadius: 24,
                  spreadRadius: -2,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  // Accent gradient strip
                  Container(
                    width: 5,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        bottomLeft: Radius.circular(24),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          colorPalette.accent.withValues(alpha: 0.8),
                          colorPalette.accent.withValues(alpha: 0.1),
                        ],
                      ),
                    ),
                  ),
                  // Content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Iconsax.sun_15,
                                size: 14,
                                color: colorPalette.accent,
                              )
                                  .animate(onPlay: (controller) => controller.repeat())
                                  .rotate(duration: 15.seconds),
                              const SizedBox(width: 8),
                              Text(
                                'DAILY INSIGHT',
                                style: PremiumTokens.sansStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 3,
                                  color: colorPalette.accent,
                                ),
                              ),
                              const Spacer(),
                              Icon(
                                Iconsax.arrow_right_3,
                                size: 14,
                                color: PremiumTokens.textMuted,
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            contextMotivation,
                            style: GoogleFonts.spectral(
                              fontSize: 16.5,
                              color: PremiumTokens.textPrimary,
                              fontWeight: FontWeight.w300,
                              height: 1.55,
                              fontStyle: FontStyle.italic,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PeaceBreathingSection extends ConsumerStatefulWidget {
  const _PeaceBreathingSection();

  @override
  ConsumerState<_PeaceBreathingSection> createState() => _PeaceBreathingSectionState();
}

class _PeaceBreathingSectionState extends ConsumerState<_PeaceBreathingSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _breathingController;
  String _breathText = "Breathe In";
  String _breathDesc = "Fill your heart with peace";
  double _breathScale = 1.0;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..addListener(() {
        if (!mounted || !_isExpanded) return;
        final val = _breathingController.value;
        if (val < 0.25) {
          // Inhale (4s)
          final progress = val / 0.25;
          setState(() {
            _breathText = "Breathe In";
            _breathDesc = "Feel divine energy entering";
            _breathScale = 1.0 + (progress * 0.45); // 1.0 to 1.45
          });
        } else if (val < 0.50) {
          // Hold (4s)
          setState(() {
            _breathText = "Hold";
            _breathDesc = "Absorb the silent tranquility";
            _breathScale = 1.45;
          });
        } else if (val < 0.75) {
          // Exhale (4s)
          final progress = (val - 0.50) / 0.25;
          setState(() {
            _breathText = "Breathe Out";
            _breathDesc = "Let go of all anxiety and stress";
            _breathScale = 1.45 - (progress * 0.45); // 1.45 to 1.0
          });
        } else {
          // Rest (4s)
          setState(() {
            _breathText = "Rest";
            _breathDesc = "Surrender to the supreme peace";
            _breathScale = 1.0;
          });
        }
      });
  }

  @override
  void dispose() {
    _breathingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ambientState = ref.watch(ambientAudioProvider);
    final current = ambientState.currentSoundscape;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: PremiumTokens.surfaceMain.withValues(alpha: 0.5),
          border: Border.all(color: PremiumTokens.borderSubtle),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header Banner (Collapsible Header)
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() {
                  _isExpanded = !_isExpanded;
                  if (_isExpanded) {
                    _breathingController.repeat();
                  } else {
                    _breathingController.stop();
                  }
                });
              },
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                color: PremiumTokens.borderSubtle.withValues(alpha: 0.15),
                child: Row(
                  children: [
                    Icon(Iconsax.sun_1, size: 14, color: PremiumTokens.activeAccent),
                    const SizedBox(width: 8),
                    Text(
                      'DIVINE PEACE ZONE',
                      style: PremiumTokens.sansStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                        color: PremiumTokens.activeAccent,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (ambientState.isPlaying)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: PremiumTokens.activeAccent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Row(
                          children: [
                            _buildMiniEqualizer(),
                            const SizedBox(width: 4),
                            Text(
                              'AMBIANCE ACTIVE',
                              style: PremiumTokens.sansStyle(
                                fontSize: 7.5,
                                fontWeight: FontWeight.bold,
                                color: PremiumTokens.activeAccent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const Spacer(),
                    Icon(
                      _isExpanded ? Iconsax.arrow_up_11 : Iconsax.arrow_down_12,
                      size: 14,
                      color: PremiumTokens.activeAccent,
                    ),
                  ],
                ),
              ),
            ),
            
            // Main Body: Breathing circle & Ambiance control
            if (_isExpanded)
              Padding(
                padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Left: Animated Breathing Circle
                      SizedBox(
                        width: 110,
                        height: 110,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Glowing breathing halo
                            AnimatedScale(
                              scale: _breathScale,
                              duration: const Duration(milliseconds: 100),
                              curve: Curves.easeInOut,
                              child: Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      PremiumTokens.activeAccent.withValues(alpha: 0.25),
                                      PremiumTokens.activeAccent.withValues(alpha: 0.05),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // Core circle
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: PremiumTokens.surfaceMain,
                                border: Border.all(
                                  color: PremiumTokens.borderSubtle,
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: PremiumTokens.activeAccent.withValues(alpha: 0.08),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Text(
                                  'ॐ',
                                  style: TextStyle(
                                    fontSize: 24,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 18),
                      // Right: Text info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _breathText,
                              style: PremiumTokens.displayStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: PremiumTokens.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _breathDesc,
                              style: PremiumTokens.sansStyle(
                                fontSize: 12,
                                color: PremiumTokens.textSecondary,
                              ).copyWith(height: 1.35),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 18),
                  const Divider(height: 1, color: Colors.transparent),
                  const SizedBox(height: 6),
                  
                  // Ambient sound select chips
                  Row(
                    children: [
                      Icon(Iconsax.music_playlist, size: 12, color: PremiumTokens.textMuted),
                      const SizedBox(width: 6),
                      Text(
                        'Select Meditative Soundscape',
                        style: PremiumTokens.sansStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: PremiumTokens.textMuted,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  
                  // Horizontal Soundscape Chips List
                  SizedBox(
                    height: 38,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      children: [
                        // Off chip
                        _buildSoundscapeChip(
                          name: 'Silent Off',
                          icon: '🚫',
                          isActive: current == null,
                          onTap: () async {
                            HapticFeedback.lightImpact();
                            await ref.read(ambientAudioProvider.notifier).stop();
                          },
                        ),
                        ...AmbientAudioNotifier.soundscapes.map((s) => _buildSoundscapeChip(
                          name: s.name,
                          icon: s.icon,
                          isActive: current?.id == s.id,
                          onTap: () async {
                            HapticFeedback.lightImpact();
                            await ref.read(ambientAudioProvider.notifier).selectSoundscape(s);
                          },
                        )),
                      ],
                    ),
                  ),
                  
                  // Volume controller if playing
                  if (current != null) ...[
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Icon(
                          ambientState.isPlaying ? Iconsax.volume_high : Iconsax.volume_cross,
                          size: 14,
                          color: PremiumTokens.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 2.5,
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                              activeTrackColor: PremiumTokens.activeAccent,
                              inactiveTrackColor: PremiumTokens.borderSubtle,
                              thumbColor: PremiumTokens.activeAccent,
                            ),
                            child: Slider(
                              value: ambientState.volume,
                              onChanged: (val) {
                                ref.read(ambientAudioProvider.notifier).setVolume(val);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${(ambientState.volume * 100).toInt()}%',
                          style: PremiumTokens.sansStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: PremiumTokens.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSoundscapeChip({
    required String name,
    required String icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isActive
                ? PremiumTokens.activeAccent.withValues(alpha: 0.15)
                : PremiumTokens.surfaceMain.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: isActive
                  ? PremiumTokens.activeAccent
                  : PremiumTokens.borderSubtle,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                icon,
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(width: 6),
              Text(
                name,
                style: PremiumTokens.sansStyle(
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: isActive ? PremiumTokens.activeAccent : PremiumTokens.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniEqualizer() {
    return SizedBox(
      width: 12,
      height: 8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(3, (index) => _EqualizerBar(index: index)),
      ),
    );
  }
}

class _EqualizerBar extends StatefulWidget {
  final int index;
  const _EqualizerBar({required this.index});

  @override
  State<_EqualizerBar> createState() => _EqualizerBarState();
}

class _EqualizerBarState extends State<_EqualizerBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400 + (widget.index * 150)),
    );
    _animation = Tween<double>(begin: 2.0, end: 8.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 2,
          height: _animation.value,
          decoration: BoxDecoration(
            color: PremiumTokens.activeAccent,
            borderRadius: BorderRadius.circular(10),
          ),
        );
      },
    );
  }
}



// ─── Streak & Level Bar ────────────────────────────────────




// ─── Daily Challenges Preview ──────────────────────────────

// Removed _DailyChallengesPreview (Consolidated into _StreakLevelBar)


// ─── Quick Actions Grid ────────────────────────────────────

class _QuickActionsGrid extends StatelessWidget {
  const _QuickActionsGrid();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          _QuickActionTile(
            icon: Iconsax.teacher,
            label: 'Gyaan',
            subtitle: 'Daily Wisdom',
            accentColor: PremiumTokens.saffronGlow,
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const DailyGyaanScreen())),
          ),
          const SizedBox(width: 10),
          _QuickActionTile(
            icon: Iconsax.calendar,
            label: 'Calendar',
            subtitle: 'Sacred Days',
            accentColor: PremiumTokens.etherealBlue,
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const SacredCalendarScreen())),
          ),
          const SizedBox(width: 10),
          _QuickActionTile(
            icon: Iconsax.user_search,
            label: 'Sangat',
            subtitle: 'Find Seekers',
            accentColor: PremiumTokens.activeAccent,
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const FindFriendsScreen())),
          ),
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color accentColor;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: PressableScale(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: PremiumTokens.surfaceMain.withValues(alpha: 0.5),
            border: Border.all(color: PremiumTokens.borderSubtle),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: accentColor.withValues(alpha: 0.1),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.15),
                  ),
                ),
                child: Icon(icon, size: 18, color: accentColor),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: PremiumTokens.sansStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: PremiumTokens.textPrimary,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.fade,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: PremiumTokens.sansStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w600,
                  color: PremiumTokens.textMuted,
                  letterSpacing: 0.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Upcoming Events Banner ───────────────────────────────

// Removed _UpcomingEventsBanner (Moved to Calendar)


// ─── Existing Sections (preserved) ────────────────────────

class _CategoriesHeader extends ConsumerWidget {
  const _CategoriesHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Categories',
              style: PremiumTokens.sansStyle(
                  color: PremiumTokens.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5)),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CategoryListScreen()),
              );
            },
            child: Text('VIEW ALL',
                style: PremiumTokens.sansStyle(
                    color: PremiumTokens.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2)),
          ),
        ],
      ),
    );
  }
}




class _PremiumNaamJapSection extends ConsumerWidget {
  const _PremiumNaamJapSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final japState = ref.watch(naamJapStateProvider);
    const goal = 1008; // Example goal
    final progress = (japState.total % goal) / goal;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Center(
        child: PressableScale(
          scaleFactor: 0.95,
          onTap: () {
            HapticFeedback.selectionClick();
            ref.read(naamJapStateProvider.notifier).increment(context);
          },
          child: SizedBox(
            width: 220,
            height: 220,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 1. Radiant Aura / Halo (The "Soul" of the UI)
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        PremiumTokens.accentSilver.withValues(alpha: 0.1),
                        PremiumTokens.accentSilver.withValues(alpha: 0.02),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),

                // 2. Structural Outer Ring (Subtle)
                Container(
                  width: 190,
                  height: 190,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: PremiumTokens.textPrimary.withValues(alpha: 0.03),
                      width: 1,
                    ),
                  ),
                ),

                // 3. Performance Progress Ring (Static and Smooth)
                SizedBox(
                  width: 184,
                  height: 184,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 8,
                    strokeCap: StrokeCap.round,
                    backgroundColor: PremiumTokens.textPrimary.withValues(alpha: 0.05),
                    valueColor: AlwaysStoppedAnimation(
                      PremiumTokens.accentSilver,
                    ),
                  ),
                ),

                // 4. Elite Inner Disc (The "Nucleus")
                Container(
                  width: 154,
                  height: 154,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: PremiumTokens.surfaceMain,
                    border: Border.all(
                      color: PremiumTokens.borderSubtle,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: PremiumTokens.scaffoldBg.withValues(alpha: 0.5),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Using ShaderMask for "Silver" Metallic look
                      ShaderMask(
                        shaderCallback: (bounds) =>
                            PremiumTokens.silverGradient.createShader(bounds),
                        child: Text(
                          '${japState.total}',
                          style: GoogleFonts.spectral(
                            fontSize: 52,
                            color: PremiumTokens.textPrimary,
                            fontWeight: FontWeight.w200,
                            letterSpacing: -2,
                          ),
                        ),
                      ),
                      Text(
                        'JAPS TODAY',
                        style: PremiumTokens.sansStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                          color: PremiumTokens.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),

                // 5. Interaction Hint
                Positioned(
                  bottom: 24,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: PremiumTokens.borderSubtle,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: PremiumTokens.borderSubtle,
                      ),
                    ),
                    child: Text(
                      'TAP TO CHANT',
                      style: PremiumTokens.sansStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                        color: PremiumTokens.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
class _CategoriesGridLite extends ConsumerWidget {
  const _CategoriesGridLite();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(personalizedCategoriesProvider);
    final displayCategories = categories.take(4).toList();

    if (displayCategories.isEmpty) {
      return const SizedBox.shrink();
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.0,
      ),
      itemCount: displayCategories.length,
      itemBuilder: (context, index) {
        final cat = displayCategories[index];
        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            // Filter library by this category and switch tab
            ref.read(libraryCategoryProvider.notifier).state = cat.name;
            ref.read(navigationIndexProvider.notifier).state = 1;
          },
          child: PremiumUI.relicStaticCard(
            borderRadius: 20,
            padding: EdgeInsets.zero,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  PremiumUI.networkImage(url: cat.imageUrl, width: 200),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          PremiumTokens.scaffoldBg.withValues(alpha: 0.96),
                          PremiumTokens.scaffoldBg.withValues(alpha: 0.45),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.45, 1.0],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 12, left: 12, right: 12,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cat.name.toUpperCase(),
                          style: PremiumTokens.sansStyle(
                            color: PremiumTokens.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${cat.count} Items',
                          style: PremiumTokens.sansStyle(
                            color: PremiumTokens.textSecondary,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RecentReflectionPreviewLite extends ConsumerWidget {
  const _RecentReflectionPreviewLite();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(readingHistoryProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('LATEST REFLECTION',
              style: PremiumTokens.sansStyle(
                color: PremiumTokens.textMuted,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
              )),
          const SizedBox(height: 16),
          historyAsync.when(
            data: (history) {
              if (history.isEmpty) return const SizedBox.shrink();
              final latest = history.first;
              return GestureDetector(
                onTap: () {
                  ref.read(navigationIndexProvider.notifier).state = 1;
                },
                child: PremiumUI.relicStaticCard(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Icon(Iconsax.moon, color: PremiumTokens.activeAccent, size: 24),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(latest.title ?? 'Sacred Reflection',
                                style: GoogleFonts.spectral(
                                  color: PremiumTokens.textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                )),
                            Text(
                                "${latest.category ?? 'Spiritual'} • Just Read",
                                style: PremiumTokens.sansStyle(
                                    color: PremiumTokens.textMuted, fontSize: 11)),
                          ],
                        ),
                      ),
                      Icon(Iconsax.arrow_right_3, color: PremiumTokens.textMuted, size: 20),
                    ],
                  ),
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}



class _PremiumContentListLite extends ConsumerStatefulWidget {
  const _PremiumContentListLite();

  @override
  ConsumerState<_PremiumContentListLite> createState() =>
      _PremiumContentListLiteState();
}

class _PremiumContentListLiteState extends ConsumerState<_PremiumContentListLite> {
  int _visibleCount = 3;

  @override
  Widget build(BuildContext context) {
    final discoveryState = ref.watch(personalizedDiscoveryProvider);
    final items = discoveryState.items;
    final isLoading = discoveryState.isLoading;

    if (items.isEmpty) {
      if (isLoading) {
        return Center(
          child: CircularProgressIndicator(color: PremiumTokens.activeAccent),
        );
      }
      return Center(
        child: Text(
          "No recommendations available yet.",
          style: PremiumTokens.sansStyle(color: PremiumTokens.textMuted, fontSize: 12),
        ),
      );
    }

    final visibleItems = items.take(_visibleCount).toList();

    return Column(
      children: [
        ...visibleItems.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: PressableScale(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ContentDetailScreen(content: item),
                ),
              );
            },
            child: SizedBox(
              height: 250, // Proportional height for split layout
              child: PremiumUI.relicStaticCard(
                padding: EdgeInsets.zero,
                borderColor: PremiumTokens.borderSubtle,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Column(
                    children: [
                      // 1. Cover image (top portion)
                      SizedBox(
                        height: 120,
                        width: double.infinity,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            PremiumUI.networkImage(
                              url: item.displayImageUrl,
                              fit: BoxFit.cover,
                            ),
                            // Vignette overlay
                            Positioned.fill(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.black.withValues(alpha: 0.15),
                                      Colors.transparent,
                                      Colors.black.withValues(alpha: 0.35),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // Resonance percentage badge overlay
                            Consumer(
                              builder: (context, ref, child) {
                                final match = ref.watch(matchPercentageProvider(item));
                                return Positioned(
                                  right: 12,
                                  top: 12,
                                  child: PremiumUI.resonanceBadge("$match% MATCH", fontSize: 8),
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      // 2. Metadata details panel (bottom portion)
                      Expanded(
                        child: Container(
                          color: PremiumTokens.surfaceMain.withValues(alpha: 0.95),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          child: Row(
                            children: [
                              // Left details text column
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (item.author != null)
                                      Text(
                                        item.author!.toUpperCase(),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: PremiumTokens.sansStyle(
                                          color: PremiumTokens.saffronGlow,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item.title,
                                      style: PremiumTokens.hindiAwareStyle(
                                        item.title,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: PremiumTokens.textPrimary,
                                        isSacred: true,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    PremiumUI.categoryBadge(item.category, fontSize: 10),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Right Actions Column (Arrow icon)
                              Icon(Iconsax.arrow_right_3, color: PremiumTokens.textMuted, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        )),
        if (isLoading)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: PremiumTokens.activeAccent,
                ),
              ),
            ),
          )
        else if (discoveryState.hasMore || _visibleCount < items.length)
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 24),
            child: PressableScale(
              onTap: () {
                HapticFeedback.mediumImpact();
                setState(() {
                  _visibleCount += 5;
                });
                if (_visibleCount >= items.length) {
                  ref.read(personalizedDiscoveryProvider.notifier).loadMore();
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: PremiumTokens.activeAccent.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: PremiumTokens.activeAccent.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Iconsax.arrow_down_1,
                      color: PremiumTokens.activeAccent,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "LOAD MORE WISDOM",
                      style: PremiumTokens.sansStyle(
                        color: PremiumTokens.activeAccent,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Header Buttons (preserved) ───────────────────────────

class _CompactSearchButton extends ConsumerWidget {
  const _CompactSearchButton();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(colorPaletteProvider);
    return PressableScale(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const SearchScreen()));

      },
      child: Icon(Iconsax.search_normal,
          color: PremiumTokens.activeAccent, size: 22),
    );
  }
}

class _CompactNotificationButton extends ConsumerWidget {
  const _CompactNotificationButton();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(colorPaletteProvider);
    return PressableScale(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context, 
          MaterialPageRoute(builder: (_) => const RitualsScreen())
        );
      },
      child: Icon(Iconsax.notification,
          color: PremiumTokens.activeAccent, size: 22),
    );
  }
}

class _CompactProfileButton extends ConsumerWidget {
  const _CompactProfileButton();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(colorPaletteProvider);
    final user = ref.watch(authStateProvider).value;
    final photoUrl = user?.photoURL;

    return PressableScale(
      onTap: () {
        HapticFeedback.lightImpact();
        ref.read(navigationIndexProvider.notifier).state = 4;
      },
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
           border: Border.all(
              color: PremiumTokens.activeAccent.withValues(alpha: 0.3)),
        ),
        child: photoUrl != null
            ? PremiumUI.networkImage(
                url: photoUrl,
                borderRadius: BorderRadius.circular(100),
                width: 32,
                height: 32,
              )
            : Icon(Iconsax.user,
                color: PremiumTokens.activeAccent, size: 16),
      ),
    );
  }
}

// Keep PremiumQuoteCard for backward compatibility
class PremiumQuoteCard extends StatelessWidget {
  const PremiumQuoteCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: PremiumTokens.borderSubtle),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.8,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: PremiumUI.networkImage(
                  url:
                      'https://images.unsplash.com/photo-1470813740244-df37b8c1edcb?auto=format&fit=crop&w=800&q=80',
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(colors: [
                PremiumTokens.charcoal.withValues(alpha: 0.9),
                PremiumTokens.surfaceCharcoal.withValues(alpha: 0.7),
              ]),
            ),
            child: Column(
              children: [
                const Icon(Iconsax.quote_up5,
                    color: PremiumTokens.saffronGlow, size: 40),
                const SizedBox(height: 24),
                Text(
                  '"The soul is neither born, nor does it ever die; nor having once existed, does it ever cease to be."',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.newsreader(
                    color: PremiumTokens.textPrimary,
                    fontSize: 22,
                    fontStyle: FontStyle.italic,
                    height: 1.4,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 20),
                Text('BHAGAVAD GITA 2.20',
                    style: GoogleFonts.manrope(
                      color: PremiumTokens.activeAccent,
                      fontWeight: FontWeight.w800,
                      fontSize: 10,
                      letterSpacing: 2,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
