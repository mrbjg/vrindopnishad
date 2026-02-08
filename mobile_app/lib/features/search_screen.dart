import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/animated_effects.dart';
import '../core/theme.dart';
import '../core/providers.dart';
import '../core/localization.dart';
import '../core/content_provider.dart';
import 'content_detail_screen.dart';
import 'category_screen.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allContent = ref.watch(sacredContentProvider);
    final currentLanguage = ref.watch(languageProvider);
    final l = AppLocalization(currentLanguage);
    final isDark = AppTheme.isDark(context);

    // Filter content based on search
    final filteredContent = _searchQuery.isEmpty
        ? <SacredContent>[]
        : allContent
              .where(
                (item) =>
                    item.title.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ||
                    item.translation.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ||
                    item.category.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ),
              )
              .toList();

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0A0A0F)
          : const Color(0xFFF8F6F3),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header with Search
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title row
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.primaryColor,
                                AppTheme.deepSaffron,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusMedium,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryColor.withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            LucideIcons.search,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l.translate('search'),
                              style: GoogleFonts.spectral(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary(context),
                              ),
                            ),
                            Text(
                              'Find sacred wisdom',
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                color: AppTheme.textMuted(context),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Search input card
                    GlassCard(
                      blur: 12,
                      opacity: isDark ? 0.12 : 0.8,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: TextField(
                        controller: _searchController,
                        focusNode: _focusNode,
                        style: GoogleFonts.outfit(
                          color: AppTheme.textPrimary(context),
                          fontSize: 15,
                        ),
                        decoration: InputDecoration(
                          hintText: l.translate('search_hint'),
                          hintStyle: GoogleFonts.outfit(
                            color: AppTheme.textMuted(context),
                          ),
                          border: InputBorder.none,
                          icon: Icon(
                            LucideIcons.search,
                            color: AppTheme.primaryColor,
                            size: 20,
                          ),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: Icon(
                                    LucideIcons.x,
                                    size: 18,
                                    color: AppTheme.textMuted(context),
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                )
                              : null,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                            _isSearching = value.isNotEmpty;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content - Trending & Categories when not searching
            if (!_isSearching) ...[
              // Trending section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            LucideIcons.flame,
                            size: 18,
                            color: AppTheme.deepSaffron,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Trending Now',
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary(context),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children:
                            [
                                  'Bhagavad Gita',
                                  'Hanuman Chalisa',
                                  'Gayatri Mantra',
                                  'Shiv Tandav',
                                  'Radha Kripa Kataksh',
                                ]
                                .map(
                                  (tag) =>
                                      _buildTrendingTag(context, tag, isDark),
                                )
                                .toList(),
                      ),
                    ],
                  ),
                ),
              ),

              // Quick Access Categories
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            LucideIcons.layoutGrid,
                            size: 18,
                            color: AppTheme.primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Browse Categories',
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary(context),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Category grid
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 2.2,
                        children: [
                          _buildCategoryCard(
                            context,
                            'Shlokas',
                            LucideIcons.scroll,
                            [const Color(0xFFE8A838), const Color(0xFFD97706)],
                            isDark,
                          ),
                          _buildCategoryCard(
                            context,
                            'Strotras',
                            LucideIcons.music,
                            [const Color(0xFFEC4899), const Color(0xFFDB2777)],
                            isDark,
                          ),
                          _buildCategoryCard(
                            context,
                            'Mantras',
                            LucideIcons.sparkles,
                            [const Color(0xFF8B5CF6), const Color(0xFF7C3AED)],
                            isDark,
                          ),
                          _buildCategoryCard(
                            context,
                            'Poems',
                            LucideIcons.feather,
                            [const Color(0xFF10B981), const Color(0xFF059669)],
                            isDark,
                          ),
                          _buildCategoryCard(
                            context,
                            'Aartis',
                            LucideIcons.flame,
                            [const Color(0xFFF97316), const Color(0xFFEA580C)],
                            isDark,
                          ),
                          _buildCategoryCard(
                            context,
                            'Vedas',
                            LucideIcons.bookOpen,
                            [const Color(0xFF3B82F6), const Color(0xFF2563EB)],
                            isDark,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Recent searches hint
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
                  child: GlassCard(
                    blur: 10,
                    opacity: isDark ? 0.08 : 0.6,
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            LucideIcons.lightbulb,
                            color: AppTheme.primaryColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Search Tip',
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary(context),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Try searching by title, category, or meaning',
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  color: AppTheme.textMuted(context),
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
            ],

            // Search results
            if (_isSearching) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.fileSearch,
                        size: 16,
                        color: AppTheme.textMuted(context),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${filteredContent.length} results found',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          color: AppTheme.textMuted(context),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              filteredContent.isEmpty
                  ? SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(48),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceColor(context),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                LucideIcons.searchX,
                                size: 40,
                                color: AppTheme.textMuted(context),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'No results found',
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary(context),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try a different search term',
                              style: GoogleFonts.outfit(
                                color: AppTheme.textMuted(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _buildResultCard(
                            context,
                            filteredContent[index],
                            isDark,
                          ),
                          childCount: filteredContent.length,
                        ),
                      ),
                    ),
            ],

            // Bottom padding
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingTag(BuildContext context, String tag, bool isDark) {
    return PressableScale(
      onTap: () {
        HapticFeedback.lightImpact();
        _searchController.text = tag;
        setState(() {
          _searchQuery = tag;
          _isSearching = true;
        });
      },
      child: GlassCard(
        blur: 8,
        opacity: isDark ? 0.1 : 0.7,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.trendingUp, size: 14, color: AppTheme.deepSaffron),
            const SizedBox(width: 8),
            Text(
              tag,
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    String label,
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
              categoryName: label,
              gradientColors: gradientColors,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          boxShadow: [
            BoxShadow(
              color: gradientColors.first.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background pattern
            Positioned(
              right: -10,
              bottom: -10,
              child: Icon(icon, size: 50, color: Colors.white.withOpacity(0.2)),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Icon(icon, size: 22, color: Colors.white),
                  const SizedBox(width: 10),
                  Text(
                    label,
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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

  Widget _buildResultCard(
    BuildContext context,
    SacredContent item,
    bool isDark,
  ) {
    final categoryColors = _getCategoryColor(item.category);

    return PressableScale(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ContentDetailScreen(content: item)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: GlassCard(
          blur: 10,
          opacity: isDark ? 0.1 : 0.75,
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: categoryColors),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: Center(
                  child: Text(
                    'ॐ',
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title.replaceAll('\n', ', '),
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
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: categoryColors.first.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item.category,
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              color: categoryColors.first,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                LucideIcons.chevronRight,
                size: 18,
                color: AppTheme.textMuted(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Color> _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'mantra':
        return [const Color(0xFF8B5CF6), const Color(0xFF7C3AED)];
      case 'aarti':
        return [const Color(0xFFF97316), const Color(0xFFEA580C)];
      case 'shloka':
        return [const Color(0xFFE8A838), const Color(0xFFD97706)];
      case 'stotra':
        return [const Color(0xFFEC4899), const Color(0xFFDB2777)];
      case 'poem':
        return [const Color(0xFF10B981), const Color(0xFF059669)];
      default:
        return [AppTheme.primaryColor, AppTheme.deepSaffron];
    }
  }
}
