import 'package:flutter/material.dart';
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
                collapsedHeight: 80,
                pinned: true,
                floating: false,
                backgroundColor: PremiumTokens.voidBlack.withOpacity(0.95),
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
                            color: Colors.white.withOpacity(0.1),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              "ETHEREAL DASHBOARD",
                              style: GoogleFonts.inter(
                                fontSize: 9,
                                color: Colors.white70,
                                fontWeight: FontWeight.w600,
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
                          },
                          child: Icon(Iconsax.notification, color: PremiumTokens.nebulaBlue, size: 24),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: PremiumTokens.nebulaBlue.withOpacity(0.3)),
                            image: const DecorationImage(
                              image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuAkQJsMLqDCMwi1jqTeWSOOqq3Wz9ZIpqA9usLZAS95EcvHTBag2RoKJxY0vI0ignkQJ8N7UDe1CbmOARjpZ4djVMMi7DYNHPxPNoYSkcaHePL2qyHdLar7mUl0CW6gMbXv788itHF2vxM4sZWWsBBAQUG96RO8rYlrZNHgfYgQ6IfsKE6u5jOS_QRQe0dd2Fy-5dU6VL7ZLOg1jCrXoMsqJDXEiKCcCuT1CctHQ72_ivF3Rc94CqJae0t_M1fKLDyKMLPrbTHwr8I'),
                              fit: BoxFit.cover,
                            ),
                          ),
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
                    return _buildCategoriesHeader(context, l);
                  },
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: _buildCategoriesGrid(context),
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
        color: PremiumTokens.nebulaBlue.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(color: PremiumTokens.nebulaBlue.withOpacity(0.2)),
      ),
      child: Icon(icon, color: PremiumTokens.nebulaBlue, size: 20),
    );
  }

  Widget _buildPremiumNaamJap(BuildContext context, WidgetRef ref) {
    final count = ref.watch(naamJapStateProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: PremiumUI.glassCard(
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
                      'DAILY CHANTS',
                      style: PremiumTokens.sansStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        color: Colors.white38,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Sacred Counter',
                      style: GoogleFonts.spectral(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
                PremiumUI.glassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  borderRadius: 12,
                  child: Text(
                    "GOAL: 1008",
                    style: PremiumTokens.sansStyle(fontSize: 10, color: PremiumTokens.nebulaBlue, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Professional Central Counter
            GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                ref.read(naamJapStateProvider.notifier).increment();
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Aura
                  Animate(
                    onPlay: (c) => c.repeat(reverse: true),
                    effects: [
                      ScaleEffect(begin: const Offset(1, 1), end: const Offset(1.2, 1.2), duration: 2.seconds),
                    ],
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            PremiumTokens.nebulaBlue.withOpacity(0.1),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // Counter Disk
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.03),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Animate(
                        target: count > 0 ? 1 : 0,
                        effects: [
                          ScaleEffect(duration: 200.ms),
                        ],
                        child: Text(
                          count.toString(),
                          style: GoogleFonts.spectral(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                ref.read(navigationIndexProvider.notifier).state = 2;
              },
              child: PremiumUI.glassCard(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                borderRadius: 20,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Iconsax.music_play, color: Colors.white, size: 18),
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
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesHeader(BuildContext context, AppLocalization l) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Sacred Wisdom',
            style: GoogleFonts.manrope(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            'View All',
            style: GoogleFonts.manrope(color: PremiumTokens.nebulaBlue, fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesGrid(BuildContext context) {
    final categories = [
      {
        'name': 'Shlokas',
        'count': '124 Verses',
        'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuAEFZ1NeG5QqGTXKSJv1rV8rLDhQhlx1UHhyfelWZwIv73jJc27pWCgFEVnAWsEtoztQzjpYfB4Ta-gdVXO8nGW3TZv6gz2VVNiXQ0bAuPAU0A2EET6kwzroKFi6QyMx_iL6hT5-nJmaJG4g5yeUcs228Qz43Q7oWwJVkCXGRh71Rj96lkX3FqW2AKzNfIzMtF4NrnJwqilFitnulwwrvmJQl5WzvK75f9qBeesP1Y_X9MsagiJDCEJtxSHRCThUFQP20TqBpHXqug'
      },
      {
        'name': 'Mantras',
        'count': '48 Audio',
        'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuBn4KXlGdM09V_vyL6FYniGawEBhjjVTHPtWkncMv7AsR6PnDmJx7em82khx96o3tU2b3i1Xv29wn9YRQoYyoZeajegx50mvb2FhsVMMSfaFhybyyp4s5nWVhvjM-Xy_QSV-yOBYDJ2x9MEKcOFTdGbZgUrn0UE6v0p2K2PQWyKunglhZdM8Zl3m2CwulCpccA2dLrSOn__UtnRnXD-8qj4bbhKvT8rR2TwLW9SujHlkdwDM9eRnU6XwEIsGvxdMY1xt3PWf0sISOE'
      },
      {
        'name': 'Stories',
        'count': '12 Series',
        'image': 'https://lh3.googleusercontent.com/aida-public/AB6AXuD6E9OTyxnJhrda-g9daQdFXrAz4TJmD0Cewd-uAJHe99lzEGrtQBZP2OLvO0-zle7gi0JAFr95Tuwe2uWVQZenYjMMg2aZuepRChhSJhrehrkL8F20BMPRedP3DHsihlTPFzXTa-TuUVlfqdV5EB1ua7JyiQrF5wAlg7lPsHMoeptGeQ5PPyMp2W0dTyvoQ3AJ_GKnESg4LjlHvVxlQm2NA-rJFW5whrIw9unR7N2UVzqZuXGSWUcnIiHviA2FeNwKnx98C7l2Eds'
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
              // Navigation or category logic
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
                          PremiumTokens.charcoal.withOpacity(0.9),
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
                accentColor: PremiumTokens.nebulaBlue.withOpacity(0.3),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: PremiumTokens.nebulaBlue.withOpacity(0.1),
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
        border: Border.all(color: Colors.white.withOpacity(0.05)),
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
                  url: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDactqYO6CbwQGgpXvjo0DgkESwH0VMyPzgUmW4lxWwigZrkL3hrpWO0GV55qftuaynG8hIGsNOSf0jyS_jbiyw5ICe60cRZF6CddbBypU9dsLavW8_kOkCYxHF7pTRhvL6Wfr2octpa0b_jMExeQV1Lotlx7iz8g0mW810-RDEKM5t2WNkYO8l4JdqMizl99LC83J63eCUMj940jv-a6uWL3suEKZHb5WQeBGmSzatYFzPn_F95l_tE6xxWZljmCNgJcSdqbypQVU',
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
                  PremiumTokens.charcoal.withOpacity(0.9),
                  PremiumTokens.surfaceCharcoal.withOpacity(0.7),
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
