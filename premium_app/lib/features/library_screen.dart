import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../core/design_system.dart';
import '../core/providers.dart';
import '../core/localization.dart';
import '../core/content_provider.dart';
import 'content_detail_screen.dart';
import 'category_screen.dart';
import '../widgets/animated_effects.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allContent = ref.watch(sacredContentProvider);
    final currentLanguage = ref.watch(languageProvider);
    final l = AppLocalization(currentLanguage);
    
    // Simulating saved items for demo
    final savedItems = allContent.take(5).toList();

    return Scaffold(
      backgroundColor: PremiumTokens.charcoal,
      body: Stack(
        children: [
          const Positioned.fill(child: AnimatedSacredBackground()),
          
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Premium Header
              SliverToBoxAdapter(
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l.translate('my_library'),
                              style: SacredStyles.devanagariMain.copyWith(
                                fontSize: 32,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            PremiumUI.glassCard(
                              padding: const EdgeInsets.all(12),
                              child: const Icon(Iconsax.archive_book, color: PremiumTokens.saffronGlow, size: 24),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: PremiumTokens.saffronGlow.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: PremiumTokens.saffronGlow.withOpacity(0.2)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Iconsax.book_1, size: 16, color: PremiumTokens.saffronGlow),
                              const SizedBox(width: 8),
                              Text(
                                "${savedItems.length} ${l.translate('saved_items')}",
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Saved Content List
              savedItems.isEmpty
                  ? SliverFillRemaining(
                      hasScrollBody: false,
                      child: _buildPremiumEmptyState(context, l),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final item = savedItems[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _buildPremiumSavedCard(context, item),
                            );
                          },
                          childCount: savedItems.length,
                        ),
                      ),
                    ),
              
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumSavedCard(BuildContext context, SacredContent item) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ContentDetailScreen(content: item)),
        );
      },
      child: PremiumUI.glassCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: PremiumTokens.saffronPremiumGradient,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: PremiumTokens.saffronGlow.withOpacity(0.2),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const Icon(Iconsax.book_1, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.displayTitle,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        item.category,
                        style: GoogleFonts.outfit(color: PremiumTokens.saffronGlow, fontSize: 12),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Iconsax.clock, size: 12, color: Colors.white38),
                      const SizedBox(width: 4),
                      Text(
                        "5 min",
                        style: GoogleFonts.outfit(color: Colors.white38, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Iconsax.arrow_right_3, color: Colors.white24, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumEmptyState(BuildContext context, AppLocalization l) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PremiumUI.glassCard(
              padding: const EdgeInsets.all(32),
              borderRadius: 100,
              child: const Icon(Iconsax.archive_book, size: 48, color: Colors.white24),
            ),
            const SizedBox(height: 32),
            Text(
              l.translate('library_empty'),
              style: GoogleFonts.spectral(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              l.translate('save_favorite'),
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(color: Colors.white38, fontSize: 15),
            ),
            const SizedBox(height: 48),
            PremiumUI.primaryButton(
              text: l.translate('explore_content'),
              onTap: () {
                // Navigate to categories or home
              },
              icon: Iconsax.discover,
            ),
          ],
        ),
      ),
    );
  }
}
