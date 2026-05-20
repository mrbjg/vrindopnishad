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

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background handled by Master Layer
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: RepaintBoundary(child: _buildHeader(context))),
                SliverToBoxAdapter(child: RepaintBoundary(child: _buildSearchBar(context, ref))),
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
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 120), // Extra bottom padding for FAB
                      sliver: SliverFixedExtentList(
                        itemExtent: 156.0,
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: SizedBox(
        width: double.infinity, // Robust bounding
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
                  child: Icon(Iconsax.close_circle, size: 14, color: PremiumTokens.activeAccent),
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
                url: currentTrack.imageUrl ?? 'assets/vaani_icon.png',
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
    // ATOMIC SELECTION: Only rebuilds when THIS item's specific playing status changes
    final isPlaying = ref.watch(audioProvider.select((s) => 
      s.isPlaying && s.currentContent?.id == item.id
    ));

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
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
          padding: const EdgeInsets.all(16),
          borderColor: isPlaying 
              ? PremiumTokens.activeAccent.withValues(alpha: 0.3) 
              : PremiumTokens.borderSubtle,
          child: Row(
            children: [
              // Enclaved Status Icon (Music vs. Book)
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isPlaying 
                      ? PremiumTokens.activeAccent.withValues(alpha: 0.1) 
                      : PremiumTokens.borderSubtle,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isPlaying 
                        ? PremiumTokens.activeAccent.withValues(alpha: 0.2) 
                        : PremiumTokens.borderSubtle,
                  ),
                ),
                child: Center(
                  child: Icon(
                    isPlaying 
                      ? Iconsax.music_play5 
                      : (item.audioUrl != null && item.audioUrl!.isNotEmpty 
                          ? Iconsax.music 
                          : Iconsax.book_1),
                    color: isPlaying ? PremiumTokens.activeAccent : PremiumTokens.textMuted,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Enriched Content Info
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
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    color: PremiumTokens.saffronGlow.withValues(alpha: 0.8),
                                  ).copyWith(letterSpacing: 1.2),
                                ),
                             ),
                          if (item.author != null && item.book != null)
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: 3,
                              height: 3,
                              decoration: BoxDecoration(shape: BoxShape.circle, color: PremiumTokens.textMuted),
                            ),
                          if (item.book != null)
                            Expanded(
                              child: Text(
                                item.book!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: PremiumTokens.hindiAwareStyle(
                                  item.book!,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: PremiumTokens.textMuted,
                                ),
                              ),
                            ),
                        ],
                      ),
                    const SizedBox(height: 2),
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: PremiumTokens.hindiAwareStyle(
                        item.title,
                        fontSize: 16,
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
                        color: PremiumTokens.textMuted,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        if (item.audioUrl != null && item.audioUrl!.isNotEmpty) ...[
                          Icon(Icons.schedule, color: PremiumTokens.textMuted, size: 10),
                          const SizedBox(width: 4),
                          Text(
                            "10:45",
                            style: PremiumTokens.sansStyle(fontSize: 10, color: PremiumTokens.textMuted),
                          ),
                          const SizedBox(width: 8),
                        ] else ...[
                          Icon(Icons.auto_stories, color: PremiumTokens.textMuted, size: 10),
                          const SizedBox(width: 4),
                          Text(
                            (item.chapter ?? "READ").toUpperCase(),
                            style: PremiumTokens.sansStyle(fontSize: 10, color: PremiumTokens.textMuted, letterSpacing: 1.0),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: PremiumTokens.borderSubtle,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: PremiumTokens.borderSubtle),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                item.categoryIcon,
                                size: 10,
                                color: PremiumTokens.textMuted,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                item.category.toUpperCase(),
                                style: PremiumTokens.sansStyle(
                                  fontSize: 8, 
                                  fontWeight: FontWeight.w900,
                                  color: PremiumTokens.textMuted,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (item.contentTags.isNotEmpty)
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              physics: const NeverScrollableScrollPhysics(), // Keep it passive, or remove and allow scroll
                              child: Row(
                                children: [
                                  const SizedBox(width: 8),
                                  ...item.contentTags.take(3).map((tag) => Container(
                                    margin: const EdgeInsets.only(right: 4),
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: PremiumTokens.borderSubtle,
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: PremiumTokens.borderSubtle),
                                    ),
                                    child: Text(
                                      tag.toUpperCase(),
                                      style: PremiumTokens.sansStyle(
                                        fontSize: 8, 
                                        fontWeight: FontWeight.bold,
                                        color: PremiumTokens.textMuted,
                                        letterSpacing: 0.5,
                                      ),
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
              
              // Interaction Column
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  PremiumUI.animatedIcon(
                    folder: 'Heart',
                    fileName: 'heart.json',
                    size: 20,
                    color: ref.watch(isFavoriteProvider(item.id)) ? PremiumTokens.saffronGlow : PremiumTokens.textMuted,
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
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isPlaying 
                                ? PremiumTokens.activeAccent.withValues(alpha: 0.1) 
                                : PremiumTokens.borderSubtle,
                            border: Border.all(
                              color: isPlaying 
                                  ? PremiumTokens.activeAccent.withValues(alpha: 0.3) 
                                  : PremiumTokens.borderMedium
                            ),
                          ),
                          child: Icon(
                            isPlaying ? Iconsax.pause : Icons.play_arrow, 
                            color: isPlaying ? PremiumTokens.activeAccent : PremiumTokens.textPrimary, 
                            size: 18
                          ),
                        ),
                      ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
