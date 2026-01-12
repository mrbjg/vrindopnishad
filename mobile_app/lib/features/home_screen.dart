import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import '../core/providers.dart';
import '../core/localization.dart';
import '../core/content_provider.dart';
import 'content_detail_screen.dart';
import 'category_screen.dart';
import 'search_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../widgets/sacred_morph_widget.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentContent = ref.watch(sacredContentProvider);
    final currentLanguage = ref.watch(languageProvider);
    final l = AppLocalization(currentLanguage);
    final isDark = AppTheme.isDark(context);

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0A0A0F)
          : const Color(0xFFF5F3F0),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // HERO HEADER - No BackdropFilter
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 20,
                left: 24,
                right: 24,
                bottom: 32,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          const Color(0xFF1A1A2E),
                          const Color(0xFF16213E),
                          const Color(0xFF0F1828),
                        ]
                      : [
                          const Color(0xFFFEF3C7),
                          const Color(0xFFFBD38D),
                          const Color(0xFFF59E0B),
                        ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l.translate('greeting'),
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                color: isDark ? Colors.white60 : Colors.black45,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l.translate('discover_wisdom'),
                              style: GoogleFonts.spectral(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF1A1A2E),
                                height: 1.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Logo - Simple container
                      // Logo - Animated Sacred Symbol
                      const SacredMorphWidget(
                        size: 56,
                        color: Colors.white,
                      )
                      .animate(onPlay: (controller) => controller.repeat())
                      .shimmer(duration: 2.seconds, color: Colors.white24)
                      .scale(duration: 1.seconds, curve: Curves.easeInOut),
                    ],
                  ),
                  const SizedBox(height: 28),
                  // Search bar - Simple, no blur
                  _buildSearchBar(context, l, isDark),
                ],
              ),
            ),
          ),

          // CATEGORIES SECTION
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                    context,
                    l.translate('categories'),
                    l.translate('view_all'),
                  ),
                  const SizedBox(height: 16),
                  _buildCategoryGrid(context, l, isDark),
                ],
              ),
            ),
          ),

          // FEATURED SECTION
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                    context,
                    l.translate('featured'),
                    l.translate('view_all'),
                  ),
                  const SizedBox(height: 16),
                  _buildFeaturedBanner(context, isDark, l),
                ],
              ),
            ),
          ),

          // RECENT WISDOM
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                    context,
                    l.translate('recent_wisdom'),
                    l.translate('view_all'),
                  ),
                  const SizedBox(height: 16),
                  _buildRecentList(context, recentContent, l, isDark),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, AppLocalization l, bool isDark) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SearchScreen()),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.1) : Colors.white,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              LucideIcons.search,
              size: 20,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
            const SizedBox(width: 14),
            Text(
              l.translate('search_hint'),
              style: GoogleFonts.outfit(
                color: isDark ? Colors.white60 : Colors.black54,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    String action,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.spectral(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary(context),
          ),
        ),
        TextButton(
          onPressed: () {},
          child: Text(
            action,
            style: GoogleFonts.outfit(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryGrid(
    BuildContext context,
    AppLocalization l,
    bool isDark,
  ) {
    final categories = [
      {
        'name': l.translate('shlokas'),
        'icon': LucideIcons.scroll,
        'gradient': [const Color(0xFFE8A838), const Color(0xFFF59E0B)],
      },
      {
        'name': l.translate('strotras'),
        'icon': LucideIcons.music,
        'gradient': [const Color(0xFFEC4899), const Color(0xFFF472B6)],
      },
      {
        'name': l.translate('poems'),
        'icon': LucideIcons.penTool,
        'gradient': [const Color(0xFF10B981), const Color(0xFF34D399)],
      },
      {
        'name': l.translate('vedas'),
        'icon': LucideIcons.bookOpen,
        'gradient': [const Color(0xFF3B82F6), const Color(0xFF60A5FA)],
      },
      {
        'name': l.translate('mantras'),
        'icon': LucideIcons.sparkles,
        'gradient': [const Color(0xFF8B5CF6), const Color(0xFFA78BFA)],
      },
      {
        'name': l.translate('stories'),
        'icon': LucideIcons.messageCircle,
        'gradient': [const Color(0xFFF97316), const Color(0xFFFB923C)],
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.95,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        return _buildCategoryCard(
          context,
          cat['name'] as String,
          cat['icon'] as IconData,
          cat['gradient'] as List<Color>,
          isDark,
        )
        .animate()
        .fadeIn(delay: (index * 100).ms, duration: 400.ms)
        .scale(delay: (index * 100).ms, duration: 400.ms, curve: Curves.easeOutBack)
        .slideY(begin: 0.2, end: 0, delay: (index * 100).ms);
      },
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    String title,
    IconData icon,
    List<Color> gradientColors,
    bool isDark,
  ) {
    return PressableScale(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CategoryScreen(
              categoryName: title,
              gradientColors: gradientColors,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.06)
              : Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.05),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: gradientColors[0].withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradientColors),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: gradientColors[0].withOpacity(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary(context),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedBanner(
    BuildContext context,
    bool isDark,
    AppLocalization l,
  ) {
    return PressableScale(
      onTap: () => HapticFeedback.lightImpact(),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryColor,
              AppTheme.primaryDark,
              const Color(0xFF8B5CF6),
            ],
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative circle with breathing animation
            Positioned(
              top: -40,
              right: -40,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.15, 1.15),
                duration: 3.seconds,
                curve: Curves.easeInOut,
              ),
            ),
            Positioned(
              bottom: -30,
              left: -30,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.2, 1.2),
                duration: 4.seconds,
                curve: Curves.easeInOut,
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      l.translate('featured').toUpperCase(),
                      style: GoogleFonts.outfit(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                  )
                  .animate()
                  .fadeIn(delay: 200.ms)
                  .slideX(begin: -0.2, end: 0, delay: 200.ms),
                  const SizedBox(height: 12),
                  Text(
                    "Bhagavad Gita",
                    style: GoogleFonts.spectral(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )
                  .animate()
                  .fadeIn(delay: 400.ms)
                  .slideY(begin: 0.3, end: 0, delay: 400.ms, curve: Curves.easeOutBack),
                  const SizedBox(height: 6),
                  Text(
                    "The Song of the Divine",
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.85),
                    ),
                  )
                  .animate()
                  .fadeIn(delay: 600.ms)
                  .slideY(begin: 0.3, end: 0, delay: 600.ms),
                ],
              ),
            ),
          ],
        ),
      )
      .animate()
      .fadeIn(duration: 500.ms)
      .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1), duration: 500.ms, curve: Curves.easeOutBack)
      .shimmer(delay: 1.seconds, duration: 1500.ms, color: Colors.white24),
    );
  }

  Widget _buildRecentList(
    BuildContext context,
    List<SacredContent> content,
    AppLocalization l,
    bool isDark,
  ) {
    if (content.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.04)
              : Colors.white.withOpacity(0.6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Icon(
              LucideIcons.inbox,
              size: 48,
              color: AppTheme.textMuted(context),
            ),
            const SizedBox(height: 16),
            Text(
              l.translate('no_content'),
              style: GoogleFonts.outfit(
                color: AppTheme.textMuted(context),
                fontSize: 15,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: content
          .take(5)
          .toList()
          .asMap()
          .entries
          .map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildRecentCard(context, entry.value, isDark)
                .animate()
                .fadeIn(delay: (entry.key * 100 + 400).ms)
                .slideX(begin: 0.1, end: 0, delay: (entry.key * 100 + 400).ms, curve: Curves.easeOutCubic),
            ),
          )
          .toList(),
    );
  }

  Widget _buildRecentCard(
    BuildContext context,
    SacredContent item,
    bool isDark,
  ) {
    return PressableScale(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ContentDetailScreen(content: item)),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.08)
                : Colors.black.withOpacity(0.04),
          ),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient(context),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                LucideIcons.bookOpen,
                color: Colors.white,
                size: 24,
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
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.category,
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              LucideIcons.chevronRight,
              size: 20,
              color: AppTheme.textMuted(context),
            ),
          ],
        ),
      ),
    );
  }
}
