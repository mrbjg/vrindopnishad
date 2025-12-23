import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
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

    final savedItems = allContent.take(5).toList();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor(context),
      body: CustomScrollView(
        slivers: [
          // Curved gradient header
          SliverToBoxAdapter(
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: AppTheme.headerGradient(context),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Stack(
                children: [
                  // Decorative element
                  Positioned(
                    top: -20,
                    right: -20,
                    child: Opacity(
                      opacity: 0.15,
                      child: const Icon(
                        LucideIcons.library,
                        size: 150,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  // Content
                  SafeArea(
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
                                style: GoogleFonts.spectral(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ).animate().fadeIn().slideX(begin: -0.1),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  LucideIcons.bookmark,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "${savedItems.length} ${l.translate('saved_items')}",
                            style: GoogleFonts.outfit(
                              fontSize: 15,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          savedItems.isEmpty
              ? SliverFillRemaining(child: _buildEmptyState(context, l))
              : SliverPadding(
                  padding: const EdgeInsets.all(24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) =>
                          _buildSavedCard(context, savedItems[index], index, l),
                      childCount: savedItems.length,
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildSavedCard(
    BuildContext context,
    SacredContent item,
    int index,
    AppLocalization l,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor(context),
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.softShadow(context),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient(context),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            LucideIcons.bookmark,
            color: Colors.white,
            size: 24,
          ),
        ),
        title: Text(
          item.title,
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: AppTheme.textPrimary(context),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Icon(
                LucideIcons.folder,
                size: 12,
                color: AppTheme.textMuted(context),
              ),
              const SizedBox(width: 4),
              Text(
                item.category,
                style: GoogleFonts.outfit(
                  color: AppTheme.textMuted(context),
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                LucideIcons.clock,
                size: 12,
                color: AppTheme.textMuted(context),
              ),
              const SizedBox(width: 4),
              Text(
                "5 min",
                style: GoogleFonts.outfit(
                  color: AppTheme.textMuted(context),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor(context),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            LucideIcons.chevronRight,
            size: 18,
            color: AppTheme.primaryColor,
          ),
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ContentDetailScreen(content: item),
          ),
        ),
      ),
    ).animate().fadeIn(delay: (80 * index).ms).slideY(begin: 0.05);
  }

  Widget _buildEmptyState(BuildContext context, AppLocalization l) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor(context),
              shape: BoxShape.circle,
            ),
            child: Icon(
              LucideIcons.bookMarked,
              size: 48,
              color: AppTheme.primaryColor.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l.translate('library_empty'),
            style: GoogleFonts.spectral(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l.translate('save_favorite'),
            style: GoogleFonts.outfit(
              color: AppTheme.textMuted(context),
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    CategoryScreen(categoryName: l.translate('shlokas')),
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(LucideIcons.compass, size: 18),
                const SizedBox(width: 8),
                Text(
                  l.translate('explore_content'),
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
