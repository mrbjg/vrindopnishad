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

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
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
          : const Color(0xFFF5F3F0),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 20,
                left: 24,
                right: 24,
                bottom: 24,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
                      : [const Color(0xFFFEF3C7), const Color(0xFFFBD38D)],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.translate('search'),
                    style: GoogleFonts.spectral(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Find sacred texts, mantras & more",
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Search input
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.08)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withOpacity(0.1)
                            : Colors.black.withOpacity(0.05),
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: GoogleFonts.outfit(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 15,
                      ),
                      decoration: InputDecoration(
                        hintText: l.translate('search_hint'),
                        hintStyle: GoogleFonts.outfit(
                          color: isDark ? Colors.white54 : Colors.black45,
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
                                  color: isDark
                                      ? Colors.white54
                                      : Colors.black45,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
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

          // Content
          if (!_isSearching) ...[
            // Trending section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Trending Now",
                      style: GoogleFonts.spectral(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children:
                          [
                                "Bhagavad Gita",
                                "Hanuman Chalisa",
                                "Gayatri Mantra",
                                "Shiv Tandav",
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

            // Quick categories
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Quick Access",
                      style: GoogleFonts.spectral(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children:
                          [
                                {
                                  "label": "Shlokas",
                                  "icon": LucideIcons.scroll,
                                  "color": const Color(0xFFE8A838),
                                },
                                {
                                  "label": "Strotras",
                                  "icon": LucideIcons.music,
                                  "color": const Color(0xFFEC4899),
                                },
                                {
                                  "label": "Mantras",
                                  "icon": LucideIcons.sparkles,
                                  "color": const Color(0xFF8B5CF6),
                                },
                                {
                                  "label": "Vedas",
                                  "icon": LucideIcons.bookOpen,
                                  "color": const Color(0xFF3B82F6),
                                },
                              ]
                              .map(
                                (cat) => _buildCategoryChip(
                                  context,
                                  cat['label'] as String,
                                  cat['icon'] as IconData,
                                  cat['color'] as Color,
                                  isDark,
                                ),
                              )
                              .toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Search results
          if (_isSearching) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: Text(
                  "${filteredContent.length} results found",
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: AppTheme.textMuted(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            filteredContent.isEmpty
                ? SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          Icon(
                            LucideIcons.searchX,
                            size: 48,
                            color: AppTheme.textMuted(context),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "No results found",
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary(context),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Try a different search term",
                            style: GoogleFonts.outfit(
                              color: AppTheme.textMuted(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.06) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.05),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              LucideIcons.trendingUp,
              size: 14,
              color: AppTheme.primaryColor,
            ),
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

  Widget _buildCategoryChip(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
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
              gradientColors: [color, color.withOpacity(0.7)],
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.06) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.05),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary(context),
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.08)
                : Colors.black.withOpacity(0.04),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient(context),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                LucideIcons.bookOpen,
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
                  Text(
                    item.category,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
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
    );
  }
}
