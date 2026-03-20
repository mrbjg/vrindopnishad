import 'package:flutter/material.dart'; // Ethereal Dashboard Base
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'package:flutter_svg/flutter_svg.dart';
import '../core/design_system.dart';
import '../core/providers.dart';
import '../core/localization.dart';
import '../core/content_provider.dart';
import '../core/audio_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/stats_provider.dart';
import '../core/auth_provider.dart';
import 'search_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(userStatsProvider);
    final user = ref.watch(authStateProvider).value;
    
    final level = statsAsync.value?.level ?? 1;
    final photoUrl = user?.photoURL;
    
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
                collapsedHeight: 80,
                pinned: true,
                floating: false,
                backgroundColor: PremiumTokens.voidBlack.withValues(alpha: 0.95),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    PremiumUI.animatedIcon(
                      folder: 'Filter',
                      fileName: 'filter.json',
                      size: 28,
                      color: PremiumTokens.nebulaBlue,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        // Filter logic
                      },
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          PremiumUI.logo(height: 28),
                          const SizedBox(width: 8),
                          Container(
                            height: 12,
                            width: 1,
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              "ORBIT $level • ETHEREAL DASHBOARD",
                              style: GoogleFonts.inter(
                                fontSize: 9,
                                color: PremiumTokens.nebulaBlue,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => SearchScreen()),
                            );
                          },
                          child: Icon(Iconsax.search_normal, color: PremiumTokens.nebulaBlue, size: 22),
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                          },
                          child: Icon(Iconsax.notification, color: PremiumTokens.nebulaBlue, size: 22),
                        ),
                        const SizedBox(width: 16),
                        Container(
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
                              )
                            : Icon(Iconsax.user, color: PremiumTokens.nebulaBlue, size: 16),
                        ),
                      ],
                    ),
                  ],
                ),
                automaticallyImplyLeading: false,
              ),

              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: PremiumQuoteCard(),
                ),
              ),

              SliverToBoxAdapter(
                child: _buildPremiumNaamJap(context, ref),
              ),

              SliverToBoxAdapter(
                child: Consumer(
                  builder: (context, ref, _) {
                    final lang = ref.watch(languageProvider);
                    final l = AppLocalization(lang);
                    return _buildCategoriesHeader(context, l, ref);
                  },
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: _buildCategoriesGrid(context, ref),
              ),

              SliverToBoxAdapter(
                child: _buildRecentReflectionPreview(context, ref),
              ),

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 32, 20, 180), // Increased to 180 for MiniPlayer + NavBar
                sliver: Consumer(
                  builder: (context, ref, _) {
                    final content = ref.watch(sacredContentProvider);
                    final visibleCount = ref.watch(visibleItemCountProvider);
                    return _buildPremiumContentList(context, content, visibleCount, ref);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: PremiumTokens.nebulaBlue.withValues(alpha: 0.1),
        shape: BoxShape.circle,
        border: Border.all(color: PremiumTokens.nebulaBlue.withValues(alpha: 0.2)),
      ),
      child: Icon(icon, color: PremiumTokens.nebulaBlue, size: 20),
    );
  }

  Widget _buildExpandPlayerButton(BuildContext context, WidgetRef ref) {
    return PremiumUI.etherealButton(
      onTap: () {
        ref.read(navigationIndexProvider.notifier).state = 2;
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
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
    );
  }

  Widget _buildPremiumNaamJap(BuildContext context, WidgetRef ref) {
    final count = ref.watch(naamJapStateProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: PremiumUI.etherealCard(
        padding: const EdgeInsets.all(24),
        borderRadius: 32,
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
                PremiumUI.etherealButton(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  borderRadius: 12,
                  onTap: () {}, 
                  color: Colors.white.withValues(alpha: 0.05),
                  child: Text(
                    "GOAL: 1008",
                    style: PremiumTokens.sansStyle(
                      fontSize: 11, 
                      color: Colors.white.withValues(alpha: 0.9), // Changed from nebulaBlue to white
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
                count: count,
                onTap: () {
                  ref.read(naamJapStateProvider.notifier).increment();
                },
                goal: 1008,
                size: 240,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Moved Expand Player inside the block, matching width
            SizedBox(
              width: double.infinity,
              child: _buildExpandPlayerButton(context, ref),
            ),
            
            const SizedBox(height: 24),
            
            // The original _buildExpandPlayerButton content was here. It's now moved to its own method.
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesHeader(BuildContext context, AppLocalization l, WidgetRef widgetRef) {
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
              widgetRef.read(navigationIndexProvider.notifier).state = 1; // View all content in Library
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

  Widget _buildCategoriesGrid(BuildContext context, WidgetRef widgetRef) {
    final categories = [
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
              widgetRef.read(navigationIndexProvider.notifier).state = 1; // Navigate to Library
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


  Widget _buildRecentReflectionPreview(BuildContext context, WidgetRef ref) {
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
          GestureDetector(
            onTap: () {
              // Select the latest reflection for audio playback if it has a URL
              // For now, expand the player or navigate
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
                          'Stillness in the Void',
                          style: GoogleFonts.newsreader(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Mar 14 • 3 min read',
                          style: GoogleFonts.manrope(color: Colors.white38, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Iconsax.arrow_right_3, color: Colors.white24, size: 20),
                    onPressed: () {
                      ref.read(navigationIndexProvider.notifier).state = 1; // Library index
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumContentList(BuildContext context, List<SacredContent> content, int visibleCount, WidgetRef ref) {
    final items = content.take(visibleCount).toList();
    
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final item = items[index];
          return Padding(
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
          );
        },
        childCount: items.length,
      ),
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
                Icon(Iconsax.quote_up5, color: PremiumTokens.nebulaBlue, size: 40),
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
