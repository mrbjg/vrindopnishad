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

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<SacredContent> _results = [];
  bool _isSearching = false;

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

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                l.translate('search'),
                style: GoogleFonts.spectral(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary(context),
                ),
              ).animate().fadeIn().slideX(begin: -0.1),
              const SizedBox(height: 8),
              Text(
                l.translate('find_wisdom'),
                style: GoogleFonts.outfit(
                  color: AppTheme.textMuted(context),
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 28),

              // Search bar
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.cardColor(context),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppTheme.softShadow(context),
                ),
                child: TextField(
                  controller: _searchController,
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
                    prefixIcon: Icon(
                      LucideIcons.search,
                      color: AppTheme.primaryColor,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              LucideIcons.x,
                              size: 18,
                              color: AppTheme.textMuted(context),
                            ),
                            onPressed: () {
                              _searchController.clear();
                              _onSearch("", allContent);
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppTheme.cardColor(context),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        color: AppTheme.primaryColor,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),

              const SizedBox(height: 32),

              if (!_isSearching) ...[
                // Trending tags
                Text(
                  l.translate('popular_searches'),
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: AppTheme.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildTag(context, "Bhagavad Gita", allContent, l),
                    _buildTag(context, "Hanuman Chalisa", allContent, l),
                    _buildTag(context, "Shiva Tandava", allContent, l),
                    _buildTag(context, "Gayatri Mantra", allContent, l),
                  ],
                ).animate().fadeIn(delay: 200.ms),

                const Spacer(),

                // Empty illustration
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceColor(context),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          LucideIcons.search,
                          size: 48,
                          color: AppTheme.primaryColor.withOpacity(0.3),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        l.translate('discover_wisdom_short'),
                        style: GoogleFonts.outfit(
                          color: AppTheme.textMuted(context),
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 300.ms),

                const Spacer(),
              ] else ...[
                // Results
                Text(
                  "${_results.length} ${l.translate('results_found')}",
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: AppTheme.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: _results.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                LucideIcons.searchX,
                                size: 48,
                                color: AppTheme.textMuted(context),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                l.translate('no_results'),
                                style: GoogleFonts.outfit(
                                  color: AppTheme.textMuted(context),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _results.length,
                          itemBuilder: (context, index) {
                            final item = _results[index];
                            return _buildResultCard(context, item, index);
                          },
                        ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(
    BuildContext context,
    String label,
    List<SacredContent> allContent,
    AppLocalization l,
  ) {
    return GestureDetector(
      onTap: () {
        _searchController.text = label;
        _onSearch(label, allContent);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.cardColor(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
          boxShadow: AppTheme.softShadow(context),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 14,
            color: AppTheme.textPrimary(context),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard(BuildContext context, SacredContent item, int index) {
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
          width: 50,
          height: 50,
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
        title: Text(
          item.title,
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary(context),
          ),
        ),
        subtitle: Text(
          item.category,
          style: GoogleFonts.outfit(
            color: AppTheme.textMuted(context),
            fontSize: 13,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor(context),
            borderRadius: BorderRadius.circular(10),
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
    ).animate().fadeIn(delay: (50 * index).ms).slideX(begin: 0.05);
  }
}
