import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../core/design_system.dart';
import '../core/content_provider.dart';
import '../core/providers.dart';
import '../core/auth_provider.dart';
import 'content_detail_screen.dart';
import 'search_screen.dart';
import 'package:flutter/services.dart';
import '../core/favorites_provider.dart';
import '../core/audio_provider.dart';
import '../core/color_theme_provider.dart';
import '../widgets/animated_effects.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                // Personalized For You section
                SliverToBoxAdapter(child: RepaintBoundary(child: _buildForYouSection(context, ref))),
                SliverToBoxAdapter(child: RepaintBoundary(child: _buildCategoryFilterIndicator(context, ref))),
                SliverToBoxAdapter(child: RepaintBoundary(child: _buildNowPlaying(context, ref))),
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
              ],
            ),
          ),
        ],
      ),
    );
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
                        borderRadius: BorderRadius.circular(19),
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
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SearchScreen()),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: PremiumTokens.surfaceElevated.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
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
  /// Shows content from categories the user has favorited.
  Widget _buildForYouSection(BuildContext context, WidgetRef ref) {
    final allContent = ref.watch(sacredContentProvider);
    final favorites = ref.watch(favoritesProvider); // Set<String> of IDs
    final palette = ref.watch(colorPaletteProvider);
    final query = ref.watch(libraryCategoryProvider);

    // Don't show when a filter/search is active
    if (query != "ALL" || allContent.isEmpty) return const SizedBox.shrink();

    // Determine top categories from favorites, fallback to first 2 categories
    final favoriteItems = allContent.where((c) => favorites.contains(c.id)).toList();
    final Set<String> preferredCategories = favoriteItems
        .map((c) => c.category)
        .toSet()
        .take(3)
        .toSet();

    // If no favorites yet, pick the top 2 categories by count
    final List<SacredContent> forYouItems;
    if (preferredCategories.isEmpty) {
      forYouItems = allContent.take(8).toList();
    } else {
      forYouItems = allContent
          .where((c) => preferredCategories.contains(c.category))
          .take(8)
          .toList();
    }

    if (forYouItems.isEmpty) return const SizedBox.shrink();

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
                favorites.isEmpty ? "DISCOVER" : "FOR YOU",
                style: PremiumTokens.sansStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: PremiumTokens.textPrimary,
                  letterSpacing: 2.5,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                favorites.isEmpty ? "Popular picks" : "Based on your favorites",
                style: PremiumTokens.sansStyle(
                  fontSize: 10,
                  color: PremiumTokens.textMuted,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 120,
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
                  HapticFeedback.lightImpact();
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
                    borderRadius: BorderRadius.circular(16),
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
                    children: [
                      PremiumUI.categoryBadge(item.category, fontSize: 10),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Text(
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
                      ),
                      if (item.author != null)
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
              borderRadius: BorderRadius.circular(12),
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
                    HapticFeedback.lightImpact();
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
        borderRadius: 16,
        child: Row(
          children: [
            SizedBox(
              width: 48,
              height: 48,
              child: PremiumUI.networkImage(
                url: currentTrack.displayImageUrl,
                width: 48,
                height: 48,
                borderRadius: BorderRadius.circular(8),
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
            GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
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
      height: 220,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: PressableScale(
          onTap: () {
            HapticFeedback.lightImpact();
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
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // 1. Full-bleed background artwork
                  Positioned.fill(
                    child: PremiumUI.networkImage(
                      url: item.displayImageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),

                  // 2. Adaptive gradient overlay for text readability matching current mood theme
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            PremiumTokens.surfaceMain.withValues(alpha: 0.15),
                            PremiumTokens.surfaceMain.withValues(alpha: 0.75),
                            PremiumTokens.surfaceMain.withValues(alpha: 0.96),
                          ],
                          stops: const [0.0, 0.45, 0.9],
                        ),
                      ),
                    ),
                  ),

                  // 3. Card Content
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Left/Main metadata details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                            fontSize: 12,
                                            fontWeight: FontWeight.w900,
                                            color: PremiumTokens.saffronGlow,
                                          ).copyWith(letterSpacing: 1.2),
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
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: PremiumTokens.textSecondary,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              const SizedBox(height: 2),
                              Text(
                                item.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: PremiumTokens.hindiAwareStyle(
                                  item.title,
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                  color: PremiumTokens.textPrimary,
                                  isSacred: true,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.commentary.startsWith('http') ? 'Sacred Verse Details' : item.commentary,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: PremiumTokens.hindiAwareStyle(
                                  item.commentary,
                                  fontSize: 11,
                                  color: PremiumTokens.textSecondary,
                                ),
                              ),
                              const Spacer(),
                              Row(
                                children: [
                                  if (item.audioUrl != null && item.audioUrl!.isNotEmpty) ...[
                                    Icon(Icons.schedule, color: PremiumTokens.textSecondary, size: 10),
                                    const SizedBox(width: 4),
                                    Text("10:45", style: PremiumTokens.sansStyle(fontSize: 12, color: PremiumTokens.textSecondary)),
                                    const SizedBox(width: 8),
                                  ] else ...[
                                    Icon(Icons.auto_stories, color: PremiumTokens.textSecondary, size: 10),
                                    const SizedBox(width: 4),
                                    Text(
                                      (item.chapter ?? "READ").toUpperCase(),
                                      style: PremiumTokens.sansStyle(fontSize: 12, color: PremiumTokens.textSecondary, letterSpacing: 1.0),
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: PremiumTokens.borderSubtle.withValues(alpha: 0.3),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: PremiumTokens.borderSubtle),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(item.categoryIcon, size: 10, color: PremiumTokens.textSecondary),
                                        const SizedBox(width: 4),
                                        Text(
                                          item.category.toUpperCase(),
                                          style: PremiumTokens.sansStyle(fontSize: 10, fontWeight: FontWeight.w900, color: PremiumTokens.textSecondary, letterSpacing: 0.5),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (item.contentTags.isNotEmpty)
                                    Expanded(
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        physics: const NeverScrollableScrollPhysics(),
                                        child: Row(
                                          children: [
                                            const SizedBox(width: 8),
                                            ...item.contentTags.take(2).map((tag) => Container(
                                              margin: const EdgeInsets.only(right: 4),
                                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: PremiumTokens.borderSubtle.withValues(alpha: 0.3),
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(color: PremiumTokens.borderSubtle),
                                              ),
                                              child: Text(
                                                tag.toUpperCase(),
                                                style: PremiumTokens.sansStyle(fontSize: 10, fontWeight: FontWeight.bold, color: PremiumTokens.textSecondary, letterSpacing: 0.5),
                                              ),
                                            )),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Right Actions column
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            PremiumUI.animatedIcon(
                              folder: 'Heart',
                              fileName: 'heart.json',
                              size: 24,
                              color: ref.watch(isFavoriteProvider(item.id)) ? PremiumTokens.saffronGlow : PremiumTokens.textSecondary,
                              isToggled: ref.watch(isFavoriteProvider(item.id)),
                              resetAfterPlay: false,
                              onTap: () {
                                HapticFeedback.lightImpact();
                                ref.read(favoritesProvider.notifier).toggleFavorite(item.id);
                              },
                            ),
                            const SizedBox(height: 20),
                            if (item.audioUrl != null && item.audioUrl!.isNotEmpty)
                              GestureDetector(
                                onTap: () {
                                  HapticFeedback.heavyImpact();
                                  ref.read(audioProvider.notifier).playWithPlaylist(item, playlist);
                                },
                                child: Container(
                                  width: 44,
                                  height: 44,
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
                                    size: 22,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
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

