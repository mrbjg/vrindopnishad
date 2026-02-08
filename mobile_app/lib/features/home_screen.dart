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
            // NAAM JAP COUNTER - Sacred mantra chanting counter
            // ═══════════════════════════════════════════════════════════════
            SliverToBoxAdapter(
              child: Consumer(
                builder: (context, ref, _) {
                  return _buildNaamJapCounter(context, ref, isDark);
                },
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
  // NAAM JAP COUNTER - Sacred mantra chanting counter
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildNaamJapCounter(
    BuildContext context,
    WidgetRef ref,
    bool isDark,
  ) {
    final count = ref.watch(naamJapCounterProvider);
    final malaCount = count ~/ 108; // Number of complete malas
    final currentInMala = count % 108; // Current position in mala
    final progress = currentInMala / 108;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.space20,
        AppTheme.space20,
        AppTheme.space20,
        0,
      ),
      child: GlassCard(
        blur: 12,
        opacity: isDark ? 0.15 : 0.8,
        borderRadius: BorderRadius.circular(AppTheme.radiusXL),
        padding: const EdgeInsets.all(AppTheme.space20),
        child: Column(
          children: [
            // Header row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.deepSaffron, AppTheme.primaryColor],
                    ),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.deepSaffron.withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    LucideIcons.repeat,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'नाम जप',
                      style: GoogleFonts.notoSansDevanagari(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary(context),
                      ),
                    ),
                    Text(
                      'Naam Jap Counter',
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        color: AppTheme.textMuted(context),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Reset button
                if (count > 0)
                  PressableScale(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      ref.read(naamJapCounterProvider.notifier).state = 0;
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceColor(context),
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusFull,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            LucideIcons.rotateCcw,
                            size: 12,
                            color: AppTheme.textMuted(context),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Reset',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              color: AppTheme.textMuted(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppTheme.space24),
            // Counter display with tappable ॐ
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Mala counter (left)
                Column(
                  children: [
                    Text(
                      '$malaCount',
                      style: GoogleFonts.outfit(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    Text(
                      'Mala',
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        color: AppTheme.textMuted(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: AppTheme.space24),
                // Main tappable ॐ button with progress ring
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    ref.read(naamJapCounterProvider.notifier).state++;
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Progress ring
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 6,
                          backgroundColor: AppTheme.surfaceColor(context),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.deepSaffron,
                          ),
                        ),
                      ),
                      // ॐ button
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppTheme.deepSaffron,
                              AppTheme.primaryColor,
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.deepSaffron.withOpacity(0.5),
                              blurRadius: 20,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'ॐ',
                            style: TextStyle(
                              fontSize: 36,
                              color: Colors.white,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppTheme.space24),
                // Current count (right)
                Column(
                  children: [
                    Text(
                      '$currentInMala',
                      style: GoogleFonts.outfit(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary(context),
                      ),
                    ),
                    Text(
                      '/ 108',
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        color: AppTheme.textMuted(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppTheme.space16),
            // Total count
            Text(
              'Total: $count',
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary(context),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap ॐ to count',
              style: GoogleFonts.outfit(
                fontSize: 11,
                color: AppTheme.textMuted(context),
              ),
            ),
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
  // CONTINUE READING - Premium glassmorphism cards
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
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.lotusRose,
                        AppTheme.lotusRose.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.lotusRose.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    LucideIcons.bookmark,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Continue Reading',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary(context),
                      ),
                    ),
                    Text(
                      'Pick up where you left off',
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
          const SizedBox(height: AppTheme.space16),
          SizedBox(
            height: 170, // Increased to accommodate multi-line content
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
    final progressPercent = (progress * 100).toInt();
    final categoryColors = _getCategoryGradient(item.category);

    return GlassCard(
      blur: 8,
      opacity: isDark ? 0.15 : 0.7,
      borderRadius: BorderRadius.circular(AppTheme.radiusXL),
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ContentDetailScreen(content: item)),
        );
      },
      child: SizedBox(
        width: 220, // Wider cards
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top: Category badge + ॐ icon
            Row(
              children: [
                // Category badge with gradient
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: categoryColors),
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                    boxShadow: [
                      BoxShadow(
                        color: categoryColors.first.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    item.category,
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Spacer(),
                // Sacred ॐ icon
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    'ॐ',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Title - adaptive: short titles on 1 line, long on 2
            Text(
              item.title,
              style: GoogleFonts.outfit(
                fontSize: item.title.length > 25 ? 13 : 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary(context),
                height: 1.3,
              ),
              maxLines: item.title.length > 25 ? 2 : 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            // Sanskrit preview - split by delimiters for readability
            Text(
              _formatSanskritPreview(item.sanskritText, 2),
              style: GoogleFonts.notoSansDevanagari(
                fontSize: 10,
                color: AppTheme.textMuted(context),
                height: 1.5,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            // Progress section
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusFull,
                        ),
                        child: Stack(
                          children: [
                            Container(
                              height: 5,
                              color: AppTheme.surfaceColor(context),
                            ),
                            FractionallySizedBox(
                              widthFactor: progress,
                              child: Container(
                                height: 5,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: categoryColors,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    AppTheme.radiusFull,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                // Progress percentage
                Text(
                  '$progressPercent%',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: categoryColors.first,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper to get category-specific gradient colors
  List<Color> _getCategoryGradient(String category) {
    switch (category.toLowerCase()) {
      case 'mantra':
        return [AppTheme.sacredViolet, const Color(0xFF8B5CF6)];
      case 'stotra':
        return [AppTheme.sereneTeal, const Color(0xFF14B8A6)];
      case 'chalisa':
        return [AppTheme.deepSaffron, AppTheme.primaryColor];
      case 'aarti':
        return [AppTheme.lotusRose, const Color(0xFFF472B6)];
      case 'bhajan':
        return [AppTheme.peacockBlue, const Color(0xFF38BDF8)];
      default:
        return [AppTheme.primaryColor, AppTheme.primaryDark];
    }
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
    final categoryColors = _getCategoryGradient(item.category);

    return GlassCard(
      blur: 10,
      opacity: isDark ? 0.12 : 0.75,
      borderRadius: BorderRadius.circular(AppTheme.radiusXL),
      borderColor: categoryColors.first.withOpacity(0.15),
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ContentDetailScreen(content: item)),
        );
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ॐ Icon with category-specific gradient
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: categoryColors,
              ),
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              boxShadow: [
                BoxShadow(
                  color: categoryColors.first.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'ॐ',
                style: TextStyle(
                  fontSize: 28,
                  color: Colors.white,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppTheme.space16),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title - adaptive sizing
                Text(
                  item.title,
                  style: GoogleFonts.outfit(
                    fontSize: item.title.length > 30 ? 15 : 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary(context),
                    height: 1.25,
                  ),
                  maxLines: item.title.length > 30 ? 2 : 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                // Sanskrit preview - split by delimiters for readability
                Text(
                  _formatSanskritPreview(item.sanskritText, 2),
                  style: GoogleFonts.notoSansDevanagari(
                    fontSize: 11,
                    color: AppTheme.textSecondary(context),
                    height: 1.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // Category and meta row
                Row(
                  children: [
                    // Category chip with gradient background
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            categoryColors.first.withOpacity(0.2),
                            categoryColors.last.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusFull,
                        ),
                        border: Border.all(
                          color: categoryColors.first.withOpacity(0.3),
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getCategoryIcon(item.category),
                            size: 10,
                            color: categoryColors.first,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item.category,
                            style: GoogleFonts.outfit(
                              fontSize: 10,
                              color: categoryColors.first,
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
                      '5 min read',
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
          // Arrow with gradient background
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  categoryColors.first.withOpacity(0.1),
                  categoryColors.last.withOpacity(0.05),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              LucideIcons.chevronRight,
              size: 16,
              color: categoryColors.first,
            ),
          ),
        ],
      ),
    );
  }

  // Helper to get category-specific icon
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'mantra':
        return LucideIcons.sparkles;
      case 'stotra':
        return LucideIcons.scroll;
      case 'chalisa':
        return LucideIcons.book;
      case 'aarti':
        return LucideIcons.flame;
      case 'bhajan':
        return LucideIcons.music;
      default:
        return LucideIcons.fileText;
    }
  }

  // Helper to format Sanskrit text by splitting on delimiters
  // Splits by | || , \n and joins with newlines for display
  String _formatSanskritPreview(String text, int maxLines) {
    // Split by common Sanskrit verse delimiters
    final delimiters = RegExp(r'\s*[\|।॥,\n]+\s*');
    final parts = text
        .split(delimiters)
        .where((s) => s.trim().isNotEmpty)
        .toList();

    if (parts.isEmpty) return text;

    // Take only first maxLines parts and join with newlines
    final linesToShow = parts.take(maxLines).join('\n');
    return linesToShow;
  }
}
