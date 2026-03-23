import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
import 'daily_challenge_screen.dart';

import '../widgets/streak_fire_animation.dart';
import '../widgets/xp_progress_bar.dart';
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

              // 1. Daily Motivation Card
              const SliverToBoxAdapter(
                child: RepaintBoundary(child: _DailyMotivationSection()),
              ),

              // 2. Streak & Level Bar
              const SliverToBoxAdapter(
                child: RepaintBoundary(child: _StreakLevelBar()),
              ),

              // 3. Today's Challenges (quick view)
              const SliverToBoxAdapter(
                child: RepaintBoundary(child: _DailyChallengesPreview()),
              ),

              // 4. Naam Jap Quick Access
              const SliverToBoxAdapter(
                child: RepaintBoundary(child: _PremiumNaamJapSection()),
              ),

              // 5. Quick Actions Grid (Gyaan, Calendar, Achievements)
              const SliverToBoxAdapter(
                child: RepaintBoundary(child: _QuickActionsGrid()),
              ),

              // 6. Upcoming Vrat/Utsav Alert
              const SliverToBoxAdapter(
                child: RepaintBoundary(child: _UpcomingEventsBanner()),
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
          padding: const EdgeInsets.all(24),
          borderRadius: 28,
          glowColor: PremiumTokens.saffronGlow.withValues(alpha: 0.15),
          child: Column(
            children: [
              Row(
                children: [
                  const Text('🌅', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Text(
                    'DAILY INSPIRATION',
                    style: PremiumTokens.sansStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      color: PremiumTokens.saffronGlow.withValues(alpha: 0.7),
                    ),
                  ),
                  const Spacer(),
                  Icon(Iconsax.arrow_right_3,
                      color: Colors.white24, size: 16),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                contextMotivation,
                style: GoogleFonts.spectral(
                  fontSize: 17,
                  color: Colors.white,
                  fontWeight: FontWeight.w300,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.05);
  }
}

// ─── Streak & Level Bar ────────────────────────────────────

class _StreakLevelBar extends ConsumerWidget {
  const _StreakLevelBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(userStatsProvider);
    final levelTier = ref.watch(spiritualityLevelProvider);
    final xpMult = ref.watch(xpMultiplierProvider);

    return statsAsync.when(
      data: (stats) {
        final level = stats?.level ?? 1;
        final xp = stats?.experiencePoints ?? 0;
        final streak = stats?.streakCount ?? 0;
        final xpForNext = SpiritualityEngine.xpForLevel(level);
        final progress = xpForNext > 0 ? (xp % xpForNext) / xpForNext : 0.0;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: PremiumUI.glassCard(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            borderRadius: 20,
            child: Row(
              children: [
                // Streak Fire
                StreakFireAnimation(streak: streak, isActive: streak > 0),

                const SizedBox(width: 16),
                Container(width: 1, height: 36, color: Colors.white10),
                const SizedBox(width: 16),

                // Level & XP Progress
                Expanded(
                  child: XPProgressBar(
                    progress: progress,
                    level: level,
                  ),
                ),

                // XP Multiplier badge
                if (xpMult > 1.0) ...[
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: PremiumTokens.saffronGlow.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${xpMult}x',
                      style: PremiumTokens.sansStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: PremiumTokens.saffronGlow,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ).animate().fadeIn(delay: 100.ms, duration: 400.ms);
      },
      loading: () => const SizedBox(height: 70),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

// ─── Daily Challenges Preview ──────────────────────────────

class _DailyChallengesPreview extends ConsumerWidget {
  const _DailyChallengesPreview();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challengesAsync = ref.watch(dailyChallengesProvider);

    return challengesAsync.when(
      data: (challenges) {
        if (challenges.isEmpty) return const SizedBox.shrink();
        final completed = challenges.where((c) => c.isCompleted).length;

        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const DailyChallengeScreen()));
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: PremiumUI.glassCard(
              padding: const EdgeInsets.all(16),
              borderRadius: 20,
              child: Row(
                children: [
                  const Text('⚡', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "TODAY'S CHALLENGES",
                          style: PremiumTokens.sansStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                            color: Colors.white54,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$completed/${challenges.length} completed',
                          style: GoogleFonts.manrope(
                            fontSize: 13,
                            color: completed == challenges.length
                                ? Colors.greenAccent
                                : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Mini progress circles
                  Row(
                    children: challenges.map((c) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: c.isCompleted
                                ? Colors.greenAccent
                                : Colors.white.withValues(alpha: 0.1),
                            border: Border.all(
                              color: c.isCompleted
                                  ? Colors.greenAccent
                                  : Colors.white.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Iconsax.arrow_right_3,
                      color: Colors.white24, size: 14),
                ],
              ),
            ),
          ),
        ).animate().fadeIn(delay: 200.ms, duration: 400.ms);
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

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
    ).animate().fadeIn(delay: 300.ms, duration: 400.ms);
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
        child: PremiumUI.glassCard(
          padding: const EdgeInsets.symmetric(vertical: 20),
          borderRadius: 20,
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 28)),
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

class _UpcomingEventsBanner extends ConsumerWidget {
  const _UpcomingEventsBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(upcomingEventsProvider);

    return eventsAsync.when(
      data: (events) {
        if (events.isEmpty) return const SizedBox.shrink();
        final nextEvent = events.first;
        final daysLeft = nextEvent.date.difference(DateTime.now()).inDays;

        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const SacredCalendarScreen()));
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: PremiumUI.etherealCard(
              padding: const EdgeInsets.all(16),
              borderRadius: 20,
              glowColor: Colors.orangeAccent.withValues(alpha: 0.15),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.orangeAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                        child: Text('🕉️', style: TextStyle(fontSize: 20))),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'UPCOMING ${nextEvent.type.toUpperCase()}',
                          style: PremiumTokens.sansStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                            color: Colors.orangeAccent.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          nextEvent.title,
                          style: GoogleFonts.manrope(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orangeAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      nextEvent.isToday
                          ? 'TODAY!'
                          : daysLeft == 1
                              ? 'TOMORROW'
                              : '${daysLeft}d LEFT',
                      style: PremiumTokens.sansStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Colors.orangeAccent,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ).animate().fadeIn(delay: 400.ms, duration: 400.ms);
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

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
          optimized: true,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('DAILY PROGRESS',
                          style: PremiumTokens.sansStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                            color: PremiumTokens.nebulaBlue
                                .withValues(alpha: 0.7),
                          )),
                      const SizedBox(height: 4),
                      Text('Sacred Counter',
                          style: GoogleFonts.spectral(
                            fontSize: 26,
                            color: Colors.white,
                            fontWeight: FontWeight.w300,
                          )),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('GOAL: 1008',
                        style: PremiumTokens.sansStyle(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        )),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Center(
                child: PremiumUI.naamJapCounter(
                  count: japState.total,
                  onTap: () {
                    ref.read(naamJapStateProvider.notifier).increment(context);
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
                      Icon(Iconsax.music_play,
                          color: Colors.white.withValues(alpha: 0.9),
                          size: 18),
                      const SizedBox(width: 12),
                      Text('EXPAND PLAYER',
                          style: PremiumTokens.sansStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                            color: Colors.white,
                          )),
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
            child: PremiumUI.saffronGlassCard(
              padding: EdgeInsets.zero,
              optimized: true,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: PremiumUI.networkImage(
                      url: cat['image']!,
                      borderRadius: BorderRadius.circular(24),
                      width: 200,
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
            context, MaterialPageRoute(builder: (_) => SearchScreen()));
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
