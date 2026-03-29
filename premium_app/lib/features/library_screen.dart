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
                SliverToBoxAdapter(child: _buildHeader()),
                SliverToBoxAdapter(child: _buildSearchBar(context, ref)),
                SliverToBoxAdapter(child: _buildCategoryFilterIndicator(context, ref)),
                SliverToBoxAdapter(child: _buildNowPlaying()),
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
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 120), // Extra bottom padding for FAB
                      sliver: SliverFixedExtentList(
                        itemExtent: 156.0,
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return _buildLibraryItem(context, ref, items[index], items);
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: SizedBox(
        width: double.infinity, // Robust bounding
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Iconsax.element_plus, color: PremiumTokens.celestialSilver.withValues(alpha: 0.4), size: 24),
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
                      color: PremiumTokens.celestialSilver.withValues(alpha: 0.4),
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
                    color: PremiumTokens.surfaceCharcoal,
                    border: Border.all(color: PremiumTokens.celestialSilver.withValues(alpha: 0.1)),
                  ),
                  child: user?.photoURL != null 
                    ? PremiumUI.networkImage(
                        url: user!.photoURL!,
                        borderRadius: BorderRadius.circular(19),
                      )
                    : const Icon(
                        Iconsax.user,
                        color: PremiumTokens.celestialSilver,
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
      padding: const EdgeInsets.symmetric(horizontal: 24),
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
            color: PremiumTokens.surfaceCharcoal.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: PremiumTokens.celestialSilver.withValues(alpha: 0.1)),
          ),
          child: Row(
            children: [
              const Icon(Iconsax.search_normal, color: PremiumTokens.celestialSilver, size: 20),
              const SizedBox(width: 12),
              Text(
                "Search sacred mantras...",
                style: PremiumTokens.sansStyle(color: Colors.white24, fontSize: 14),
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
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: PremiumTokens.nebulaBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: PremiumTokens.nebulaBlue.withValues(alpha: 0.2)),
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
                    color: PremiumTokens.nebulaBlue,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    ref.read(libraryCategoryProvider.notifier).state = "ALL";
                  },
                  child: const Icon(Iconsax.close_circle, size: 14, color: PremiumTokens.nebulaBlue),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNowPlaying() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: PremiumUI.voidGlassCard(
        padding: const EdgeInsets.all(12),
        borderRadius: 16,
        child: Row(
          children: [
            SizedBox(
              width: 48,
              height: 48,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  'https://santvaani.app/logo.png', // Stable fallback
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: PremiumTokens.surfaceCharcoal,
                    child: const Icon(Iconsax.music, color: PremiumTokens.celestialSilver, size: 20),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "NOW PLAYING",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: PremiumTokens.sansStyle(
                      fontSize: 10,
                      color: PremiumTokens.celestialSilver.withValues(alpha: 0.4),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Gayatri Mantra (Divine Peace)",
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
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: PremiumTokens.celestialSilver.withValues(alpha: 0.1),
              ),
              child: PremiumUI.animatedIcon(
                folder: 'Refresh',
                fileName: 'refresh.json',
                size: 24,
                color: PremiumTokens.celestialSilver,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLibraryItem(BuildContext context, WidgetRef ref, SacredContent item, List<SacredContent> playlist) {
    final audioState = ref.watch(audioProvider);
    final isPlaying = audioState.isPlaying && audioState.currentContent?.id == item.id;

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
          padding: const EdgeInsets.all(20),
          borderColor: isPlaying 
              ? PremiumTokens.nebulaBlue.withValues(alpha: 0.3) 
              : PremiumTokens.celestialSilver.withValues(alpha: 0.1),
          child: Row(
            children: [
              // Enclaved Status Icon (Music vs. Book)
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isPlaying 
                      ? PremiumTokens.nebulaBlue.withValues(alpha: 0.1) 
                      : PremiumTokens.celestialSilver.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isPlaying 
                        ? PremiumTokens.nebulaBlue.withValues(alpha: 0.2) 
                        : PremiumTokens.celestialSilver.withValues(alpha: 0.05),
                  ),
                ),
                child: Center(
                  child: Icon(
                    isPlaying 
                      ? Iconsax.music_play5 
                      : (item.audioUrl != null && item.audioUrl!.isNotEmpty 
                          ? Iconsax.music 
                          : Iconsax.book_1),
                    color: isPlaying ? PremiumTokens.nebulaBlue : PremiumTokens.celestialSilver.withValues(alpha: 0.5),
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
                                  item.author!.toUpperCase(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: PremiumTokens.sansStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.2,
                                    color: PremiumTokens.saffronGlow.withValues(alpha: 0.8),
                                  ),
                                ),
                             ),
                          if (item.author != null && item.book != null)
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: 3,
                              height: 3,
                              decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white24),
                            ),
                          if (item.book != null)
                            Expanded(
                              child: Text(
                                item.book!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: PremiumTokens.sansStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: PremiumTokens.celestialSilver.withValues(alpha: 0.5),
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
                      style: PremiumTokens.sansStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.commentary.startsWith('http') ? 'Sacred Verse Details' : item.commentary,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: PremiumTokens.sansStyle(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.45),
                      ).copyWith(height: 1.3),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        if (item.audioUrl != null && item.audioUrl!.isNotEmpty) ...[
                          const Icon(Icons.schedule, color: Colors.white24, size: 10),
                          const SizedBox(width: 4),
                          Text(
                            "10:45",
                            style: PremiumTokens.sansStyle(fontSize: 10, color: Colors.white24),
                          ),
                          const SizedBox(width: 8),
                        ] else ...[
                          const Icon(Icons.auto_stories, color: Colors.white24, size: 10),
                          const SizedBox(width: 4),
                          Text(
                            (item.chapter ?? "READ").toUpperCase(),
                            style: PremiumTokens.sansStyle(fontSize: 10, color: Colors.white24, letterSpacing: 1.0),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: PremiumTokens.celestialSilver.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: PremiumTokens.celestialSilver.withValues(alpha: 0.05)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getCategoryIcon(item.category),
                                size: 10,
                                color: PremiumTokens.celestialSilver.withValues(alpha: 0.5),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                item.category.toUpperCase(),
                                style: PremiumTokens.sansStyle(
                                  fontSize: 8, 
                                  fontWeight: FontWeight.w900,
                                  color: PremiumTokens.celestialSilver.withValues(alpha: 0.4),
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
                                      color: PremiumTokens.celestialSilver.withValues(alpha: 0.03),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: PremiumTokens.celestialSilver.withValues(alpha: 0.05)),
                                    ),
                                    child: Text(
                                      tag.toUpperCase(),
                                      style: PremiumTokens.sansStyle(
                                        fontSize: 8, 
                                        fontWeight: FontWeight.bold,
                                        color: PremiumTokens.celestialSilver.withValues(alpha: 0.25),
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
                    color: ref.watch(isFavoriteProvider(item.id)) ? PremiumTokens.saffronGlow : Colors.white24,
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
                                ? PremiumTokens.nebulaBlue.withValues(alpha: 0.1) 
                                : PremiumTokens.celestialSilver.withValues(alpha: 0.05),
                            border: Border.all(
                              color: isPlaying 
                                  ? PremiumTokens.nebulaBlue.withValues(alpha: 0.3) 
                                  : PremiumTokens.celestialSilver.withValues(alpha: 0.2)
                            ),
                          ),
                          child: Icon(
                            isPlaying ? Iconsax.pause : Icons.play_arrow, 
                            color: isPlaying ? PremiumTokens.nebulaBlue : PremiumTokens.celestialSilver, 
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

  IconData _getCategoryIcon(String category) {
    final cat = category.toUpperCase();
    if (cat.contains('MANTRA')) return Iconsax.music_play;
    if (cat.contains('SHLOKA') || cat.contains('VERSE')) return Iconsax.quote_up;
    if (cat.contains('WISDOM') || cat.contains('GYAAN')) return Iconsax.lamp_on;
    if (cat.contains('RITUAL')) return Iconsax.status_up;
    if (cat.contains('HISTORY') || cat.contains('KATHA')) return Iconsax.book_1;
    return Iconsax.document_text;
  }
}
