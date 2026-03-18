import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/design_system.dart';
import '../content_detail_screen.dart';

class ReadingHistoryScreen extends StatelessWidget {
  const ReadingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final historyItems = [
      {'title': 'Ashtavakra Gita', 'category': 'Shloka', 'time': '2 hours ago'},
      {'title': 'Gayatri Mantra', 'category': 'Strotra', 'time': 'Yesterday'},
      {
        'title': 'Introduction to Vedas',
        'category': 'Article',
        'time': '3 days ago',
      },
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
                title: const Text("Reading History"),
                backgroundColor: Colors.transparent,
                elevation: 0,
                pinned: true,
                centerTitle: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: PremiumTokens.nebulaBlue, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  TextButton(
                    onPressed: () {},
                    child: const Text("Clear All", style: TextStyle(color: Colors.redAccent)),
                  ),
                ],
              ),
              if (historyItems.isEmpty)
                SliverFillRemaining(child: _buildEmptyState(context))
              else
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = historyItems[index];
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
                                  color: PremiumTokens.nebulaBlue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: PremiumTokens.nebulaBlue.withOpacity(0.1)),
                                ),
                                child: const Icon(
                                  Iconsax.clock,
                                  color: PremiumTokens.nebulaBlue,
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
                                "${item['category']} • ${item['time']}",
                                style: PremiumTokens.sansStyle(
                                  color: Colors.white38,
                                  fontSize: 12,
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
                      childCount: historyItems.length,
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
              color: PremiumTokens.nebulaBlue.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: PremiumTokens.nebulaBlue.withOpacity(0.2)),
            ),
            child: const Icon(
              Iconsax.clock,
              size: 48,
              color: PremiumTokens.nebulaBlue,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "No reading history",
            style: PremiumTokens.displayStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Start exploring sacred content",
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
