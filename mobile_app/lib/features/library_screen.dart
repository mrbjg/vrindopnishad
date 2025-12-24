import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    final isDark = AppTheme.isDark(context);

    final savedItems = allContent.take(5).toList();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor(context),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Premium curved gradient header
          SliverToBoxAdapter(
            child: Container(
              height: 260,
              decoration: BoxDecoration(
                gradient: isDark
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF1A1A2E),
                          const Color(0xFF16213E),
                          AppTheme.glowBlue.withOpacity(0.3),
                        ],
                      )
                    : LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFFFEF3C7),
                          const Color(0xFFFBD38D),
                          AppTheme.primaryColor,
                        ],
                      ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(48),
                  bottomRight: Radius.circular(48),
                ),
              ),
              child: Stack(
                children: [
                  // Decorative elements
                  Positioned(
                    top: -30,
                    right: -30,
                    child:
                        Container(
                              width: 160,
                              height: 160,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    Colors.white.withOpacity(0.15),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            )
                            .animate(onPlay: (c) => c.repeat())
                            .shimmer(duration: 3000.ms, color: Colors.white24),
                  ),
                  Positioned(
                    bottom: 40,
                    left: -20,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppTheme.glowPurple.withOpacity(0.2),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Content
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  l.translate('my_library'),
                                  style: GoogleFonts.spectral(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: -0.5,
                                  ),
                                ).animate().fadeIn().slideX(begin: -0.1),
                              ),
                              // Floating icon with glow
                              Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.2),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppTheme.primaryColor
                                              .withOpacity(0.3),
                                          blurRadius: 20,
                                          spreadRadius: -5,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      LucideIcons.bookmark,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  )
                                  .animate()
                                  .fadeIn(delay: 200.ms)
                                  .scale(begin: const Offset(0.8, 0.8)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Stats row with glassmorphism
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.15),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      LucideIcons.library,
                                      size: 18,
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      "${savedItems.length} ${l.translate('saved_items')}",
                                      style: GoogleFonts.outfit(
                                        fontSize: 14,
                                        color: Colors.white.withOpacity(0.9),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
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
              ? SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmptyState(context, l),
                )
              : SliverPadding(
                  padding: const EdgeInsets.all(24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      if (index == savedItems.length) {
                        return const SizedBox(height: 80); // Bottom nav padding
                      }
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildSavedCard(
                          context,
                          savedItems[index],
                          index,
                          l,
                          isDark,
                        ),
                      );
                    }, childCount: savedItems.length + 1),
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
    bool isDark,
  ) {
    return PressableScale(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ContentDetailScreen(content: item),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.06)
                  : Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.08)
                    : Colors.black.withOpacity(0.04),
                width: 1.5,
              ),
              boxShadow: AppTheme.softShadow(context),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Gradient icon container
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient(context),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                          spreadRadius: -4,
                        ),
                      ],
                    ),
                    child: const Icon(
                      LucideIcons.bookmark,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: AppTheme.textPrimary(context),
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    LucideIcons.folder,
                                    size: 11,
                                    color: AppTheme.primaryColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    item.category,
                                    style: GoogleFonts.outfit(
                                      color: AppTheme.primaryColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
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
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor(context),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      LucideIcons.chevronRight,
                      size: 18,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: (100 + 80 * index).ms).slideX(begin: 0.05);
  }

  Widget _buildEmptyState(BuildContext context, AppLocalization l) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated empty state icon
          Container(
                padding: const EdgeInsets.all(36),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryColor.withOpacity(0.1),
                      AppTheme.glowPurple.withOpacity(0.1),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  LucideIcons.bookmark,
                  size: 52,
                  color: AppTheme.primaryColor.withOpacity(0.5),
                ),
              )
              .animate()
              .fadeIn()
              .scale(begin: const Offset(0.8, 0.8))
              .then()
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.05, 1.05),
                duration: 2000.ms,
              ),
          const SizedBox(height: 28),
          Text(
            l.translate('library_empty'),
            style: GoogleFonts.spectral(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary(context),
              letterSpacing: -0.5,
            ),
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 10),
          Text(
            l.translate('save_favorite'),
            style: GoogleFonts.outfit(
              color: AppTheme.textMuted(context),
              fontSize: 15,
            ),
          ).animate().fadeIn(delay: 150.ms),
          const SizedBox(height: 36),
          PressableScale(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    CategoryScreen(categoryName: l.translate('shlokas')),
              ),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient(context),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                    spreadRadius: -8,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    LucideIcons.compass,
                    size: 20,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    l.translate('explore_content'),
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
        ],
      ),
    );
  }
}
