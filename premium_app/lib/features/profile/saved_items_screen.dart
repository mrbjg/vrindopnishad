import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/design_system.dart';
import '../../core/content_provider.dart';
import '../../core/favorites_provider.dart';
import '../content_detail_screen.dart';
import '../../core/color_theme_provider.dart';
import '../../widgets/animated_effects.dart';

class SavedItemsScreen extends ConsumerWidget {
  const SavedItemsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allContent = ref.watch(sacredContentProvider);
    final favoriteIds = ref.watch(favoritesProvider);
    ref.watch(colorPaletteProvider);
    
    // Filter content to only show favorites
    final savedItems = allContent.where((c) => favoriteIds.contains(c.id)).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          PremiumUI.voidBackground(context),
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                title: const Text("Saved Items"),
                backgroundColor: Colors.transparent,
                elevation: 0,
                pinned: true,
                centerTitle: true,
                leading: IconButton(
                  icon: PremiumUI.animatedIcon(
                    folder: 'Chevron-left',
                    fileName: 'chevron-left.json',
                    size: 20,
                    color: PremiumTokens.activeAccent,
                    onTap: () => Navigator.pop(context),
                  ),
                  onPressed: () {}, // Handled by animatedIcon onTap
                ),
              ),
              if (savedItems.isEmpty)
                SliverFillRemaining(child: _buildEmptyState(context))
              else
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = savedItems[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: SizedBox(
                            height: 110,
                            child: PressableScale(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ContentDetailScreen(
                                      content: item,
                                      title: item.title,
                                      category: item.category,
                                    ),
                                  ),
                                );
                              },
                              child: PremiumUI.relicStaticCard(
                                padding: EdgeInsets.zero,
                                borderColor: PremiumTokens.borderSubtle,
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

                                      // 2. Adaptive gradient overlay for text readability
                                      Positioned.fill(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                PremiumTokens.surfaceMain.withValues(alpha: 0.10),
                                                PremiumTokens.surfaceMain.withValues(alpha: 0.70),
                                                PremiumTokens.surfaceMain.withValues(alpha: 0.96),
                                              ],
                                              stops: const [0.0, 0.45, 0.85],
                                            ),
                                          ),
                                        ),
                                      ),

                                      // 3. Card content
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    item.title,
                                                    style: GoogleFonts.manrope(
                                                      color: PremiumTokens.textPrimary,
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    item.category.toUpperCase(),
                                                    style: GoogleFonts.manrope(
                                                      color: PremiumTokens.activeAccent,
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.w800,
                                                      letterSpacing: 1.5,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Icon(
                                              Iconsax.arrow_right_3,
                                              size: 20,
                                              color: PremiumTokens.textPrimary.withValues(alpha: 0.8),
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
                      },
                      childCount: savedItems.length,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: PremiumTokens.activeAccent.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: PremiumTokens.activeAccent.withValues(alpha: 0.2)),
            ),
            child: PremiumUI.animatedIcon(
              folder: 'Heart',
              fileName: 'heart.json',
              size: 80,
              color: PremiumTokens.activeAccent,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "No saved items yet",
            style: PremiumTokens.displayStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Bookmark your favorite content",
            style: PremiumTokens.sansStyle(
              color: PremiumTokens.textMuted,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
