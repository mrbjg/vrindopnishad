import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../core/design_system.dart';
import '../core/content_provider.dart';
import '../core/providers.dart';
import '../core/auth_provider.dart';
import 'content_detail_screen.dart';
import 'search_screen.dart';
import 'saint_detail_screen.dart';
import 'book_detail_screen.dart';
import 'raga_detail_screen.dart';
import 'package:flutter/services.dart';
import '../core/favorites_provider.dart';
import '../core/audio_provider.dart';
import '../core/color_theme_provider.dart';
import '../widgets/animated_effects.dart';
import '../core/personalized_feed_provider.dart';
import '../core/mood_theme_provider.dart';

final libraryTabProvider = StateProvider<int>((ref) => 0);

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    PremiumTokens.of(context);
    final activeTab = ref.watch(libraryTabProvider);
    ref.watch(themeProvider);
    ref.watch(colorPaletteProvider);
    ref.watch(moodThemeProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: RepaintBoundary(child: _buildHeader(context))),
                SliverToBoxAdapter(child: RepaintBoundary(child: _buildSearchBar(context, ref))),
                SliverToBoxAdapter(child: RepaintBoundary(child: _buildLibraryTabs(context, ref))),
                SliverToBoxAdapter(child: RepaintBoundary(child: _buildNowPlaying(context, ref))),

                if (activeTab == 0) ...[
                  SliverToBoxAdapter(child: RepaintBoundary(child: _buildForYouSection(context, ref))),
                  SliverToBoxAdapter(child: RepaintBoundary(child: _buildCategoryFilterIndicator(context, ref))),
                  Consumer(
                    builder: (context, ref, child) {
                      final content = ref.watch(sacredContentProvider);
                      final query = ref.watch(libraryCategoryProvider);
                      final List<SacredContent> items;

                      if (query.startsWith("SEARCH:")) {
                        items = ref.watch(searchedContentProvider(query.replaceFirst("SEARCH:", "")));
                      } else if (query == "ALL") {
                        items = content;
                      } else {
                        items = ref.watch(filteredContentProvider(query));
                      }

                      return SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 180),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              return RepaintBoundary(
                                child: _buildLibraryItem(context, ref, items[index], items),
                              );
                            },
                            childCount: items.length,
                          ),
                        ),
                      );
                    },
                  ),
                ] else if (activeTab == 1) ...[
                  _buildSaintsTab(context, ref),
                ] else if (activeTab == 2) ...[
                  _buildBooksTab(context, ref),
                ] else if (activeTab == 3) ...[
                  _buildRagasTab(context, ref),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLibraryTabs(BuildContext context, WidgetRef ref) {
    final activeTab = ref.watch(libraryTabProvider);
    final tabs = ["Verses", "Saints", "Granthas", "Ragas"];
    final palette = ref.watch(colorPaletteProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final slotWidth = width / tabs.length;
          const double marginVal = 4.0;
          const double heightVal = 48.0;
          const double capsuleHeight = heightVal - (marginVal * 2);
          final capsuleWidth = slotWidth - (marginVal * 2);

          return Container(
            height: heightVal,
            decoration: BoxDecoration(
              color: PremiumTokens.surfaceElevated.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: PremiumTokens.borderSubtle),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  // Sliding Background Capsule
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutBack,
                    left: (activeTab * slotWidth) + marginVal,
                    top: marginVal,
                    width: capsuleWidth,
                    height: capsuleHeight,
                    child: Container(
                      decoration: BoxDecoration(
                        color: palette.accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  
                  // Interactive Tab Items
                  Positioned.fill(
                    child: Row(
                      children: List.generate(tabs.length, (index) {
                        final isSelected = activeTab == index;
                        return Expanded(
                          child: PressableScale(
                            onTap: () {
                              AppHapticFeedback.lightImpact();
                              ref.read(libraryTabProvider.notifier).state = index;
                            },
                            child: Container(
                              alignment: Alignment.center,
                              color: Colors.transparent, // Ensures entire slot is tap-target
                              child: AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 200),
                                style: PremiumTokens.sansStyle(
                                  fontSize: 10,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: isSelected ? palette.accent : PremiumTokens.textSecondary,
                                  letterSpacing: 0.8,
                                ),
                                child: Text(
                                  tabs[index].toUpperCase(),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSaintsTab(BuildContext context, WidgetRef ref) {
    final saints = ref.watch(saintsProvider);
    if (saints.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 80),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 180),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 20,
          childAspectRatio: 0.8,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final saint = saints[index];
            final h = saint.hashCode.abs();
            final avatarUrl = [
              'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?auto=format&fit=crop&w=300&q=80',
              'https://images.unsplash.com/photo-1470813740244-df37b8c1edcb?auto=format&fit=crop&w=300&q=80',
              'https://images.unsplash.com/photo-1518241353330-0f7941c2d9b5?auto=format&fit=crop&w=300&q=80',
              'https://images.unsplash.com/photo-1506126613408-eca07ce68773?auto=format&fit=crop&w=300&q=80',
            ][h % 4];

            return PressableScale(
              onTap: () {
                AppHapticFeedback.lightImpact();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SaintDetailScreen(saintName: saint),
                  ),
                );
              },
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: PremiumTokens.borderMedium,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: PremiumUI.networkImage(
                          url: avatarUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    saint,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: PremiumTokens.hindiAwareStyle(
                      saint,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: PremiumTokens.textPrimary,
                    ),
                  ),
                ],
              ),
            );
          },
          childCount: saints.length,
        ),
      ),
    );
  }

  Widget _buildBooksTab(BuildContext context, WidgetRef ref) {
    final books = ref.watch(booksProvider);
    if (books.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 80),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 180),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.72,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final book = books[index];
            final h = book.hashCode.abs();
            final coverUrl = [
              'https://images.unsplash.com/photo-1544947950-fa07a98d237f?auto=format&fit=crop&w=400&q=80',
              'https://images.unsplash.com/photo-1512820790803-83ca734da794?auto=format&fit=crop&w=400&q=80',
              'https://images.unsplash.com/photo-1476275466078-4007374efbbe?auto=format&fit=crop&w=400&q=80',
              'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&w=400&q=80',
            ][h % 4];

            return PressableScale(
              onTap: () {
                AppHapticFeedback.lightImpact();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BookDetailScreen(bookName: book),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: PremiumTokens.borderSubtle),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      PremiumUI.networkImage(
                        url: coverUrl,
                        fit: BoxFit.cover,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.5),
                              Colors.black.withValues(alpha: 0.85),
                            ],
                            stops: const [0.5, 0.8, 1.0],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 12,
                        right: 12,
                        bottom: 12,
                        child: Text(
                          book,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: PremiumTokens.hindiAwareStyle(
                            book,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          childCount: books.length,
        ),
      ),
    );
  }

  Widget _buildRagasTab(BuildContext context, WidgetRef ref) {
    final ragas = ref.watch(ragasProvider);
    final palette = ref.watch(colorPaletteProvider);

    if (ragas.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 80),
          child: Center(
            child: Text("No ragas found in the database."),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 180),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final raga = ragas[index];
            final count = ref.watch(contentByRagaProvider(raga)).length;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: PressableScale(
                onTap: () {
                  AppHapticFeedback.lightImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RagaDetailScreen(ragaName: raga),
                    ),
                  );
                },
                child: PremiumUI.relicStaticCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: palette.accent.withValues(alpha: 0.1),
                          border: Border.all(color: palette.accent.withValues(alpha: 0.2)),
                        ),
                        child: Icon(Iconsax.music, color: palette.accent, size: 20),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              raga,
                              style: PremiumTokens.sansStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: PremiumTokens.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getRagaTime(raga),
                              style: PremiumTokens.sansStyle(
                                fontSize: 11,
                                color: PremiumTokens.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: PremiumTokens.borderSubtle,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          "$count Track${count == 1 ? '' : 's'}",
                          style: PremiumTokens.sansStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: PremiumTokens.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          childCount: ragas.length,
        ),
      ),
    );
  }

  String _getRagaTime(String raga) {
    final lower = raga.toLowerCase().trim();
    if (lower.contains('yaman')) return 'Evening Prahar';
    if (lower.contains('bhairavi')) return 'Morning Prahar';
    if (lower.contains('bhairav')) return 'Early Morning Prahar';
    if (lower.contains('darbari')) return 'Late Night Prahar';
    if (lower.contains('sarang') || lower.contains('vrindavani')) return 'Afternoon Prahar';
    if (lower.contains('desh')) return 'Night Prahar';
    return 'Universal Prahar';
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: SizedBox(
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Iconsax.element_plus, color: PremiumTokens.textMuted, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "SANT-VAANI",
                    style: PremiumTokens.sansStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 4,
                    ),
                  ),
                  Text(
                    "SACRED LIBRARY",
                    style: PremiumTokens.sansStyle(
                      fontSize: 10,
                      color: PremiumTokens.textMuted,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Consumer(
              builder: (context, ref, child) {
                final user = ref.watch(authStateProvider).value;
                return Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: PremiumTokens.surfaceElevated,
                    border: Border.all(color: PremiumTokens.borderSubtle),
                  ),
                  child: user?.photoURL != null 
                    ? PremiumUI.networkImage(
                        url: user!.photoURL!,
                        borderRadius: BorderRadius.circular(100),
                      )
                    : Icon(
                        Iconsax.user,
                        color: PremiumTokens.textMuted,
                        size: 20,
                      ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: PressableScale(
        onTap: () {
          AppHapticFeedback.lightImpact();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SearchScreen()),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: PremiumTokens.surfaceElevated.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: PremiumTokens.borderSubtle),
          ),
          child: Row(
            children: [
              Icon(Iconsax.search_normal, color: PremiumTokens.textMuted, size: 20),
              const SizedBox(width: 12),
              Text(
                "Search sacred mantras...",
                style: PremiumTokens.sansStyle(color: PremiumTokens.textHint, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Personalized "For You" horizontal scroll section.
  /// Shows content from categories the user has interacted with or favorited.
  Widget _buildForYouSection(BuildContext context, WidgetRef ref) {
    final forYouItems = ref.watch(categoryRecommendationsProvider);
    final affinity = ref.watch(userAffinityProvider);
    final favorites = ref.watch(favoritesProvider);
    final palette = ref.watch(colorPaletteProvider);
    final query = ref.watch(libraryCategoryProvider);

    // Don't show when a filter/search is active
    if (query != "ALL" || forYouItems.isEmpty) return const SizedBox.shrink();

    final bool hasAffinity = favorites.isNotEmpty || affinity.readContentIds.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: Row(
            children: [
              Container(
                width: 3,
                height: 14,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [palette.accent, palette.accentDark],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                !hasAffinity ? "DISCOVER" : "FOR YOU",
                style: PremiumTokens.sansStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: PremiumTokens.textPrimary,
                  letterSpacing: 2.5,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                !hasAffinity ? "Popular picks" : "Based on your preferences",
                style: PremiumTokens.sansStyle(
                  fontSize: 10,
                  color: PremiumTokens.textMuted,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 155,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: forYouItems.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final item = forYouItems[index];
              return PressableScale(
                onTap: () {
                  AppHapticFeedback.lightImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ContentDetailScreen(content: item),
                    ),
                  );
                },
                child: Container(
                  width: 160,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: PremiumTokens.surfaceMain.withValues(alpha: 0.7),
                    border: Border.all(
                      color: palette.accent.withValues(alpha: 0.14),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: palette.glow.withValues(alpha: 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      PremiumUI.categoryBadge(item.category, fontSize: 10),
                      const SizedBox(height: 8),
                      Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: PremiumTokens.hindiAwareStyle(
                          item.title,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: PremiumTokens.textPrimary,
                        ),
                      ),
                      if (item.author != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          item.author!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: PremiumTokens.sansStyle(
                            fontSize: 9,
                            color: PremiumTokens.saffronGlow.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 1,
                  color: PremiumTokens.borderSubtle,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  "ALL CONTENT",
                  style: PremiumTokens.sansStyle(
                    fontSize: 9,
                    color: PremiumTokens.textMuted,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 1,
                  color: PremiumTokens.borderSubtle,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildCategoryFilterIndicator(BuildContext context, WidgetRef ref) {
    final query = ref.watch(libraryCategoryProvider);
    if (query == "ALL" || query.startsWith("SEARCH:")) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: PremiumTokens.activeAccent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: PremiumTokens.activeAccent.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "FILTER: ${query.toUpperCase()}",
                  style: PremiumTokens.sansStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                    color: PremiumTokens.activeAccent,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    AppHapticFeedback.lightImpact();
                    ref.read(libraryCategoryProvider.notifier).state = "ALL";
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    child: Icon(Iconsax.close_circle, size: 14, color: PremiumTokens.activeAccent),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNowPlaying(BuildContext context, WidgetRef ref) {
    final audioState = ref.watch(audioProvider);
    final currentTrack = audioState.currentContent;
    
    if (currentTrack == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: PremiumUI.voidGlassCard(
        padding: const EdgeInsets.all(12),
        borderRadius: 24,
        child: Row(
          children: [
            SizedBox(
              width: 48,
              height: 48,
              child: PremiumUI.networkImage(
                url: currentTrack.displayImageUrl,
                width: 48,
                height: 48,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    audioState.isPlaying ? "NOW PLAYING" : "PAUSED",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: PremiumTokens.sansStyle(
                      fontSize: 10,
                      color: audioState.isPlaying 
                          ? PremiumTokens.activeAccent 
                          : PremiumTokens.textMuted,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    currentTrack.title,
                    style: PremiumTokens.sansStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Play/Pause Action
            PressableScale(
              onTap: () {
                AppHapticFeedback.mediumImpact();
                ref.read(audioProvider.notifier).togglePlayPause();
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: PremiumTokens.borderSubtle,
                ),
                child: Icon(
                  audioState.isPlaying ? Iconsax.pause5 : Iconsax.play5,
                  color: PremiumTokens.activeAccent,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLibraryItem(BuildContext context, WidgetRef ref, SacredContent item, List<SacredContent> playlist) {
    final isPlaying = ref.watch(audioProvider.select((s) =>
      s.isPlaying && s.currentContent?.id == item.id
    ));

    return SizedBox(
      height: 265, // Increased height for split layout safety
      child: Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: PressableScale(
          onTap: () {
            AppHapticFeedback.lightImpact();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ContentDetailScreen(content: item),
              ),
            );
          },
          child: PremiumUI.relicStaticCard(
            padding: EdgeInsets.zero,
            borderColor: isPlaying
                ? PremiumTokens.activeAccent.withValues(alpha: 0.3)
                : PremiumTokens.borderSubtle,
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
                        // Dark overlay gradient for depth
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
                        // Match percentage / resonance badge overlay
                        Consumer(
                          builder: (context, ref, child) {
                            final match = ref.watch(matchPercentageProvider(item));
                            return Positioned(
                              right: 12,
                              top: 12,
                              child: PremiumUI.resonanceBadge("$match% RESONANCE", fontSize: 8),
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
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          // Left Details Text Column
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (item.author != null || item.book != null)
                                  Row(
                                    children: [
                                      if (item.author != null)
                                        Flexible(
                                          child: Text(
                                            item.author!,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: PremiumTokens.hindiAwareStyle(
                                              item.author!,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w900,
                                              color: PremiumTokens.saffronGlow,
                                            ).copyWith(letterSpacing: 1.0),
                                          ),
                                        ),
                                      if (item.author != null && item.book != null)
                                        Container(
                                          margin: const EdgeInsets.symmetric(horizontal: 4),
                                          width: 3,
                                          height: 3,
                                          decoration: BoxDecoration(shape: BoxShape.circle, color: PremiumTokens.textSecondary),
                                        ),
                                      if (item.book != null)
                                        Expanded(
                                          child: Text(
                                            item.book!,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: PremiumTokens.hindiAwareStyle(
                                              item.book!,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: PremiumTokens.textSecondary,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                const SizedBox(height: 4),
                                Text(
                                  item.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: PremiumTokens.hindiAwareStyle(
                                    item.title,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: PremiumTokens.textPrimary,
                                    isSacred: true,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  item.commentary.startsWith('http') ? 'Sacred Verse Details' : item.commentary,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: PremiumTokens.hindiAwareStyle(
                                    item.commentary,
                                    fontSize: 10,
                                    color: PremiumTokens.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    if (item.audioUrl != null && item.audioUrl!.isNotEmpty) ...[
                                      Icon(Icons.schedule, color: PremiumTokens.textSecondary, size: 10),
                                      const SizedBox(width: 4),
                                      Text("10:45", style: PremiumTokens.sansStyle(fontSize: 10, color: PremiumTokens.textSecondary)),
                                      const SizedBox(width: 8),
                                    ] else ...[
                                      Icon(Icons.auto_stories, color: PremiumTokens.textSecondary, size: 10),
                                      const SizedBox(width: 4),
                                      Text(
                                        (item.chapter ?? "READ").toUpperCase(),
                                        style: PremiumTokens.sansStyle(fontSize: 10, color: PremiumTokens.textSecondary, letterSpacing: 0.5),
                                      ),
                                      const SizedBox(width: 8),
                                    ],
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: PremiumTokens.borderSubtle.withValues(alpha: 0.3),
                                        borderRadius: BorderRadius.circular(100),
                                        border: Border.all(color: PremiumTokens.borderSubtle),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(item.categoryIcon, size: 9, color: PremiumTokens.textSecondary),
                                          const SizedBox(width: 3),
                                          Text(
                                            item.category.toUpperCase(),
                                            style: PremiumTokens.sansStyle(fontSize: 9, fontWeight: FontWeight.w900, color: PremiumTokens.textSecondary, letterSpacing: 0.5),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Right Actions Column
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              PremiumUI.animatedIcon(
                                folder: 'Heart',
                                fileName: 'heart.json',
                                size: 22,
                                color: ref.watch(isFavoriteProvider(item.id)) ? PremiumTokens.saffronGlow : PremiumTokens.textSecondary,
                                isToggled: ref.watch(isFavoriteProvider(item.id)),
                                resetAfterPlay: false,
                                onTap: () {
                                  AppHapticFeedback.lightImpact();
                                  ref.read(favoritesProvider.notifier).toggleFavorite(item.id);
                                },
                              ),
                              if (item.audioUrl != null && item.audioUrl!.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                GestureDetector(
                                  onTap: () {
                                    AppHapticFeedback.heavyImpact();
                                    ref.read(audioProvider.notifier).playWithPlaylist(item, playlist);
                                  },
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isPlaying
                                          ? PremiumTokens.activeAccent.withValues(alpha: 0.15)
                                          : PremiumTokens.borderSubtle.withValues(alpha: 0.4),
                                      border: Border.all(
                                        color: isPlaying
                                            ? PremiumTokens.activeAccent
                                            : PremiumTokens.borderMedium,
                                      ),
                                    ),
                                    child: Icon(
                                      isPlaying ? Iconsax.pause : Icons.play_arrow,
                                      color: isPlaying ? PremiumTokens.activeAccent : PremiumTokens.textPrimary,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ],
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

