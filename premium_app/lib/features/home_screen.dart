import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import '../core/theme.dart';
import '../core/design_system.dart';
import '../core/providers.dart';
import '../core/localization.dart';
import '../core/content_provider.dart';
import 'content_detail_screen.dart';
import 'category_screen.dart';
import 'search_screen.dart';
import 'profile/saved_items_screen.dart';
import 'profile/settings_screen.dart';
import '../widgets/animated_effects.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: PremiumTokens.charcoal,
      body: Stack(
        children: [
          // Ambient backgrounds
          const Positioned.fill(child: AnimatedSacredBackground()),
          
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Consumer(
                  builder: (context, ref, _) {
                    final lang = ref.watch(languageProvider);
                    final l = AppLocalization(lang);
                    return _buildPremiumHeader(context, l);
                  },
                ),
              ),

              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
                    return _buildPremiumCategories(context, l);
                  },
                ),
              ),

              SliverToBoxAdapter(
                child: Consumer(
                  builder: (context, ref, _) {
                    final content = ref.watch(sacredContentProvider);
                    final lang = ref.watch(languageProvider);
                    final l = AppLocalization(lang);
                    return _buildPremiumContinueReading(context, content, l);
                  },
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 32, left: 24, right: 24),
                  child: Row(
                    children: [
                      const Icon(Iconsax.magic_star, color: PremiumTokens.saffronGlow, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        'Recent Wisdom',
                        style: GoogleFonts.manrope(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
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

  Widget _buildPremiumHeader(BuildContext context, AppLocalization l) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  decoration: PremiumTokens.evolvingAura(
                    color: PremiumTokens.saffronGlow,
                    intensity: 0.6,
                  ),
                  child: const PulsingOmButton(size: 60),
                ),
                const SizedBox(width: 16),
                const Expanded(child: AnimatedGreeting()),
                PremiumUI.glassCard(
                  padding: const EdgeInsets.all(10),
                  child: const Icon(Iconsax.notification, color: Colors.white, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildJourneyStats(),
          ],
        ),
      ),
    );
  }

  Widget _buildJourneyStats() {
    return Row(
      children: [
        Expanded(
          child: PremiumUI.glassCard(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            child: Column(
              children: [
                Text(
                  'Celestial Path',
                  style: GoogleFonts.manrope(color: Colors.white60, fontSize: 10, letterSpacing: 1),
                ),
                const SizedBox(height: 8),
                Text(
                  'Orbit 4',
                  style: GoogleFonts.manrope(
                    color: PremiumTokens.celestialGlow,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: PremiumUI.glassCard(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            child: Column(
              children: [
                Text(
                  'Total Jap Hours',
                  style: GoogleFonts.manrope(color: Colors.white60, fontSize: 10, letterSpacing: 1),
                ),
                const SizedBox(height: 8),
                Text(
                  '142.5 hrs',
                  style: GoogleFonts.manrope(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: PremiumUI.glassCard(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            child: Column(
              children: [
                Text(
                  'Stillness Score',
                  style: GoogleFonts.manrope(color: Colors.white60, fontSize: 10, letterSpacing: 1),
                ),
                const SizedBox(height: 8),
                Text(
                  '84 / 100',
                  style: GoogleFonts.manrope(
                    color: PremiumTokens.saffronGlow,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumNaamJap(BuildContext context, WidgetRef ref) {
    final count = ref.watch(naamJapCounterProvider);
    final progress = (count % 108) / 108;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: PremiumUI.glassCard(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'नाम जप',
                      style: SacredStyles.devanagariMain.copyWith(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Active Meditative Chant',
                      style: GoogleFonts.manrope(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
                if (count > 0)
                  IconButton(
                    icon: const Icon(Iconsax.refresh, color: Colors.white54, size: 20),
                    onPressed: () => ref.read(naamJapCounterProvider.notifier).state = 0,
                  ),
              ],
            ),
            const SizedBox(height: 32),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 140,
                  height: 140,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 4,
                    backgroundColor: Colors.white12,
                    valueColor: const AlwaysStoppedAnimation(PremiumTokens.saffronGlow),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    ref.read(naamJapCounterProvider.notifier).state++;
                  },
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      gradient: PremiumTokens.saffronPremiumGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: PremiumTokens.saffronGlow.withOpacity(0.4),
                          blurRadius: 25,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'ॐ',
                        style: TextStyle(fontSize: 48, color: Colors.white, fontWeight: FontWeight.normal),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              '$count',
              style: GoogleFonts.manrope(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
            Text(
              'TOTAL JAPS',
              style: GoogleFonts.manrope(
                fontSize: 12,
                color: PremiumTokens.saffronGlow,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumCategories(BuildContext context, AppLocalization l) {
    final categories = [
      {'name': 'Shlokas', 'icon': Iconsax.document_text, 'color': PremiumTokens.saffronGlow},
      {'name': 'Stotras', 'icon': Iconsax.music, 'color': Colors.pinkAccent},
      {'name': 'Mantras', 'icon': Iconsax.magic_star, 'color': Colors.purpleAccent},
      {'name': 'Poems', 'icon': Iconsax.edit, 'color': Colors.tealAccent},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Text(
            'Explore Sacred Wisdom',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: PremiumUI.glassCard(
                  width: 120,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(cat['icon'] as IconData, color: cat['color'] as Color, size: 32),
                      const SizedBox(height: 12),
                      Text(
                        cat['name'] as String,
                        style: GoogleFonts.manrope(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumContinueReading(BuildContext context, List<SacredContent> content, AppLocalization l) {
    if (content.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 32, left: 24, bottom: 16),
          child: Text(
            'Keep Journeying',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: content.take(3).length,
            itemBuilder: (context, index) {
              final item = content[index];
              return Container(
                width: 280,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: PremiumUI.glassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: PremiumTokens.saffronGlow.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              item.category,
                              style: const TextStyle(color: PremiumTokens.saffronGlow, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const Spacer(),
                          const Icon(Iconsax.book_1, color: Colors.white38, size: 16),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        item.title,
                        style: GoogleFonts.manrope(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(Iconsax.clock, color: Colors.white30, size: 14),
                          const SizedBox(width: 4),
                          Text('5 min left', style: GoogleFonts.manrope(color: Colors.white30, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
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
            child: PremiumUI.glassCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: PremiumTokens.saffronGlow.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(child: Text('ॐ', style: TextStyle(color: PremiumTokens.saffronGlow, fontSize: 24))),
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
                          style: GoogleFonts.manrope(color: PremiumTokens.saffronGlow, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Iconsax.arrow_right_3, color: Colors.white24, size: 16),
                ],
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
    return PremiumUI.glassCard(
      opacity: 0.12,
      child: Column(
        children: [
          const Icon(Iconsax.quote_up, color: PremiumTokens.saffronGlow, size: 24),
          const SizedBox(height: 16),
          Text(
            "The soul is never born nor dies at any time. It has not come into being, does not come into being, and will not come into being.",
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              color: Colors.white,
              fontSize: 16,
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "— Bhagavad Gita 2.20",
            style: GoogleFonts.manrope(
              color: PremiumTokens.saffronGlow,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
