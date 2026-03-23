import 'package:flutter/material.dart'; // Ethereal Dashboard Base
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/design_system.dart';
import '../core/providers.dart';
import '../core/content_provider.dart';
import '../core/audio_provider.dart';
import '../core/stats_provider.dart';
import '../core/auth_provider.dart';
import '../core/theme.dart';
import 'search_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background handled by MainNavigationScreen to prevent overdraw
          
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Sticky Header (matching bg-background-dark/80 backdrop-blur-md)
              SliverAppBar(
                expandedHeight: 0,
                collapsedHeight: 72,
                pinned: true,
                floating: false,
                elevation: 0,
                scrolledUnderElevation: 0,
                backgroundColor: AppTheme.lowPerformanceMode 
                    ? PremiumTokens.voidIndigo 
                    : PremiumTokens.voidIndigo.withValues(alpha: 0.98),
                titleSpacing: 20,
                title: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: PremiumUI.logo(height: 28),
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

              const SliverToBoxAdapter(
                child: RepaintBoundary(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 30, 20, 10),
                    child: PremiumQuoteCard(),
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                child: _PremiumNaamJapSection(),
              ),

              const SliverToBoxAdapter(
                child: _CategoriesHeader(),
              ),

              const SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                sliver: _CategoriesGrid(),
              ),

              const SliverToBoxAdapter(
                child: _RecentReflectionPreview(),
              ),

              const SliverPadding(
                padding: EdgeInsets.fromLTRB(20, 32, 20, 180), // Increased to 180 for MiniPlayer + NavBar
                sliver: _PremiumContentList(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoriesHeader extends ConsumerWidget {
  const _CategoriesHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch language only to rebuild when it changes
    ref.watch(languageProvider);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Sacred Wisdom',
            style: GoogleFonts.manrope(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              ref.read(navigationIndexProvider.notifier).state = 1; // View all content in Library
            },
            child: Text(
              'View All',
              style: GoogleFonts.manrope(color: PremiumTokens.nebulaBlue, fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumContentList extends ConsumerWidget {
  const _PremiumContentList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.watch(sacredContentProvider);
    final visibleCount = ref.watch(visibleItemCountProvider);
    final items = content.take(visibleCount).toList();
    
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final item = items[index];
          return RepaintBoundary(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: GestureDetector(
              onTap: () {
                HapticFeedback.heavyImpact();
                ref.read(audioProvider.notifier).play(item);
              },
              child: PremiumUI.voidCard(
                padding: const EdgeInsets.all(16),
                accentColor: PremiumTokens.nebulaBlue.withValues(alpha: 0.3),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: PremiumTokens.nebulaBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(child: Text('ॐ', style: TextStyle(color: PremiumTokens.nebulaBlue, fontSize: 24))),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: GoogleFonts.manrope(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.category,
                            style: GoogleFonts.manrope(color: PremiumTokens.nebulaBlue, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Iconsax.arrow_right_3, color: Colors.white24, size: 16),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        childCount: items.length,
      ),
    );
  }
}

class _PremiumNaamJapSection extends ConsumerWidget {
  const _PremiumNaamJapSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final japState = ref.watch(naamJapStateProvider);

    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: PremiumUI.etherealCard(
        padding: const EdgeInsets.all(24),
        borderRadius: 32,
        optimized: true, // Bypass BackdropFilter for frequent counter updates
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DAILY PROGRESS',
                      style: PremiumTokens.sansStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        color: PremiumTokens.nebulaBlue.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Sacred Counter',
                      style: GoogleFonts.spectral(
                        fontSize: 26,
                        color: Colors.white,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "GOAL: 1008",
                    style: PremiumTokens.sansStyle(
                      fontSize: 11, 
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            // Enhanced Premium Counter
            Center(
              child: PremiumUI.naamJapCounter(
                count: japState.total,
                onTap: () {
                  ref.read(naamJapStateProvider.notifier).increment();
                },
                goal: 1008,
                size: 240,
              ),
            ),
            
            const SizedBox(height: 32),
            
            SizedBox(
              width: double.infinity,
              child: PremiumUI.etherealButton(
                optimized: true,
                onTap: () {
                  ref.read(navigationIndexProvider.notifier).state = 2;
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Iconsax.music_play, color: Colors.white.withValues(alpha: 0.9), size: 18),
                    const SizedBox(width: 12),
                    Text(
                      "EXPAND PLAYER",
                      style: PremiumTokens.sansStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoriesGrid extends ConsumerWidget {
  const _CategoriesGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const categories = [
      {
        'name': 'Shlokas',
        'count': '124 Verses',
        'image': 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&w=400&q=80'
      },
      {
        'name': 'Mantras',
        'count': '48 Audio',
        'image': 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=400&q=80'
      },
      {
        'name': 'Stories',
        'count': '12 Series',
        'image': 'https://images.unsplash.com/photo-1470813740244-df37b8c1edcb?auto=format&fit=crop&w=400&q=80'
      },
    ];

    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.0,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final cat = categories[index];
          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              ref.read(navigationIndexProvider.notifier).state = 1; // Navigate to Library
            },
            child: PremiumUI.saffronGlassCard(
              padding: EdgeInsets.zero,
              optimized: true,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: PremiumUI.networkImage(
                      url: cat['image'],
                      borderRadius: BorderRadius.circular(24),
                      width: 200, // Explicit sizing for cache
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          PremiumTokens.charcoal.withValues(alpha: 0.9),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cat['name']!,
                          style: GoogleFonts.manrope(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        Text(
                          cat['count']!,
                          style: GoogleFonts.manrope(color: Colors.white54, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        childCount: categories.length,
      ),
    );
  }
}

class _RecentReflectionPreview extends ConsumerWidget {
  const _RecentReflectionPreview();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(readingHistoryProvider);
    
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'LATEST REFLECTION',
            style: GoogleFonts.manrope(
              color: Colors.white38,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          historyAsync.when(
            data: (history) {
              if (history.isEmpty) return const SizedBox.shrink();
              final latest = history.first;
              return GestureDetector(
                onTap: () {
                  ref.read(navigationIndexProvider.notifier).state = 1;
                },
                child: PremiumUI.voidCard(
                  child: Row(
                    children: [
                      const Icon(Iconsax.moon, color: Color(0xFFC0C0CF), size: 24),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              latest.title ?? 'Sacred Reflection',
                              style: GoogleFonts.newsreader(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "${latest.category ?? 'Spiritual'} • Just Read",
                              style: GoogleFonts.manrope(color: Colors.white38, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Iconsax.arrow_right_3, color: Colors.white24, size: 20),
                        onPressed: () {
                          ref.read(navigationIndexProvider.notifier).state = 1;
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 1)),
            error: (e, _) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _CompactSearchButton extends StatelessWidget {
  const _CompactSearchButton();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => SearchScreen()),
        );
      },
      child: const Icon(Iconsax.search_normal, color: PremiumTokens.nebulaBlue, size: 22),
    );
  }
}

class _CompactNotificationButton extends StatelessWidget {
  const _CompactNotificationButton();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
      },
      child: const Icon(Iconsax.notification, color: PremiumTokens.nebulaBlue, size: 22),
    );
  }
}

class _CompactProfileButton extends ConsumerWidget {
  const _CompactProfileButton();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final photoUrl = user?.photoURL;
    
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: PremiumTokens.nebulaBlue.withValues(alpha: 0.3)),
      ),
      child: photoUrl != null 
        ? PremiumUI.networkImage(
            url: photoUrl,
            borderRadius: BorderRadius.circular(15),
            width: 32,
            height: 32,
          )
        : const Icon(Iconsax.user, color: PremiumTokens.nebulaBlue, size: 16),
    );
  }
}

class PremiumQuoteCard extends StatelessWidget {
  const PremiumQuoteCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ethereal Bokeh Background from template
          Positioned.fill(
            child: Opacity(
              opacity: 0.8,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: PremiumUI.networkImage(
                  url: 'https://images.unsplash.com/photo-1470813740244-df37b8c1edcb?auto=format&fit=crop&w=800&q=80',
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: [
                  PremiumTokens.charcoal.withValues(alpha: 0.9),
                  PremiumTokens.surfaceCharcoal.withValues(alpha: 0.7),
                ],
              ),
            ),
            child: Column(
              children: [
                const Icon(Iconsax.quote_up5, color: PremiumTokens.nebulaBlue, size: 40),
                const SizedBox(height: 24),
                Text(
                  '"The soul is neither born, nor does it ever die; nor having once existed, does it ever cease to be."',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.newsreader(
                    color: Colors.white,
                    fontSize: 22,
                    fontStyle: FontStyle.italic,
                    height: 1.4,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'BHAGAVAD GITA 2.20',
                  style: GoogleFonts.manrope(
                    color: PremiumTokens.nebulaBlue,
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                    letterSpacing: 2,
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
