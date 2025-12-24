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

class CategoryScreen extends ConsumerStatefulWidget {
  final String categoryName;
  final List<Color> gradientColors;

  const CategoryScreen({
    super.key,
    required this.categoryName,
    required this.gradientColors,
  });

  @override
  ConsumerState<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends ConsumerState<CategoryScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'All';
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

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

    final normalizedCategory = widget.categoryName.endsWith('s')
        ? widget.categoryName.substring(0, widget.categoryName.length - 1)
        : widget.categoryName;

    var filteredContent = allContent
        .where(
          (item) =>
              item.category.toLowerCase() == normalizedCategory.toLowerCase(),
        )
        .toList();

    if (_searchQuery.isNotEmpty) {
      filteredContent = filteredContent
          .where(
            (item) =>
                item.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                item.translation.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ),
          )
          .toList();
    }

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0A0A0F)
          : const Color(0xFFF5F3F0),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Header with category gradient
          SliverToBoxAdapter(
            child: Container(
              height: _isSearching ? 220 : 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    widget.gradientColors[0],
                    widget.gradientColors[1],
                    widget.gradientColors[0].withOpacity(0.8),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(48),
                  bottomRight: Radius.circular(48),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Navigation row
                      Row(
                        children: [
                          _buildHeaderButton(
                            icon: LucideIcons.arrowLeft,
                            onTap: () => Navigator.pop(context),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              widget.categoryName,
                              style: GoogleFonts.spectral(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                          _buildHeaderButton(
                            icon: _isSearching
                                ? LucideIcons.x
                                : LucideIcons.search,
                            onTap: () => setState(() {
                              _isSearching = !_isSearching;
                              if (!_isSearching) {
                                _searchController.clear();
                                _searchQuery = '';
                              }
                            }),
                          ),
                          const SizedBox(width: 12),
                          _buildHeaderButton(
                            icon: LucideIcons.sliders,
                            onTap: () => _showFilterSheet(context, l),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Search bar
                      if (_isSearching) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: TextField(
                            controller: _searchController,
                            autofocus: true,
                            style: GoogleFonts.outfit(fontSize: 15),
                            decoration: InputDecoration(
                              hintText:
                                  "${l.translate('search')} in ${widget.categoryName}...",
                              hintStyle: GoogleFonts.outfit(
                                color: Colors.black45,
                              ),
                              border: InputBorder.none,
                              icon: Icon(
                                LucideIcons.search,
                                color: widget.gradientColors[0],
                                size: 20,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 16,
                              ),
                            ),
                            onChanged: (value) =>
                                setState(() => _searchQuery = value),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      // Stats badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              LucideIcons.bookOpen,
                              size: 16,
                              color: Colors.white.withOpacity(0.9),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "${filteredContent.length} ${l.translate('sacred_texts')}",
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Content list
          filteredContent.isEmpty
              ? SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmptyState(context, l),
                )
              : SliverPadding(
                  padding: const EdgeInsets.all(24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildContentCard(
                        context,
                        filteredContent[index],
                        index,
                        isDark,
                      ),
                      childCount: filteredContent.length,
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return PressableScale(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  void _showFilterSheet(BuildContext context, AppLocalization l) {
    final isDark = AppTheme.isDark(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppTheme.textMuted(context).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l.translate('filter_options'),
                style: GoogleFonts.spectral(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary(context),
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children:
                    [
                      'All',
                      l.translate('recent'),
                      l.translate('popular'),
                      l.translate('a_z'),
                    ].map((filter) {
                      final isSelected = _selectedFilter == filter;
                      return PressableScale(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setState(() => _selectedFilter = filter);
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? LinearGradient(
                                    colors: [
                                      AppTheme.primaryColor,
                                      AppTheme.primaryDark,
                                    ],
                                  )
                                : null,
                            color: isSelected
                                ? null
                                : (isDark
                                      ? Colors.white.withOpacity(0.05)
                                      : Colors.black.withOpacity(0.03)),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            filter,
                            style: GoogleFonts.outfit(
                              color: isSelected
                                  ? Colors.white
                                  : AppTheme.textPrimary(context),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalization l) {
    return Center(
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
              LucideIcons.folderOpen,
              size: 52,
              color: AppTheme.primaryColor.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            "${l.translate('no_content')} ${widget.categoryName}",
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary(context),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            l.translate('check_back'),
            style: GoogleFonts.outfit(
              color: AppTheme.textMuted(context),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentCard(
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
          MaterialPageRoute(builder: (_) => ContentDetailScreen(content: item)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(24),
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
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: widget.gradientColors),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                LucideIcons.bookOpen,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w600,
                      fontSize: 17,
                      color: AppTheme.textPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.translation,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      color: AppTheme.textSecondary(context),
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              LucideIcons.chevronRight,
              size: 18,
              color: widget.gradientColors[0],
            ),
          ],
        ),
      ),
    );
  }
}
