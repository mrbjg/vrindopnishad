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

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<SacredContent> _results = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    // Auto-focus search field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearch(String query, List<SacredContent> allContent) {
    setState(() {
      if (query.isEmpty) {
        _results = [];
        _isSearching = false;
      } else {
        _isSearching = true;
        _results = allContent
            .where(
              (item) =>
                  item.title.toLowerCase().contains(query.toLowerCase()) ||
                  item.category.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final allContent = ref.watch(sacredContentProvider);
    final currentLanguage = ref.watch(languageProvider);
    final l = AppLocalization(currentLanguage);
    final isDark = AppTheme.isDark(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor(context),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l.translate('search'),
                                style: GoogleFonts.spectral(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary(context),
                                  letterSpacing: -0.5,
                                ),
                              ).animate().fadeIn().slideX(begin: -0.1),
                              const SizedBox(height: 6),
                              Text(
                                l.translate('find_wisdom'),
                                style: GoogleFonts.outfit(
                                  color: AppTheme.textMuted(context),
                                  fontSize: 15,
                                ),
                              ).animate().fadeIn(delay: 50.ms),
                            ],
                          ),
                        ),
                        Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppTheme.primaryColor.withOpacity(0.15),
                                    AppTheme.glowPurple.withOpacity(0.15),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Icon(
                                LucideIcons.sparkles,
                                color: AppTheme.primaryColor,
                                size: 24,
                              ),
                            )
                            .animate(onPlay: (c) => c.repeat(reverse: true))
                            .scale(
                              begin: const Offset(1, 1),
                              end: const Offset(1.1, 1.1),
                              duration: 1500.ms,
                            ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withOpacity(0.08)
                                : Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withOpacity(0.1)
                                  : Colors.black.withOpacity(0.05),
                              width: 1.5,
                            ),
                            boxShadow: AppTheme.softShadow(context),
                          ),
                          child: TextField(
                            controller: _searchController,
                            focusNode: _focusNode,
                            onChanged: (query) => _onSearch(query, allContent),
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              color: AppTheme.textPrimary(context),
                            ),
                            decoration: InputDecoration(
                              hintText: l.translate('search_hint'),
                              hintStyle: GoogleFonts.outfit(
                                color: AppTheme.textMuted(context),
                              ),
                              prefixIcon: Container(
                                padding: const EdgeInsets.all(12),
                                margin: const EdgeInsets.only(
                                  left: 8,
                                  right: 4,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor.withOpacity(
                                      0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    LucideIcons.compass,
                                    color: AppTheme.primaryColor,
                                    size: 18,
                                  ),
                                ),
                              ),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: AppTheme.textMuted(
                                            context,
                                          ).withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          LucideIcons.x,
                                          size: 14,
                                          color: AppTheme.textMuted(context),
                                        ),
                                      ),
                                      onPressed: () {
                                        _searchController.clear();
                                        _onSearch("", allContent);
                                      },
                                    )
                                  : null,
                              filled: true,
                              fillColor: Colors.transparent,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 18,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(22),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(22),
                                borderSide: BorderSide(
                                  color: AppTheme.primaryColor,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
          _isSearching
              ? _buildSliverSearchResults(context, l, isDark)
              : SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverToBoxAdapter(
                    child: _buildSuggestions(context, l, allContent, isDark),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildSuggestions(
    BuildContext context,
    AppLocalization l,
    List<SacredContent> allContent,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.glowOrange, AppTheme.primaryColor],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                LucideIcons.trendingUp,
                size: 14,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              "Trending Now",
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: AppTheme.textPrimary(context),
              ),
            ),
          ],
        ).animate().fadeIn(delay: 150.ms),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildTag(context, "Bhagavad Gita", allContent, isDark, 0),
            _buildTag(context, "Hanuman Chalisa", allContent, isDark, 1),
            _buildTag(context, "Shiva Tandava", allContent, isDark, 2),
            _buildTag(context, "Gayatri Mantra", allContent, isDark, 3),
          ],
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.glowPurple, AppTheme.glowBlue],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                LucideIcons.sparkles,
                size: 14,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              "Quick Access",
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: AppTheme.textPrimary(context),
              ),
            ),
          ],
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildCategoryChip(
              context,
              LucideIcons.scroll,
              "Shlokas",
              isDark,
              0,
            ),
            _buildCategoryChip(context, LucideIcons.mic, "Stotras", isDark, 1),
            _buildCategoryChip(
              context,
              LucideIcons.sparkles,
              "Mantras",
              isDark,
              2,
            ),
            _buildCategoryChip(
              context,
              LucideIcons.library,
              "Vedas",
              isDark,
              3,
            ),
          ],
        ),
        const SizedBox(height: 48),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                      LucideIcons.compass,
                      size: 52,
                      color: AppTheme.primaryColor.withOpacity(0.4),
                    ),
                  )
                  .animate()
                  .fadeIn(delay: 300.ms)
                  .scale(begin: const Offset(0.8, 0.8)),
              const SizedBox(height: 24),
              Text(
                l.translate('discover_wisdom_short'),
                style: GoogleFonts.outfit(
                  color: AppTheme.textMuted(context),
                  fontSize: 15,
                ),
              ).animate().fadeIn(delay: 350.ms),
            ],
          ),
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildTag(
    BuildContext context,
    String label,
    List<SacredContent> allContent,
    bool isDark,
    int index,
  ) {
    return PressableScale(
          onTap: () {
            HapticFeedback.lightImpact();
            _searchController.text = label;
            _onSearch(label, allContent);
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.06)
                      : Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.primaryColor.withOpacity(0.2),
                  ),
                  boxShadow: AppTheme.softShadow(context),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      LucideIcons.hash,
                      size: 14,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: AppTheme.textPrimary(context),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(delay: (200 + 50 * index).ms)
        .scale(begin: const Offset(0.9, 0.9));
  }

  Widget _buildSliverSearchResults(
    BuildContext context,
    AppLocalization l,
    bool isDark,
  ) {
    if (_results.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: _buildNoResults(context, l),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      LucideIcons.checkCircle,
                      size: 16,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "${_results.length} ${l.translate('results_found')}",
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: AppTheme.textPrimary(context),
                    ),
                  ),
                ],
              ),
            );
          }
          final item = _results[index - 1];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildResultCard(context, item, index - 1, isDark),
          );
        }, childCount: _results.length + 1),
      ),
    );
  }

  Widget _buildNoResults(BuildContext context, AppLocalization l) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              LucideIcons.searchX,
              size: 48,
              color: Colors.red.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l.translate('no_results'),
            style: GoogleFonts.outfit(
              color: AppTheme.textMuted(context),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Try a different search term",
            style: GoogleFonts.outfit(
              color: AppTheme.textMuted(context).withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(
    BuildContext context,
    SacredContent item,
    int index,
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
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient(context),
                      borderRadius: BorderRadius.circular(16),
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
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: AppTheme.textPrimary(context),
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
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
          ),
        ),
      ),
    ).animate().fadeIn(delay: (50 * index).ms).slideX(begin: 0.05);
  }

  Widget _buildCategoryChip(
    BuildContext context,
    IconData icon,
    String label,
    bool isDark,
    int index,
  ) {
    return PressableScale(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryScreen(categoryName: label),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.06)
              : AppTheme.primaryColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : AppTheme.primaryColor.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppTheme.primaryColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary(context),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (250 + 50 * index).ms).slideY(begin: 0.1);
  }
}
