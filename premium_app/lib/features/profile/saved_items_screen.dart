import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
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
                            height: 220, // Height for saved item cards
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
                                  child: Column(
                                    children: [
                                      // 1. Cover image (top portion)
                                      SizedBox(
                                        height: 110,
                                        width: double.infinity,
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            PremiumUI.networkImage(
                                              url: item.displayImageUrl,
                                              fit: BoxFit.cover,
                                            ),
                                            Positioned.fill(
                                              child: DecoratedBox(
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                    colors: [
                                                      Colors.black.withValues(alpha: 0.15),
                                                      Colors.transparent,
                                                      Colors.black.withValues(alpha: 0.3),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // 2. Metadata details panel (bottom portion)
                                      Expanded(
                                        child: Container(
                                          color: PremiumTokens.surfaceMain.withValues(alpha: 0.95),
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    if (item.author != null)
                                                      Text(
                                                        item.author!.toUpperCase(),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: PremiumTokens.sansStyle(
                                                          color: PremiumTokens.saffronGlow,
                                                          fontSize: 9,
                                                          fontWeight: FontWeight.w900,
                                                          letterSpacing: 1.0,
                                                        ),
                                                      ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      item.title,
                                                      style: PremiumTokens.hindiAwareStyle(
                                                        item.title,
                                                        fontSize: 15,
                                                        fontWeight: FontWeight.bold,
                                                        color: PremiumTokens.textPrimary,
                                                        isSacred: true,
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                    const SizedBox(height: 4),
                                                    PremiumUI.categoryBadge(item.category, fontSize: 10),
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
