import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/design_system.dart';
import '../../core/content_provider.dart';
import '../../core/favorites_provider.dart';
import '../content_detail_screen.dart';

class SavedItemsScreen extends ConsumerWidget {
  const SavedItemsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allContent = ref.watch(sacredContentProvider);
    final favoriteIds = ref.watch(favoritesProvider);
    
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
                          child: PremiumUI.voidGlassCard(
                            padding: EdgeInsets.zero,
                            optimized: true,
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              leading: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  gradient: PremiumTokens.nebulaGradient,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: PremiumUI.customIcon(
                                  fileName: 'iconsax-archive-27ilzneb-.svg',
                                  color: PremiumTokens.textPrimary,
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                item.title,
                                style: PremiumTokens.displayStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                item.category,
                                style: PremiumTokens.sansStyle(
                                  color: PremiumTokens.activeAccent,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              trailing: Icon(
                                Iconsax.arrow_right_3,
                                size: 18,
                                color: PremiumTokens.textHint,
                              ),
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
