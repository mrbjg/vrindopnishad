import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/animated_effects.dart';
import '../core/theme.dart';
import '../core/design_system.dart';
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
    final currentLanguage = ref.watch(languageProvider);
    final l = AppLocalization(currentLanguage);

    final filteredContent = ref.watch(searchedContentProvider(_searchQuery));

    return Scaffold(
      backgroundColor: PremiumTokens.charcoal,
      body: Stack(
        children: [
          const Positioned.fill(child: AnimatedSacredBackground()),
          
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Header with Search bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.translate('search'),
                          style: GoogleFonts.spectral(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 24),
                        PremiumUI.glassCard(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          borderRadius: 20,
                          child: TextField(
                            controller: _searchController,
                            focusNode: _focusNode,
                            style: GoogleFonts.outfit(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: l.translate('search_hint'),
                              hintStyle: GoogleFonts.outfit(color: Colors.white24),
                              border: InputBorder.none,
                              icon: const Icon(Iconsax.search_normal, color: PremiumTokens.saffronGlow, size: 20),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Iconsax.close_circle, size: 18, color: Colors.white38),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() {
                                          _searchQuery = '';
                                          _isSearching = false;
                                        });
                                      },
                                    )
                                  : null,
                            ),
                            onChanged: (v) => setState(() {
                              _searchQuery = v;
                              _isSearching = v.isNotEmpty;
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                if (!_isSearching) ...[
                  // Trending tags
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionLabel("Trending Wisdom"),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              'Bhagavad Gita',
                              'Hanuman Chalisa',
                              'Gayatri Mantra',
                              'Shiv Tandav',
                            ].map((tag) => _buildTrendingTag(tag)).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Quick Access Categories
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionLabel("Sacred Categories"),
                          const SizedBox(height: 16),
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 2.5,
                            children: [
                              _buildCategoryTile('Shlokas', Iconsax.document_text, [const Color(0xFFE8A838), const Color(0xFFD97706)]),
                              _buildCategoryTile('Strotras', Iconsax.music, [const Color(0xFFEC4899), const Color(0xFFDB2777)]),
                              _buildCategoryTile('Mantras', Iconsax.magic_star, [const Color(0xFF8B5CF6), const Color(0xFF7C3AED)]),
                              _buildCategoryTile('Poems', Iconsax.edit_2, [const Color(0xFF10B981), const Color(0xFF059669)]),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  // Search Results
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: filteredContent.isEmpty
                        ? SliverFillRemaining(hasScrollBody: false, child: _buildEmptyResults())
                        : SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _buildSearchResultCard(context, filteredContent[index]),
                              ),
                              childCount: filteredContent.length,
                            ),
                          ),
                  ),
                ],

                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: GoogleFonts.outfit(
        color: Colors.white24,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 2,
      ),
    );
  }

  Widget _buildTrendingTag(String tag) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _searchController.text = tag;
        setState(() {
          _searchQuery = tag;
          _isSearching = true;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Iconsax.chart_2, size: 14, color: PremiumTokens.saffronGlow),
            const SizedBox(width: 8),
            Text(tag, style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTile(String label, IconData icon, List<Color> colors) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CategoryScreen(categoryName: label, gradientColors: colors),
          ),
        );
      },
      child: PremiumUI.glassCard(
        padding: const EdgeInsets.all(12),
        borderRadius: 16,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colors[0].withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: colors[0], size: 18),
            ),
            const SizedBox(width: 12),
            Text(label, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResultCard(BuildContext context, SacredContent item) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ContentDetailScreen(content: item)),
        );
      },
      child: PremiumUI.glassCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: PremiumTokens.saffronPremiumGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(child: Text('ॐ', style: TextStyle(color: Colors.white, fontSize: 20))),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.displayTitle,
                    style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.category,
                    style: GoogleFonts.outfit(color: PremiumTokens.saffronGlow, fontSize: 11),
                  ),
                ],
              ),
            ),
            const Icon(Iconsax.arrow_right_3, color: Colors.white12, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyResults() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Iconsax.search_zoom_out, size: 48, color: Colors.white10),
        const SizedBox(height: 16),
        Text(
          "No results found on this path",
          style: GoogleFonts.outfit(color: Colors.white38, fontSize: 15),
        ),
      ],
    );
  }
}
