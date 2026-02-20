import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../core/theme.dart';
import '../core/providers.dart';
import '../core/localization.dart';
import '../core/content_provider.dart';
import 'content_detail_screen.dart';
import 'category_screen.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allContent = ref.watch(sacredContentProvider);
    final currentLanguage = ref.watch(languageProvider);
    final l = AppLocalization(currentLanguage);
    final isDark = AppTheme.isDark(context);

    final savedItems = allContent.take(5).toList();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor(context),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 20,
                left: 20,
                right: 20,
                bottom: 24,
              ),
              decoration: BoxDecoration(
                gradient: AppTheme.headerGradient(context),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l.translate('my_library'),
                        style: SacredStyles.spectralHeader.copyWith(
                          fontSize: 28,
                          color: isDark
                              ? Colors.white
                              : AppTheme.lightTextPrimary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withOpacity(0.1)
                              : Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Iconsax.archive_book,
                          color: isDark ? Colors.white : AppTheme.primaryColor,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Iconsax.book_1,
                          size: 16,
                          color: isDark
                              ? Colors.white70
                              : AppTheme.primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "${savedItems.length} ${l.translate('saved_items')}",
                          style: SacredStyles.outfitSubtitle.copyWith(
                            fontSize: 13,
                            color: isDark
                                ? Colors.white
                                : AppTheme.lightTextPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          savedItems.isEmpty
              ? SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmptyState(context, l),
                )
              : SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      if (index == savedItems.length) {
                        return const SizedBox(height: 80);
                      }
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildSavedCard(context, savedItems[index]),
                      );
                    }, childCount: savedItems.length + 1),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildSavedCard(BuildContext context, SacredContent item) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ContentDetailScreen(content: item)),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.cardColor(context),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppTheme.borderColor(context).withOpacity(0.05),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient(context),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Iconsax.archive_book,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.displayTitle,
                    style: SacredStyles.outfitTitle.copyWith(
                      fontSize: 15,
                      color: AppTheme.textPrimary(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Iconsax.folder,
                              size: 11,
                              color: AppTheme.primaryColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              item.category,
                              style: SacredStyles.outfitLabel.copyWith(
                                color: AppTheme.primaryColor,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Icon(
                        Iconsax.clock,
                        size: 12,
                        color: AppTheme.textMuted(context),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "5 min",
                        style: SacredStyles.outfitMuted.copyWith(
                          color: AppTheme.textMuted(context),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Iconsax.arrow_right_3,
              size: 18,
              color: AppTheme.textMuted(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalization l) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Iconsax.archive_book,
                size: 48,
                color: AppTheme.primaryColor.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l.translate('library_empty'),
              style: SacredStyles.spectralHeader.copyWith(
                fontSize: 22,
                color: AppTheme.textPrimary(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l.translate('save_favorite'),
              style: SacredStyles.outfitSubtitle.copyWith(
                color: AppTheme.textMuted(context),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CategoryScreen(
                    categoryName: l.translate('shlokas'),
                    gradientColors: const [
                      Color(0xFFE8A838),
                      Color(0xFFF59E0B),
                    ],
                  ),
                ),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient(context),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppTheme.glowShadow(AppTheme.primaryColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Iconsax.discover, size: 18, color: Colors.white),
                    const SizedBox(width: 10),
                    Text(
                      l.translate('explore_content'),
                      style: SacredStyles.outfitTitle.copyWith(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
