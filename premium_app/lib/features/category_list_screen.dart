import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/design_system.dart';
import '../core/content_provider.dart';
import '../core/providers.dart';
import '../widgets/animated_effects.dart';
import '../core/personalized_feed_provider.dart';

class CategoryListScreen extends ConsumerStatefulWidget {
  const CategoryListScreen({super.key});

  @override
  ConsumerState<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends ConsumerState<CategoryListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    PremiumTokens.of(context);
    // Sync system status and navigation bar overlay style
    PremiumUI.setSacredStatus();

    final allCategories = ref.watch(personalizedCategoriesProvider);
    final filteredCategories = allCategories.where((cat) {
      return cat.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background Gradient
          Positioned.fill(
            child: PremiumUI.masterBackground(index: 1, context: context),
          ),

          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Header
              SliverAppBar(
                expandedHeight: 0,
                collapsedHeight: 80,
                pinned: true,
                backgroundColor: PremiumTokens.scaffoldBg.withValues(alpha: 0.8),
                elevation: 0,
                scrolledUnderElevation: 0,
                leading: IconButton(
                  icon: Icon(Iconsax.arrow_left, color: PremiumTokens.textPrimary),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Text(
                  'Explore Categories',
                  style: PremiumTokens.sansStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: PremiumTokens.textPrimary,
                  ),
                ),
                centerTitle: true,
              ),

              // Search Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  child: Container(
                    decoration: BoxDecoration(
                      color: PremiumTokens.surfaceCard.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: PremiumTokens.borderSubtle,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: PremiumTokens.textPrimary.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) => setState(() => _searchQuery = value),
                          style: GoogleFonts.manrope(
                            color: PremiumTokens.textPrimary,
                            fontSize: 15,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search categories...',
                            hintStyle: GoogleFonts.manrope(
                              color: PremiumTokens.textMuted,
                              fontSize: 15,
                            ),
                            prefixIcon: Icon(
                              Iconsax.search_normal,
                              color: PremiumTokens.activeAccent,
                              size: 20,
                            ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: Icon(Icons.close, color: PremiumTokens.textMuted, size: 18),
                                    onPressed: () {
                                      setState(() {
                                        _searchController.clear();
                                        _searchQuery = '';
                                      });
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            filled: false,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Categories Grid
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final cat = filteredCategories[index];
                      return _buildCategoryCard(context, ref, cat);
                    },
                    childCount: filteredCategories.length,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, WidgetRef ref, CategoryInfo cat) {
    return PressableScale(
      onTap: () {
        // Set category filter and switch to Library tab
        ref.read(libraryCategoryProvider.notifier).state = cat.name;
        ref.read(navigationIndexProvider.notifier).state = 1;
        // Pop back to main navigation (which will now show Library)
        Navigator.pop(context);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: PremiumTokens.borderSubtle,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: PremiumTokens.textPrimary.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Premium Network Image
              PremiumUI.networkImage(
                url: cat.imageUrl,
                fit: BoxFit.cover,
              ),
              
              // Gradient Overlay (blending text with dynamic background)
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      PremiumTokens.scaffoldBg.withValues(alpha: 0.98),
                      PremiumTokens.scaffoldBg.withValues(alpha: 0.7),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.6, 1.0],
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cat.name,
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        color: PremiumTokens.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: PremiumTokens.textPrimary.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: PremiumTokens.textPrimary.withValues(alpha: 0.08),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '${cat.count} ${cat.count == 1 ? "Item" : "Items"}',
                        style: GoogleFonts.manrope(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: PremiumTokens.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
