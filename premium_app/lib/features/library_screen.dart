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

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.watch(sacredContentProvider);

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
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return _buildLibraryItem(context, ref, items[index]);
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
            PremiumUI.animatedIcon(
              folder: 'Filter',
              fileName: 'filter.json',
              size: 28,
              color: PremiumTokens.nebulaBlue,
            ),
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
                      color: PremiumTokens.nebulaBlue,
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
                    border: Border.all(color: PremiumTokens.nebulaBlue.withValues(alpha: 0.3)),
                  ),
                  child: user?.photoURL != null 
                    ? PremiumUI.networkImage(
                        url: user!.photoURL!,
                        borderRadius: BorderRadius.circular(19),
                      )
                    : const Icon(
                        Iconsax.user,
                        color: PremiumTokens.nebulaBlue,
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
            MaterialPageRoute(builder: (_) => SearchScreen()),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: PremiumTokens.surfaceCharcoal.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: PremiumTokens.nebulaBlue.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Icon(Iconsax.search_normal, color: PremiumTokens.nebulaBlue, size: 20),
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
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuCjQJTEsIPehLdGJWjz8TSfCs7o0uifTz1QfDnl0xe93A5gwv8Ccp6F6nm2FkjhjUj-lsuWJp_6-RmW3i55zjk4S3YdTRrnK9JmL9XsZSc-iTnTfSCX7_p5yEUkOkxMU3MemeaubUJtFNFJYkdACZTW5tDjmWG-00z4idxNYyHwoXDU0xQ0aLM7iRJHndrXYnv81TX6k4McMTD-djipl40MQhHU1yqz82hU_EPJxc4L3nXERe5g9bmTm34Ofr96MF0fmtSB5VA-PLg',
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: PremiumTokens.surfaceCharcoal,
                    child: const Icon(Icons.music_note, color: PremiumTokens.nebulaBlue),
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
                      color: PremiumTokens.nebulaBlue,
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
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: PremiumTokens.nebulaBlue,
              ),
              child: PremiumUI.animatedIcon(
                folder: 'Refresh',
                fileName: 'refresh.json',
                size: 24,
                color: PremiumTokens.charcoal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLibraryItem(BuildContext context, WidgetRef ref, SacredContent item) {
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
        child: PremiumUI.voidCard(
          padding: const EdgeInsets.all(16),
          borderRadius: 16,
          optimized: true,
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: PremiumTokens.surfaceCharcoal,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: PremiumTokens.nebulaBlue.withValues(alpha: 0.1)),
                ),
                child: Center(
                  child: item.imageUrl != null 
                    ? PremiumUI.networkImage(url: item.imageUrl, borderRadius: BorderRadius.circular(8))
                    : const Icon(Icons.spa, color: PremiumTokens.nebulaBlue, size: 28),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.schedule, color: Colors.white24, size: 12),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            "10:45 • ${item.category}",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: PremiumTokens.sansStyle(
                              fontSize: 12,
                              color: Colors.white38,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Like Button
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
              const SizedBox(width: 16),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: PremiumTokens.nebulaBlue.withValues(alpha: 0.3)),
                ),
                child: const Icon(Icons.play_arrow, color: PremiumTokens.nebulaBlue, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
