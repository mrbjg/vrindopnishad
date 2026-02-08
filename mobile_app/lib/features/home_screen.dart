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
import '../widgets/animated_effects.dart';
import '../widgets/sacred_card.dart';

/// ═══════════════════════════════════════════════════════════════════════════
/// HOME SCREEN - Stunning, Modern, Immersive Experience
/// Features animated backgrounds, glassmorphism, and rich interactions
/// ═══════════════════════════════════════════════════════════════════════════

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = AppTheme.isDark(context);

    return Scaffold(
      body: AnimatedSacredBackground(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ═══════════════════════════════════════════════════════════════
            // IMMERSIVE HEADER
            // ═══════════════════════════════════════════════════════════════
            SliverToBoxAdapter(
              child: Consumer(
                builder: (context, ref, _) {
                  final lang = ref.watch(languageProvider);
                  final l = AppLocalization(lang);
                  return _buildImmersiveHeader(context, l, isDark);
                },
              ),
            ),

            // ═══════════════════════════════════════════════════════════════
            // QUOTE OF THE DAY
            // ═══════════════════════════════════════════════════════════════
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  AppTheme.space20,
                  AppTheme.space8,
                  AppTheme.space20,
                  0,
                ),
                child: QuoteCard(
                  quote:
                      "You have the right to work, but never to the fruit of work.",
                  source: "Bhagavad Gita 2.47",
                ),
              ),
            ),

            // ═══════════════════════════════════════════════════════════════
            // CATEGORIES GRID - Stunning gradient cards
            // ═══════════════════════════════════════════════════════════════
            SliverToBoxAdapter(
              child: Consumer(
                builder: (context, ref, _) {
                  final lang = ref.watch(languageProvider);
                  final l = AppLocalization(lang);
                  return _buildCategoriesSection(context, l, isDark);
                },
              ),
            ),

            // ═══════════════════════════════════════════════════════════════
            // CONTINUE READING
            // ═══════════════════════════════════════════════════════════════
            SliverToBoxAdapter(
              child: Consumer(
                builder: (context, ref, _) {
                  final content = ref.watch(sacredContentProvider);
                  final lang = ref.watch(languageProvider);
                  final l = AppLocalization(lang);
                  return _buildContinueReading(context, content, l, isDark);
                },
              ),
            ),

            // ═══════════════════════════════════════════════════════════════
            // RECENT CONTENT
            // ═══════════════════════════════════════════════════════════════
            SliverToBoxAdapter(
              child: Consumer(
                builder: (context, ref, _) {
                  final lang = ref.watch(languageProvider);
                  final l = AppLocalization(lang);
                  return Padding(
                    padding: const EdgeInsets.only(top: AppTheme.space24),
                    child: SectionHeader(
                      title: l.translate('recent_wisdom'),
                      action: l.translate('view_all'),
                      onAction: () {},
                      icon: LucideIcons.sparkles,
                    ),
                  );
                },
              ),
            ),

            // CONTENT LIST with glass cards
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.space20,
                AppTheme.space16,
                AppTheme.space20,
                140,
              ),
              sliver: Consumer(
                builder: (context, ref, _) {
                  final content = ref.watch(sacredContentProvider);
                  final visibleCount = ref.watch(visibleItemCountProvider);
                  return _buildContentList(
                    context,
                    content,
                    visibleCount,
                    isDark,
                    ref,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // IMMERSIVE HEADER - Animated greeting with pulsing ॐ
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildImmersiveHeader(
    BuildContext context,
    AppLocalization l,
    bool isDark,
  ) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppTheme.space20,
          AppTheme.space16,
          AppTheme.space20,
          AppTheme.space24,
        ),
        child: Row(
          children: [
            // Pulsing ॐ button with radial menu
            RadialMenu(
              items: [
                RadialMenuItem(
                  icon: LucideIcons.search,
                  label: 'Search',
                  color: AppTheme.peacockBlue,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SearchScreen()),
                  ),
                ),
                RadialMenuItem(
                  icon: LucideIcons.bookmark,
                  label: 'Saved',
                  color: AppTheme.sacredViolet,
                  onTap: () {},
                ),
                RadialMenuItem(
                  icon: LucideIcons.settings,
                  label: 'Settings',
                  color: AppTheme.sereneTeal,
                  onTap: () {},
                ),
              ],
              child: const PulsingOmButton(size: 56),
            ),
            const SizedBox(width: AppTheme.space16),
            // Dynamic animated greeting
            const Expanded(child: AnimatedGreeting()),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CATEGORIES SECTION - Beautiful gradient cards
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildCategoriesSection(
    BuildContext context,
    AppLocalization l,
    bool isDark,
  ) {
    final categories = [
      {
        'name': l.translate('shlokas'),
        'icon': LucideIcons.scroll,
        'gradient': [AppTheme.primaryColor, AppTheme.primaryDark],
        'count': 108,
      },
      {
        'name': l.translate('strotras'),
        'icon': LucideIcons.music,
        'gradient': [AppTheme.lotusRose, const Color(0xFFC2185B)],
        'count': 54,
      },
      {
        'name': l.translate('poems'),
        'icon': LucideIcons.penTool,
        'gradient': [AppTheme.sereneTeal, const Color(0xFF00897B)],
        'count': 72,
      },
      {
        'name': l.translate('mantras'),
        'icon': LucideIcons.sparkles,
        'gradient': [AppTheme.sacredViolet, const Color(0xFF4527A0)],
        'count': 33,
      },
    ];

    return Padding(
      padding: const EdgeInsets.only(top: AppTheme.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.space20),
            child: Row(
              children: [
                Icon(
                  LucideIcons.layoutGrid,
                  size: 18,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Explore',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.space16),
          SizedBox(
            height: 130,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.space20),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                final card = RepaintBoundary(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: index < categories.length - 1
                          ? AppTheme.space12
                          : 0,
                    ),
                    child: SizedBox(
                      width: 140,
                      child: GradientCategoryCard(
                        title: cat['name'] as String,
                        icon: cat['icon'] as IconData,
                        gradientColors: cat['gradient'] as List<Color>,
                        itemCount: cat['count'] as int,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CategoryScreen(
                                categoryName: cat['name'] as String,
                                gradientColors: cat['gradient'] as List<Color>,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
                // Only animate first few items to avoid scroll jank
                if (index < 4) {
                  return card.animate().fadeIn(duration: 300.ms);
                }
                return card;
              },
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CONTINUE READING - Glassmorphism cards
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildContinueReading(
    BuildContext context,
    List<SacredContent> content,
    AppLocalization l,
    bool isDark,
  ) {
    if (content.length < 2) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: AppTheme.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.space20),
            child: Row(
              children: [
                Icon(LucideIcons.bookmark, size: 18, color: AppTheme.lotusRose),
                const SizedBox(width: 8),
                Text(
                  'Continue Reading',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.space12),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.space20),
              itemCount: content.take(4).length,
              itemBuilder: (context, index) {
                final item = content[index];
                final progress = (index + 1) * 0.2;
                final card = RepaintBoundary(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: index < 3 ? AppTheme.space12 : 0,
                    ),
                    child: _buildGlassReadingCard(
                      context,
                      item,
                      progress,
                      isDark,
                    ),
                  ),
                );
                // Only animate first few items
                if (index < 4) {
                  return card.animate().fadeIn(duration: 300.ms);
                }
                return card;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassReadingCard(
    BuildContext context,
    SacredContent item,
    double progress,
    bool isDark,
  ) {
    return GlassCard(
      blur: 6,
      opacity: isDark ? 0.12 : 0.6,
      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ContentDetailScreen(content: item)),
        );
      },
      child: SizedBox(
        width: 180,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient(context),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: const Text(
                    'ॐ',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item.title,
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary(context),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Spacer(),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              child: Stack(
                children: [
                  Container(height: 4, color: AppTheme.surfaceColor(context)),
                  FractionallySizedBox(
                    widthFactor: progress,
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CONTENT LIST - Glass effect cards
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildContentList(
    BuildContext context,
    List<SacredContent> content,
    int visibleCount,
    bool isDark,
    WidgetRef ref,
  ) {
    if (content.isEmpty) {
      return SliverToBoxAdapter(
        child: GlassCard(
          blur: 15,
          opacity: isDark ? 0.1 : 0.5,
          padding: const EdgeInsets.all(AppTheme.space32),
          child: Column(
            children: [
              Icon(
                LucideIcons.inbox,
                size: 48,
                color: AppTheme.textMuted(context),
              ),
              const SizedBox(height: AppTheme.space16),
              Text(
                'No content available',
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  color: AppTheme.textMuted(context),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final itemsToShow = content.take(visibleCount).toList();
    final hasMore = content.length > visibleCount;

    return SliverMainAxisGroup(
      slivers: [
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final item = itemsToShow[index];
              final card = RepaintBoundary(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.space12),
                  child: _buildGlassContentCard(context, item, isDark),
                ),
              );
              // Only animate first 5 items to avoid scroll jank
              if (index < 5) {
                return card.animate().fadeIn(duration: 300.ms);
              }
              return card;
            },
            childCount: itemsToShow.length,
            addAutomaticKeepAlives: true,
            addRepaintBoundaries: true,
          ),
        ),
        if (hasMore)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: AppTheme.space16),
              child: PressableScale(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  ref.read(visibleItemCountProvider.notifier).state += 5;
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    border: Border.all(
                      color: AppTheme.primaryColor.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        LucideIcons.chevronDown,
                        size: 18,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Load More Wisdom',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildGlassContentCard(
    BuildContext context,
    SacredContent item,
    bool isDark,
  ) {
    return GlassCard(
      blur: 8,
      opacity: isDark ? 0.1 : 0.7,
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ContentDetailScreen(content: item)),
        );
      },
      child: Row(
        children: [
          // ॐ Icon with glow
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient(context),
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              boxShadow: AppTheme.glowShadow(AppTheme.primaryColor),
            ),
            child: const Center(
              child: Text(
                'ॐ',
                style: TextStyle(
                  fontSize: 26,
                  color: Colors.white,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppTheme.space12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary(context),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusFull,
                        ),
                      ),
                      child: Text(
                        item.category,
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      LucideIcons.clock,
                      size: 12,
                      color: AppTheme.textMuted(context),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '5 min',
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        color: AppTheme.textMuted(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Animated chevron
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor(context),
              shape: BoxShape.circle,
            ),
            child: Icon(
              LucideIcons.chevronRight,
              size: 16,
              color: AppTheme.textMuted(context),
            ),
          ),
        ],
      ),
    );
  }
}
