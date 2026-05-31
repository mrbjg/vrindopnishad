import 'package:flutter/material.dart';
import '../core/content_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/design_system.dart';
import '../core/providers.dart';
import '../features/content_detail_screen.dart';
import 'package:flutter/services.dart';
import '../core/favorites_provider.dart';
import '../core/color_theme_provider.dart';
import '../core/personalized_feed_provider.dart';
import '../widgets/animated_effects.dart';

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
    ref.watch(colorPaletteProvider);
    final recentSearchesAsync = ref.watch(recentSearchesProvider);
    
    final List<SacredContent> displayItems = _isSearching
        ? ref.watch(searchedContentProvider(_searchQuery))
        : [];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(child: PremiumUI.bokehBackground(context)),
          Positioned.fill(child: PremiumUI.mandalaOverlay(opacity: 0.03)),
          
          SafeArea(
            child: Column(
              children: [
                // Global Header
                _buildSearchHeader(context),
                
                // Search Input Field
                _buildSearchInput(),

                Expanded(
                  child: _isSearching 
                    ? _buildSearchResults(displayItems)
                    : _buildInitialView(recentSearchesAsync),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          PremiumUI.glassCard(
            padding: const EdgeInsets.all(10),
            borderRadius: 14,
            child: PremiumUI.animatedIcon(
              folder: 'Chevron-left',
              fileName: 'chevron-left.json',
              size: 20,
              color: PremiumTokens.textPrimary,
              onTap: () {
                HapticFeedback.mediumImpact();
                Navigator.pop(context);
              },
            ),
          ),
          const SizedBox(width: 16),
          Text(
            "SACRED SEARCH",
            style: GoogleFonts.manrope(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: PremiumTokens.textPrimary,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: PremiumUI.etherealCard(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        borderRadius: 32,
        showGlow: true,
        glowColor: PremiumTokens.activeAccent,
        child: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          autofocus: false,
          style: GoogleFonts.manrope(color: PremiumTokens.textPrimary, fontSize: 15),
          cursorColor: PremiumTokens.activeAccent,
          decoration: InputDecoration(
            hintText: "Search mantras, stories, shlokas...",
            hintStyle: GoogleFonts.manrope(color: PremiumTokens.textHint, fontSize: 14),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
            prefixIcon: Icon(Iconsax.search_normal, color: PremiumTokens.activeAccent, size: 20),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(Iconsax.close_circle, size: 18, color: PremiumTokens.textMuted),
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
    );
  }



  Widget _buildSacredListItem(BuildContext context, SacredContent item) {
    final match = ref.watch(matchPercentageProvider(item));
    return SizedBox(
      height: 195,
      child: PressableScale(
        onTap: () {
          ref.read(recentSearchesProvider.notifier).addSearch(_searchQuery);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ContentDetailScreen(content: item)),
          );
        },
        child: PremiumUI.relicStaticCard(
          padding: EdgeInsets.zero,
          borderColor: PremiumTokens.borderSubtle,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // 1. Full-bleed background artwork
                Positioned.fill(
                  child: PremiumUI.networkImage(
                    url: item.displayImageUrl,
                    fit: BoxFit.cover,
                  ),
                ),

                // 2. Adaptive gradient overlay for text readability
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          PremiumTokens.surfaceMain.withValues(alpha: 0.10),
                          PremiumTokens.surfaceMain.withValues(alpha: 0.70),
                          PremiumTokens.surfaceMain.withValues(alpha: 0.96),
                        ],
                        stops: const [0.0, 0.4, 0.85],
                      ),
                    ),
                  ),
                ),

                // 3. Card content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        item.displayTitle,
                        style: GoogleFonts.manrope(
                          color: PremiumTokens.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          PremiumUI.categoryBadge(item.category, fontSize: 11),
                          const SizedBox(width: 8),
                          PremiumUI.resonanceBadge("$match% MATCH", fontSize: 10),
                          const Spacer(),
                          // Like Button
                          PremiumUI.animatedIcon(
                            folder: 'Heart',
                            fileName: 'heart.json',
                            size: 24,
                            color: ref.watch(isFavoriteProvider(item.id)) ? PremiumTokens.saffronGlow : PremiumTokens.textMuted,
                            isToggled: ref.watch(isFavoriteProvider(item.id)),
                            resetAfterPlay: false,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              ref.read(favoritesProvider.notifier).toggleFavorite(item.id);
                            },
                          ),
                          const SizedBox(width: 12),
                          Icon(Iconsax.arrow_right_3, color: PremiumTokens.textMuted, size: 20),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInitialView(AsyncValue<List<String>> recentSearches) {
    final affinity = ref.watch(userAffinityProvider);
    final trending = ref.watch(trendingContentProvider);

    // Dynamic suggested paths based on affinity & trending
    final sortedCategories = affinity.categoryWeights.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final sortedTags = affinity.tagWeights.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final List<String> suggestions = [];
    if (sortedCategories.isNotEmpty) {
      suggestions.add(sortedCategories.first.key);
    }
    for (final tag in sortedTags) {
      if (suggestions.length >= 4) break;
      if (tag.key.isNotEmpty && !suggestions.contains(tag.key)) {
        suggestions.add(tag.key);
      }
    }
    for (final item in trending) {
      if (suggestions.length >= 6) break;
      if (item.title.isNotEmpty && !suggestions.contains(item.title)) {
        suggestions.add(item.title);
      }
    }

    if (suggestions.isEmpty) {
      suggestions.addAll(["Hanuman Chalisa", "Meditation", "Mantra", "Spirituality", "Peace"]);
    }

    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        recentSearches.when(
          data: (searches) {
            if (searches.isEmpty) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "RECENT SEARCHES",
                      style: GoogleFonts.manrope(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: PremiumTokens.textMuted,
                        letterSpacing: 2,
                      ),
                    ),
                    TextButton(
                      onPressed: () => ref.read(recentSearchesProvider.notifier).clear(),
                      child: Text("Clear", style: TextStyle(color: PremiumTokens.activeAccent, fontSize: 12)),
                    ),
                  ],
                ),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: searches.map((s) => _buildSearchTag(s)).toList(),
                ),
                const SizedBox(height: 40),
              ],
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),

        Text(
          "SUGGESTED PATHS",
          style: GoogleFonts.manrope(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: PremiumTokens.textMuted,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: suggestions.map((s) => _buildSearchTag(s, isStatic: true)).toList(),
        ),
      ],
    );
  }

  Widget _buildSearchTag(String text, {bool isStatic = false}) {
    return PressableScale(
      onTap: () {
        _searchController.text = text;
        setState(() {
          _searchQuery = text;
          _isSearching = true;
        });
        if (isStatic) {
          ref.read(recentSearchesProvider.notifier).addSearch(text);
        }
      },
      child: PremiumUI.glassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        borderRadius: 100,
        child: Text(
          text,
          style: GoogleFonts.manrope(
            color: PremiumTokens.textSecondary, 
            fontSize: 12, 
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults(List<SacredContent> displayItems) {
    if (displayItems.isEmpty) return _buildEmptyResults();
    
    return ListView.builder(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      itemCount: displayItems.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: _buildSacredListItem(context, displayItems[index]),
      ),
    );
  }

  Widget _buildEmptyResults() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Iconsax.search_status, size: 64, color: PremiumTokens.textMuted),
        const SizedBox(height: 24),
        Text(
          "NO SACRED ECHOES FOUND",
          style: GoogleFonts.manrope(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: PremiumTokens.textMuted,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            "Try searching for broader spiritual topics like 'Radhe', 'Braj', or 'Nitya Vihar'.",
            style: GoogleFonts.manrope(
              fontSize: 12,
              color: PremiumTokens.textHint,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
