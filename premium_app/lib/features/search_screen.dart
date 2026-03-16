import 'package:flutter/material.dart';
import '../core/content_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/design_system.dart';
import '../core/providers.dart';
import '../features/content_detail_screen.dart';
import 'package:flutter/services.dart';

class SearchScreen extends ConsumerStatefulWidget {
  SearchScreen({super.key});

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
    
    final currentCategory = ref.watch(libraryCategoryProvider);
    
    // Logic: If searching, show search results. If not searching, show category-filtered content.
    final List<SacredContent> displayItems = _isSearching
        ? ref.watch(searchedContentProvider(_searchQuery))
        : ref.watch(filteredContentProvider(currentCategory));

    return Scaffold(
      backgroundColor: PremiumTokens.charcoal,
      body: Stack(
        children: [
          Positioned.fill(child: PremiumUI.bokehBackground()),
          Positioned.fill(child: PremiumUI.mandalaOverlay(opacity: 0.03)),
          
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Premium Integrated Header
                SliverAppBar(
                  floating: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  centerTitle: true,
                  title: Text(
                    "Sacred Library",
                    style: GoogleFonts.manrope(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Iconsax.notification, color: Colors.white54),
                      onPressed: () {},
                    ),
                  ],
                ),

                // Immersive Search Section
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  sliver: SliverToBoxAdapter(
                    child: PremiumUI.glassCard(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      borderRadius: 16,
                      child: TextField(
                        controller: _searchController,
                        focusNode: _focusNode,
                        style: GoogleFonts.manrope(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Search mantras, stories, shlokas...",
                          hintStyle: GoogleFonts.manrope(color: Colors.white24, fontSize: 14),
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
                  ),
                ),

                if (!_isSearching) ...[
                  // Featured Content Card
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Stack(
                        children: [
                          PremiumUI.saffronGlassCard(
                            padding: EdgeInsets.zero,
                            borderRadius: 24,
                            child: Stack(
                              children: [
                                // Featured Image with Overlay
                                Container(
                                  height: 200,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: PremiumUI.networkImage(
                                    url: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBHu8Eu-IeZXmdDyP9CGIYZOUdk_ADEEcjbsJd_ERe8TJLT3bqNwsEF1qd2GIc52oBip9aRZZDzDNBprKDu5y207MDsU76yeRRf3XYO2ckGgQheqCBn0KAhdLascnDZP8F98XNQ9C3TmOV1CgjrJEjniTKhkeNACkVMntZbA8c5IqPYst5pK_IM2XxlgMHNS1UuBOjGAQ-Rf0Jthy4ZQeoOcjBE4OSo8F2lFNBeRiSW-BgFyqXmAUwhFtXOfZ7lGaH9CfX1J_YyFUg',
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                ),
                                Container(
                                  height: 200,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24),
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        PremiumTokens.charcoal.withValues(alpha: 0.9),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                                
                                // Text Content
                                Positioned(
                                  left: 20,
                                  bottom: 20,
                                  right: 20,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: PremiumTokens.saffronGlow,
                                          borderRadius: BorderRadius.circular(100),
                                        ),
                                        child: Text(
                                          "FEATURED MANTRA",
                                          style: GoogleFonts.manrope(
                                            color: PremiumTokens.charcoal,
                                            fontSize: 9,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 1.5,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        "Maha Mrityunjaya",
                                        style: GoogleFonts.manrope(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Horizontal Categories
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                          child: Text(
                            "CATEGORIES",
                            style: GoogleFonts.manrope(
                              color: Colors.white38,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 50,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            children: [
                              _buildPremiumPill("ALL", currentCategory == "ALL"),
                              _buildPremiumPill("PEACE", currentCategory == "PEACE"),
                              _buildPremiumPill("PROSPERITY", currentCategory == "PROSPERITY"),
                              _buildPremiumPill("PROTECTION", currentCategory == "PROTECTION"),
                              _buildPremiumPill("HEALING", currentCategory == "HEALING"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Recommended List
                  SliverPadding(
                    padding: const EdgeInsets.all(24),
                    sliver: displayItems.isEmpty
                        ? SliverToBoxAdapter(child: Center(child: _buildEmptyResults()))
                        : SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: _buildSacredListItem(context, displayItems[index]),
                                );
                              },
                              childCount: displayItems.length,
                            ),
                          ),
                  ),
                ] else ...[
                  // Search Results
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    sliver: displayItems.isEmpty
                        ? SliverFillRemaining(hasScrollBody: false, child: _buildEmptyResults())
                        : SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _buildSacredListItem(context, displayItems[index]),
                              ),
                              childCount: displayItems.length,
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

  Widget _buildPremiumPill(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        ref.read(libraryCategoryProvider.notifier).state = label;
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? PremiumTokens.saffronGlow : PremiumTokens.saffronGlow.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: isSelected ? Colors.transparent : PremiumTokens.saffronGlow.withValues(alpha: 0.1),
              ),
              boxShadow: isSelected ? [
                BoxShadow(
                  color: PremiumTokens.saffronGlow.withValues(alpha: 0.3),
                  blurRadius: 15,
                  spreadRadius: -2,
                )
              ] : null,
            ),
            child: Text(
              label,
              style: GoogleFonts.manrope(
                color: isSelected ? PremiumTokens.charcoal : Colors.white60,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.2);
  }

  Widget _buildSacredListItem(BuildContext context, SacredContent item) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ContentDetailScreen(content: item)),
        );
      },
      child: PremiumUI.glassCard(
        padding: const EdgeInsets.all(12),
        borderRadius: 20,
        child: Row(
          children: [
            // Thumbnail
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: PremiumTokens.saffronPremiumGradient,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: PremiumUI.networkImage(
                  url: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBYgYpRIViZa_gs2-nCpkN1icsC_3pKdUI9kLKymK91_Hm6B-jfE2Pe3E0-_ZbwyIhJ2fR284qfSjio3EB9NlauKKMN9rDWkm5XkNbYRNgOG18SbA22nyjAoz28MOPuLnLR-CKQv__Z_w8NTW9tn3PiV_USrXL7kOcOCAOTfPacSJscNJP6wY9Z8NdE0TPeJ9J5OHWc8xY6s0Jf2CmGkAWAb2D50TcF-X-eaRb9_yYjEvphxoNmVLQXbc11L34Myzi3Ziyz0C9vOoE',
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            SizedBox(width: 16),
            
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.displayTitle,
                    style: GoogleFonts.manrope(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Iconsax.music, size: 10, color: PremiumTokens.saffronGlow.withValues(alpha: 0.5)),
                      SizedBox(width: 4),
                      Text(
                        item.category.toUpperCase(),
                        style: GoogleFonts.manrope(
                          color: PremiumTokens.saffronGlow.withValues(alpha: 0.7),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Actions
            IconButton(
              icon: const Icon(Iconsax.play_circle5, color: PremiumTokens.saffronGlow, size: 28),
              onPressed: () {},
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1);
  }

  Widget _buildEmptyResults() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Iconsax.search_zoom_out, size: 48, color: Colors.white10),
        const SizedBox(height: 16),
        Text(
          "No results found on this path",
          style: GoogleFonts.manrope(color: Colors.white38, fontSize: 15),
        ),
      ],
    );
  }
}
