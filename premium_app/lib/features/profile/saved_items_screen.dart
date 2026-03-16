import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/design_system.dart';
import '../content_detail_screen.dart';

class SavedItemsScreen extends StatelessWidget {
  const SavedItemsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final savedItems = [
      {'title': 'Bhagavad Gita - Chapter 2', 'category': 'Shloka'},
      {'title': 'Shiva Tandava Stotram', 'category': 'Strotra'},
      {'title': 'Hanuman Chalisa', 'category': 'Poem'},
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          PremiumUI.voidBackground(),
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
                  icon: const Icon(Icons.arrow_back_ios, color: PremiumTokens.nebulaBlue, size: 20),
                  onPressed: () => Navigator.pop(context),
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
                                child: const Icon(
                                  Iconsax.archive_book,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                item['title']!,
                                style: PremiumTokens.displayStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                item['category']!,
                                style: PremiumTokens.sansStyle(
                                  color: PremiumTokens.nebulaBlue,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              trailing: const Icon(
                                Iconsax.arrow_right_3,
                                size: 18,
                                color: Colors.white24,
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ContentDetailScreen(
                                      title: item['title']!,
                                      category: item['category']!,
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
              color: PremiumTokens.nebulaBlue.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: PremiumTokens.nebulaBlue.withValues(alpha: 0.2)),
            ),
            child: const Icon(
              Iconsax.folder_open,
              size: 48,
              color: PremiumTokens.nebulaBlue,
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
              color: Colors.white38,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
