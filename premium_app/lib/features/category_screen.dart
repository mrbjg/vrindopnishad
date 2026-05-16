import 'package:flutter/material.dart';
import '../core/content_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/design_system.dart';
import '../core/localization.dart';
import '../core/providers.dart';
import '../features/content_detail_screen.dart';
import '../widgets/animated_effects.dart';
import 'package:flutter/services.dart';

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
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentLanguage = ref.watch(languageProvider);
    final l = AppLocalization(currentLanguage);

    final normalizedCategory = widget.categoryName.endsWith('s')
        ? widget.categoryName.substring(0, widget.categoryName.length - 1)
        : widget.categoryName;

    var filteredContent = ref.watch(filteredContentProvider(normalizedCategory));

    if (_searchQuery.isNotEmpty) {
      filteredContent = filteredContent
          .where((item) =>
              item.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              item.translation.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    return Scaffold(
      backgroundColor: PremiumTokens.scaffoldBg,
      body: Stack(
        children: [
          const Positioned.fill(child: AnimatedSacredBackground()),
          
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Premium Header
              SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        widget.gradientColors[0].withValues(alpha: 0.3),
                        widget.gradientColors[1].withValues(alpha: 0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _buildGlassIcon(Iconsax.arrow_left, () => Navigator.pop(context)),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  widget.categoryName,
                                  style: GoogleFonts.spectral(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: PremiumTokens.textPrimary,
                                  ),
                                ),
                              ),
                              _buildGlassIcon(
                                _isSearching ? Iconsax.close_circle : Iconsax.search_normal,
                                () => setState(() {
                                  _isSearching = !_isSearching;
                                  if (!_isSearching) {
                                    _searchController.clear();
                                    _searchQuery = '';
                                  }
                                }),
                              ),
                            ],
                          ),
                          
                          if (_isSearching) ...[
                            const SizedBox(height: 24),
                            PremiumUI.glassCard(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              borderRadius: 16,
                              child: TextField(
                                controller: _searchController,
                                autofocus: true,
                                style: GoogleFonts.outfit(color: PremiumTokens.textPrimary),
                                decoration: InputDecoration(
                                  hintText: "${l.translate('search')}...",
                                  hintStyle: GoogleFonts.outfit(color: PremiumTokens.textMuted),
                                  border: InputBorder.none,
                                  icon: Icon(Iconsax.search_normal, color: PremiumTokens.textMuted, size: 20),
                                ),
                                onChanged: (v) => setState(() => _searchQuery = v),
                              ),
                            ),
                          ],
                          
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: PremiumTokens.borderSubtle,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: PremiumTokens.borderSubtle),
                            ),
                            child: Text(
                              "${filteredContent.length} ${l.translate('sacred_texts')}",
                              style: GoogleFonts.outfit(color: PremiumTokens.textSecondary, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Content List
              filteredContent.isEmpty
                  ? SliverFillRemaining(
                      hasScrollBody: false,
                      child: _buildEmptyState(context, l),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _buildPremiumContentCard(context, filteredContent[index]),
                          ),
                          childCount: filteredContent.length,
                        ),
                      ),
                    ),
              
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGlassIcon(IconData icon, VoidCallback onTap) {
    return PremiumUI.glassCard(
      padding: const EdgeInsets.all(12),
      borderRadius: 14,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Icon(icon, color: PremiumTokens.textPrimary, size: 22),
      ),
    );
  }

  Widget _buildPremiumContentCard(BuildContext context, SacredContent item) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ContentDetailScreen(content: item)),
        );
      },
      child: PremiumUI.glassCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: widget.gradientColors),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Iconsax.book_1, color: PremiumTokens.textPrimary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.displayTitle,
                    style: GoogleFonts.outfit(color: PremiumTokens.textPrimary, fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.translation,
                    style: GoogleFonts.outfit(color: PremiumTokens.textMuted, fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Iconsax.arrow_right_3, color: widget.gradientColors[0].withValues(alpha: 0.5), size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalization l) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.folder_open, size: 64, color: PremiumTokens.borderSubtle),
          const SizedBox(height: 16),
          Text(
            l.translate('no_content'),
            style: GoogleFonts.outfit(color: PremiumTokens.textMuted, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
