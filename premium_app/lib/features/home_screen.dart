import 'package:flutter/material.dart';
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
import '../core/spirituality_provider.dart';
import '../core/spirituality_engine.dart';
import 'search_screen.dart';
import 'daily_motivation_screen.dart';
import 'daily_gyaan_screen.dart';
import 'sacred_calendar_screen.dart';
import 'achievements_screen.dart';

import '../widgets/daily_check_in_widget.dart';


class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Sticky Header
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

              // 0. Daily Check-in
              const SliverPadding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
                sliver: SliverToBoxAdapter(child: DailyCheckInWidget()),
              ),

              // Consolodated Lite Section
              const SliverToBoxAdapter(
                child: Column(
                  children: [
                    _DailyMotivationSection(),
                    _StreakLevelBar(),
                    RepaintBoundary(child: _PremiumNaamJapSection()),
                    _QuickActionsGrid(),
                  ],
                ),
              ),




              // 7. Sacred Wisdom Categories
              const SliverToBoxAdapter(child: _CategoriesHeader()),

              const SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                sliver: _CategoriesGrid(),
              ),

              // 8. Recent Content
              const SliverToBoxAdapter(child: _RecentReflectionPreview()),

              const SliverPadding(
                padding: EdgeInsets.fromLTRB(20, 32, 20, 180),
                sliver: _PremiumContentList(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Daily Motivation Section ──────────────────────────────

class _DailyMotivationSection extends ConsumerWidget {
  const _DailyMotivationSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contextMotivation = ref.watch(contextualMotivationProvider);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const DailyMotivationScreen()));
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
        child: PremiumUI.etherealCard(
          padding: const EdgeInsets.all(20),
          borderRadius: 24,
          glowColor: PremiumTokens.saffronGlow.withValues(alpha: 0.1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  EmojiToIcon.getIconWidget('🌅',
                      size: 16, color: PremiumTokens.saffronGlow),
                  const SizedBox(width: 8),
                  Text(
                    'DAILY INSPIRATION',
                    style: PremiumTokens.sansStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                      color: PremiumTokens.saffronGlow.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                contextMotivation,
                style: GoogleFonts.spectral(
                  fontSize: 16,
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w300,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// ─── Streak & Level Bar ────────────────────────────────────

class _StreakLevelBar extends ConsumerWidget {
  const _StreakLevelBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(userStatsProvider);
    final challengesAsync = ref.watch(dailyChallengesProvider);

    // Use .value to prevent UI from hiding during subsequent loading states
    final stats = statsAsync.value;
    final challenges = challengesAsync.value;

    if (stats == null) {
      if (statsAsync.isLoading) return const SizedBox(height: 60);
      return const SizedBox.shrink();
    }

    final level = stats.level;
    final xp = stats.experiencePoints;
    final streak = stats.streakCount;

    final xpForNext = SpiritualityEngine.xpForLevel(level);
    final progress = xpForNext > 0 ? (xp % xpForNext) / xpForNext : 0.0;

    // Use previous challenges if available to prevent flicker
    if (challenges == null) {
      if (challengesAsync.isLoading) return const SizedBox(height: 60);
      return const SizedBox.shrink();
    }

    final completed = challenges.where((c) => c.isCompleted).length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: PremiumUI.glassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        borderRadius: 16,
        child: Row(
          children: [
            // Streak & Level info
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('STREAK: $streak',
                        style: PremiumTokens.sansStyle(
                            fontSize: 9, fontWeight: FontWeight.w900)),
                    const SizedBox(width: 12),
                    Text('L$level',
                        style: PremiumTokens.sansStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: PremiumTokens.nebulaBlue)),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 120,
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white10,
                    valueColor:
                        const AlwaysStoppedAnimation(PremiumTokens.nebulaBlue),
                    minHeight: 4,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
            const Spacer(),
            // Challenges compact view
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('CHALLENGES: $completed/${challenges.length}',
                    style: PremiumTokens.sansStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: Colors.white54)),
                const SizedBox(height: 6),
                Row(
                  children: challenges.take(3).map((c) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: c.isCompleted
                              ? Colors.greenAccent
                              : Colors.white10,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}



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
            emoji: '📚',
            label: 'Gyaan',
            color: PremiumTokens.nebulaBlue,
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const DailyGyaanScreen())),
          ),
          const SizedBox(width: 12),
          _QuickActionTile(
            emoji: '📅',
            label: 'Calendar',
            color: Colors.orangeAccent,
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const SacredCalendarScreen())),
          ),
          const SizedBox(width: 12),
          _QuickActionTile(
            emoji: '🏆',
            label: 'Badges',
            color: PremiumTokens.saffronGlow,
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AchievementsScreen())),
          ),
        ],
      ),
    );
  }
}



class _QuickActionTile extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.emoji,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: PremiumUI.voidCard(
          padding: const EdgeInsets.symmetric(vertical: 20),
          borderRadius: 20,
          accentColor: color,
          child: Column(
            children: [
              EmojiToIcon.getIconWidget(emoji, size: 24, color: color),
              const SizedBox(height: 8),
              Text(
                label.toUpperCase(),
                style: PremiumTokens.sansStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                  color: color,
                ),
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
    ref.watch(languageProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Sacred Wisdom',
              style: GoogleFonts.manrope(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              ref.read(navigationIndexProvider.notifier).state = 1;
            },
            child: Text('View All',
                style: GoogleFonts.manrope(
                    color: PremiumTokens.nebulaBlue,
                    fontSize: 13,
                    fontWeight: FontWeight.bold)),
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
                      child: const Center(
                          child: Text('ॐ',
                              style: TextStyle(
                                  color: PremiumTokens.nebulaBlue,
                                  fontSize: 24))),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.title,
                              style: GoogleFonts.manrope(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15)),
                          const SizedBox(height: 4),
                          Text(item.category,
                              style: GoogleFonts.manrope(
                                  color: PremiumTokens.nebulaBlue,
                                  fontSize: 12)),
                        ],
                      ),
                    ),
                    const Icon(Iconsax.arrow_right_3,
                        color: Colors.white24, size: 16),
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


class _PremiumNaamJapSection extends ConsumerWidget {
  const _PremiumNaamJapSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final japState = ref.watch(naamJapStateProvider);
    const goal = 1008; // Example goal
    final progress = (japState.total % goal) / goal;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Center(
        child: GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            ref.read(naamJapStateProvider.notifier).increment(context);
          },
          child: SizedBox(
            width: 200,
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Static Halo / Aura
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: PremiumTokens.nebulaBlue.withValues(alpha: 0.15),
                        blurRadius: 60,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),

                // Outermost Ring
                SizedBox(
                  width: 180,
                  height: 180,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 4,
                    backgroundColor: Colors.white.withValues(alpha: 0.05),
                    valueColor: const AlwaysStoppedAnimation(
                      PremiumTokens.nebulaBlue,
                    ),
                  ),
                ),

                // Inner Disc
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF0F0F2D),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                    gradient: RadialGradient(
                      colors: [
                        PremiumTokens.nebulaBlue.withValues(alpha: 0.05),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${japState.total}',
                        style: GoogleFonts.spectral(
                          fontSize: 42,
                          color: Colors.white,
                          fontWeight: FontWeight.w200,
                          letterSpacing: -1,
                        ),
                      ),
                      Text(
                        'JAPS TODAY',
                        style: PremiumTokens.sansStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                          color: Colors.white38,
                        ),
                      ),
                    ],
                  ),
                ),

                // Tap Prompt (Subtle)
                Positioned(
                  bottom: 20,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'TAP TO CHANT',
                      style: PremiumTokens.sansStyle(
                        fontSize: 7,
                        fontWeight: FontWeight.w900,
                        color: PremiumTokens.nebulaBlue.withValues(alpha: 0.7),
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
class _CategoriesGrid extends ConsumerWidget {

  const _CategoriesGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const categories = [
      {
        'name': 'Shlokas',
        'count': '124 Verses',
        'image':
            'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&w=400&q=80'
      },
      {
        'name': 'Mantras',
        'count': '48 Audio',
        'image':
            'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=400&q=80'
      },
      {
        'name': 'Stories',
        'count': '12 Series',
        'image':
            'https://images.unsplash.com/photo-1470813740244-df37b8c1edcb?auto=format&fit=crop&w=400&q=80'
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
              ref.read(navigationIndexProvider.notifier).state = 1;
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    PremiumUI.networkImage(
                      url: cat['image']!,
                      width: 200,
                    ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black87,
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      left: 12,
                      right: 12,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(cat['name']!,
                              style: GoogleFonts.manrope(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14)),
                          Text(cat['count']!,
                              style: GoogleFonts.manrope(
                                  color: Colors.white54, fontSize: 10)),
                        ],
                      ),
                    ),
                  ],
                ),
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
          Text('LATEST REFLECTION',
              style: GoogleFonts.manrope(
                color: Colors.white38,
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
                child: PremiumUI.voidCard(
                  child: Row(
                    children: [
                      const Icon(Iconsax.moon,
                          color: Color(0xFFC0C0CF), size: 24),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(latest.title ?? 'Sacred Reflection',
                                style: GoogleFonts.newsreader(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                )),
                            Text(
                                "${latest.category ?? 'Spiritual'} • Just Read",
                                style: GoogleFonts.manrope(
                                    color: Colors.white38, fontSize: 11)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Iconsax.arrow_right_3,
                            color: Colors.white24, size: 20),
                        onPressed: () {
                          ref.read(navigationIndexProvider.notifier).state = 1;
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
            loading: () =>
                const Center(child: CircularProgressIndicator(strokeWidth: 1)),
            error: (e, _) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

// ─── Header Buttons (preserved) ───────────────────────────

class _CompactSearchButton extends StatelessWidget {
  const _CompactSearchButton();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const SearchScreen()));

      },
      child: const Icon(Iconsax.search_normal,
          color: PremiumTokens.nebulaBlue, size: 22),
    );
  }
}

class _CompactNotificationButton extends StatelessWidget {
  const _CompactNotificationButton();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => HapticFeedback.lightImpact(),
      child: const Icon(Iconsax.notification,
          color: PremiumTokens.nebulaBlue, size: 22),
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
        border: Border.all(
            color: PremiumTokens.nebulaBlue.withValues(alpha: 0.3)),
      ),
      child: photoUrl != null
          ? PremiumUI.networkImage(
              url: photoUrl,
              borderRadius: BorderRadius.circular(15),
              width: 32,
              height: 32,
            )
          : const Icon(Iconsax.user,
              color: PremiumTokens.nebulaBlue, size: 16),
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
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
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
                    color: PremiumTokens.nebulaBlue, size: 40),
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
                Text('BHAGAVAD GITA 2.20',
                    style: GoogleFonts.manrope(
                      color: PremiumTokens.nebulaBlue,
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
