import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/design_system.dart';
import '../core/providers.dart';
import '../core/spirituality_provider.dart';
import '../core/stats_provider.dart';
import '../core/auth_provider.dart';
import '../core/audio_provider.dart';
import '../core/content_provider.dart';
import 'search_screen.dart';
import 'daily_motivation_screen.dart';
import 'daily_gyaan_screen.dart';
import 'sacred_calendar_screen.dart';
import 'category_list_screen.dart';
import 'rituals_screen.dart';
import 'profile_screen.dart';

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
                        child: PremiumUI.logo(height: 28)
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
                    RepaintBoundary(child: _PremiumNaamJapSection()),
                    _QuickActionsGrid(),
                  ],
                ),
              ),




              // 7-9. Consolidated Legacy Content (Performance Optimization)
              const SliverToBoxAdapter(
                child: Column(
                  children: [
                    _CategoriesHeader(),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: _CategoriesGridLite(),
                    ),
                    _RecentReflectionPreviewLite(),
                    Padding(
                      padding: EdgeInsets.fromLTRB(20, 32, 20, 180),
                      child: _PremiumContentListLite(),
                    ),
                  ],
                ),
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
        child: PremiumUI.voidCard(
          padding: const EdgeInsets.all(28),
          borderRadius: 24,
          accentColor: PremiumTokens.etherealBlue,
          child: Center(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    EmojiToIcon.getIconWidget('🌅',
                        size: 14, color: PremiumTokens.textMuted),
                    const SizedBox(width: 8),
                    Text(
                      'CELESTIAL INSIGHT',
                      style: PremiumTokens.sansStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 3,
                        color: PremiumTokens.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  contextMotivation,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.spectral(
                    fontSize: 18,
                    color: PremiumTokens.textPrimary,
                    fontWeight: FontWeight.w300,
                    height: 1.6,
                    fontStyle: FontStyle.italic,
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
            emoji: '📚',
            label: 'Gyaan',
            color: PremiumTokens.textPrimary,
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const DailyGyaanScreen())),
          ),
          const SizedBox(width: 12),
          _QuickActionTile(
            emoji: '📅',
            label: 'Calendar',
            color: PremiumTokens.textPrimary,
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const SacredCalendarScreen())),
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
        child: PremiumUI.relicCard(
          padding: const EdgeInsets.symmetric(vertical: 24),
          borderRadius: 4, // Subtle rounding for a "watchmaker" feel
          child: Column(
            children: [
              Icon(
                label == 'Gyaan' ? Iconsax.teacher : Iconsax.calendar,
                size: 24,
                color: PremiumTokens.textMuted,
              ),
              const SizedBox(height: 12),
              Text(
                label.toUpperCase(),
                style: PremiumTokens.sansStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                  color: PremiumTokens.textSecondary,
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
        child: GestureDetector(
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
                      borderRadius: BorderRadius.circular(12),
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
    final categories = ref.watch(sacredCategoriesProvider);
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
                        colors: [PremiumTokens.scaffoldBg.withValues(alpha: 0.87), Colors.transparent],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 12, left: 12, right: 12,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(cat.name, style: GoogleFonts.manrope(color: PremiumTokens.textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
                        Text('${cat.count} Items', style: GoogleFonts.manrope(color: PremiumTokens.textMuted, fontSize: 10)),
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



class _PremiumContentListLite extends ConsumerWidget {
  const _PremiumContentListLite();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.watch(sacredContentProvider);
    final visibleCount = ref.watch(visibleItemCountProvider);
    final items = content.take(visibleCount).toList();

    return Column(
      children: items.map((item) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: GestureDetector(
          onTap: () {
            HapticFeedback.heavyImpact();
            // Pass the featured items as the playlist
            ref.read(audioProvider.notifier).playWithPlaylist(item, items);
          },
          child: PremiumUI.relicStaticCard(
            padding: const EdgeInsets.all(20),
            borderColor: PremiumTokens.borderSubtle,
            child: Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: PremiumTokens.borderSubtle,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: PremiumTokens.borderSubtle),
                  ),
                  child: Center(child: Text('ॐ', style: TextStyle(color: PremiumTokens.textPrimary, fontSize: 20))),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title, style: PremiumTokens.sansStyle(color: PremiumTokens.textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 4),
                      Text(item.category.toUpperCase(), style: PremiumTokens.sansStyle(color: PremiumTokens.textMuted, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
                    ],
                  ),
                ),
                Icon(Iconsax.arrow_right_3, color: PremiumTokens.textMuted, size: 14),
              ],
            ),
          ),
        ),
      )).toList(),
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
      child: Icon(Iconsax.search_normal,
          color: PremiumTokens.activeAccent, size: 22),
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
    final user = ref.watch(authStateProvider).value;
    final photoUrl = user?.photoURL;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context, 
          MaterialPageRoute(builder: (_) => const ProfileScreen())
        );
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
                borderRadius: BorderRadius.circular(15),
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
