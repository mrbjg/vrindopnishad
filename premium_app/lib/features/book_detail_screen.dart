import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../core/design_system.dart';
import '../core/content_provider.dart';
import '../core/audio_provider.dart';
import 'content_detail_screen.dart';
import '../widgets/animated_effects.dart';

class BookDetailScreen extends ConsumerWidget {
  final String bookName;

  const BookDetailScreen({super.key, required this.bookName});

  String _getBookCoverUrl(String name) {
    final h = name.hashCode.abs();
    final covers = [
      'https://images.unsplash.com/photo-1544947950-fa07a98d237f?auto=format&fit=crop&w=600&q=80',
      'https://images.unsplash.com/photo-1512820790803-83ca734da794?auto=format&fit=crop&w=600&q=80',
      'https://images.unsplash.com/photo-1476275466078-4007374efbbe?auto=format&fit=crop&w=600&q=80',
      'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&w=600&q=80',
    ];
    return covers[h % covers.length];
  }

  String _getBookIntro(String name) {
    return "A sacred scripture containing compiled revelations and divine verses. It serves as a repository of spiritual wisdom, detailing absolute truths, mystical insights, and paths of devotional surrender.";
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    PremiumTokens.of(context);
    final verses = ref.watch(contentByBookProvider(bookName));
    final coverUrl = _getBookCoverUrl(bookName);
    final intro = _getBookIntro(bookName);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background Gradient
          Positioned.fill(
            child: PremiumUI.masterBackground(index: 2, context: context),
          ),

          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 1. Netflix-style cover banner with back button
              SliverAppBar(
                expandedHeight: 320,
                pinned: true,
                stretch: true,
                backgroundColor: PremiumTokens.scaffoldBg.withValues(alpha: 0.85),
                elevation: 0,
                scrolledUnderElevation: 0,
                leading: Container(
                  margin: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
                  decoration: BoxDecoration(
                    color: PremiumTokens.scaffoldBg.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                    border: Border.all(color: PremiumTokens.borderSubtle),
                  ),
                  child: IconButton(
                    icon: Icon(Iconsax.arrow_left, color: PremiumTokens.textPrimary, size: 18),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [
                    StretchMode.zoomBackground,
                    StretchMode.blurBackground,
                  ],
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Full-bleed cover
                      PremiumUI.networkImage(
                        url: coverUrl,
                        fit: BoxFit.cover,
                      ),
                      // Cinematic vignette mask
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.3),
                              PremiumTokens.scaffoldBg.withValues(alpha: 0.3),
                              PremiumTokens.scaffoldBg,
                            ],
                            stops: const [0.0, 0.6, 1.0],
                          ),
                        ),
                      ),
                      // Title Info Overlay
                      Positioned(
                        left: 20,
                        right: 20,
                        bottom: 24,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: PremiumTokens.activeAccent.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: PremiumTokens.activeAccentLight.withValues(alpha: 0.3), width: 0.8),
                              ),
                              child: Text(
                                "SACRED GRANTHA / BOOK",
                                style: PremiumTokens.sansStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w900,
                                  color: PremiumTokens.activeAccentLight,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              bookName,
                              style: PremiumTokens.hindiAwareStyle(
                                bookName,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: PremiumTokens.textPrimary,
                                isSacred: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Book Info Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: PremiumUI.voidGlassCard(
                    padding: const EdgeInsets.all(20),
                    borderRadius: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Iconsax.book, color: PremiumTokens.activeAccent, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              "GRANTHA SYNOPSIS",
                              style: PremiumTokens.sansStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: PremiumTokens.textSecondary,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          intro,
                          style: PremiumTokens.sansStyle(
                            fontSize: 13,
                            color: PremiumTokens.textSecondary,
                          ).copyWith(height: 1.5),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildMetricTile("VERSES", "${verses.length}"),
                            ),
                            Container(width: 1, height: 30, color: PremiumTokens.borderSubtle),
                            Expanded(
                              child: _buildMetricTile("SECTIONS", "${_countUniqueChapters(verses)}"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 3. Chapter Lists Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Text(
                    "CHAPTERS & VERSES",
                    style: PremiumTokens.sansStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: PremiumTokens.textPrimary,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),

              // 4. Verses List
              verses.isEmpty
                  ? const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 48),
                        child: Center(
                          child: Text("No verses found inside this book."),
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final item = verses[index];
                            return _buildVerseItemCard(context, ref, item, verses);
                          },
                          childCount: verses.length,
                        ),
                      ),
                    ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: PremiumTokens.sansStyle(
            fontSize: 9,
            color: PremiumTokens.textMuted,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: PremiumTokens.sansStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: PremiumTokens.activeAccent,
          ),
        ),
      ],
    );
  }

  int _countUniqueChapters(List<SacredContent> items) {
    final Set<String> chapters = {};
    for (final item in items) {
      if (item.chapter != null && item.chapter!.isNotEmpty) {
        chapters.add(item.chapter!);
      }
    }
    return chapters.isEmpty ? 1 : chapters.length;
  }

  Widget _buildVerseItemCard(BuildContext context, WidgetRef ref, SacredContent item, List<SacredContent> playlist) {
    final isPlaying = ref.watch(audioProvider.select((s) =>
      s.isPlaying && s.currentContent?.id == item.id
    ));

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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
            child: SizedBox(
              height: 110,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Full-bleed background image
                  Positioned.fill(
                    child: PremiumUI.networkImage(
                      url: item.displayImageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Gradient cover mask
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            PremiumTokens.surfaceMain.withValues(alpha: 0.95),
                            PremiumTokens.surfaceMain.withValues(alpha: 0.65),
                            PremiumTokens.surfaceMain.withValues(alpha: 0.3),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Details row
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (item.chapter != null || item.author != null)
                                Text(
                                  "${item.chapter ?? 'Chapter'} • ${item.author ?? 'Tradition'}",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: PremiumTokens.sansStyle(
                                    fontSize: 10,
                                    color: PremiumTokens.saffronGlow,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              const SizedBox(height: 2),
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
                              const SizedBox(height: 6),
                              PremiumUI.categoryBadge(item.category, fontSize: 8),
                            ],
                          ),
                        ),
                        // Player button
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (item.audioUrl != null && item.audioUrl!.isNotEmpty)
                              GestureDetector(
                                onTap: () {
                                  HapticFeedback.heavyImpact();
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
