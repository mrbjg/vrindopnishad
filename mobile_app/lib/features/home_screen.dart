import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../core/providers.dart';
import '../core/localization.dart';
import '../core/content_provider.dart';
import 'content_detail_screen.dart';
import 'category_screen.dart';
import 'search_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentContent = ref.watch(sacredContentProvider);
    final currentLanguage = ref.watch(languageProvider);
    final l = AppLocalization(currentLanguage);
    final isDark = AppTheme.isDark(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor(context),
      body: SafeArea(
        top: false,
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ═══════════════════════════════════════════════════════════════
            // HERO HEADER - Glassmorphism Style
            // ═══════════════════════════════════════════════════════════════
            SliverToBoxAdapter(
              child: Container(
                height: 340,
                decoration: BoxDecoration(
                  gradient: isDark
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF1A1A2E),
                            const Color(0xFF16213E),
                            AppTheme.primaryColor.withOpacity(0.2),
                          ],
                        )
                      : LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFFFEF3C7),
                            const Color(0xFFFBD38D),
                            AppTheme.primaryColor.withOpacity(0.4),
                          ],
                        ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(48),
                    bottomRight: Radius.circular(48),
                  ),
                ),
                child: Stack(
                  children: [
                    // Decorative animated patterns
                    Positioned(
                      top: -60,
                      right: -60,
                      child:
                          Container(
                                width: 220,
                                height: 220,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      AppTheme.primaryColor.withOpacity(0.3),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              )
                              .animate(onPlay: (c) => c.repeat())
                              .shimmer(
                                duration: 3000.ms,
                                color: Colors.white24,
                              ),
                    ),
                    Positioned(
                      bottom: 60,
                      left: -40,
                      child: Container(
                        width: 120,
                        height: 120,
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
                    // Floating decorative icon
                    Positioned(
                      top: 80,
                      right: 30,
                      child:
                          Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(
                                    isDark ? 0.1 : 0.3,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: AppTheme.glowShadow(
                                    AppTheme.primaryColor,
                                    intensity: 0.2,
                                  ),
                                ),
                                child: Icon(
                                  LucideIcons.flower2,
                                  size: 28,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              )
                              .animate()
                              .fadeIn(delay: 300.ms)
                              .slideY(begin: -0.3)
                              .then()
                              .animate(onPlay: (c) => c.repeat(reverse: true))
                              .moveY(
                                begin: 0,
                                end: -8,
                                duration: 2000.ms,
                                curve: Curves.easeInOut,
                              ),
                    ),
                    // Main content
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 70, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                                            fontSize: 15,
                                            color: Colors.white.withOpacity(
                                              0.7,
                                            ),
                                            letterSpacing: 0.5,
                                          ),
                                        )
                                        .animate()
                                        .fadeIn(delay: 100.ms)
                                        .slideX(begin: -0.1),
                                    const SizedBox(height: 8),
                                    Text(
                                          l.translate('discover_wisdom'),
                                          style: GoogleFonts.spectral(
                                            fontSize: 30,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            height: 1.2,
                                            letterSpacing: -0.5,
                                          ),
                                        )
                                        .animate()
                                        .fadeIn(delay: 200.ms)
                                        .slideX(begin: -0.1),
                                  ],
                                ),
                              ),
                              // Logo container with glow
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
                                    child: SvgPicture.asset(
                                      'assets/logo.svg',
                                      height: 30,
                                      colorFilter: const ColorFilter.mode(
                                        Colors.white,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  )
                                  .animate()
                                  .fadeIn(delay: 300.ms)
                                  .scale(begin: const Offset(0.8, 0.8)),
                            ],
                          ),
                          const Spacer(),
                          // Premium search bar with glassmorphism
                          _buildGlassSearchBar(context, l),
                          const SizedBox(height: 28),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ═══════════════════════════════════════════════════════════════
            // CATEGORIES - Bento Grid Style
            // ═══════════════════════════════════════════════════════════════
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(
                      context,
                      l.translate('categories'),
                      l.translate('see_all'),
                    ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.05),
                    const SizedBox(height: 20),
                    _buildCategoryGrid(context, l),
                  ],
                ),
              ),
            ),

            // ═══════════════════════════════════════════════════════════════
            // FEATURED BANNER - Premium Glassmorphism Card
            // ═══════════════════════════════════════════════════════════════
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildFeaturedBanner(context, l),
              ),
            ),

            // ═══════════════════════════════════════════════════════════════
            // RECENT WISDOM - Clean Card List
            // ═══════════════════════════════════════════════════════════════
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(
                      context,
                      l.translate('recent_wisdom'),
                      l.translate('view_all'),
                    ),
                    const SizedBox(height: 16),
                    _buildRecentList(context, recentContent, l),
                    const SizedBox(height: 100), // Bottom nav padding
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassSearchBar(BuildContext context, AppLocalization l) {
    final isDark = AppTheme.isDark(context);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const SearchScreen(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position:
                    Tween<Offset>(
                      begin: const Offset(0, 0.05),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 400),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.white.withOpacity(0.85),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.15)
                    : Colors.white.withOpacity(0.6),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    LucideIcons.compass,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    l.translate('search_hint'),
                    style: GoogleFonts.outfit(
                      color: AppTheme.textMuted(context),
                      fontSize: 15,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor(context),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withOpacity(0.05)
                          : AppTheme.primaryColor.withOpacity(0.1),
                    ),
                  ),
                  child: Icon(
                    LucideIcons.sliders,
                    size: 18,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.15);
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
            letterSpacing: -0.5,
          ),
        ),
        PressableScale(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategoryScreen(categoryName: title),
            ),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              action,
              style: GoogleFonts.outfit(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryGrid(BuildContext context, AppLocalization l) {
    final isDark = AppTheme.isDark(context);

    final categories = [
      {
        'name': l.translate('shlokas'),
        'icon': LucideIcons.scroll,
        'gradient': [const Color(0xFFE8A838), const Color(0xFFF59E0B)],
      },
      {
        'name': l.translate('strotras'),
        'icon': LucideIcons.mic,
        'gradient': [const Color(0xFFEC4899), const Color(0xFFF472B6)],
      },
      {
        'name': l.translate('poems'),
        'icon': LucideIcons.pencil,
        'gradient': [const Color(0xFF10B981), const Color(0xFF34D399)],
      },
      {
        'name': l.translate('vedas'),
        'icon': LucideIcons.library,
        'gradient': [const Color(0xFF3B82F6), const Color(0xFF60A5FA)],
      },
      {
        'name': l.translate('mantras'),
        'icon': LucideIcons.sparkles,
        'gradient': [const Color(0xFF8B5CF6), const Color(0xFFA78BFA)],
      },
      {
        'name': l.translate('stories'),
        'icon': LucideIcons.messageSquare,
        'gradient': [const Color(0xFFF97316), const Color(0xFFFB923C)],
      },
    ];

    return GridView.builder(
      padding: EdgeInsets.zero,
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
            .fadeIn(delay: (100 + 60 * index).ms)
            .scale(begin: const Offset(0.85, 0.85), curve: Curves.easeOutBack);
      },
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    String title,
    IconData icon,
    List<Color> gradient,
    bool isDark,
  ) {
    return PressableScale(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CategoryScreen(categoryName: title),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardColor(context),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.black.withOpacity(0.03),
          ),
          boxShadow: AppTheme.softShadow(context),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradient,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: gradient[0].withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                    spreadRadius: -4,
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary(context),
                letterSpacing: 0.1,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedBanner(BuildContext context, AppLocalization l) {
    final isDark = AppTheme.isDark(context);

    return PressableScale(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ContentDetailScreen(
            title: "Sacred Journey",
            category: "Featured",
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF1E1E2E),
                    AppTheme.primaryColor.withOpacity(0.3),
                    const Color(0xFF2D1B4E),
                  ]
                : [
                    AppTheme.primaryColor,
                    const Color(0xFFD4922A),
                    const Color(0xFFBF8F20),
                  ],
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.35),
              blurRadius: 32,
              offset: const Offset(0, 16),
              spreadRadius: -8,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative glow
            Positioned(
              top: -30,
              right: -30,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Colors.white.withOpacity(0.2), Colors.transparent],
                  ),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: Text(
                          l.translate('featured'),
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l.translate('featured_title'),
                        style: GoogleFonts.spectral(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.25,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              l.translate('start_now'),
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryDark,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              LucideIcons.arrowRight,
                              size: 16,
                              color: AppTheme.primaryDark,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Animated floating icon
                Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: Icon(
                        LucideIcons.sparkles,
                        size: 40,
                        color: Colors.white,
                      ),
                    )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .rotate(begin: -0.02, end: 0.02, duration: 2000.ms)
                    .scale(
                      begin: const Offset(1, 1),
                      end: const Offset(1.05, 1.05),
                      duration: 2000.ms,
                    ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1);
  }

  Widget _buildRecentList(
    BuildContext context,
    List<SacredContent> content,
    AppLocalization l,
  ) {
    final isDark = AppTheme.isDark(context);

    if (content.isEmpty) {
      return Container(
        height: 260,
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor(context),
                  shape: BoxShape.circle,
                  boxShadow: AppTheme.softShadow(context),
                ),
                child: Icon(
                  LucideIcons.inbox,
                  size: 48,
                  color: AppTheme.primaryColor.withOpacity(0.4),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l.translate('no_content'),
                style: GoogleFonts.outfit(
                  color: AppTheme.textMuted(context),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ).animate().fadeIn();
    }

    return Column(
      children: content.take(3).toList().asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;

        return PressableScale(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ContentDetailScreen(content: item),
            ),
          ),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardColor(context),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.black.withOpacity(0.03),
              ),
              boxShadow: AppTheme.softShadow(context),
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient(context),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                        spreadRadius: -4,
                      ),
                    ],
                  ),
                  child: const Icon(
                    LucideIcons.bookOpen,
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
                      const SizedBox(height: 6),
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
                            child: Text(
                              item.category,
                              style: GoogleFonts.outfit(
                                color: AppTheme.primaryColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
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
              ],
            ),
          ),
        ).animate().fadeIn(delay: (600 + 80 * index).ms).slideX(begin: 0.05);
      }).toList(),
    );
  }
}
